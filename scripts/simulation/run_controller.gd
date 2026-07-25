class_name RunController
extends Node

## Drives a run: freezes/unfreezes bodies, gives the starter its impulse,
## propagates the *live* flag (PRD §4.2.1), and detects when a run has ended
## via all three PRD §4.9.2 mechanisms. Fast-forward uses Engine.time_scale
## (PRD §4.9.1) — this changes wall-clock speed only, never
## physics_ticks_per_second, so the tick sequence and its outcome are
## identical, just compressed in real time.

signal run_started
signal run_ended(last_live_body: Node)

@export var starter: RigidBody3D
@export var camera_rig: CameraRig
@export var palette: BlockPalette
@export var placement_controller: PlacementController

@export_group("Starter impulse")
@export var impulse_direction: Vector3 = Vector3.RIGHT
@export var impulse_strength: float = 1.6
@export var impulse_height_fraction: float = 0.3

@export_group("Run-end detection (PRD §4.9.2)")
@export var settle_velocity_threshold: float = 0.15
@export var settle_ticks_required: int = 30
@export var no_progress_seconds: float = 3.0
@export var live_contact_force_threshold: float = 1.0

## FO-021: until a scene actually loads through LevelLoader (which reads
## LevelDefinition.coin_amount directly), this grey-box scene needs its own
## starting amount to initialize CoinBudget.
@export var starting_coin_amount: int = 20

@export_group("Lost blocks")
@export var lost_block_y: float = -8.0

@export var fast_forward_time_scale: float = 3.0

var is_running: bool = false
var _live_bodies: Array = []
var _last_live_body: Node = null
var _settle_counter: int = 0
var _ticks_since_progress: int = 0
var _snapshot: LayoutSnapshot = LayoutSnapshot.new()
var _fast_forward: bool = false
var _starter_original_transform: Transform3D


func _ready() -> void:
	set_physics_process(false)
	_starter_original_transform = starter.transform
	CoinBudget.load_level(starting_coin_amount)


func start_run() -> void:
	if is_running:
		return
	CommandHistory.clear() # PRD §4.8: history is cleared when a run starts
	_snapshot.capture()
	for command in BuildState.commands:
		var body: RigidBody3D = command.get_body()
		if body != null:
			body.freeze = false
	starter.freeze = false
	_live_bodies.clear()
	_mark_live(starter)
	_last_live_body = starter
	var offset: Vector3 = Vector3(0.0, starter_height() * impulse_height_fraction, 0.0)
	starter.apply_impulse(impulse_direction.normalized() * impulse_strength, offset)

	if palette != null:
		palette.visible = false
	if camera_rig != null:
		camera_rig.run_mode = true
		camera_rig.input_enabled = true # orbit still works during a run
	if placement_controller != null:
		placement_controller.set_process_unhandled_input(false)

	is_running = true
	_settle_counter = 0
	_ticks_since_progress = 0
	set_physics_process(true)
	run_started.emit()


func abort_run() -> void:
	if not is_running:
		return
	_end_run()
	reset()


func reset() -> void:
	set_physics_process(false)
	is_running = false
	set_fast_forward(false)
	_snapshot.restore()
	starter.freeze = true
	starter.linear_velocity = Vector3.ZERO
	starter.angular_velocity = Vector3.ZERO
	starter.transform = _starter_original_transform
	starter.sleeping = false
	_live_bodies.clear()
	for command in BuildState.commands:
		var body: RigidBody3D = command.get_body()
		if body != null:
			body.visible = true
			body.set_meta(&"live", false)

	if palette != null:
		palette.visible = true
	if camera_rig != null:
		camera_rig.run_mode = false
	if placement_controller != null:
		placement_controller.set_process_unhandled_input(true)


func set_fast_forward(on: bool) -> void:
	_fast_forward = on
	Engine.time_scale = fast_forward_time_scale if on else 1.0


func is_fast_forwarding() -> bool:
	return _fast_forward


func starter_height() -> float:
	var shape_node: CollisionShape3D = starter.get_node("CollisionShape3D")
	if shape_node != null and shape_node.shape is BoxShape3D:
		return (shape_node.shape as BoxShape3D).size.y
	return 4.0


func get_live_bodies() -> Array:
	return _live_bodies


func _physics_process(_delta: float) -> void:
	if not is_running:
		return

	var any_moving: bool = false
	var newly_live: Array = []

	for body in _live_bodies:
		if not is_instance_valid(body):
			continue
		if _is_lost(body):
			_remove_lost_body(body)
			continue
		if body.linear_velocity.length() > settle_velocity_threshold or body.angular_velocity.length() > settle_velocity_threshold:
			any_moving = true
		for other in body.get_colliding_bodies():
			if other is RigidBody3D and not _live_bodies.has(other):
				var relative_speed: float = (body.linear_velocity - other.linear_velocity).length()
				if relative_speed >= live_contact_force_threshold:
					newly_live.append(other)

	for body in newly_live:
		_mark_live(body)
		_last_live_body = body
		_ticks_since_progress = 0

	if any_moving:
		_settle_counter = 0
	else:
		_settle_counter += 1
	_ticks_since_progress += 1

	var settled: bool = _settle_counter >= settle_ticks_required
	var no_progress: bool = _ticks_since_progress >= int(no_progress_seconds * Engine.physics_ticks_per_second)
	if settled or no_progress:
		_end_run()


func _mark_live(body: Node) -> void:
	if not _live_bodies.has(body):
		_live_bodies.append(body)
	body.set_meta(&"live", true)


func _is_lost(body: Node3D) -> bool:
	return body.global_position.y < lost_block_y


func _remove_lost_body(body: Node) -> void:
	_live_bodies.erase(body)
	if body is Node3D:
		(body as Node3D).visible = false
	if body is RigidBody3D:
		(body as RigidBody3D).freeze = true


func _end_run() -> void:
	# Deliberately leaves run_mode/palette/placement alone: the player looks
	# at where the run stopped and presses Reset (FO-016) when ready. Win/fail
	# screens (FO-023/FO-026) hook onto run_ended to add their own flow.
	if not is_running:
		return
	is_running = false
	set_physics_process(false)
	set_fast_forward(false)
	run_ended.emit(_last_live_body)
