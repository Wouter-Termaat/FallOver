class_name ObstacleSlot
extends Resource

## A semantic obstacle placeholder (PRD §7.11). Levels place slots, never
## specific models — a world's ThemeKit maps slot name to model. Collision
## belongs to the slot in every theme (the one absolute rule) and is
## authored here, never derived from whichever model a theme supplies.

@export var slot_name: String = ""

## The volume every theme's model must fill (PRD §7.11.2) — not just the
## collision shape. A theme model visibly smaller than this makes chains
## stop short and look broken while the physics is entirely correct.
@export var footprint: Vector2 = Vector2(2.0, 2.0)
@export var height: float = 4.0

## Collision layer convention shared with the rest of the project (see
## docs/greybox-island.md): 1=ground 2=water 4=start/finish 8=placed blocks.
## Obstacles default to 16; Bridge overrides to 1 (walkable), Hazard Surface
## to 2 (water-like), Prop/Decoration to 0 (no physical interaction).
@export var collision_layer: int = 16

## Grey-box placeholder colour (PRD §8.3), used whenever no ThemeKit
## supplies a model for this slot (PRD §7.11.3 — unthemed renders grey-box).
@export var grey_box_color: Color = Palette.DARK_GREEN
