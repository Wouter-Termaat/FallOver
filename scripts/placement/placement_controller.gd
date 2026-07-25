class_name PlacementController
extends Node3D

## PRD §6.1 — selection-driven placement, the core interaction of the game.
## Every mutation goes through a PlacementCommand (see placement_command.gd)
## so FO-017 can stack real undo/redo on top without rewriting this file.
##
## Collision layer convention (docs/greybox-island.md), extended here:
## 1=ground 2=water 4=start/finish 8=player-placed blocks.

enum State { IDLE, POSITIONING, ROTATING, EDIT_MENU }

const GROUND_LAYER: int = 1
const WATER_LAYER: int = 2
const START_FINISH_LAYER: int = 4
const PLACED_BLOCK_LAYER: int = 8
const RAYCAST_MASK: int = GROUND_LAYER | WATER_LAYER | START_FINISH_LAYER | PLACED_BLOCK_LAYER
const OVERLAP_MASK: int = START_FINISH_LAYER | PLACED_BLOCK_LAYER

@export var camera_rig: CameraRig
@export var palette: BlockPalette

@export_group("Placement")
@export var grid_size: float = 0.5
@export var edge_pan_margin_px: float = 80.0
@export var edge_pan_speed: float = 12.0
## Raycast this far above the actual finger position, so the finger/thumb
## doesn't sit on top of the exact spot it's placing — Wouter's call.
@export var finger_offset_px: Vector2 = Vector2(0.0, -140.0)

@export_group("Rotation — tune on device, this is the feel of the game")
@export var rotation_degrees_per_screen_width: float = 180.0
@export var tap_max_movement_px: float = 12.0

@export_group("Edit — FO-014")
@export var radial_menu_radius_px: float = 90.0

var _state: State = State.IDLE
var _definition: BlockDefinition = null
var _ghost: MeshInstance3D = null
var _ghost_valid: bool = false
var _current_command: PlacementCommand = null
var _touch_index: int = -1
var _touch_start_pos: Vector2 = Vector2.ZERO
var _touch_moved: bool = false

var _edit_command: PlacementCommand = null
var _editing_existing: bool = false
var _radial_menu: Control = null
var _suppress_next_edit_menu_release: bool = false


func _ready() -> void:
	palette.block_selected.connect(_on_block_selected)
	palette.block_deselected.connect(_on_block_deselected)


func _on_block_selected(definition: BlockDefinition) -> void:
	_finish_rotation()
	_definition = definition
	camera_rig.input_enabled = false
	_state = State.IDLE
	if _ghost != null:
		_ghost.queue_free()
		_ghost = null


func _on_block_deselected() -> void:
	_finish_rotation()
	_definition = null
	camera_rig.input_enabled = true
	_state = State.IDLE
	if _ghost != null:
		_ghost.queue_free()
		_ghost = null


func _finish_rotation() -> void:
	if _state == State.ROTATING:
		_state = State.IDLE
		_current_command = null
		_editing_existing = false
		if _edit_command != null:
			_deselect_edit() # finishing an edit-rotate fully deselects too
		_editing_existing = false


func _unhandled_input(event: InputEvent) -> void:
	if _definition == null and _state == State.IDLE:
		# Third input state (PRD §6.1): nothing selected, nothing mid-edit.
		# Still watch for a tap on a placed block; anything else is left
		# alone for the camera (input_enabled stays true in that case).
		if event is InputEventScreenTouch:
			_on_touch(event.pressed, event.index, event.position)
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			_on_touch(event.pressed, 0, event.position)
		return

	if event is InputEventScreenTouch:
		_on_touch(event.pressed, event.index, event.position)
	elif event is InputEventScreenDrag:
		if event.index == _touch_index:
			_on_pointer_move(event.position, event.relative)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_on_touch(event.pressed, 0, event.position)
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_on_pointer_move(event.position, event.relative)


func _on_touch(pressed: bool, index: int, position: Vector2) -> void:
	if pressed:
		if _touch_index != -1:
			return # ignore extra fingers during placement
		_touch_index = index
		_touch_start_pos = position
		_touch_moved = false
		if _state == State.IDLE:
			if _definition != null:
				_begin_positioning(position)
			else:
				_try_select_placed_block(position)
	else:
		if index != _touch_index:
			return
		_touch_index = -1
		_on_release(position)


func _on_pointer_move(position: Vector2, relative: Vector2) -> void:
	if position.distance_to(_touch_start_pos) > tap_max_movement_px:
		_touch_moved = true
	match _state:
		State.POSITIONING:
			_update_ghost(position)
			_apply_edge_pan(position)
		State.ROTATING:
			_apply_rotation(relative.x)


func _on_release(position: Vector2) -> void:
	match _state:
		State.POSITIONING:
			_commit_or_cancel()
		State.ROTATING:
			if not _touch_moved:
				_finish_rotation() # tap on empty ground finishes it
			# else: the drag just performed was the rotation swipe itself
		State.EDIT_MENU:
			if _suppress_next_edit_menu_release:
				_suppress_next_edit_menu_release = false
			elif not _touch_moved:
				_deselect_edit() # tap on empty ground deselects (PRD §6.1)


func _begin_positioning(position: Vector2) -> void:
	_state = State.POSITIONING
	if _ghost == null:
		_ghost = _build_ghost()
		add_child(_ghost)
	_update_ghost(position)


func _build_ghost() -> MeshInstance3D:
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	var box: BoxMesh = BoxMesh.new()
	box.size = _definition.extents
	mesh_instance.mesh = box
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh_instance.material_override = material
	return mesh_instance


func _update_ghost(screen_pos: Vector2) -> void:
	var result: Dictionary = _raycast(screen_pos + finger_offset_px)
	var material: StandardMaterial3D = _ghost.material_override
	if result.is_empty():
		_ghost_valid = false
		_ghost.visible = false
		return
	_ghost.visible = true
	var layer: int = result.collider.collision_layer
	if (layer & WATER_LAYER) != 0 or (layer & START_FINISH_LAYER) != 0:
		_ghost_valid = false
		_ghost.global_position = result.position
		material.albedo_color = Color(Palette.INVALID_PLACEMENT, 0.6)
		return
	var snapped: Vector3 = Vector3(
		round(result.position.x / grid_size) * grid_size,
		result.position.y + _definition.extents.y * 0.5,
		round(result.position.z / grid_size) * grid_size
	)
	var candidate_transform: Transform3D = Transform3D(_ghost.transform.basis, snapped)
	_ghost.global_transform = candidate_transform
	var overlapping: bool = _check_overlap(candidate_transform)
	_ghost_valid = ((layer & GROUND_LAYER) != 0) and not overlapping
	material.albedo_color = Color(_definition.palette_color if _ghost_valid else Palette.INVALID_PLACEMENT, 0.6)


func _raycast(screen_pos: Vector2) -> Dictionary:
	var cam: Camera3D = camera_rig.get_camera()
	var from: Vector3 = cam.project_ray_origin(screen_pos)
	var to: Vector3 = from + cam.project_ray_normal(screen_pos) * 200.0
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to, RAYCAST_MASK)
	return space_state.intersect_ray(query)


func _check_overlap(candidate_transform: Transform3D) -> bool:
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = _definition.extents
	var params: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
	params.shape = shape
	params.transform = candidate_transform
	params.collision_mask = OVERLAP_MASK
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var results: Array = space_state.intersect_shape(params, 1)
	return not results.is_empty()


func _apply_edge_pan(screen_pos: Vector2) -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var nudge: Vector3 = Vector3.ZERO
	if screen_pos.x < edge_pan_margin_px:
		nudge.x -= 1.0
	elif screen_pos.x > viewport_size.x - edge_pan_margin_px:
		nudge.x += 1.0
	if nudge != Vector3.ZERO:
		camera_rig.nudge_focus_world(nudge * edge_pan_speed * get_process_delta_time())


func _commit_or_cancel() -> void:
	if _editing_existing:
		if _ghost_valid:
			_edit_command.move_to(_ghost.global_transform)
			_current_command = _edit_command
			_state = State.ROTATING
		else:
			_state = State.IDLE
		var body: RigidBody3D = _edit_command.get_body()
		body.visible = true
		body.collision_layer = PLACED_BLOCK_LAYER
		_editing_existing = false
	elif _ghost_valid:
		_current_command = PlacementCommand.new(get_parent(), _definition, _ghost.global_transform)
		_current_command.do()
		_state = State.ROTATING
	else:
		_state = State.IDLE
	_ghost.visible = false


func _apply_rotation(relative_x: float) -> void:
	if _current_command == null:
		return
	var viewport_width: float = get_viewport().get_visible_rect().size.x
	var radians: float = deg_to_rad(rotation_degrees_per_screen_width) * (relative_x / viewport_width)
	_current_command.get_body().rotate_y(radians)


func _try_select_placed_block(position: Vector2) -> void:
	var result: Dictionary = _raycast(position)
	if result.is_empty():
		return
	var body: Object = result.collider
	if not (body is Node) or not (body as Node).has_meta(&"command"):
		return
	_edit_command = (body as Node).get_meta(&"command")
	_edit_command.set_highlighted(true)
	camera_rig.input_enabled = false
	_state = State.EDIT_MENU
	_suppress_next_edit_menu_release = true
	_show_radial_menu()


func _show_radial_menu() -> void:
	_radial_menu = Control.new()
	_radial_menu.set_anchors_preset(Control.PRESET_FULL_RECT)
	_radial_menu.mouse_filter = Control.MOUSE_FILTER_IGNORE
	get_viewport().add_child(_radial_menu)

	var screen_pos: Vector2 = camera_rig.get_camera().unproject_position(_edit_command.get_body().global_position)
	var labels: Array = ["Move", "Rotate", "Sell"]
	var callbacks: Array[Callable] = [_on_move_pressed, _on_rotate_pressed, _on_sell_pressed]
	for i in labels.size():
		var angle: float = TAU * i / labels.size() - PI / 2.0
		var offset: Vector2 = Vector2(cos(angle), sin(angle)) * radial_menu_radius_px
		var button: Button = Button.new()
		button.text = labels[i]
		button.custom_minimum_size = Vector2(96, 72)
		button.position = screen_pos + offset - button.custom_minimum_size * 0.5
		button.pressed.connect(callbacks[i])
		_radial_menu.add_child(button)


func _hide_radial_menu() -> void:
	if _radial_menu != null:
		_radial_menu.queue_free()
		_radial_menu = null


func _on_move_pressed() -> void:
	_hide_radial_menu()
	_definition = _edit_command.get_definition()
	_editing_existing = true
	var body: RigidBody3D = _edit_command.get_body()
	body.visible = false
	body.collision_layer = 0
	_state = State.POSITIONING
	if _ghost == null:
		_ghost = _build_ghost()
		add_child(_ghost)
	_ghost.global_transform = body.global_transform
	_ghost.visible = true
	_ghost_valid = true


func _on_rotate_pressed() -> void:
	_hide_radial_menu()
	_current_command = _edit_command
	_state = State.ROTATING


func _on_sell_pressed() -> void:
	_hide_radial_menu()
	_edit_command.undo() # refund lands in Phase 2 (FO-021) once coins exist
	_edit_command = null
	camera_rig.input_enabled = true
	_state = State.IDLE
	_definition = null


func _deselect_edit() -> void:
	if _edit_command != null:
		_edit_command.set_highlighted(false)
	_hide_radial_menu()
	_edit_command = null
	camera_rig.input_enabled = true
	_state = State.IDLE
	_definition = null
