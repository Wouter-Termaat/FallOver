# Grey-box island — layer/group convention

FO-009. `scenes/levels/greybox_island.tscn`.

## Collision layers

| Layer (bit) | Meaning | Used by |
|---|---|---|
| 1 | Ground — valid placement surface | Platforms, ramp |
| 2 | Water — hazard, rejects placement | Water plane |
| 3 | Starter/Finish objects | `Start`, `Victory` bodies |

**Off-island** is not a layer — it's the absence of one. A placement raycast that hits nothing (or exceeds
max distance) is off-island, same practical outcome as hitting water.

## Groups

`Start` and `Victory` nodes are also tagged with matching Godot groups (`"Start"`, `"Victory"`) as a
redundant, human-readable way to find them (`get_tree().get_nodes_in_group("Start")`), independent of the
collision-layer convention above.

## Layout

Two platforms (`PlatformStart`, `PlatformFinish`) separated by a 3-unit water gap needing a bridge, a ramp
(`Ramp`) climbing from `PlatformFinish` up to `RaisedPlatform`. `CameraBounds` is a non-colliding `Area3D`
marking the island's extent for FO-011 to read. Starter (Dark Green, group `Start`) sits on
`PlatformStart`; Victory (Dark Red, group `Victory`) sits on `RaisedPlatform` — hardcoded placeholders per
FO-009, replaced by data-driven placement in FO-020.

All CSG pieces are grey-box scaffolding (`CSGBox3D`), not the modular kit (FO-030) — rebuildable in
minutes, not meant to survive as final geometry.
