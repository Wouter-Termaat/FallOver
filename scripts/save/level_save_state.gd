class_name LevelSaveState
extends Resource

## Per-level save data (PRD §11). No level name (PRD §7.7 — levels are
## numbered, keyed by id string) and no plate field (PRD §5.8).

@export var completed: bool = false
@export var best_stars: int = 0
@export var best_coins_left: int = 0
@export var flythrough_seen: bool = false

## In-progress layout, restored by FO-029. Plain dictionaries (block
## resource path + transform), not nested custom Resources, so this
## round-trips reliably through ResourceSaver.
@export var in_progress_layout: Array[Dictionary] = []
@export var in_progress_coins_spent: int = 0
