@tool
class_name KitPieceInstance
extends Node3D

## Drop this scene into a level and assign a KitPiece resource — it builds
## its own mesh/collision from the piece's footprint (PRD §7.10.1), visible
## live in the editor (@tool) so assembling an island is drag-and-set-piece,
## not hand-authoring CSG per level the way FO-009's grey-box island did.

@export var piece: KitPiece:
	set(value):
		piece = value
		_rebuild()

var _mesh_instance: MeshInstance3D
var _static_body: StaticBody3D
var _collision_shape: CollisionShape3D


func _ready() -> void:
	_rebuild()


func _rebuild() -> void:
	if piece == null:
		return
	if _static_body == null:
		_static_body = StaticBody3D.new()
		_static_body.name = "StaticBody3D"
		add_child(_static_body)
		if Engine.is_editor_hint():
			_static_body.owner = get_tree().edited_scene_root

		_mesh_instance = MeshInstance3D.new()
		_mesh_instance.name = "MeshInstance3D"
		_static_body.add_child(_mesh_instance)
		if Engine.is_editor_hint():
			_mesh_instance.owner = get_tree().edited_scene_root

		_collision_shape = CollisionShape3D.new()
		_collision_shape.name = "CollisionShape3D"
		_static_body.add_child(_collision_shape)
		if Engine.is_editor_hint():
			_collision_shape.owner = get_tree().edited_scene_root

	var size: Vector3 = Vector3(piece.footprint.x, piece.height, piece.footprint.y)

	var box_mesh: BoxMesh = BoxMesh.new()
	box_mesh.size = size
	_mesh_instance.mesh = box_mesh

	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = piece.grey_box_color
	_mesh_instance.material_override = material

	_static_body.rotation = Vector3(0.0, 0.0, deg_to_rad(piece.slope_degrees))
	_static_body.collision_layer = piece.collision_layer()
	_static_body.collision_mask = 0

	if piece.surface_tag == KitPiece.SurfaceTag.GAP:
		_collision_shape.disabled = true
		_mesh_instance.visible = false
	else:
		_collision_shape.disabled = false
		_mesh_instance.visible = true
		var box_shape: BoxShape3D = BoxShape3D.new()
		box_shape.size = size
		_collision_shape.shape = box_shape
