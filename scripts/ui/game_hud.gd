class_name GameHud
extends Control

## Start / abort-reset / fast-forward (PRD §4.9, §6.3), plus undo/redo
## (PRD §4.8) and clear-all (PRD §4.12). Leaves room for FO-021's coin
## display — it adds its own control to Row rather than rebuilding this.

@export var run_controller: RunController

@onready var _start_button: Button = $Row/StartButton
@onready var _reset_button: Button = $Row/ResetButton
@onready var _fast_forward_button: Button = $Row/FastForwardButton
@onready var _undo_button: Button = $BuildRow/UndoButton
@onready var _redo_button: Button = $BuildRow/RedoButton
@onready var _clear_all_button: Button = $BuildRow/ClearAllButton
@onready var _clear_all_confirm: ConfirmationDialog = $ClearAllConfirm
@onready var _coin_label: Label = $CoinLabel


func _ready() -> void:
	_start_button.pressed.connect(_on_start_pressed)
	_reset_button.pressed.connect(_on_reset_pressed)
	_fast_forward_button.pressed.connect(_on_fast_forward_pressed)
	_undo_button.pressed.connect(_on_undo_pressed)
	_redo_button.pressed.connect(_on_redo_pressed)
	_clear_all_button.pressed.connect(_on_clear_all_pressed)
	_clear_all_confirm.confirmed.connect(_on_clear_all_confirmed)
	run_controller.run_started.connect(_on_run_state_changed)
	run_controller.run_ended.connect(_on_run_ended)
	CommandHistory.changed.connect(_update_undo_redo_buttons)
	CoinBudget.changed.connect(_update_coin_label)
	_update_buttons()
	_update_undo_redo_buttons()
	_update_coin_label()


func _update_coin_label() -> void:
	_coin_label.text = "Coins: %d" % CoinBudget.remaining


func _on_start_pressed() -> void:
	run_controller.start_run()
	_update_buttons()


func _on_reset_pressed() -> void:
	run_controller.reset()
	_update_buttons()


func _on_fast_forward_pressed() -> void:
	run_controller.set_fast_forward(not run_controller.is_fast_forwarding())
	_fast_forward_button.text = "Fast-Forward: ON" if run_controller.is_fast_forwarding() else "Fast-Forward"


func _on_undo_pressed() -> void:
	CommandHistory.undo()


func _on_redo_pressed() -> void:
	CommandHistory.redo()


func _on_clear_all_pressed() -> void:
	_clear_all_confirm.popup_centered()


func _on_clear_all_confirmed() -> void:
	var command: ClearAllCommand = ClearAllCommand.new()
	if not command.is_empty():
		CommandHistory.execute(command)


func _on_run_state_changed() -> void:
	_update_buttons()


func _on_run_ended(_last_live_body: Node) -> void:
	_update_buttons()


func _update_buttons() -> void:
	_start_button.disabled = run_controller.is_running
	_fast_forward_button.disabled = not run_controller.is_running
	_undo_button.disabled = run_controller.is_running or not CommandHistory.can_undo()
	_redo_button.disabled = run_controller.is_running or not CommandHistory.can_redo()
	_clear_all_button.disabled = run_controller.is_running


func _update_undo_redo_buttons() -> void:
	_undo_button.disabled = run_controller.is_running or not CommandHistory.can_undo()
	_redo_button.disabled = run_controller.is_running or not CommandHistory.can_redo()
