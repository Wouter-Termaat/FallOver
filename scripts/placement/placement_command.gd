class_name PlacementCommand
extends RefCounted

## A single reversible placement action (PRD §4.8). FO-017 stacks these into
## real undo/redo history; this story only needs the shape to exist so that
## isn't a rewrite later — do()/undo() are called directly for now, no
## stack yet.

var _parent: Node3D
var _body: RigidBody3D
var _definition: BlockDefinition
var _placed_transform: Transform3D


func _init(parent: Node3D, definition: BlockDefinition, placed_transform: Transform3D) -> void:
	_parent = parent
	_definition = definition
	_placed_transform = placed_transform


func do() -> void:
	if _body == null:
		_body = BlockSpawner.spawn(_definition)
		_body.set_meta(&"placed_by_player", true)
		_body.set_meta(&"command", self)
		_body.collision_layer = 8
		_parent.add_child(_body)
	_body.transform = _placed_transform
	_body.freeze = true # stays put until the run starts (FO-015); no physics settling during build


func undo() -> void:
	if _body != null:
		_body.queue_free()
		_body = null


func get_body() -> RigidBody3D:
	return _body


func get_definition() -> BlockDefinition:
	return _definition


## FO-014: move the same body to a new transform rather than spawning a new
## one, so it stays the same command/identity for a future undo stack.
func move_to(new_transform: Transform3D) -> void:
	_placed_transform = new_transform
	_body.transform = new_transform


func set_highlighted(on: bool) -> void:
	var mesh_instance: MeshInstance3D = _body.get_node("MeshInstance3D")
	var material: StandardMaterial3D = mesh_instance.material_override
	material.emission_enabled = on
	material.emission = Palette.WHITE
	material.emission_energy_multiplier = 0.6 if on else 0.0
