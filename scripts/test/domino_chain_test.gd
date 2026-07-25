extends Node3D

## FO-003 grey-box test scene: prove a chain of standing blocks reliably
## topples end to end from a single fixed impulse.
##
## This is the permanent tuning bench for block feel (PRD §4.9.2, open #31).
## Out of scope here: placement, coins, UI, win conditions, camera work.
##
## Unit scale is not yet decided (PRD open #5 / FO-008). Dimensions below use
## the Standard Block ratio from PRD §4.4 directly as Godot units; FO-008
## re-tests this scene at other scale interpretations.
##
## Orientation: a domino's thin face (depth) points along the direction of
## travel, and its wide face (length) is perpendicular to it, so a falling
## domino's wide face catches the next one — as with real dominoes.

@export var block_count: int = 15
@export var spacing: float = 2.4

@export_group("Block dimensions — Standard Block ratio, PRD §4.4 (H x L x D)")
@export var block_height: float = 4.0
@export var block_length: float = 2.0
@export var block_depth: float = 0.5

@export_group("Physics — starting point, tune by feel on device (PRD open #31)")
@export var block_mass: float = 1.0
@export var friction: float = 2.0
@export var restitution: float = 0.0
@export var linear_damp: float = 0.5
@export var angular_damp: float = 2.0

@export_group("Impulse")
@export var impulse_strength: float = 5.0
@export var impulse_height_fraction: float = 0.3

const GROUND_MARGIN: float = 6.0
const GROUND_WIDTH: float = 10.0
const GROUND_THICKNESS: float = 1.0

@onready var _ground: StaticBody3D = $Ground
@onready var _camera: Camera3D = $Camera3D

var _blocks: Array[RigidBody3D] = []
var _started: bool = false


func _ready() -> void:
	_build_ground()
	_spawn_chain()
	_frame_camera()

	# Headless mechanical verification only (FO-003 findings) — not part of
	# normal play. Absent this flag, the scene behaves exactly as shipped.
	if "--fo-autostart" in OS.get_cmdline_args():
		await get_tree().create_timer(0.3).timeout
		_start_run()


func _unhandled_input(event: InputEvent) -> void:
	if _started:
		return
	var is_key_press: bool = event is InputEventKey and event.pressed and not event.echo
	var is_click_or_tap: bool = event is InputEventMouseButton and event.pressed
	if is_key_press or is_click_or_tap:
		_start_run()


func _start_run() -> void:
	if _started or _blocks.is_empty():
		return
	_started = true
	var first: RigidBody3D = _blocks[0]
	var offset: Vector3 = Vector3(0.0, block_height * impulse_height_fraction, 0.0)
	first.apply_impulse(Vector3.RIGHT * impulse_strength, offset)


func _spawn_chain() -> void:
	for i in block_count:
		var block: RigidBody3D = _make_block()
		block.position = Vector3(i * spacing, block_height * 0.5, 0.0)
		add_child(block)
		_blocks.append(block)


func _make_block() -> RigidBody3D:
	var body: RigidBody3D = RigidBody3D.new()
	body.mass = block_mass
	body.can_sleep = true
	body.linear_damp = linear_damp
	body.angular_damp = angular_damp

	var material: PhysicsMaterial = PhysicsMaterial.new()
	material.friction = friction
	material.bounce = restitution
	body.physics_material_override = material

	# Thin edge (depth) along X, the direction of travel; wide face (length)
	# along Z, so a toppling block's wide face catches the next one in line.
	var box_size: Vector3 = Vector3(block_depth, block_height, block_length)

	var collision: CollisionShape3D = CollisionShape3D.new()
	var box_shape: BoxShape3D = BoxShape3D.new()
	box_shape.size = box_size
	collision.shape = box_shape
	body.add_child(collision)

	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	var box_mesh: BoxMesh = BoxMesh.new()
	box_mesh.size = box_size
	mesh_instance.mesh = box_mesh
	var material_override: StandardMaterial3D = StandardMaterial3D.new()
	material_override.albedo_color = Palette.STANDARD_BLOCK
	mesh_instance.material_override = material_override
	body.add_child(mesh_instance)

	return body


func _build_ground() -> void:
	var chain_span: float = (block_count - 1) * spacing
	var ground_length: float = chain_span + GROUND_MARGIN * 2.0
	var ground_size: Vector3 = Vector3(ground_length, GROUND_THICKNESS, GROUND_WIDTH)

	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	var box_mesh: BoxMesh = BoxMesh.new()
	box_mesh.size = ground_size
	mesh_instance.mesh = box_mesh
	var material_override: StandardMaterial3D = StandardMaterial3D.new()
	material_override.albedo_color = Palette.TERRAIN
	mesh_instance.material_override = material_override
	_ground.add_child(mesh_instance)

	var collision: CollisionShape3D = CollisionShape3D.new()
	var box_shape: BoxShape3D = BoxShape3D.new()
	box_shape.size = ground_size
	collision.shape = box_shape
	_ground.add_child(collision)

	_ground.position = Vector3(chain_span * 0.5, -GROUND_THICKNESS * 0.5, 0.0)


func _frame_camera() -> void:
	var chain_span: float = (block_count - 1) * spacing
	var chain_center: Vector3 = Vector3(chain_span * 0.5, block_height * 0.4, 0.0)
	var distance: float = chain_span * 0.9 + block_height * 2.0
	_camera.position = chain_center + Vector3(0.0, distance * 0.55, distance * 0.75)
	_camera.look_at(chain_center, Vector3.UP)
