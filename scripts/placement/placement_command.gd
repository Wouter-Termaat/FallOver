class_name PlacementCommand
extends RefCounted

## A single reversible placement action (PRD §4.8), stacked by CommandHistory
## (FO-017). Moves and rotations of this same body are separate
## TransformCommands, not this one — this command only ever represents
## "this block exists (or doesn't)".

var _parent: Node3D
var _body: RigidBody3D
var _definition: BlockDefinition
var _placed_transform: Transform3D
var _registered: bool = false


func _init(parent: Node3D, definition: BlockDefinition, placed_transform: Transform3D) -> void:
	_parent = parent
	_definition = definition
	_placed_transform = placed_transform


func do() -> void:
	if _body == null:
		_body = BlockSpawner.spawn(_definition)
		_body.set_meta(&"placed_by_player", true)
		_body.set_meta(&"command", self)
		_parent.add_child(_body)
	# Re-show rather than recreate: a later TransformCommand may hold a
	# direct reference to this same body, which a fresh spawn would orphan.
	_body.visible = true
	_body.collision_layer = 8
	_body.transform = _placed_transform
	_body.freeze = true # stays put until the run starts (FO-015); no physics settling during build
	if not _registered:
		BuildState.register(self)
		_registered = true
		CoinBudget.spend(_definition.coin_price)


func undo() -> void:
	if _body != null:
		if _registered:
			BuildState.unregister(self)
			_registered = false
			CoinBudget.refund(_definition.coin_price)
		_body.visible = false
		_body.collision_layer = 0
		_body.freeze = true


## Frees the underlying body permanently — only call when the block is
## truly gone for good (e.g. leaving the level), never as part of undo/redo.
func discard() -> void:
	if _body != null:
		_body.queue_free()
		_body = null


func get_body() -> RigidBody3D:
	return _body


func get_definition() -> BlockDefinition:
	return _definition


func set_highlighted(on: bool) -> void:
	var mesh_instance: MeshInstance3D = _body.get_node("MeshInstance3D")
	var material: StandardMaterial3D = mesh_instance.material_override
	material.emission_enabled = on
	material.emission = Palette.WHITE
	material.emission_energy_multiplier = 0.6 if on else 0.0
