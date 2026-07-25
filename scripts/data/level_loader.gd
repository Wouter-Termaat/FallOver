class_name LevelLoader
extends RefCounted

## Builds a playable level's content (terrain, obstacles, starter, finish)
## from one LevelDefinition plus its world's ThemeKit (PRD §13.3). Returns
## just the level content — the reusable game shell (CameraRig,
## PlacementController, RunController, HUD) stays a separate scene that
## instances this under itself, the way greybox_island.tscn does by hand.

const KIT_PIECE_SCENE: String = "res://scenes/kit/kit_piece.tscn"
const OBSTACLE_SLOT_SCENE: String = "res://scenes/kit/obstacle_slot.tscn"

## Matches the domino ratio used throughout the project (PRD §4.4).
const STARTER_FINISH_SIZE: Vector3 = Vector3(0.5, 4.0, 2.0)


static func build(level: LevelDefinition, world: WorldDefinition) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "LevelContent"

	var kit_piece_scene: PackedScene = load(KIT_PIECE_SCENE)
	for placement in level.island_layout:
		var instance: KitPieceInstance = kit_piece_scene.instantiate()
		root.add_child(instance)
		instance.piece = placement.piece
		instance.transform = placement.piece_transform

	var obstacle_slot_scene: PackedScene = load(OBSTACLE_SLOT_SCENE)
	for placement in level.obstacle_slots:
		var instance: ObstacleSlotInstance = obstacle_slot_scene.instantiate()
		root.add_child(instance)
		instance.theme_kit = world.theme_kit if world != null else null
		instance.slot = placement.slot
		instance.transform = placement.slot_transform

	root.add_child(_build_starter(level))
	root.add_child(_build_finish(level))

	return root


static func _build_starter(level: LevelDefinition) -> RigidBody3D:
	var body: RigidBody3D = RigidBody3D.new()
	body.name = "Start"
	body.transform = level.starter_transform
	body.collision_layer = 4
	body.collision_mask = 1
	body.freeze = true
	body.can_sleep = true
	body.linear_damp = 0.5
	body.angular_damp = 2.0
	body.contact_monitor = true
	body.max_contacts_reported = 8
	body.add_to_group("Start")

	# Named explicitly — get_node("CollisionShape3D") elsewhere
	# (run_controller.gd's starter_height()) needs the clean name, not the
	# "@CollisionShape3D@N" a node created via .new() gets otherwise.
	var collision: CollisionShape3D = CollisionShape3D.new()
	collision.name = "CollisionShape3D"
	var box_shape: BoxShape3D = BoxShape3D.new()
	box_shape.size = STARTER_FINISH_SIZE
	collision.shape = box_shape
	body.add_child(collision)

	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	mesh_instance.name = "MeshInstance3D"
	var box_mesh: BoxMesh = BoxMesh.new()
	box_mesh.size = STARTER_FINISH_SIZE
	mesh_instance.mesh = box_mesh
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Palette.DARK_GREEN
	mesh_instance.material_override = material
	body.add_child(mesh_instance)

	return body


static func _build_finish(level: LevelDefinition) -> Area3D:
	# Grey-box shape (a real chest is FO-086, Phase 5) but a real hit
	# detector — Area3D so WinCondition (FO-023) can catch a live body
	# entering it directly via body_entered, no per-tick contact scanning.
	var body: Area3D = Area3D.new()
	body.name = "Victory"
	body.transform = level.finish_transform
	body.collision_layer = 4
	body.collision_mask = 4 | 8 # starter (4) or a placed block (8)
	body.monitoring = true
	body.monitorable = true
	body.add_to_group("Victory")

	var collision: CollisionShape3D = CollisionShape3D.new()
	var box_shape: BoxShape3D = BoxShape3D.new()
	box_shape.size = STARTER_FINISH_SIZE
	collision.shape = box_shape
	body.add_child(collision)

	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	var box_mesh: BoxMesh = BoxMesh.new()
	box_mesh.size = STARTER_FINISH_SIZE
	mesh_instance.mesh = box_mesh
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Palette.DARK_RED
	mesh_instance.material_override = material
	body.add_child(mesh_instance)

	return body
