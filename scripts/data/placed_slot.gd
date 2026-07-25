class_name PlacedSlot
extends Resource

## One obstacle slot instance within a level's layout (PRD §13.3). Never a
## specific model — the world's ThemeKit resolves that at load time.

@export var slot: ObstacleSlot
@export var slot_transform: Transform3D
