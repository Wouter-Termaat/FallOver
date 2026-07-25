# Fall Over — working instructions

Read this before doing anything. Then read `PRD.md`.

## What this is

**Fall Over** is a 3D mobile puzzle game about building domino chains. Each level is a small island. One domino
is already standing (the *starter*); somewhere on the island is a *finish*. The player buys blocks with coins,
places them to build an unbroken chain, presses Start, and watches it run.

- **Engine:** Godot 4.7.1, **GDScript** (standard build, not .NET)
- **Target:** Android phones, portrait. iOS deferred.
- **Owner:** Wouter Termaat. He makes all design decisions.

## The two documents

| File | What it holds |
|---|---|
| `PRD.md` | Every design decision. **The PRD wins any disagreement.** |
| `BACKLOG.md` | Numbered stories (`FO-000`…). Work one at a time. |

## How to work

1. **Read `PRD.md` first.** If a story seems to contradict it, stop and flag it — don't guess.
2. **One story at a time.** Do the story you were given and nothing else. A story that quietly does three other
   things can't be reviewed or reverted.
3. **Every acceptance criterion must be met.** If one can't be, say so. Never silently drop one.
4. **Never invent a design decision.** Anything in **PRD §16** is unresolved and is Wouter's call. If a story is
   blocked on one, **stop and ask.** Do not pick an answer and continue.
5. **Respect *Out of scope*** where a story lists it.
6. **Commit per story:** `FO-014: short description`.
7. **Check `BACKLOG.md` for execution order.** Several phases say *"execution order is not document order"* and
   give an explicit sequence. Follow it.

## Hard rules — breaking these breaks the game

**1. Gameplay logic never runs in `_process`.** Only `_physics_process`. The whole reliability promise (PRD
§13.1) depends on gameplay reading a fixed physics tick, never a render frame. Nothing may depend on frame delta.

**2. Never change the physics timestep to change speed.** Fast-forward runs *more ticks per frame*. Scaling the
timestep changes physics results, so a layout would pass at normal speed and fail fast-forwarded.

**3. Collision belongs to the slot, never to the art.** Obstacles are placed as *semantic slots* ("tall
obstacle"), and each world's theme kit maps slots to models. A slot has the same collision shape in every theme.
The moment collision comes from a mesh, swapping themes silently changes physics and every tuned level breaks.
(PRD §7.11)

**4. The camera is orthographic.** "Zoom" means changing orthographic size, never moving the camera closer.
Because orthographic gives no perspective depth cue, **shadows are how the player judges where a block sits** —
never weaken ground-contact shadows for a visual effect.

**5. Coins are never purchasable.** Not with diamonds, not with money, not by watching an ad, not ever. The
moment coins can be bought, no level can rely on its own constraint and the puzzle is dead. (PRD §5.1)

**6. No blocks on top of blocks.** Stacking is forbidden — it's the least stable configuration in any physics
engine. Verticality comes from terrain, ramps and long blocks used as bridges. (PRD §4.7)

**7. No analytics, no ad SDK, no IAP, no tracking** until a business model is decided. Leave seams, add nothing.

## Terminology — get these right

| Term | Meaning |
|---|---|
| **Coins** | The per-level budget. Resets every level. Never purchasable. Never called "money" or "wallet" in code. |
| **Diamonds** | The persistent app-wide currency. Buys cosmetics only. Never buys coins, blocks or capability. |
| **Stars** | Max 3 per level. 1 for finishing, 2 from leftover coins. |
| **Starter** | The pre-placed domino that gets pushed. Tagged `Start`. |
| **Finish** | The target that ends the level. Tagged `Victory`. |
| **Slot** | A semantic obstacle placeholder ("tall obstacle") that a theme maps to a model. |
| **Kit piece** | A modular island building block (flat plate, slope, cliff edge…). |
| **Plates** | **Cut from the design.** A reference to plates as a game feature is stale — delete it. (Exception: "turntables" in PRD §14 is an unrelated rotating-disc mechanic.) |

## Code conventions

- `snake_case` files and variables · `PascalCase` classes and nodes · `SCREAMING_CASE` constants
- **Static typing on every declaration:** `var speed: float = 0.0`
- **No magic numbers.** Anything tunable goes in an `@export` variable or a config resource, so it can be
  adjusted without editing code. This matters more than usual here — most of this game is feel, and feel is found
  by tweaking numbers on a real phone.
- **Use the brand palette** (PRD §8.4). Never invent a colour. Font is Roboto.
- Blocks and levels are **data, not code**. Adding a block type or a level must never require writing a script.

## Project layout

```
scenes/        .tscn scenes — test/ ui/ placement/ levels/ meta/ kit/
scripts/       .gd scripts — test/ data/ camera/ ui/ placement/ simulation/ save/ economy/ meta/ authoring/
resources/     blocks/ levels/ worlds/ kit/ slots/ themes/ achievements/
assets/        meshes, materials, audio
tests/         automated tests
docs/          decision records and setup guides
```

## Things that are decided — don't relitigate

Orthographic camera · portrait only · plain coloured blocks, no pips · miniature diorama scale · islands in
ocean · modular kit pieces, not freeform terrain · free continuous rotation via place-then-swipe-sideways · full
undo/redo · unlimited free retries that preserve the layout · no hints, no level skip · rolling level-reveal
window · English only at launch · no time tracking · no plates · no player character · skins after launch.

Reasoning for each is in `PRD.md`. **PRD §15** lists what was deliberately cut and whether it's reversible —
check there before proposing something that sounds like a good idea.

## Known risks worth remembering

- **FO-013 (placement) is the highest-risk story.** Continuous rotation on a touchscreen is hard to make feel
  good. No amount of correct code substitutes for iterating on a real phone.
- **The run camera is the biggest "feels cheap" risk** in the whole game.
- **There is no analytics**, so the only way to find out where players get stuck is manual playtesting.
- **Physics is chaotic.** A fraction of a degree at domino 1 is a hit-or-miss by domino 20. Every level ships
  with a recorded reference solution that passes with comfortable margin, and gets tested 200× headless.
