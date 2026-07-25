class_name SellCommand
extends RefCounted

## FO-014's sell action, as a reversible command: do() removes the block
## (delegating to the underlying PlacementCommand's undo, which frees the
## body and unregisters it from BuildState), undo() restores it (the
## underlying command's do(), which respawns and re-registers).

var _underlying: PlacementCommand


func _init(underlying: PlacementCommand) -> void:
	_underlying = underlying


func do() -> void:
	_underlying.undo()


func undo() -> void:
	_underlying.do()
