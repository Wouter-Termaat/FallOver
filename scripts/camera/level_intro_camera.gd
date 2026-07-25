class_name LevelIntroCamera
extends Node

## PRD §6.4 — the opening fly-through. Moves the camera directly through two
## authored positions/look-targets/orthographic sizes; suspends CameraRig
## entirely for the duration rather than feeding it a target, since an
## authored sweep isn't "orbit a focus point" — a different model, not
## worth teaching the rig two unrelated update strategies.

signal finished

@export var camera_rig: CameraRig
@export var placement_controller: PlacementController
@export var skip_button: Button

@export var position_a: Vector3 = Vector3(0.0, 12.0, 20.0)
@export var look_at_a: Vector3 = Vector3.ZERO
@export var size_a: float = 24.0

@export var position_b: Vector3 = Vector3(20.0, 12.0, -10.0)
@export var look_at_b: Vector3 = Vector3(20.0, 0.0, 0.0)
@export var size_b: float = 24.0

@export var duration: float = 3.0

var _suppressed: bool = false
var _playing: bool = false
var _elapsed: float = 0.0
var _camera: Camera3D


## FO-029 calls this to skip the sweep entirely when resuming a mid-build
## level — the hook this story is required to provide.
func suppress() -> void:
	_suppressed = true


func _ready() -> void:
	play.call_deferred()


func play() -> void:
	_camera = camera_rig.get_camera()
	if _suppressed:
		finished.emit()
		return
	_playing = true
	_elapsed = 0.0
	camera_rig.suspended = true
	if placement_controller != null:
		placement_controller.set_process_unhandled_input(false)
	if skip_button != null:
		skip_button.visible = true
	set_process(true)


## Must be reachable with one tap (PRD §6.4) — connect a skip button/overlay
## to this from whatever hosts it (game_hud.tscn).
func skip() -> void:
	if _playing:
		_finish()


func _process(delta: float) -> void:
	if not _playing:
		return
	_elapsed += delta
	var t: float = clamp(_elapsed / duration, 0.0, 1.0) if duration > 0.0 else 1.0
	var eased: float = _smoothstep(t)
	_camera.global_position = position_a.lerp(position_b, eased)
	_camera.look_at(look_at_a.lerp(look_at_b, eased), Vector3.UP)
	_camera.size = lerp(size_a, size_b, eased)
	if t >= 1.0:
		_finish()


func _smoothstep(t: float) -> float:
	return t * t * (3.0 - 2.0 * t) # eased, never a snap at either end


func _finish() -> void:
	_playing = false
	set_process(false)
	camera_rig.suspended = false
	if placement_controller != null:
		placement_controller.set_process_unhandled_input(true)
	if skip_button != null:
		skip_button.visible = false
	finished.emit()
