extends Control

## PRD §4.10 — the break point is obvious (WinCondition already highlights
## it and the camera naturally rests there, RunCamera keeps its last
## framing once nothing is moving). Retry keeps the layout — it's a reset,
## never a clear-all.

signal retry_pressed

@onready var _retry_button: Button = $Panel/RetryButton


func _ready() -> void:
	_retry_button.pressed.connect(func(): retry_pressed.emit())
