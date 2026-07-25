class_name LevelDefinition
extends Resource

## A level as data (PRD §13.3), not a hand-built scene. Superseding
## FO-009's manual grey-box island as the authoring path going forward —
## that scene remains as Phase 0/1's test bench, this is how real levels
## are built from FO-028 onward.
##
## Deliberately absent, per PRD: no plate field (§5.8), no level name (§7.7)
## — levels are numbered only, and the number lives in the file name /
## the world's ordered list, not a field here.

@export var island_layout: Array[PlacedPiece] = []
@export var obstacle_slots: Array[PlacedSlot] = []

@export var starter_transform: Transform3D
@export var starter_impulse_direction: Vector3 = Vector3.RIGHT
@export var finish_transform: Transform3D

@export var coin_amount: int = 20
@export var available_block_types: Array[BlockDefinition] = []

## Never computed by formula (PRD §5.2) — authored per level, or proposed
## by FO-034's deriver from a recorded reference solution and then
## overridden here.
@export var star2_coin_threshold: int = 0
@export var star3_coin_threshold: int = 0

@export_group("Opening fly-through (PRD §6.4)")
@export var flythrough_position_a: Vector3
@export var flythrough_size_a: float = 20.0
@export var flythrough_position_b: Vector3
@export var flythrough_size_b: float = 20.0
@export var flythrough_duration: float = 3.0

@export_group("Reference solution (PRD §7.10.3, populated by FO-032)")
@export var reference_solution: Array[PlacedBlock] = []
@export var reference_solution_coin_cost: int = 0
## True only for thresholds Wouter has manually overridden (FO-034) — an
## overridden value is never recomputed by the deriver.
@export var star2_threshold_overridden: bool = false
@export var star3_threshold_overridden: bool = false
@export var coin_amount_overridden: bool = false

@export_group("Reassignment validation (PRD §7.10.5, checked by FO-033)")
@export var required_block_types: Array[BlockDefinition] = []
