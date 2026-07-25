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
