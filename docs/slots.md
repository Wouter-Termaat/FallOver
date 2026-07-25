# Obstacle slots and theme kits

FO-031. PRD §7.11 — levels place semantic slots, never specific models; a world's theme kit maps each
slot to a model.

## The one absolute rule

**Collision belongs to the slot, in every theme.** A slot's `footprint`/`height`/`collision_layer` are
authored once on the `ObstacleSlot` resource and never touched by which theme is active. Verified directly
in this story (see Findings below) by instancing the same slot under two different theme kits and
confirming the collision shape and layer are byte-identical while the visual differs.

## The volume budget

A slot also states the **visual volume** every theme's model must fill (`footprint`/`height` again — same
fields serve both purposes). This isn't optional: if a theme's model is visibly smaller than the slot, a
chain reaching it stops short and looks broken, even though the physics is entirely correct — a confusing
bug to diagnose blind. Check new theme models against the slot's stated volume before they ship. A model
that can't fill the volume needs a different slot, not a shrunken box.

## The six starting slots

| Slot | Footprint | Height | Collision layer | Notes |
|---|---|---|---|---|
| Tall Obstacle | 2×2 | 6 | 16 (obstacle) | Blocks the route entirely — pine tree, cactus, etc. |
| Low Obstacle | 2×2 | 2 | 16 | Shorter — a rock, dune stone |
| Wide Barrier | 6×1 | 3 | 16 | Spans width — a fence, palisade, ice wall |
| Bridge | 2×6 | 0.5 | **1 (ground)** | The one slot that must be walkable — layer differs from the others deliberately |
| Hazard Surface | 6×6 | 1 | **2 (water)** | Water/quicksand/thin ice/lava — behaves like the existing water convention |
| Prop / Decoration | 2×2 | 2 | **0 (none)** | Pure dressing, no physical interaction |

Collision layers reuse the project-wide convention (`docs/greybox-island.md`): 1=ground, 2=water,
4=start/finish, 8=placed blocks. Obstacles get a new layer, 16, except where the slot's own nature demands
otherwise (Bridge, Hazard Surface, Prop).

## How to use one

1. Drag `scenes/kit/obstacle_slot.tscn` into a level
2. Assign an `ObstacleSlot` from `resources/slots/` to **Slot**
3. Optionally assign a `ThemeKit` from `resources/themes/` to **Theme Kit** — with none assigned (or the
   kit missing a model for this slot), it renders as a grey-box shape in brand palette colours (PRD
   §7.11.3), which is deliberate: an unthemed level should look visibly unfinished, not silently complete

## Theme kits

A `ThemeKit` maps slot names to models (`Mesh` or `PackedScene`) and belongs to a **world**, never a
level — that's what lets a level move between worlds and re-dress automatically (PRD §7.10.5).

Two kits exist so far:

- **`resources/themes/grey_box.tres`** — empty. Every slot falls back to its grey-box placeholder.
- **`resources/themes/grass_stub.tres`** — maps `tall_obstacle` to a placeholder pine-tree-shaped
  `CylinderMesh`, just to prove the swap works end to end. Not real art — Phase 5 replaces this.

Adding a real theme is filling in a `ThemeKit`'s `slot_models` dictionary with real meshes/scenes per slot
name; no code changes needed.

## A gotcha worth remembering

`ObstacleSlotInstance` originally rebuilt its model using `queue_free()` on the old one before adding the
new one. `queue_free()` is deferred to end-of-frame, so a script (or the editor, on rapid successive
property changes) checking the node's children immediately afterward could still see the *old* model
alongside the new one. Fixed by using immediate `remove_child()` + `free()` instead — this is a
Godot-editor-authored node fully owned by this script, so freeing it immediately is safe.

## Not built here

The theme kit *mapping table* per real world (Grass/Desert/Snow/Volcano) is Phase 5 art work (FO-073) —
this story only needed grey-box primitives and one stub to prove the mechanism.
