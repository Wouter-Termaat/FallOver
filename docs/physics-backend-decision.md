# Physics backend decision

Resolves PRD open decision #2. FO-004.

## Decision: Jolt Physics

**`physics/3d/physics_engine = "Jolt Physics"`** — set in `project.godot`.

⚠️ **Note the exact value.** The enum's valid values are `DEFAULT`, `Jolt Physics` (with a space — the
human-readable label, not a code-style identifier), `GodotPhysics3D`, `Dummy`. A first attempt at this
story set `"JoltPhysics3D"`, which is not a valid value — Godot accepted it silently with no warning or
error, and quietly fell back to `GodotPhysics3D`. Every early result in this story that looked like "Jolt"
was actually GodotPhysics3D running twice, which produced suspiciously identical output before the mistake
was caught. If this setting is ever "corrected" back to something that looks more like a class name,
check it isn't reintroducing this exact bug — verify the actual enum via
`ProjectSettings.get_property_list()` rather than guessing the string.

## Why: Jolt resolves FO-019's jitter; GodotPhysics3D does not

FO-019 found that one block in FO-003's fallen chain never fully settles under GodotPhysics3D at gravity
98 — real residual velocity (~1 m/s), indefinitely, and not fixable by increasing damping or friction
(pushing those values higher made it *worse*, affecting more blocks, which pointed at a genuine solver
limitation rather than a tuning problem). This story existed partly to check whether Jolt — which Godot's
own docs specifically recommend for stacked/resting-body stability — fixes it.

**It does, completely, with the exact same scene, tuning, and gravity.**

| | GodotPhysics3D | Jolt Physics |
|---|---|---|
| All 15 blocks topple | Yes | Yes |
| Settles to full sleep | **No** — one block stays at ~1 m/s indefinitely (tested to 30s headless, ~27s on device, no decay) | **Yes** — full sleep within ~5 seconds |
| Determinism (3 repeated runs) | Bit-identical | Bit-identical |
| Mid-run physics time (headless, frame 120) | 0.317 ms | 0.402–0.666 ms (comparable; timing noise dominates at this trivial scale) |
| On-device physics time once settled (Pixel 9 Pro XL) | **~4 ms sustained**, barely decaying from 12s to 27s after launch | **~0.26 ms** — near zero, confirming genuine sleep |
| Tunneling / instability | None observed | None observed |

Both were tested identically: FO-003's chain, autostarted via the `--fo-autostart` flag already built
into the scene (no manual tap needed), on **Wouter's Pixel 9 Pro XL**, via `adb shell screencap`
screenshots and the on-screen perf overlay (`show_perf_overlay`, added in FO-007) for real device numbers —
not just headless simulation.

## Jolt's experimental status

Godot's docs describe the Jolt integration (available since 4.4) as experimental. Accepted here because:

- It directly solves a real, reproducible instability that GodotPhysics3D does not, in exactly the
  scenario (a chain of resting/leaning bodies) this entire game is built around.
- It's also Godot's own recommended engine for stacked-body stability and cylinder shapes — and cylinders
  are a planned block type (PRD §4.4), so this pays off twice.
- No instability, crash, or unexpected behavior was found in either headless or on-device testing.
- The alternative — shipping GodotPhysics3D with a chain that never fully settles — is a worse and better
  understood risk than Jolt's experimental label. A pile that never sleeps affects real gameplay systems
  later (settle detection, no-progress detection, run-end timing, PRD §4.9.2) in ways that are harder to
  work around than "an experimental physics backend that behaves correctly in every test so far."

**Revisit if:** a Jolt-specific bug surfaces in later stories (branching, the Ball/Cylinder blocks, or
larger active-body counts in FO-005). If Jolt ever needs reverting, GodotPhysics3D remains a fallback, but
the settle-time problem documented here would need its own fix (different tuning, a different chain
geometry, or accepting a no-progress-detection cutoff in the actual game logic rather than requiring true
sleep).

## Not retested from scratch

Jolt was tested using the **same damping/friction values FO-019 tuned for GodotPhysics3D**
(`friction = 2.0`, `linear_damp = 0.5`, `angular_damp = 2.0`). Jolt fully resolved the jitter with these
values as-is — no retuning was needed to get a clean settle. Whether different values would make Jolt
settle even faster, or feel different, is an open question for on-device *feel* testing later, not
something this measurement-driven story needed to answer.
