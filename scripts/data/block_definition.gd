class_name BlockDefinition
extends Resource

## Data-driven block type (PRD §13.3). Adding a block type is a new .tres
## instance of this resource, never a script change.

@export var display_name: String = ""

## Box collision/visual extents as (depth, height, length) — depth is the
## thin edge along the direction of travel, length is the wide face that
## catches the next block, matching the domino orientation convention.
@export var extents: Vector3 = Vector3(0.5, 4.0, 2.0)

@export var mass: float = 1.0
@export var friction: float = 2.0
@export var restitution: float = 0.0
## Placeholder, unbalanced — real pricing is FO-047, Phase 3.
@export var coin_price: int = 1

## Grey-box placeholder colour (PRD §8.3). Real art arrives in Phase 5.
@export var palette_color: Color = Color.WHITE

## Unused until Phase 5 — real art replaces the grey-box mesh.
@export var mesh_override: Mesh = null
