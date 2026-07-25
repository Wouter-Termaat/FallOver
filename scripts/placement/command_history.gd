extends Node

## Autoload. Full undo/redo history over placement/move/rotate/sell/clear-all
## commands (PRD §4.8) — not one step back. Cleared when a run starts and
## when a level is exited; deliberately not persisted across a mid-build
## save/resume (FO-029 doesn't touch this).

signal changed

var _undo_stack: Array = []
var _redo_stack: Array = []


## For an action already performed live (e.g. a rotation applied
## incrementally during a drag) — records it without calling do() again.
func push(command) -> void:
	_undo_stack.append(command)
	_redo_stack.clear()
	changed.emit()


## For an action not yet performed — calls do() then records it.
func execute(command) -> void:
	command.do()
	push(command)


func undo() -> void:
	if _undo_stack.is_empty():
		return
	var command = _undo_stack.pop_back()
	command.undo()
	_redo_stack.append(command)
	changed.emit()


func redo() -> void:
	if _redo_stack.is_empty():
		return
	var command = _redo_stack.pop_back()
	command.do()
	_undo_stack.append(command)
	changed.emit()


func clear() -> void:
	_undo_stack.clear()
	_redo_stack.clear()
	changed.emit()


func can_undo() -> bool:
	return not _undo_stack.is_empty()


func can_redo() -> bool:
	return not _redo_stack.is_empty()
