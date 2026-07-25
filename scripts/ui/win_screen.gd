extends Control

## PRD §4.2.2/§9. Stars, coins left, continue/replay. Reserves a disabled
## slot for a share button (PRD §5.11, §13.5) — sharing is deferred, but the
## space exists so adding it later isn't a redesign.

signal continue_or_replay_pressed

@onready var _stars_label: Label = $Panel/VBox/StarsLabel
@onready var _coins_label: Label = $Panel/VBox/CoinsLabel
@onready var _continue_button: Button = $Panel/VBox/Row/ContinueButton
@onready var _replay_button: Button = $Panel/VBox/Row/ReplayButton


func _ready() -> void:
	_continue_button.pressed.connect(func(): continue_or_replay_pressed.emit())
	_replay_button.pressed.connect(func(): continue_or_replay_pressed.emit())


func show_result(stars: int, coins_left: int) -> void:
	_stars_label.text = "★".repeat(stars) + "☆".repeat(3 - stars)
	_coins_label.text = "Coins left: %d" % coins_left
