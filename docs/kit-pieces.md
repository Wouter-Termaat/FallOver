# Kit pieces

FO-030. PRD §7.10.1 — islands assembled from a shared kit, not sculpted per level.

## How to use one

1. Drag `scenes/kit/kit_piece.tscn` into a level scene (as many times as needed)
2. In the Inspector, assign a `KitPiece` resource from `resources/kit/` to the **Piece** property
3. It builds its own mesh and collision immediately, visible in the editor — no need to press Play to see
   or position it correctly
4. Move/rotate the instance like any other node to assemble the island; each instance can also override
   its own `piece` for a different footprint/height at that spot

Collision is **always** authored from the piece's `footprint`/`height`/`surface_tag` — never derived from
whatever mesh eventually replaces the grey-box placeholder (PRD §7.11's one absolute rule). Swapping in real
art in Phase 5 means changing `mesh_override`-equivalent visuals later without ever touching a level's
collision.

## Grid

Pieces are authored on an **8×8 unit footprint** by default (0.8m at the project's 10cm-per-unit scale,
FO-008), except Raised Platform which is 6×6 — position instances so footprints share edges with no gaps
or overlaps. There is no snap-to-grid enforcement yet; align by eye or by entering exact `position` values,
matching multiples of 4 (half the standard footprint) to keep edges flush.

## The six starting pieces

| Piece | Footprint | Height | Surface | Notes |
|---|---|---|---|---|
| Flat Plate | 8×8 | 2 | Ground (layer 1) | The default buildable surface |
| Slope | 8×8 | 2 | Ground | Tilted 20° about local Z — a ramp. Angle is per-instance tunable via `slope_degrees`, not fixed to this default |
| Cliff Edge | 8×8 | 6 | Ground | Taller box, for a drop-off / elevation change |
| Water Channel | 8×8 | 1 | Water (layer 2) | Matches the existing island's water collision convention — blocks and the starter are lost here (PRD §4.10) |
| Raised Platform | 6×6 | 4 | Ground | Smaller footprint, tall — an elevated island section |
| Gap | 8×8 | — | **None** | No collision, no visible mesh. A deliberate hole — nothing to stand on, distinct from water (no "lost block" splash, just empty space) |

All six are plain boxes (grey-box placeholders, PRD §8.3) tinted from the brand palette. A purchased or
modelled kit replaces the visuals in Phase 5 (PRD open #33) without touching any level, because collision
never depended on the mesh in the first place.

## Adding a new piece

Only when an actual level needs one — the kit grows on demand, not speculatively (PRD §7.10.1). Create a new
`.tres` in `resources/kit/` with the `KitPiece` resource type; no code or scene changes needed unless the new
piece needs a shape `kit_piece_instance.gd` can't build from a plain box (e.g. a piece with a hole through
it) — that would need a real authored `Shape3D`/mesh rather than the generic box builder.

## Known limitation

`kit_piece_instance.gd` only builds axis-aligned boxes (optionally tilted about Z for slopes). Anything
needing a non-box collision shape (an L-shaped platform, a true ramp with a taper) isn't representable yet
— extend the script's `_rebuild()` when a level actually needs one.
