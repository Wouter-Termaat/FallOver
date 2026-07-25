class_name TransformCommand
extends RefCounted

## A move or rotation of an already-placed body (FO-013's rotate-after-place,
## FO-014's move/rotate-edit). Both are just "this body's transform changed
## from A to B" — one class covers either.

var _body: RigidBody3D
var _old_transform: Transform3D
var _new_transform: Transform3D


func _init(body: RigidBody3D, old_transform: Transform3D, new_transform: Transform3D) -> void:
	_body = body
	_old_transform = old_transform
	_new_transform = new_transform


func do() -> void:
	_body.transform = _new_transform


func undo() -> void:
	_body.transform = _old_transform
