class_name WorldDefinition
extends Resource

## A world as data (PRD §13.3). Owns the theme kit and block unlocks — a
## level never stores its own theme (PRD §7.10.5), it resolves from
## whichever world's `levels` array currently contains it.

@export var world_name: String = ""
@export var music_track: AudioStream = null
@export var theme_kit: ThemeKit = null
@export var unlocked_block_types: Array[BlockDefinition] = []
@export var cumulative_star_gate: int = 0
@export var levels: Array[LevelDefinition] = []
