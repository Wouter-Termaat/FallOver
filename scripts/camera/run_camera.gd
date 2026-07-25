class_name RunCamera
extends Node

## PRD §6.3.1 — frames the aggregate of still-moving live bodies, not a
## single block. Only moving bodies count; once everything included in the
## box has stopped, the last framing is kept rather than snapping away.

@export var run_controller: RunController
@export var camera_rig: CameraRig
@export var min_size: float = 10.0
@export var margin: float = 6.0
@export var velocity_threshold: float = 0.15


func _physics_process(_delta: float) -> void:
	if not run_controller.is_running:
		return

	var moving_bodies: Array = []
	for body in run_controller.get_live_bodies():
		if not is_instance_valid(body):
			continue
		if body.linear_velocity.length() > velocity_threshold or body.angular_velocity.length() > velocity_threshold:
			moving_bodies.append(body)

	if moving_bodies.is_empty():
		return # nothing currently moving: keep the last good framing

	var box_min: Vector3 = moving_bodies[0].global_position
	var box_max: Vector3 = box_min
	for body in moving_bodies:
		var pos: Vector3 = body.global_position
		box_min = Vector3(min(box_min.x, pos.x), min(box_min.y, pos.y), min(box_min.z, pos.z))
		box_max = Vector3(max(box_max.x, pos.x), max(box_max.y, pos.y), max(box_max.z, pos.z))

	var center: Vector3 = (box_min + box_max) * 0.5
	var extent: Vector3 = box_max - box_min
	var needed_size: float = max(extent.x, extent.z) + margin
	camera_rig.set_run_target(center, max(needed_size, min_size))
