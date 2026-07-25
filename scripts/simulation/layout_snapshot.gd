class_name LayoutSnapshot
extends RefCounted

## Records each placed block's transform right before a run starts, so
## FO-016's reset (and later FO-029's mid-build resume) can restore exactly
## what the player built. PRD §4.10: reset restores the layout, discards
## only physics state.

var _entries: Array = []


func capture() -> void:
	_entries.clear()
	for command in BuildState.commands:
		var body: RigidBody3D = command.get_body()
		if body != null:
			_entries.append({"command": command, "transform": body.transform})


func restore() -> void:
	for entry in _entries:
		var command: PlacementCommand = entry.command
		var body: RigidBody3D = command.get_body()
		if body == null:
			continue
		body.freeze = true
		body.linear_velocity = Vector3.ZERO
		body.angular_velocity = Vector3.ZERO
		body.transform = entry.transform
		body.sleeping = false
