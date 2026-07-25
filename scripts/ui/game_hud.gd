class_name GameHud
extends Control

## Start / abort-reset / fast-forward (PRD §4.9, §6.3). Leaves room for
## FO-017's undo/redo, FO-018's clear-all and FO-021's coin display —
## each adds its own control to the same Row rather than rebuilding this.

@export var run_controller: RunController

@onready var _start_button: Button = $Row/StartButton
@onready var _reset_button: Button = $Row/ResetButton
@onready var _fast_forward_button: Button = $Row/FastForwardButton


func _ready() -> void:
	_start_button.pressed.connect(_on_start_pressed)
	_reset_button.pressed.connect(_on_reset_pressed)
	_fast_forward_button.pressed.connect(_on_fast_forward_pressed)
	run_controller.run_started.connect(_on_run_state_changed)
	run_controller.run_ended.connect(_on_run_ended)
	_update_buttons()


func _on_start_pressed() -> void:
	run_controller.start_run()
	_update_buttons()


func _on_reset_pressed() -> void:
	run_controller.reset()
	_update_buttons()


func _on_fast_forward_pressed() -> void:
	run_controller.set_fast_forward(not run_controller.is_fast_forwarding())
	_fast_forward_button.text = "Fast-Forward: ON" if run_controller.is_fast_forwarding() else "Fast-Forward"


func _on_run_state_changed() -> void:
	_update_buttons()


func _on_run_ended(_last_live_body: Node) -> void:
	_update_buttons()


func _update_buttons() -> void:
	_start_button.disabled = run_controller.is_running
	_fast_forward_button.disabled = not run_controller.is_running
