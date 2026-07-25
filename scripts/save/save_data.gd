class_name SaveData
extends Resource

## Full save schema (PRD §11). The version field exists from the first
## commit — non-negotiable, migrations later are painful without it.
## No plate field (PRD §5.8), no per-level run time (PRD §5.9), no level
## names anywhere (PRD §7.7).

const CURRENT_VERSION: int = 1

@export var save_format_version: int = CURRENT_VERSION

@export_group("Global")
@export var selected_skin: String = "" # unused until skins ship (Phase 8)
@export var unlocked_block_types: Array[String] = [] # BlockDefinition resource paths
@export var achievement_progress: Dictionary = {}
@export var diamonds: int = 0
@export var claimed_star_payouts: Dictionary = {} # "level_id:star_index" -> true, once paid
@export var haptics_enabled: bool = true
@export var total_blocks_placed: int = 0
@export var total_levels_completed: int = 0
@export var total_play_time_seconds: float = 0.0 # aggregate stat only (PRD §5.9), never per-level

@export_group("Per world")
@export var world_cumulative_stars: Dictionary = {} # world_id: String -> int

@export_group("Per level")
@export var level_states: Dictionary = {} # level_id: String -> LevelSaveState


## Entitlement flags can be added here later without a migration (PRD §13.5)
## — this dictionary exists for exactly that, empty until there's a model.
@export var entitlements: Dictionary = {}
