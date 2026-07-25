class_name ThemeKit
extends Resource

## Maps obstacle slot names to models, owned by a world (PRD §7.11, §13.3) —
## never by a level, so a level can be reassigned between worlds and
## re-dress automatically (PRD §7.10.5). Terrain re-themes by material only
## (PRD §7.11.1); this resource is for obstacles, where the mesh itself
## legitimately differs per theme.

@export var theme_name: String = ""

## Keys are ObstacleSlot.slot_name strings; values are Mesh or PackedScene.
## A slot name missing from this dictionary falls back to the grey-box
## placeholder (PRD §7.11.3) — that's normal for a kit still being filled
## in, not an error.
@export var slot_models: Dictionary = {}


func get_model(slot_name: String) -> Variant:
	return slot_models.get(slot_name)
