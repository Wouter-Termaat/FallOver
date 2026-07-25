class_name CameraRig
extends Node3D

## Build-phase camera (PRD §6.2). Orthographic — "zoom" changes orthographic
## size, the rig never moves closer. One shared exponential-damping model
## drives orbit, pan and zoom alike: a "target" value is set directly from
## input, a "current" value eases toward it every frame. During a drag the
## target tracks the finger 1:1 (free orbit); on release the target snaps to
## the nearest 45° and the same easing carries the settle — no separate
## tween needed, and only one damping constant to tune per axis.
##
## Pan/zoom decoupling rule (PRD's "must not fight" requirement): zoom reads
## the *ratio* of inter-finger distance frame to frame, pan reads the delta
## of the finger *midpoint*. These are independent quantities by
## construction — a pure pinch keeps the midpoint still (no pan), a pure
## two-finger pan keeps the distance constant (no zoom) — so no dominant-
## gesture arbitration is needed on top.

@export_group("Orbit")
@export var orbit_sensitivity: float = 0.004
@export var orbit_damping: float = 12.0
@export var snap_increment_deg: float = 45.0
@export var pitch_default_deg: float = 35.0
@export var pitch_min_deg: float = 15.0
@export var pitch_max_deg: float = 75.0

@export_group("Pan")
@export var pan_sensitivity: float = 0.05
@export var pan_damping: float = 10.0

@export_group("Zoom")
@export var zoom_sensitivity: float = 1.0
@export var zoom_damping: float = 10.0
@export var min_orthographic_size: float = 8.0
@export var max_orthographic_size: float = 40.0
@export var default_orthographic_size: float = 34.0

@export_group("Desktop (mouse/scroll, for fast iteration)")
@export var mouse_orbit_sensitivity: float = 0.003
@export var scroll_zoom_step: float = 2.0

## FO-013 disables the rig's own gestures while a block is selected — while
## placing, all touch input is placement, per PRD §6.1's single clean rule.
@export var input_enabled: bool = true

const CAMERA_DISTANCE: float = 40.0

@onready var _camera: Camera3D = $Camera3D

var _target_yaw: float = 0.0
var _current_yaw: float = 0.0
var _target_pitch: float
var _current_pitch: float
var _target_focus: Vector3 = Vector3.ZERO
var _current_focus: Vector3 = Vector3.ZERO
var _target_size: float
var _current_size: float

var _bounds_min: Vector2 = Vector2(-1e6, -1e6)
var _bounds_max: Vector2 = Vector2(1e6, 1e6)

# Active touches, keyed by touch index, for manual multi-touch gesture
# detection (Godot has no built-in two-finger pinch/pan for raw touch).
var _touches: Dictionary = {}
var _mouse_dragging: bool = false


func _ready() -> void:
	_target_pitch = deg_to_rad(pitch_default_deg)
	_current_pitch = _target_pitch
	_target_size = default_orthographic_size
	_current_size = default_orthographic_size
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	# Islands are wider than tall (PRD §7.9.1) but the screen is portrait —
	# KEEP_WIDTH makes `size` govern the island's wide axis directly, with
	# the tall screen giving headroom on the other axis for free.
	_camera.keep_aspect = Camera3D.KEEP_WIDTH
	_camera.size = _current_size
	_read_bounds()
	_update_camera_transform()


func get_camera() -> Camera3D:
	return _camera


func _read_bounds() -> void:
	var bounds: Area3D = get_tree().get_first_node_in_group("CameraBounds")
	if bounds == null:
		return
	var shape_node: CollisionShape3D = bounds.get_node_or_null("CollisionShape3D")
	if shape_node == null or not (shape_node.shape is BoxShape3D):
		return
	var box: BoxShape3D = shape_node.shape
	var center: Vector3 = bounds.global_position
	var half: Vector3 = box.size * 0.5
	_bounds_min = Vector2(center.x - half.x, center.z - half.z)
	_bounds_max = Vector2(center.x + half.x, center.z + half.z)
	_target_focus = center
	_current_focus = center


func _process(delta: float) -> void:
	# Presentation only, not gameplay logic — frame-rate-dependent smoothing
	# here is fine (CLAUDE.md hard rule 1 concerns gameplay outcomes).
	var orbit_t: float = 1.0 - exp(-orbit_damping * delta)
	var pan_t: float = 1.0 - exp(-pan_damping * delta)
	var zoom_t: float = 1.0 - exp(-zoom_damping * delta)

	_current_yaw = lerp_angle(_current_yaw, _target_yaw, orbit_t)
	_current_pitch = lerp(_current_pitch, _target_pitch, orbit_t)
	_current_focus = _current_focus.lerp(_target_focus, pan_t)
	_current_size = lerp(_current_size, _target_size, zoom_t)

	_update_camera_transform()


func _update_camera_transform() -> void:
	var offset: Vector3 = Vector3(
		sin(_current_yaw) * cos(_current_pitch),
		sin(_current_pitch),
		cos(_current_yaw) * cos(_current_pitch)
	) * CAMERA_DISTANCE
	_camera.position = _current_focus + offset
	_camera.size = _current_size
	_camera.look_at(_current_focus, Vector3.UP)


func _unhandled_input(event: InputEvent) -> void:
	if not input_enabled:
		return
	if event is InputEventScreenTouch:
		_on_screen_touch(event)
	elif event is InputEventScreenDrag:
		_on_screen_drag(event)
	elif event is InputEventMouseButton:
		_on_mouse_button(event)
	elif event is InputEventMouseMotion:
		_on_mouse_motion(event)


func _on_screen_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		_touches[event.index] = event.position
	else:
		_touches.erase(event.index)
		if _touches.size() < 2:
			pass # nothing to reconcile — next drag just restarts reference points
		if _touches.is_empty():
			_snap_yaw_to_nearest_increment()


func _on_screen_drag(event: InputEventScreenDrag) -> void:
	if not _touches.has(event.index):
		_touches[event.index] = event.position
		return

	if _touches.size() == 1:
		_apply_orbit_delta(event.relative)
	elif _touches.size() == 2:
		_apply_two_finger_gesture(event.index, event.position)

	_touches[event.index] = event.position


func _apply_two_finger_gesture(moved_index: int, new_position: Vector2) -> void:
	var other_index: int = -1
	for index in _touches.keys():
		if index != moved_index:
			other_index = index
			break
	if other_index == -1:
		return
	var other_pos: Vector2 = _touches[other_index]
	var old_pos: Vector2 = _touches[moved_index]

	var old_mid: Vector2 = (old_pos + other_pos) * 0.5
	var new_mid: Vector2 = (new_position + other_pos) * 0.5
	var old_dist: float = old_pos.distance_to(other_pos)
	var new_dist: float = new_position.distance_to(other_pos)

	_apply_pan_delta(new_mid - old_mid)
	if old_dist > 1.0:
		_apply_zoom_ratio(old_dist / new_dist)


func _on_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_LEFT:
		_mouse_dragging = event.pressed
		if not event.pressed:
			_snap_yaw_to_nearest_increment()
	elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
		_apply_zoom_ratio(1.0 + scroll_zoom_step / max_orthographic_size)
	elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		_apply_zoom_ratio(1.0 - scroll_zoom_step / max_orthographic_size)


func _on_mouse_motion(event: InputEventMouseMotion) -> void:
	if _mouse_dragging:
		_apply_orbit_delta(event.relative, mouse_orbit_sensitivity)


func _apply_orbit_delta(relative: Vector2, sensitivity: float = -1.0) -> void:
	var s: float = orbit_sensitivity if sensitivity < 0.0 else sensitivity
	_target_yaw -= relative.x * s
	_target_pitch = clamp(_target_pitch - relative.y * s, deg_to_rad(pitch_min_deg), deg_to_rad(pitch_max_deg))
	_current_pitch = clamp(_current_pitch, deg_to_rad(pitch_min_deg), deg_to_rad(pitch_max_deg))


func _apply_pan_delta(relative: Vector2) -> void:
	# Horizontal only, by design (Wouter's call): with a fixed orthographic
	# elevation, panning "toward/away from camera" reads oddly, so two-finger
	# drag only slides the focus sideways, relative to current yaw so it
	# still matches screen-left/right regardless of viewing angle.
	var right: Vector3 = Vector3(cos(_current_yaw), 0.0, -sin(_current_yaw))
	var delta_world: Vector3 = -right * relative.x * pan_sensitivity
	var new_focus: Vector3 = _target_focus + delta_world
	new_focus.x = clamp(new_focus.x, _bounds_min.x, _bounds_max.x)
	new_focus.z = clamp(new_focus.z, _bounds_min.y, _bounds_max.y)
	_target_focus = new_focus


## FO-013's edge-pan while a block is held — world-space, not screen-relative,
## since placement drags a ghost, not the camera.
func nudge_focus_world(delta: Vector3) -> void:
	var new_focus: Vector3 = _target_focus + delta
	new_focus.x = clamp(new_focus.x, _bounds_min.x, _bounds_max.x)
	new_focus.z = clamp(new_focus.z, _bounds_min.y, _bounds_max.y)
	_target_focus = new_focus


func _apply_zoom_ratio(ratio: float) -> void:
	_target_size = clamp(_target_size * ratio, min_orthographic_size, max_orthographic_size)


func _snap_yaw_to_nearest_increment() -> void:
	var increment: float = deg_to_rad(snap_increment_deg)
	_target_yaw = round(_target_yaw / increment) * increment
