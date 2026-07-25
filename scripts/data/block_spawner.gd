class_name BlockSpawner
extends RefCounted

## Builds a working rigid body purely from a BlockDefinition — proves block
## types are data, not code (PRD §13.3). No linear/angular damp fields yet;
## FO-003/FO-019 found those per-scene, not per-block-type — revisit once a
## real level needs it. Meanwhile, use the values FO-019/FO-004 validated
## under Jolt (docs/physics-backend-decision.md) as the shared default,
## rather than leaving real placed blocks undamped.
const DEFAULT_LINEAR_DAMP: float = 0.5
const DEFAULT_ANGULAR_DAMP: float = 2.0

static func spawn(definition: BlockDefinition) -> RigidBody3D:
	var body: RigidBody3D = RigidBody3D.new()
	body.name = definition.display_name.replace(" ", "")
	body.mass = definition.mass
	body.can_sleep = true
	body.linear_damp = DEFAULT_LINEAR_DAMP
	body.angular_damp = DEFAULT_ANGULAR_DAMP
	# Live-flag propagation (FO-023) needs each body to report what it hits.
	body.contact_monitor = true
	body.max_contacts_reported = 8

	var material: PhysicsMaterial = PhysicsMaterial.new()
	material.friction = definition.friction
	material.bounce = definition.restitution
	body.physics_material_override = material

	var collision: CollisionShape3D = CollisionShape3D.new()
	var box_shape: BoxShape3D = BoxShape3D.new()
	box_shape.size = definition.extents
	collision.shape = box_shape
	body.add_child(collision)

	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	if definition.mesh_override != null:
		mesh_instance.mesh = definition.mesh_override
	else:
		var box_mesh: BoxMesh = BoxMesh.new()
		box_mesh.size = definition.extents
		mesh_instance.mesh = box_mesh
		var material_override: StandardMaterial3D = StandardMaterial3D.new()
		material_override.albedo_color = definition.palette_color
		mesh_instance.material_override = material_override
	body.add_child(mesh_instance)

	return body
