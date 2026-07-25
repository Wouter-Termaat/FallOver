class_name WinCondition
extends Node

## PRD §4.2/§4.2.1 — win fires the moment the chest is hit by a live body;
## any hit counts, but a hit from a non-live body does nothing (closes both
## exploits: a block already resting against the chest, and a block that
## topples on its own while the layout settles). Reuses RunController's
## live-flag tracking (built for FO-015's camera) rather than a second
## propagation system.

signal won
signal failed(break_point: Node)

@export var run_controller: RunController
@export var victory_area: Area3D
@export var hold_before_win_signal: float = 1.0

var _won: bool = false
var _highlighted_command: PlacementCommand = null


func _ready() -> void:
	victory_area.body_entered.connect(_on_victory_body_entered)
	run_controller.run_started.connect(_on_run_started)
	run_controller.run_ended.connect(_on_run_ended)
	run_controller.reset_performed.connect(_clear_highlight)


func _on_run_started() -> void:
	_won = false
	_clear_highlight()


func _on_victory_body_entered(body: Node) -> void:
	if _won or not run_controller.is_running:
		return
	if not body.get_meta(&"live", false):
		return # a hit that didn't trace back to the starter doesn't count
	_won = true
	# Win sequencing (PRD §4.2.2): chest opens -> brief hold on the settled
	# chain -> win screen. The actual chest-opening animation is FO-086
	# (Phase 5); this just leaves the timing gap and the signal hook rather
	# than snapping straight to a win screen that doesn't exist yet.
	await get_tree().create_timer(hold_before_win_signal).timeout
	won.emit()


func _on_run_ended(last_live_body: Node) -> void:
	if _won:
		return
	_highlight_break_point(last_live_body)
	failed.emit(last_live_body)


func _highlight_break_point(body: Node) -> void:
	if body == null or not body.has_meta(&"command"):
		return # the starter itself has no command wrapper to highlight
	_highlighted_command = body.get_meta(&"command")
	_highlighted_command.set_highlighted(true)


func _clear_highlight() -> void:
	if _highlighted_command != null:
		_highlighted_command.set_highlighted(false)
		_highlighted_command = null
