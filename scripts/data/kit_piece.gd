class_name KitPiece
extends Resource

## A modular island terrain piece (PRD §7.10.1). One mesh per piece,
## forever — themes change only the material (PRD §7.11.1), never the shape
## or collision. Collision is authored here directly from footprint/height,
## never derived from a mesh, so a piece with no real art yet still has
## full, correct collision.

enum SurfaceTag { GROUND, WATER, GAP }

@export var display_name: String = ""

## Snap footprint on the shared grid (PRD's "pieces snap to a shared grid").
@export var footprint: Vector2 = Vector2(4.0, 4.0)
@export var height: float = 1.0

## GAP has no collision at all — a deliberate hole, not solid and not water.
@export var surface_tag: SurfaceTag = SurfaceTag.GROUND

## Grey-box placeholder colour (PRD §8.3). The material slot a theme
## overrides (PRD §7.11.1) — real art replaces this per world in Phase 5.
@export var grey_box_color: Color = Palette.LIGHT_GREEN

## Slope pieces tilt; 0 for flat pieces. Degrees, rotated about local Z so
## the piece rises along its local X axis.
@export var slope_degrees: float = 0.0


func collision_layer() -> int:
	match surface_tag:
		SurfaceTag.GROUND:
			return 1
		SurfaceTag.WATER:
			return 2
		_:
			return 0
