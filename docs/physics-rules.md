# Physics rules

Implements PRD §13.1 (simulation reliability) and §13.2 (physics interpolation).

**Do not change any value here casually.** These settings decide every level's physics outcome. Changing
one invalidates every tuned level and every recorded reference solution (PRD §7.10.3).

Godot **strips hand-written comments from `project.godot`** when it saves, so this file is the only durable
record of the reasoning. If you change a setting, change it here too.

## The settings

Set in `project.godot` under `[physics]`. Paths verified against Godot 4.7.1 and confirmed to read back
with the intended values.

| Setting | Value | Godot default | Why |
|---|---|---|---|
| `physics/common/physics_ticks_per_second` | `60` | `60` | Fixed timestep. Equals the default **on purpose** — set explicitly so it reads as a deliberate choice rather than an untouched default, and so anyone tempted to change it sees it. |
| `physics/common/max_physics_steps_per_frame` | `8` | `8` | Ceiling on physics steps per rendered frame. Kept at the default until device testing says otherwise. |
| `physics/common/physics_interpolation` | `true` | `false` | Smooths rendering when render rate and physics tick don't align. Enabled for how the falling chain looks (PRD §13.2). |

## Exceeding `max_physics_steps_per_frame` causes slow motion, not divergence

If the device can't keep up and physics needs more than 8 steps in one rendered frame, Godot does **not**
drop ticks and the simulation does **not** diverge. The tick sequence stays intact; physics simply falls
behind wall-clock time, so the run visibly plays in **slow motion**. Godot's docs call this the
*physics spiral of death*.

This is the good failure mode — the result is still correct, just late. But a chain that crawls is nearly
as bad for the player as one that fails.

**The fix is never to raise the ceiling or lower the tick rate as a reflex.** In order of preference:

1. Fewer simultaneously active rigid bodies (blocks at rest must sleep — PRD §13.4)
2. A lower tick rate, accepting that this changes physics outcomes and re-invalidates tuned levels

Must be tested on a low-end device.

## Interpolation renders 1–2 ticks in the past

Physics interpolation draws objects where they were one to two ticks ago. Invisible when watching a chain
fall, but it means:

> **Gameplay logic reads physics state, never interpolated visual transforms.**

Win detection, settle detection and scoring must read the rigid body's physics state. Reading a visual
transform gets you a stale answer that is also frame-rate dependent.

## Hard rule: gameplay logic never runs in `_process`

**Only `_physics_process`.** Nothing may depend on frame delta.

The entire reliability promise depends on gameplay reading a fixed physics tick rather than a render
frame. `_process` runs at whatever rate the GPU manages, which varies by device, by thermal state, and by
what else the phone is doing. Any gameplay decision made there is non-reproducible.

This applies to win detection, settle detection, no-progress detection, scoring, and the run camera's
framing logic. Purely visual work (UI tweens, particle effects) may use `_process`.

## Related, deliberately not decided here

- **Physics backend** (`physics/3d/physics_engine`, currently `DEFAULT` = GodotPhysics3D) — chosen by
  measurement in FO-004, not by argument. Jolt is the other candidate (PRD §13.1).
- **Fast-forward** must run *more ticks per frame*, never scale the timestep or the tick rate. Scaling the
  timestep changes the physics result, so a layout would pass at normal speed and fail fast-forwarded
  (PRD §4.9.1).
- **Damping values** are found by feel in FO-003, not here.
