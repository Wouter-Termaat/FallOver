@tool
class_name ObstacleSlotInstance
extends Node3D

## Drop into a level and assign an ObstacleSlot. With no theme_kit assigned
## (or the kit has no model for this slot), renders as a grey-box shape in
## brand palette colours (PRD §7.11.3) — visibly work-in-progress rather
## than silently looking finished. Collision always comes from the slot,
## never from whatever model a theme supplies (the one absolute rule,
## PRD §7.11) — verified explicitly in FO-031's findings.

@export var slot: ObstacleSlot:
	set(value):
		slot = value
		_rebuild()

@export var theme_kit: ThemeKit:
	set(value):
		theme_kit = value
		_rebuild()

var _static_body: StaticBody3D
var _collision_shape: CollisionShape3D
var _model_holder: Node3D


func _ready() -> void:
	_rebuild()


func _rebuild() -> void:
	if slot == null:
		return
	if _static_body == null:
		_static_body = StaticBody3D.new()
		_static_body.name = "StaticBody3D"
		add_child(_static_body)
		if Engine.is_editor_hint():
			_static_body.owner = get_tree().edited_scene_root

		_collision_shape = CollisionShape3D.new()
		_collision_shape.name = "CollisionShape3D"
		_static_body.add_child(_collision_shape)
		if Engine.is_editor_hint():
			_collision_shape.owner = get_tree().edited_scene_root

		_model_holder = Node3D.new()
		_model_holder.name = "Model"
		_static_body.add_child(_model_holder)
		if Engine.is_editor_hint():
			_model_holder.owner = get_tree().edited_scene_root

	# Collision: always from the slot, never from the model (PRD §7.11).
	var box_shape: BoxShape3D = BoxShape3D.new()
	box_shape.size = Vector3(slot.footprint.x, slot.height, slot.footprint.y)
	_collision_shape.shape = box_shape
	_static_body.collision_layer = slot.collision_layer
	_static_body.collision_mask = 0

	for child in _model_holder.get_children():
		# Immediate, not queue_free(): a subsequent property set in the same
		# frame (e.g. slot then theme_kit, both from the Inspector) must see
		# the old model actually gone, not still present until frame end.
		_model_holder.remove_child(child)
		child.free()

	var model: Variant = theme_kit.get_model(slot.slot_name) if theme_kit != null else null
	if model is PackedScene:
		var instance: Node = (model as PackedScene).instantiate()
		_model_holder.add_child(instance)
		if Engine.is_editor_hint():
			instance.owner = get_tree().edited_scene_root
	elif model is Mesh:
		var mesh_instance: MeshInstance3D = MeshInstance3D.new()
		mesh_instance.mesh = model
		_model_holder.add_child(mesh_instance)
		if Engine.is_editor_hint():
			mesh_instance.owner = get_tree().edited_scene_root
	else:
		# Grey-box: no theme, or theme has no model for this slot yet.
		var mesh_instance: MeshInstance3D = MeshInstance3D.new()
		var box_mesh: BoxMesh = BoxMesh.new()
		box_mesh.size = box_shape.size
		mesh_instance.mesh = box_mesh
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.albedo_color = slot.grey_box_color
		mesh_instance.material_override = material
		_model_holder.add_child(mesh_instance)
		if Engine.is_editor_hint():
			mesh_instance.owner = get_tree().edited_scene_root
