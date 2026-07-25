class_name ClearAllCommand
extends RefCounted

## FO-018: wipes every placed block as a single undoable action (PRD §4.12
## notes undo can reverse an accidental clear-all). Snapshots the current
## BuildState command list at construction time.

var _commands: Array = []


func _init() -> void:
	_commands = BuildState.commands.duplicate()


func do() -> void:
	for command in _commands:
		BuildState.unregister(command)
		command.undo()


func undo() -> void:
	for command in _commands:
		command.do()
		BuildState.register(command)


func is_empty() -> bool:
	return _commands.is_empty()
