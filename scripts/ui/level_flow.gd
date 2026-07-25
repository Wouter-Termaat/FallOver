class_name LevelFlow
extends Node

## Orchestrates what happens when a run ends — the single choke point PRD
## §13.5 wants left open for a future interstitial/rewarded hook. No SDK,
## no IAP, no analytics added here; only the seam, and a comment saying so.

@export var run_controller: RunController
@export var win_condition: WinCondition
@export var win_screen: Control
@export var fail_prompt: Control
@export var level: LevelDefinition
@export var level_id: String = "w1_l01" # placeholder until real level select (Phase 4) supplies this


func _ready() -> void:
	win_condition.won.connect(_on_won)
	win_condition.failed.connect(_on_failed)
	win_screen.connect("continue_or_replay_pressed", _on_continue_or_replay_pressed)
	fail_prompt.connect("retry_pressed", _on_retry_pressed)
	win_screen.visible = false
	fail_prompt.visible = false


func _on_won() -> void:
	var coins_left: int = CoinBudget.remaining
	var stars: int = Scoring.calculate_stars(level, coins_left, true) if level != null else 1
	Scoring.record_result(level_id, stars, coins_left)

	# PRD §13.5 choke point: level flow passes through here on every win,
	# which is where a future interstitial/rewarded hook could be inserted.
	# Deliberately nothing here yet — no ad SDK, no IAP, no analytics.

	win_screen.call("show_result", stars, coins_left)
	win_screen.visible = true


func _on_failed(_last_live_body: Node) -> void:
	fail_prompt.visible = true


func _on_continue_or_replay_pressed() -> void:
	win_screen.visible = false
	run_controller.reset()


func _on_retry_pressed() -> void:
	fail_prompt.visible = false
	run_controller.reset()
