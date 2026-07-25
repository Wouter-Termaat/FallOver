extends Node

## Autoload. The single registry of currently-placed blocks (PlacementCommand
## instances), so FO-015's snapshot/reset, FO-017's undo/redo, and FO-021's
## coin accounting can all see the same list without deep coupling to
## PlacementController.

signal block_registered(command: PlacementCommand)
signal block_unregistered(command: PlacementCommand)

var commands: Array = []


func register(command: PlacementCommand) -> void:
	commands.append(command)
	block_registered.emit(command)


func unregister(command: PlacementCommand) -> void:
	commands.erase(command)
	block_unregistered.emit(command)


## Removes every placed block and refunds nothing itself — FO-018/FO-021 hook
## coin refunds onto block_unregistered.
func clear_all() -> void:
	for command in commands.duplicate():
		command.undo()
		unregister(command)
