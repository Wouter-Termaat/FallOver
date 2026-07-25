# Fall Over — Product Requirements Document

**Version:** 0.15
**Last updated:** 2026-07-24
**Owner:** Wouter Termaat
**Status:** Pre-production. Items marked 🔓 are unresolved and are Wouter's call — see §16.

**Changes since v0.2:** **Plates cut entirely.** Stars are now 1 for finishing plus 2 from leftover
coins. Stars gate progression (1 to advance a level, cumulative totals for worlds and bonus levels).
**Diamonds are a real currency** with defined sources and sinks. Achievements defined across four
categories. Added undo/redo, mid-level resume, and haptics. Blocks cannot be stacked. **Skins deferred
past launch**, which changes the launch meta-screen set. **Level select now uses a rolling reveal
window** (§7.7) — this replaced one-at-a-time reveal after §5.3.1 showed the main route was otherwise a
hard wall for stuck players.

**Changes since v0.14:** Theming specified precisely (§7.11.1–7.11.3). **Terrain: same mesh, material swap
only** — five worlds of terrain for the price of one. **Obstacles: different mesh, fixed collision**, and a slot
is therefore a **volume budget** every theme's model must fill (§7.11.2) or chains stop short of things and look
broken. Unthemed levels render as grey-box, so Grass is a theme you assign rather than a fallback.

**Changes since v0.13:** **Run camera clarified** (§6.3): the game owns position and framing, the player owns
rotation — continuously, with no hand-off or resume timer. Rotation is free and unsnapped during a run; panning
and zooming are not available. Added §6.3.1: the camera frames the **aggregate of still-moving live bodies**, not
the newest one, which avoids jitter, backwards lurches and branch ping-pong.

**Changes since v0.12:** Added the **win moment** — the chest bursts open, then holds on the settled chain
before the win screen (§4.2.2). Rotation is taught by a **prompt on 1-1**, with the skipped-prompt risk recorded
and a cheap fallback noted (§7.8). **Sharing deferred with a reserved hook** (§5.11). No reduce-motion option —
the camera is expected to flow smoothly instead (§6.3).

**Changes since v0.11:** **Island shape rule added** (§7.9.1). Portrait plus eight fixed camera angles means
verticality, not sprawl, is how a level uses the screen. Worlds 1–2 are compact and fully visible; later worlds
may grow. Camera and tooling must handle both from the start.

**Changes since v0.10:** Art direction sharpened — **banded cel shading with real shadows kept** (§8.3.1),
**no outlines**, and **opaque water with a foam shoreline** (§8.3.2). Fully unshaded flat colour was rejected
because it breaks depth perception in orthographic. Foam needs depth-texture access, which links it to the
renderer choice (FO-007).

**Changes since v0.9:** Unit scale fixed at **1 unit = 10 cm**, and — critically — **gravity raised to 98**
to match (§4.4.1). Without this, blocks simulate as 4-metre objects and fall ~3× too slowly, which is what the
first FO-003 playtest reported. Must be done before FO-004 and FO-005 measure anything.

**Changes since v0.8:** **Fixed-inventory levels cut** (§4.6) — coins are the only constraint model. The same
puzzles are reachable by pricing blocks high or limiting which types a level offers.

**Changes since v0.7:** The finish is now **a chest**, won by any hit — but the hit must **trace back to the
starter** via a propagating *live* flag (§4.2, §4.2.1), which also gives break-point and failed-branch detection
for free. Fly-through always plays and is always skippable. Six obstacle slot types fixed (§7.11). The chest
partly resolves the colour-accessibility problem (§8.7).

**Changes since v0.6:** Four blocking interaction decisions resolved (§6.1): **auto edge-pan** while holding a
block, **deselect via palette toggle plus a cancel button**, and a **radial ring** for editing a placed block.
Kit piece list fixed at **six basics** (§7.10.1). Unblocks FO-012, FO-013, FO-014 and FO-030.

**Changes since v0.5:** **Rotation gesture decided** — place the block, then swipe sideways to spin it (§4.7).
The original Unity project is gone, so art starts from scratch: CSG placeholders now, purchased or modelled kit
later (§7.10.1, §8.6). Project folder is `C:\Privé\Fall Over`.

**Changes since v0.4:** **Level authoring system defined** (§7.10, §7.11) — islands assembled from modular
kit pieces; obstacles placed as **semantic slots** with per-theme model mappings; **collision belongs to the
slot, never the art**; theme comes from world assignment so levels can be reordered late; reference solutions
**recorded by playing**, not hand-authored; coin budgets and star thresholds auto-derived then overridden.
Authoring happens in the Godot editor now, with an in-game mode later. Added the ghost block spec (§6.1.1).
Terrain plugins rejected as the wrong tool for diorama-scale islands.

**Changes since v0.3:** Visual identity settled — **orthographic projection**, miniature diorama scale,
islands in ocean, plain coloured blocks, clean flat rounded playful UI (§8). Camera rotation snaps to 45°
on release. Added **fast-forward during the run**, **run-end rules**, lost-block handling, and a
**clear-all** button. App flow defined (§9). Levels are numbered, not named. Audio: one theme with
per-world variants, ducked during the run. English only at launch.

---

## 1. Vision

**Fall Over** is a 3D mobile puzzle game about building domino chains. Each level is a small island.
One domino is already standing — the *starter* — and somewhere on the island is a *finish*. The player
buys and places blocks to build an unbroken chain from starter to finish, then presses **Start** and
watches it run.

The fantasy is the satisfaction of a domino run you built yourself: the moment the chain disappears
behind a rock and you don't yet know whether it made it. The puzzle is doing it within the coins the
level gives you.

**One-line pitch:** Buy dominoes, build the chain, knock it over, don't run out of coins.

### 1.1 Design pillars

These decide every argument. If a feature doesn't serve one, cut it.

1. **The run is the payoff.** Everything before pressing Start is setup. The run must be watchable,
   legible and worth waiting for. The camera follows it like a camera operator.
2. **Failure is cheap and informative.** A failed run must instantly show *where* it broke and let the
   player fix that one thing. Never make the player rebuild what already worked.
3. **Elegance is the score.** Passing earns a star; passing with coins left earns the other two. A
   completed chain should look tidier than last time.

### 1.2 What this game is not

- Not a physics sandbox. There is always a goal and always a constraint.
- Not a timing or reflex game. No input during the run, and no clocks in normal play (§5.9).
- Not a real domino simulator. If realism fights readability, readability wins.
- **Not pay-to-win.** Coins are never purchasable. Diamonds never buy puzzle capability (§5.1).

---

## 2. Platform and technology

| Item | Decision |
|---|---|
| Engine | **Godot 4.7.1** (stable, released 2026-07-14) |
| Language | **GDScript** (standard Godot build, not .NET) |
| Primary target | **Android** — phones, portrait orientation |
| Secondary target | **iOS** — deferred; needs macOS + Xcode, access uncertain |
| Renderer | 🔓 Mobile or Forward+ — decide in Phase 0 on a real device |
| Min Android | 🔓 Propose API 24 (Android 7); confirm against audience |
| Source control | git — **must be moved out of OneDrive**, see §2.2 |

### 2.1 Orientation and aspect

Portrait only (the prototype ran 1080×1920). UI must survive 4:3 tablets through 20:9 tall phones,
and must respect notches and safe areas.

### 2.1.1 Language

**English only at launch.** The game is nearly text-free — levels are numbered rather than named (§7.7), and
the only real text lives in settings, achievements and the tutorial.

*Recommendation, not a decision:* route all displayed text through a translation table from the first commit
anyway. It costs a little discipline now and means adding a language later is filling in a spreadsheet rather
than hunting hardcoded strings through the codebase. Given how little text exists, this is close to free.

### 2.2 ⚠️ Infrastructure risk: OneDrive + git

This repository currently sits inside a OneDrive-synced folder, and **this has already caused two
failures** — commits aborted partway through when OneDrive locked git's internal files, leaving stale
`HEAD.lock` and `index.lock` files. This is the documented failure mode and it will recur.

**Action:** the project moves to **`C:\Privé\Fall Over`** — outside OneDrive — and pushes to a private
remote for backup. Tracked as story FO-000.

---

## 3. Core loop

```
Level loads  →  Opening fly-through shows the island (skippable)
             →  Player inspects island (camera free)
             →  Player selects a block type from the palette
             →  Player places / rotates / undoes / repositions blocks (coins decrease)
             →  (clear all and start over at any time)
             →  Player presses START
             →  Simulation runs, camera widens to fit the action, player may fast-forward
             →  Finish triggered?
                  YES → Level complete → 1 star + up to 2 from coins left
                                       → diamonds paid for new stars → next level
                  NO  → Failure shown at the break point → RESET to standing layout
                      → Player adjusts → START again (unlimited, free)
```

**Session length target:** 30 seconds to 3 minutes per level. Playable one-handed on a bus.

---

## 4. Game rules

### 4.1 The starter block

- Exactly one per level, pre-placed and immovable. Tagged `Start`.
- Visually distinct (prototype used green — see §8.7 on the colour-accessibility issue).
- On **Start** it receives a fixed impulse in a level-authored direction, and falls.
- The impulse is identical on every run and is never randomised.

### 4.2 The finish — a chest

- Exactly one per level. Tagged `Victory`.
- **It is a chest, not a domino.** Visually distinct in *shape* as well as colour, which matters — see §8.7.
- **The level is won the moment the chest is hit by anything that is part of the chain.** No tilt threshold, no
  "did it fall over" question. A hit is a hit. Simpler to build, and simpler for the player to read.
- Because it doesn't need to topple, the chest can be a **static body with a hit detector** rather than a rigid
  body — fewer moving parts and one less thing that can behave unpredictably.

#### 4.2.1 ⚠️ The hit must trace back to the starter

A hit only counts if it came from a chain that began with the starter. Without this rule, two things would win
the level by accident:

- a block placed so it already rests against the chest
- a block that topples on its own while the layout settles, before anything is pushed

**Implementation:** propagate a *live* flag. The starter becomes live when it receives its impulse (§4.1). Any
live body that strikes another body above a force threshold makes that body live too. The chest only accepts a
hit from a live body.

This is cheap to build and it is what makes the puzzle honest. It also gives failure feedback a useful signal for
free: the set of live bodies at the end of a run *is* the chain that actually happened, so the last live block is
the break point (§4.10), and with branching (§4.3) it identifies which branch stalled.

🔓 The force threshold for propagating *live*. Too low and a settling wobble spreads it; too high and a gentle but
genuine link in the chain is ignored. Tune on device (§16 #38).

#### 4.2.2 The win moment

**The chest bursts open.** Lid flies up, light or coins spill out, a satisfying sound.

This is the payoff of everything the player built, and it is the cheapest possible way to make finishing feel
good — a few seconds of animation for the emotional peak of the whole loop. Pillar 1 says the run is the payoff;
this is its final beat.

Sequenced: chest is hit → chest opens → **brief hold on the settled chain** so the player can see what they
built → win screen. Don't cut straight to UI over the top of the moment.

### 4.3 Chains and branching

**There is always one main chain from starter to finish.** The win condition is simply: was the finish
triggered.

Later levels add **enabling branches**. A branch is a side chain whose job is to make the main chain
possible — knock a switch to open a gate the main chain must pass through, drop a bridge, release a
ball. Branches are *prerequisites*, not parallel goals. The player still gets one push; the chain
splits to do the extra work.

Consequences:

- Win detection stays a single check on the finish. No dependency graph is needed for scoring.
- Level design becomes far richer: one impulse, several jobs, ordering that matters.
- **The run camera must handle multiple simultaneous fronts** — see §6.3.
- Failure feedback must identify *which* branch broke, not just that the run failed.

Early worlds are single-chain. Branching is introduced once the basics are taught.

### 4.4 Block catalogue

From the *Project Overview* spreadsheet. Costs in **coins**. Dimensions **H × L × D**, weights relative.

| Block | Cost | Dimensions | Weight | Behaviour | Status |
|---|---|---|---|---|---|
| Standard Block | 1 | 4 × 2 × 0.5 | 1.0 | Falls over | Confirmed |
| Long Block | 3 | 6 × 2 × 0.5 | 1.5 | Falls over; reaches further, bridges gaps, works as a ramp | Confirmed |
| Ball Block | 5 | 5 × 5 | 2.0 | Rolls with drag | Planned |
| Cylinder | 4 | 4 × 2 × 2 | 2.0 | Rolls with drag, single axis | Planned |
| Turnaround | 5 | 3 × 6 × 0.5 | 4.0 | Swings to reverse chain direction | Candidate |
| Slow Block | 2 | 4 × 2 × 0.5 | 2.0 | Falls slowly to delay the chain | Candidate |
| Heavy Block | 3 | 4 × 2 × 0.5 | 3.0 | More impact force | Candidate |
| Bridge | 🔓 | 0.5 × 5 × 2 | 2.0 | Spans large gaps. Must cost more than solving the same gap with normal blocks, or it trivialises them | Candidate |
| Rope | 🔓 | — | — | Connects blocks to each other or to the environment | Candidate |
| Fragile / glass block | 🔓 | — | — | Lightweight, can break | Candidate |

#### 4.4.1 Unit scale and gravity

**1 Godot unit = 10 cm.** A Standard Block is authored as 4 × 2 × 0.5 units, understood as 40 × 20 × 5 cm —
chunky, oversized dominoes suiting the diorama look (§8.1), and comfortably inside the range Godot's solver is
tuned for. Recorded in `docs/unit-scale.md`.

**⚠️ Gravity must be scaled to match: `physics/3d/default_gravity` = 98, not 9.8.**

This is not optional polish, and the reason is easy to get wrong. Godot applies gravity as though 1 unit = 1
metre, regardless of what we *say* a unit means. So a block authored 4 units tall physically behaves like a
**4-metre** domino. Toppling time scales with the square root of height, so it falls about **3× too slowly** —
which is exactly what Wouter's first playtest of FO-003 reported as "a bit slow".

Calling the unit 10 cm is a *labelling* convention; it changes nothing in the simulation. The fix is to scale
gravity by the same factor as the size exaggeration: 10× bigger blocks need 10× stronger gravity to fall at the
rate the eye expects. Same principle as filming a model and speeding the footage up.

Consequences to respect:

- **Impact speeds rise ~3×**, so the solver has less time per tick to resolve contacts. 60 ticks/second may no
  longer be enough — this needs a stability retest, not just a settings change (§13.1).
- **Damping values tuned before this change are invalid** and must be re-found.
- **This must be settled before FO-004 and FO-005**, which measure backend stability and the active-body ceiling.
  Measuring at the wrong gravity produces numbers that have to be thrown away.

**⚠️ Two things need resolving before any of this is built:**

- ~~**Units and scale**~~ — **RESOLVED**, see §4.4.1 above. (Original note retained for context: "4 × 2 × 0.5" has no unit.) A real domino is roughly 45 × 24 × 7 mm, so the
  ratios are plausible but the scale is undefined. Godot's physics is tuned for **1 unit = 1 metre**,
  and rigid bodies behave badly at very small scales. Recommendation: treat 1 unit ≈ 10 cm, making a
  standard block 40 × 20 × 5 cm — chunky, oversized dominoes, which suits the stylised look and keeps
  physics stable. Needs confirming; every level's geometry depends on it.
- 🔓 **"Standard Block 1"** appeared as a third palette button in prototype video 2. Variant, or naming
  artefact?

**Not blocks — placement tools.** The spreadsheet lists these among block types, but they are tools:
*Measuring tape*, *Line of blocks*, *Building blocks* (stairs/ramps), *drawing tools*. All deferred
(§4.8). 🔓 *Skateboard*, *coin* and *bottle* also appear with no description — blocks, obstacles or
props?

**Every block is defined by data, not code** (§13.3). Adding a type must never require a script.

### 4.5 Block unlocks

- Reaching a world **permanently unlocks** the block types it introduces. Unlocked types persist
  globally in save data.
- **Each level still specifies which of the unlocked types it offers.** The designer keeps full
  control of every puzzle's palette.

This gives the player a sense of accumulation while keeping levels authorable. A level never has to
account for what the player might or might not have. **Block types are never purchasable** (§5.1).

### 4.6 Coins — the level constraint

**Coins are the per-level budget.** They are not a persistent currency, they reset every level, and
**they are never purchasable with diamonds or real money.** This is deliberate: the moment coins can
be bought, no level can rely on its own constraint, and the puzzle is dead.

- Each level authors a coin amount (prototype: `Wallet: 20`).
- Each block type has a coin price (§4.4).
- Placing a block spends its price; removing or undoing it refunds in full.
- There is **no penalty for changing your mind** during the build phase — Pillar 2.

**Coins are the only constraint model.** The "fixed inventory" idea — handing the player exact counts instead of
coins — is **cut**. Every level gives coins, and stars always work the same way: one for finishing, two from
coins left over (§5.2).

This loses nothing, because the same puzzles are reachable through the coin system:

- **Want a tight toolbox?** Offer only certain block types in that level (§4.5).
- **Want a specific piece to feel precious?** Price it high.
- **Want to force efficiency?** Set a tight coin budget.

One system to build, one to balance, one to explain. Two scoring models would have been the alternative, and the
second one never scored cleanly anyway.

### 4.7 Placement

- **Free positioning** anywhere valid on the island.
- **A light positional grid assists alignment** — fine enough not to feel restrictive, not drawn on
  screen. Size tuned on device.
- **Free, continuous rotation. No snapping.** Deliberate: choosing the angle is a skill the game tests.
- **Blocks cannot be stacked on other blocks.** Every block sits on terrain. Verticality comes from
  the island itself, from ramps, and from long blocks used as bridges.

  *Reasoning, recorded so it isn't relitigated:* stacked rigid bodies are the least stable
  configuration in any physics engine, and stacking is exactly where reliability problems appear. Since
  §13.1 commits to reliable simulation as a core promise, free stacking works against the game's
  foundations. If verticality later feels lacking, the safer route is purpose-built platform pieces
  (the spreadsheet's "Building blocks") whose physics can be made predictable.
- Blocks may be moved, rotated and removed after placement, with a full refund.
- **Full undo/redo history** for the build phase (§4.8).
- Invalid placements (overlapping, off-island, in water, on another block) are rejected with clear
  feedback and **never** silently cost coins.

**No placement aid.** The game shows no reach indicator, no predicted fall arc, no facing arrow. Spacing is
judged purely by eye, exactly as with real dominoes.

*Risk to watch, recorded because it's a real one:* on a small screen, with free rotation and no perspective
depth cue (§8.1), misjudged spacing may read as the game being imprecise rather than the player being
imprecise. Two things mitigate it — the ghost block shows the exact footprint before committing (§6.1.1), and
shadows give a strong ground contact cue (§8.1). If playtesting shows players blaming the game rather than
themselves, a reach indicator is a small addition. Watch for it; don't pre-build it.

**The rotation gesture: place first, then swipe sideways to spin.** Placement is two steps rather than one:

1. **Position.** Drag or tap to put the block down. The ghost (§6.1.1) follows the finger; release commits.
2. **Rotate.** The block stays selected after landing. A **horizontal swipe spins it** — continuous, no
   snapping. Swipe further to turn further.
3. **Finish.** The block deselects and its angle is locked in.

Why this works: positioning and rotating never compete for the same gesture, so there is no ambiguity to
detect and nothing to get wrong. It is also more forgiving — the player sees the block sitting in place at real
size before deciding its angle, rather than judging both at once.

🔓 **Two details still to settle (§16 #6):**

- **How much rotation per swipe distance.** A full screen-width swipe should turn the block a sensible amount —
  probably around 180°, so any angle is reachable in one or two swipes without feeling twitchy. Tune on device;
  it must be exported, never hardcoded.
- **How the player finishes.** Candidates: tap empty ground; pick the next block from the palette; or an
  explicit confirm button. Recommendation: **tapping empty ground or picking the next block both finish it**,
  with no confirm button — the common case is placing several blocks in a row, and a confirm tap on every one
  would be exhausting.

### 4.8 Undo and redo

- **Full undo/redo history** across the whole build phase, not just one step back.
- Undo reverses placements, moves, rotations and sells, refunding or re-charging coins correctly.
- **History is cleared when the run starts, and cleared when the level is exited.** It is deliberately
  **not** persisted across a mid-build save/resume (§4.11) — serialising a command history buys little
  and risks corrupting a resumed level. The player resumes with their layout intact and an empty history.
- The player can therefore try an entire alternative layout and step back out of it — which matters
  because there is no hint system (§7.9) and experimentation is the only way forward.

**Deferred placement tools** (the spreadsheet's "drawing tools" idea — a good one, not for v1): draw a
path and auto-fill dominoes at a chosen spacing; pre-built line of blocks; saved reusable
combinations; copy/paste/mirror; measuring tape.

### 4.9 The run

- **Start** freezes the build UI and begins the simulation.
- **No player input affects the simulation.** The player watches, may move the camera, and may
  fast-forward.
- The player may abort early and reset.

#### 4.9.1 Fast-forward

A fast-forward control is available during the run, so a player on their twentieth retry needn't re-watch
the half they already know works.

⚠️ **Implementation constraint, not a preference.** Fast-forward must be done by **running more physics
ticks per rendered frame**, never by scaling the timestep or changing `physics_ticks_per_second`. Scaling
the timestep changes the physics result — the same layout would pass at normal speed and fail fast-forwarded,
which would destroy the reliability promise in §13.1. The tick rate is fixed; only how many ticks we run per
frame changes.

Note the interaction with §13.1 item 2: fast-forward deliberately does the same thing a slow device does
accidentally. Test both.

#### 4.9.2 How a run ends

Three mechanisms, in order of what the player actually experiences:

1. **Drag.** Blocks and balls have damping tuned so motion decays and things come to rest naturally. This
   is the primary tool and it's a feel decision as much as a technical one — it makes runs end on their own.
2. **Settle detection.** The run ends when nothing has exceeded a small velocity threshold for N
   consecutive physics ticks.
3. **No-progress detection.** The run also ends when **nothing new has been disturbed for ~3 seconds**,
   even if something is still moving. This exists because a stray ball circling a dip will never come to
   rest and will never hit anything again — without this rule the player waits on a screen where nothing
   is happening.

Thresholds and durations are all exported and tunable.

**⚠️ Accepted risk: no maximum run duration.** A hard time ceiling was considered and declined. The
consequence: if some unforeseen physics case keeps disturbing new objects indefinitely, the run never ends
and the game appears frozen. Judged unlikely given drag plus the two detection rules — and if it ever
happens, a maximum duration is a handful of lines to add. Recorded so it's a known choice, not a surprise.

### 4.10 Failure and retry

- Retries are **unlimited and free**. They never cost coins, stars or diamonds.
- On reset, **every player-placed block returns to exactly the position and rotation the player gave
  it.** The layout survives; only physics state is discarded.
- Failure feedback must make the break point obvious — highlight the last block that fell, rest the
  camera there, and with branching, identify *which* branch stalled.
- **Blocks that fall into the water or off the island are lost for that run, and restored on reset.** They
  sink or drop away *visibly* — a chain that ends in the sea should feel like a failure, not silently
  vanish. No coin consequence ever: the layout is always restored intact, so a block lost to the ocean
  costs nothing but the attempt.
- 🔓 Offer a replay or slow-motion review of the last run? Strongly serves Pillar 2, and more valuable
  once branching exists because the player may have been watching the wrong place. Not required for v1.

### 4.11 Leaving a level mid-build

**A half-built layout is saved and resumed exactly as left.** A phone call must never cost the player
ten minutes of work — this is a mobile game played in short bursts, and losing progress to an
interruption is the fastest route to an uninstall.

- The in-progress layout and coins spent are persisted per level. **Undo history is not** — see §4.8.
- Returning to the level restores it and skips the fly-through (§6.4).
- A completed level reopens showing the layout that won it, so the player can try to improve their
  stars from where they left off.

### 4.12 Clear all

A **clear-all** control wipes every placed block and refunds all coins, returning the level to its starting
state without replaying the fly-through.

- **Requires confirmation.** Undoing an accidental clear-all is technically possible via undo history, but a
  player who taps it by mistake and sees thirty blocks vanish will not think to look for undo.
- Distinct from *reset after a run* (§4.10), which preserves the layout. Clear-all deliberately destroys it.
- Exists because undoing thirty placements one at a time is not a reasonable way to try a different approach.

---

## 5. Rewards and economy

### 5.1 The one rule

**Puzzle capability is never for sale.** Coins are a level constraint, not a wallet. Block types come
from progression, not purchase. Diamonds buy cosmetics and convenience, never capability.

Specifically and permanently ruled out: buying coins, buying blocks, buying budget top-ups, buying
solutions. Any future monetisation proposal that touches these breaks the design (§13.5).

### 5.2 Stars

Maximum **3 per level**:

| Star | Earned by |
|---|---|
| 1st | **Finishing the level.** Guaranteed on any win. |
| 2nd | Coins left over above the level's authored second threshold |
| 3rd | Coins left over above the level's authored third threshold |

- Thresholds are **authored per level**, never computed by formula — a formula is always wrong for the
  interesting levels.
- Best rating persists and **never decreases** on replay.
- Replaying to improve stars is encouraged and is the intended response to being short of a world gate
  (§7.4).

Note the deliberate consequence: **the first star carries no information about skill**, only about
completion. That's the price of guaranteeing every player something, and it's why the world gate uses
cumulative totals rather than "1 star" as a meaningful bar.

### 5.3 Star gating

Stars gate progression at three points:

| Gate | Requirement |
|---|---|
| Next level | **1 star** — i.e. finishing the previous level |
| Next world | A **cumulative star total** across the current world |
| Bonus levels | A **cumulative star total**, or diamonds to unlock early (§5.4) |

The level-to-level gate is satisfied by finishing, so it adds no requirement beyond completing the
level. The cumulative gates give a player short of the next *world* something productive to do: replay
an earlier level more efficiently.

### 5.3.1 Why a rolling reveal window is load-bearing

An earlier draft of this document claimed cumulative gating protected stuck players. **It didn't.** "1
star to advance" means *finishing*, so if levels were revealed strictly one at a time, a player who
couldn't finish level 7 could never reach level 8 by any route — replaying levels 1–6 earns stars toward
the *world* gate only. The main path would have been a hard wall.

**The fix is §7.7's rolling reveal window**, and it is why the design now holds together:

- Several levels are visible ahead of the player's progress, not just one.
- A player stuck on level 7 plays 8 or 9 instead, and comes back later with fresh eyes.
- Those levels still award stars, so the detour is *productive* — it counts toward the world gate.
- The world gate then does the job it was meant to: it eventually requires going back and cleaning up
  what you skipped, but only at a world boundary, never mid-flow.

**These three decisions are load-bearing for each other: the reveal window, cumulative world gating, and
no hints (§7.9).** Change any one and the other two need re-examining. In particular, **narrowing the
reveal window to one level reinstates the hard wall** and would require adding hints or a skip.

🔓 The actual cumulative thresholds per world. Cannot be set until levels exist and their difficulty is
known.

### 5.4 Diamonds

The persistent, app-wide currency.

**Earned from:**

- **Stars** — each star pays diamonds the first time it is earned. Re-earning the same star pays
  nothing; improving from 1 star to 3 pays for the two new ones.
- **Achievements** — chunky one-off payouts (§5.7).

**Spent on:**

- **Block skins** (§5.6) — cosmetic only
- **Unlocking bonus levels early**, bypassing the star requirement (§7.5)

**Never spent on:** coins, blocks, budget, hints, or anything affecting whether a puzzle can be solved.

🔓 Payout and price figures. These cannot be balanced until the game is playable and it's possible to
feel how rewarding progress is. The *rules* above are settled; the *numbers* are not.

### 5.5 ⚠️ Accepted risk: diamonds ship before anything to spend them on

Skins are deferred past launch (§5.6) and bonus levels are post-launch (§7.5). **At launch, diamonds
are earned and displayed but cannot be spent.** The decision is to show them anyway, with a shop
marked as coming soon.

The risk, recorded so it's a choice rather than an oversight: an empty shop is one of the clearest
signals of an unfinished game, and reviews single it out.

**Mitigation.** An empty grid labelled "coming soon" is the worst version of this. Better, in order of
preference given that skin *art* won't exist at launch (§8.3 forbids art before mechanics are proven):

1. **A named roadmap, no art.** List the skin sets that are coming — "Dark Mode", "Beach", "Halloween" —
   as text with a lock icon and no price. The player knows what they're saving for, and it costs nothing
   but a list. Prices stay absent because they're unset (🔓 §16 #25).
2. **Show the balance only**, with a one-line note that skins are coming in a free update, and no shop
   screen at all.
3. Anything that renders as an empty shelf.

Prefer 1. Prefer 2 over 3. **Do not build a shop that shows priced items**, because prices cannot be set
until the diamond economy is balanced against real play (§5.4), and a price shown then changed is worse
than no price.

### 5.6 Skins — deferred past launch

**No skins at launch.** Base game and mechanics first. Skins arrive in the first content update, along
with the shop that spends diamonds on them.

When they arrive:

- Skins restyle the **blocks**, as coordinated themed sets — selecting the Cowboy set restyles every
  block type at once.
- **There is no player character.** The spreadsheet's "Player" column is not being pursued.
- From the spreadsheet: Default, Dark Mode, All White, single-colour sets (red / green / blue /
  yellow), 50 Shades of Grey, Beach, Halloween, Flags of the World, plus themed sets — Lumberjack,
  Cowboy, Miner, Knight, Princess, Wizard, Diver, Astronaut, Fisherman, Pirate.
- One spreadsheet entry, "Indian", is **deliberately dropped** — a national or ethnic costume as a
  purchasable cosmetic risks reading as caricature, and store review is increasingly alert to it.
  Recorded rather than silently omitted; say so if you disagree. "Flags of the World" covers similar
  ground without depicting people.

### 5.7 Achievements

Named goals with diamond rewards, browsable in their own screen with visible progress. **All four
categories are in:**

| Category | Examples | Notes |
|---|---|---|
| **Milestone counters** | Place 100 blocks · complete 10 levels · earn 20 stars | Cheapest to build — the numbers are already in save data. Pay out steadily just for playing. |
| **Mastery challenges** | 3-star a whole world · clear a level using only standard blocks · win without selling | Reward skill, drive replay. Important when launch has only 20 levels. |
| **Discovery** | Knock over an optional prop · trigger something unexpected · find a hidden spot | Reward curiosity rather than optimisation, and give optional island props a reason to exist. Also the natural home for ideas from §14. |
| **Collection** | Unlock every block type · own 5 skins · finish every bonus level | Tie the meta systems together. Pay out late, and the skin-related ones only once skins ship. |

🔓 The specific achievement list and diamond values. Discovery achievements in particular can only be
written once levels contain things to discover.

### 5.8 Plates — cut

v0.2 specified a themed plate per level as a completion trophy, with its own collection screen.
**Cut entirely.** Stars now carry both completion and performance, so plates said the same thing twice.
Removed from save data, the level definition, and the meta screens.

Recorded here only so the cut is explicit — if you see a plate reference anywhere in the codebase or
docs, it's stale and should be deleted.

### 5.9 No time tracking

The original save structure tracked run time for highscores. **Cut.** Thinking time is the point of a
puzzle game, and a visible clock makes players rush and feel judged.

Precisely what is cut: **no timing of the player's performance.** No per-level timers, no time shown
during play, no speed scoring, no time-based leaderboards, no run time stored per level.

What remains, and why it isn't a contradiction: **total play time** as an aggregate lifetime stat
(§11). Never shown during a level, never compared, never scored — the same category as "total blocks
placed". If it ever creates pressure, cut it too.

🔓 Time attack as a **bonus level** mode (§7.5) is the one place a clock could be permitted, since it's
opt-in and clearly separate. Flagged rather than assumed — the decision was a flat cut, so confirm
before any bonus level uses a timer.

### 5.10 Daily rewards — deferred

No daily login bonus, streak or return incentive at launch. Revisit after launch if retention data
shows a problem. Worth noting the tension if it's ever added: a daily payout rewards *opening the app*,
which sits oddly beside a currency otherwise earned through skill.

---

### 5.11 Sharing — deferred, hook reserved

A finished domino chain is inherently shareable, and with **no ads and no analytics** (§12, §13.5), word of mouth
is the only growth lever this game has. So sharing matters more here than it would elsewhere.

**Not built for launch.** The win screen reserves a disabled slot for a share button (§13.5) so adding it later
is a feature, not a redesign.

When built, the cheap version is a **screenshot of the settled chain** through the phone's normal share sheet —
no servers, no accounts, no infrastructure. A video clip of the run would be far more compelling, since domino
chains are made for video, but screen recording on Android is real work. Screenshot first.

---

## 6. Camera and controls

### 6.1 Control scheme — selection-driven modality

| State | Touch input does |
|---|---|
| **A block type is selected in the palette** | Placement: position and rotate the new block |
| **An already-placed block is selected** | Edit that block: move, rotate, sell |
| **Nothing selected** | Camera: rotate, pan, pinch-zoom |

There is no mode button. **The current selection is the mode.**

The third state exists so the player can fix a block they already placed (Pillar 2). Tapping a placed
block while nothing else is selected picks it up; tapping empty ground releases it back to camera
control.

**Edge cases to resolve before placement is built:**

**Panning while a block is selected: auto edge-pan.** Dragging a held block toward a screen edge scrolls the
view in that direction, the way dragging a file to the edge of a window does. This preserves the single clean
rule above — while a block is held, *all* input is placement — and adds no gesture to learn. Edge threshold and
scroll speed exported and tunable.

**Deselecting: two ways, deliberately.** Tapping the active palette button again releases the block, *and* a
small cancel button appears while a block is held. The redundancy is the point: toggle-off alone is
undiscoverable, and a mobile player who can't work out how to back out doesn't experiment, they quit.

**Editing a placed block: a radial ring.** Tapping a placed block shows three icons around it — move, rotate,
sell. Chosen over a bottom bar so the player's eyes stay on the block being edited, and over pure gestures
because "drag it into the sea to sell" is not discoverable.

#### 6.1.1 The ghost block

While a block type is selected, a **ghost** — a translucent preview of the block at full size — follows the
player's finger across the terrain, showing exactly where and at what angle the block will land before they
commit.

- Position comes from a raycast from the camera to the terrain surface.
- The ghost shows the block's **exact footprint**, not an approximation. This is the player's only
  spacing aid, since there is no reach indicator (§4.7).
- The ghost casts a shadow, or shows an explicit ground marker. In orthographic projection there is no
  perspective depth cue (§8.1), so without this the player cannot tell where the block will actually sit.
- Invalid positions tint the ghost Light Red and cannot be committed (§4.7).
- Placement commits on release; the selected block type stays selected so several can be placed in a row.

### 6.2 Build-phase camera

**Projection is orthographic** (§8.1). "Zoom" therefore means changing the orthographic size, not moving the
camera closer — worth stating because it behaves differently and the two are easy to conflate in code.

| Gesture | Action |
|---|---|
| One-finger drag | Orbit — free while dragging, **snaps to the nearest 45° on release** |
| Two-finger drag | Pan |
| Two-finger pinch | Zoom (orthographic size) |

**Rotation snapping.** The player orbits freely while their finger is down, then the camera settles to the
nearest 45° increment when they let go. This gives eight viewing angles, all of which the art can be designed
to look good from — which matters in orthographic, where an off-axis angle looks like a mistake rather than a
choice. The settle must be eased, not snapped; a jerky settle will feel broken.

Constrained so the player cannot go under the terrain or leave the island's bounds. Smoothed and damped. All
sensitivities, snap increments and easing values exported and tunable.

### 6.3 Run-phase camera

**The camera decides where to look. The player decides which side to look from.** That split is the whole design,
and it removes any need to arbitrate between them.

| Aspect | Owned by |
|---|---|
| **Position and framing** | The game — always automatic, never player-controlled during a run |
| **Rotation (which side you watch from)** | The player — always, freely, at any moment |

There is **no hand-off and no resume timer.** The player is never "taking over" the camera and the game is never
waiting to take it back. They control different things, continuously. Do nothing and the run plays out from
whatever angle you were already on.

- **Rotation is free and unsnapped during a run.** Unlike the build phase (§6.2), it does not settle to 45°
  increments — the player is following motion, not judging placement, and may want to peek round a rock at any
  angle.
- **Panning and zooming are not available during a run.** The framing is the game's job; letting the player fight
  it is how cameras end up feeling broken.
- The run starts at whatever angle the build phase ended on. No reorientation, ever — re-aiming the camera
  mid-collapse would be disorienting.

#### 6.3.1 How the camera picks its target

**It follows the aggregate of live bodies that are still moving, not a single block.**

Each physics tick: collect the bodies carrying the *live* flag (§4.2.1) whose velocity is above a threshold,
compute the bounding box that contains them, aim at its centre, and size the orthographic view to fit. Damp both
position and size so the camera eases rather than snaps.

**Only moving bodies count.** Including settled ones drags the camera backwards toward the start of the chain as
the fallen tail accumulates behind the action.

*Why not simply chase the newest live block* — which is what the Unity prototype did, and the obvious first
instinct:

- Several blocks often go live in the same physics tick, so the camera flicks between them
- A domino sometimes knocks something *behind* it, lurching the camera backwards
- With branching (§4.3), two simultaneous fronts make it ping-pong — the nauseating case
- The interesting thing is a *region*, the front of the collapse, not a point

Framing a box solves all four without special-casing any of them: simultaneous activations just widen the box, a
backwards knock barely moves its centre, and two branches are simply a bigger box.

Two guards, because naive fit-to-box ruins the shot:

- **A maximum orthographic size clamp.** Never widen so far that blocks become unreadable specks. If the action
  genuinely cannot fit, prioritise the main chain.
- **Only widen when needed.** A single-chain run keeps the tight, exciting framing. Widening happens only with
  genuinely multiple active fronts.

Motion must be smooth and predictable. **This camera is the single biggest "feels cheap" risk in the game** and
deserves more iteration than any other system.

**No reduce-motion option.** Declined on the grounds that the camera should flow smoothly enough not to need one.
That puts the burden on the camera itself: if the motion is slow and eased nobody needs a toggle, and if it snaps
or whips a toggle wouldn't have saved it. Note that the player controlling rotation helps here — they're never
being spun around against their will. Revisit only if a playtester reports discomfort, and note there is no
analytics to surface that, so it would have to come up in person (§12).

### 6.4 Opening fly-through

Every level opens with a **short camera sweep of the island** before handing control over. Functional,
not decorative: it shows the player the starter, the finish and the obstacles before they build.

- Authored per level via two camera positions and a duration. **In orthographic, each position also carries
  an orthographic size**, interpolated along with the transform — otherwise the sweep can't push in or pull
  out, only slide.
- **Must be skippable with one tap** — by the fifth retry it becomes an irritation.
- **Skipped automatically when resuming a level in progress** (§4.11).
- **Not auto-skipped on completed levels** — it plays every time and is always one tap away from being skipped.
  Consistent behaviour, one less rule. If the tap becomes annoying over twenty levels, revisit.

### 6.5 Haptics

**Subtle vibration on impacts and UI.** Scaled by impact force, like the audio (§10) — a big collapse
feels different from a single tap.

Cheap to build and a disproportionate return: it makes the chain feel physical in the player's hand.
Requires a settings toggle, since some players dislike vibration and it costs battery.

---

## 7. Progression and content

### 7.1 Structure

- **One island = one level.** Small, self-contained, purpose-built.
- **Islands are grouped into themed worlds**, ten levels each.
- Each world must **introduce exactly one new idea** — a block type, an obstacle, or a terrain trick. A
  world that introduces nothing is filler and should be cut or merged.
- Difficulty ramps within a world and resets slightly at the start of the next.

### 7.2 World themes

**Core worlds**, in order: Grass/Generic → Sand/Desert → Snow/Mountains → Jungle/Rivers → Volcano/Lava.

**Bonus themes** (eleven, post-launch, §7.5): Space, Wild West, Knights & Castles, Beach, Cave,
Playground, Sports/Olympics, Lo-Fi Neon City, Mini, Japanese Garden, Mexico.

### 7.3 Launch scope

**2 worlds, 20 levels: Grass and Desert.** Enough to prove the game is good and get real player
feedback; small enough that a design change doesn't mean re-authoring fifty levels. Further worlds ship
as free updates, which also gives players a reason to return.

**Mechanics introduced across worlds 1–2:**

1. Gaps and holes to bridge — teaches that block choice matters
2. Stairs, ramps and height changes — teaches thinking in 3D rather than flat lines
3. Obstacles to route around — turns a straight line into a routing decision
4. Slopes for balls to roll down — introduces the Ball block and rolling as a distinct motion

🔓 How these four distribute across the two worlds, and where branching is introduced (world 2 or 3).

The spreadsheet's Levels sheet already sketched world 1's teaching order: block placement and rotation
plus camera control → stairs and tight spaces → environment colliders → falling blocks. A sound ramp
and a good starting point for the twenty-level plan.

### 7.4 What a stuck player does

Short of a **world gate**: replay earlier levels more efficiently to earn the missing stars.

Stuck on a **level**: **play the next one instead.** The reveal window (§7.7) keeps several levels open at
any time, so a blockage is a detour rather than a stop. Stars earned ahead count toward the world gate just
the same, so the detour is productive. Come back to the hard one later.

Also available throughout: unlimited free retries (§4.10) and full undo/redo to experiment at no cost
(§4.8).

### 7.5 Bonus levels — post-launch

Optional levels off the main progression route, one or more per world. Unlocked by a cumulative star
total, or early with diamonds (§5.4). Each uses an **alternate rule**: one block type only, a
minimum-blocks challenge, or possibly time attack (🔓 §5.9). This is where the eleven bonus themes live.

### 7.6 World map

- A single overview of all worlds, styled after a stylised nations map.
- **Initially covered by clouds**, revealing worlds as they're reached.
- Each world's theme visible on the map.
- Tapping a world opens its ten-level route.
- Shows cumulative star progress toward the next world gate — the player must be able to see how far
  off they are, or the gate feels arbitrary.

### 7.7 Level select and the rolling reveal window

- Ten levels per world, shown as small islands **numbered 1–10** — no level names. Numbers only means zero
  authoring overhead and nothing to translate; the trade-off is that levels have less individual character
  and are harder to refer to in conversation.
- Joined by a **dotted line** route.
- **Levels ahead are revealed in a rolling window, not one at a time.** Default: everything up to
  *(highest level completed + 3)* is visible and playable. So finishing level 1 reveals 2, 3 and 4.
- **Levels may be played out of order.** A player stuck on 7 can play 8 and 9, and return to 7 later.
  Skipped levels stay available and their stars stay unearned.
- This is the game's only safety net for stuck players, and it is why no hint system is needed — see
  §5.3.1 and §7.9. **Do not narrow this window without revisiting those.**
- Each node shows stars earned (0–3), so the player can see where improvement is available.
- Bonus level entrances appear separately, off the main route, with their star requirement shown.

🔓 The window size. Three is a starting guess. Larger is more forgiving but weakens the difficulty ramp;
smaller tightens pacing but risks the wall returning. Tune once real levels exist.

🔓 Edge case: a player stuck on three *consecutive* levels is blocked again. Options if this shows up in
playtesting: widen the window, or count *completed levels* rather than *highest completed* so any progress
slides the window forward. Note it now, decide it on evidence.

### 7.8 Tutorial

**Level 1-1 is a guided walkthrough with explicit prompts** — tap here, drag here, press Start. It must
be **near-impossible to fail**: flat ground, a straight line, generous coins, and no obstacle. It teaches
placement and nothing else.

After that, level design does the teaching: each new idea arrives in a level constrained enough that the
new thing is the obvious move.

**The rotation gesture is taught by a prompt on level 1-1.** "Place the block, then swipe sideways to spin it" —
shown once, as text or an animated finger.

⚠️ **Recorded risk:** players skip prompts. Place-then-swipe is not a gesture anyone will discover unaided, there
is no hint system (§7.9), and there is no analytics (§12) to reveal that someone never worked out how to rotate.
A player who misses this prompt is stuck on the game's core verb with no way to recover.

Cheap insurance if playtesting shows it happening: make an early level *require* rotation to complete — put the
chest off to one side so a straight line cannot reach it. Teaching by necessity survives a skipped prompt.
Flagged rather than built (§16 #40).

🔓 Do later new mechanics (the Ball block, the Turnaround, branching, undo) get a short first-time prompt too, or
does level design carry them alone?

### 7.9 No hints, no skip — and why that's now safe

**Decision: no hint system and no level skip.** Players work it out.

An earlier draft justified this with cumulative star gating, which was wrong (§5.3.1). The correct
justification is the **rolling reveal window** (§7.7): a stuck player has somewhere else to go. They play
the next level instead, earn stars there, and return with fresh eyes. Nobody is ever presented with a
single unsolvable obstacle and no alternative.

This is the right trade. The game never hands over an answer, and it never traps anyone.

**Dependency to respect:** this decision is only safe while the reveal window stays wide. If the window
is ever narrowed to one level, hints or a skip become necessary in the same change.

**If playtesting still shows players stalling**, the cheapest fix remains available: every level already
stores a reference solution for automated fragility testing (§13.1 item 4), so a hint that ghosts the next
correct block is nearly free to add. Held in reserve, not planned.

### 7.9.1 Island shape and the portrait screen

The screen is 1080×1920 — tall and narrow — and the camera is orthographic, looking down at one of eight fixed
45° angles (§6.2). This constrains island design in a way that's cheap to design around and expensive to retrofit.

**The geometry.** Looking down at an angle, the visible ground area is a diamond, not a rectangle. Ground running
*away* from the camera is foreshortened, so the tall screen covers roughly 1.4× more ground depth than its pixel
height suggests. Portrait is generous in depth and stingy across it. But **because the camera snaps to eight
angles, the player chooses which direction "away" is** — so no island can be designed to exploit that. An island
long in one axis frames well from two angles and badly from the two at right angles.

Also: the block palette occupies the bottom of the screen and the coin count the top, so usable play area is
closer to 1080×1400.

**The resolution: height, not sprawl.** Elevation maps directly onto screen-vertical and reads identically from
all eight angles. A cliff, a tier, a raised platform fills the tall screen wherever the player stands; horizontal
sprawl does not. This also happens to match the height-change mechanics worlds 1–2 already introduce (§7.3) — the
screen shape and the mechanic list want the same thing.

**The rule, staged:**

| Stage | Island shape |
|---|---|
| **Worlds 1–2 (launch)** | **Compact footprint, fully visible at default zoom.** The player never has to pan to understand the puzzle. Interest comes from elevation — cliffs, tiers, platforms — not from area. |
| **Worlds 3+ (post-launch)** | May grow larger, once players understand the game well enough to explore an island they can't see all at once. |

**⚠️ Consequence for the camera and tooling:** because bigger islands are planned for later, the camera rig
(FO-011), the run camera (FO-015) and the level tooling must handle both cases **from the start**. Building for
compact islands only and widening later means reworking the camera bounds, the zoom limits and the fit logic
after levels exist. Design for the general case; ship the constrained one.

🔓 The actual footprint limit for a compact island, in Godot units. Falls out of FO-011 once the camera's default
orthographic size is tuned — a level is "compact" if it fits in that view (§16 #39).

### 7.10 Level authoring

Twenty levels at launch and many more later, so authoring speed is a first-class concern. **The goal is that
designing a level is fast and enjoyable, not a chore.**

#### 7.10.1 Modular island pieces

Islands are **assembled from a kit of pre-made pieces**, not sculpted freely. Expected starting kit: flat
plate, slope, cliff edge, water channel, raised platform, gap.

Why this over freeform terrain:

- **Fast.** Snapping pieces together is minutes; sculpting is hours.
- **Visually consistent** without effort — every island shares a vocabulary.
- **Physically predictable.** Each piece's collision is authored and tested once. Arbitrary terrain is where
  simulation reliability problems hide (§13.1).
- **Re-themeable.** A "slope piece" is itself a slot (§7.11) — grassy slope, sand slope, snow slope. This is
  what makes moving a level between worlds actually work.

The cost, accepted: islands are constrained to what the kit contains. **The kit grows on demand** — when a
level you want to build needs a piece that doesn't exist, that's the trigger to add one, not before.

🔓 **Where the kit comes from is open (§16 #33).** Options, in rough order of promise:

**The Jan 2024 Unity project no longer exists**, so there is no existing art to salvage. Remaining options:

1. **Build it from CSG in Godot.** `CSGBox3D`, `CSGCylinder3D` and friends, combined with union and subtract
   operations. Needs nothing installed and works today — a slab minus a thin box gives a water channel.
   Geometry is messy and it can't do bevelled edges or stylised silhouettes, so it's grey-box only, but it
   **unblocks level design immediately.**
2. **Buy a modular low-poly kit.** Fastest route to good-looking. Caveat: pack pieces rarely snap together
   cleanly, and you end up designing around what the pack happens to include.
3. **Model it in Blender.** Best final result, full control, real learning curve.

**These are not exclusive, and that's the point.** CSG placeholders now plus a purchased or modelled kit later
costs nothing extra, *because pieces carry their own fixed collision* — swapping the art doesn't disturb a
single tuned level. Recommendation: **option 1 now, shop for option 2 in parallel.**

**Initial piece list: six basics.** Flat plate · slope · cliff edge · water channel · raised platform · gap.
Enough to build every world 1–2 mechanic in §7.3, and nothing speculative. **The kit grows on demand only** —
when a level being designed needs a piece that doesn't exist, that's the trigger to add one.

#### 7.10.2 Where levels are built

**Now: the Godot editor.** Drag pieces into a scene, set parameters in the inspector, press F6 to play.
Nothing to build, available on day one.

**Later: an in-game authoring mode.** A hidden mode inside the game itself — place pieces and obstacles with
the same controls the player uses, in the player's exact orthographic view and scale, and press Start to test
instantly.

This sequencing is deliberate. **The game is already most of a level editor**: placement with free rotation,
grid snap, the orthographic camera, undo/redo and clear-all are all built for the player in Phase 1. An
authoring mode mostly adds piece placement, starter/finish placement, a parameter panel and save. Building it
*after* a handful of levels exist means building the tool you actually need rather than the one you guessed at.

🔓 **When to build it (§16 #36).** Recommendation: after five levels have been made in the Godot editor,
because by then the friction points will be obvious.

**Keep a player-facing editor possible.** Not planned, but the internal tool should reuse player controls and
keep the level format cleanly serialisable, so exposing it later is a decision rather than a rewrite. Small
discipline now, large saving if it ever happens.

#### 7.10.3 Reference solutions are recorded, not authored

The designer does **not** hand-author the intended solution. They play their own level, solve it, and press
**"save as reference solution"** — one button.

- Captures the exact block layout that worked.
- Feeds the automated fragility testing in §13.1 item 5 for free.
- Also makes a hint system nearly free if it's ever needed (§7.9).
- Means the stored solution is always one a human actually achieved, not one that only works in theory.

#### 7.10.4 Numbers are derived, then overridden

Coin budgets and star thresholds are **auto-derived from the recorded reference solution**, then adjusted by
hand where the automatic answer is wrong.

- The tool proposes: coin budget from the solution's cost plus headroom; the 3-star threshold at or near the
  solution's cost; the 2-star threshold looser.
- **Wouter overrides anything that feels wrong.** A formula is always wrong for the interesting levels, and
  the override is the point, not a fallback.
- Every derived or overridden number is then **verified against the fragility test** before the level ships,
  so no level can go out with a budget its own reference solution can't meet.

#### 7.10.5 Levels must be reassignable between worlds

**A level's theme is not baked into the level.** Theme comes from whichever world the level is currently
assigned to (§7.11). This exists so the difficulty curve can be retuned late: moving level 2-4 to slot 1-7
should be a one-line change that re-dresses the island automatically, not a rebuild.

⚠️ **This needs a validation, or it will cause silent breakage.** Each level declares which block types and
mechanics it requires. Reassigning a level to an earlier world where those blocks aren't unlocked yet
(§4.5) would make it unsolvable. The authoring tool must refuse the move — or at minimum warn loudly —
rather than let it through.

### 7.11 Obstacle slots and theme kits

**Levels are authored against semantic slots, not against art.** A designer places a *"tall obstacle"*, never
*"a pine tree"*. Each world's theme kit maps slots to actual models:

| Slot | Forest | Desert | Snow | Volcano |
|---|---|---|---|---|
| Tall obstacle | Pine tree | Cactus | Snow-laden fir | Basalt column |
| Low obstacle | Rock | Dune stone | Snow mound | Cooled lava lump |
| Wide barrier | Fence | Wooden palisade | Ice wall | Rock ridge |
| Bridge | Wooden planks | Rope bridge | Ice slab | Stone arch |
| Hazard surface | Water | Quicksand | Thin ice | Lava |
| Prop / dressing | Cabin, stump | Skull, dead tree | Igloo, icicles | Vent, ash pile |

**The six starting slot types are fixed:** tall obstacle · low obstacle · wide barrier · bridge · hazard surface
· prop/decoration. Between them they cover blocking the route, forcing a detour, crossing a gap, and danger —
every puzzle idea planned for worlds 1 and 2. Grow the list on demand only.

The *models* each theme maps them to are Phase 5 art work; the table above is illustrative.

#### 7.11.1 What a theme actually changes

Two different rules, because terrain and obstacles behave differently.

**Terrain kit pieces: same mesh, material only.** A slope is one mesh, forever. Grass, sand, snow and rock are
different *materials* on that identical mesh. Collision is guaranteed identical because it is literally the same
object — there is no way to get it wrong. A new world's terrain is a handful of materials, not a set of models.

The trade-off, accepted: shape never varies. Sand won't have wind ripples and snow won't have drifts. Colour,
texture and the cel-shading bands carry the whole difference. For a stylised low-poly game viewed
orthographically at diorama scale, that is enough — and it means five worlds of terrain cost roughly what one
world of terrain would otherwise.

**Obstacle slots: different mesh, same collision.** Here the mesh *must* differ — a pine tree that looks like a
cactus defeats the point. So each theme supplies its own model for each slot, and the collision shape stays fixed
on the slot.

#### 7.11.2 ⚠️ A slot is a volume budget, not just a collision shape

This is the practical rule that makes obstacle theming work, and the one most likely to be discovered too late.

Because collision is fixed but models vary, **every theme's model for a slot must fill roughly the same visual
volume.** If the desert's cactus is noticeably smaller than the forest's pine tree:

- the chain stops dead a few centimetres short of the cactus and looks broken
- the physics is entirely correct, which makes the bug baffling to diagnose

And if a model is larger than the slot, the chain visibly passes through its edges.

So a slot definition carries three things, not two: a name, a collision shape, **and a stated visual volume every
theme must fill**. Document the volume alongside the collision shape, and check new theme models against it before
they ship. A model that can't fill the volume needs a different slot, not a smaller box.

#### 7.11.3 No theme assigned

A level with no theme renders as **grey-box shapes in brand palette colours** (§8.3) — unmistakably a work in
progress.

Grass is a real theme you assign, not the fallback. This keeps design and art properly separate: a level can be
built, tuned and fragility-tested with no art in existence, which is the main reason for building the system this
way (§7.11). It also means an unthemed level is visibly unthemed, rather than silently looking finished.

**⚠️ The one absolute rule: collision belongs to the slot, never to the art.**

A "tall obstacle" has the same invisible collision shape in every theme. The cactus and the pine tree are
decoration hung on an identical physical object. **The moment collision comes from the mesh, swapping themes
silently changes physics and every tuned level breaks.** This is free to design in now and effectively
impossible to retrofit — by the time it matters, twenty levels depend on it.

Three things this buys:

1. **Design before art exists.** Grey boxes labelled "tall obstacle" are enough to build and tune a real
   puzzle. Level authoring does not have to wait for Phase 5 — this is the grey-box-first principle (§8.3)
   extended to level design, and it's the single biggest schedule win available.
2. **Cheap new worlds.** A new theme is a new mapping table plus models, not a new set of levels.
3. **Reassignable levels** (§7.10.5).

**Not for content multiplication.** Each level ships in exactly one theme, and each world gets its own new
levels. Re-theming is a design and production tool, not a way to pad the level count — players notice a
reskin, and it reads as padding.

---

## 8. Visual style

### 8.1 Visual identity

Four decisions define how the game looks, and they hang together.

| Decision | Choice |
|---|---|
| **Projection** | **Orthographic.** No perspective distortion; parallel lines stay parallel. |
| **World scale** | **Miniature diorama** — playful, not literal. Dominoes are comparable in size to trees and fences. |
| **Setting** | **Islands in ocean** — flat-shaded water surrounds each island, as in prototype B. |
| **Blocks** | **Plain coloured blocks.** No domino pips, no face markings. |

**Why orthographic is right here.** In a game about judging the gap between two dominoes, distance changing
apparent size is actively unhelpful. Orthographic means a 20 cm gap looks identical wherever it is on screen,
so spacing learned in level 1 transfers to level 20. It also suits the toy-diorama reading — orthographic is
how model kits and board games are drawn.

**⚠️ The consequence: shadows become load-bearing.** Orthographic removes perspective as a depth cue, so a
block floating slightly above the ground looks identical to one resting on it. **Shadows are the primary way
the player reads where a block actually sits.** They were already described as functional (§8.5); with
orthographic they are not optional. Any lighting decision that weakens ground-contact shadows is a gameplay
regression, not an art choice.

**On plain blocks.** They read cleanly at any zoom, skin freely, and match both prototypes. The trade-off,
accepted: a screenshot doesn't instantly say "dominoes", and the game leans on motion rather than iconography
to communicate what it is. Worth revisiting only if store screenshots test badly.

**On diorama scale.** Playful rather than accurate scale removes any obligation to be realistic — a domino
next to a pine tree is a stylistic choice, not an error. It also makes the "Mini" bonus theme a natural fit
rather than a novelty.

### 8.2 UI style

**Clean, flat, rounded and playful.**

- Soft rounded rectangles, flat fills from the brand palette (§8.4), no gradients or textures
- **Chunky, friendly buttons** — big enough for a thumb, with a little bounce or squash on press
- Thick, confident shapes over fine detail; readable at a glance in one hand
- Generous spacing; no dense panels
- No ornament, no wood grain, no skeuomorphism — the islands are the pretty part, the UI stays out of the way
- Roboto throughout (§8.4)

The combination should read as approachable and toy-like, consistent with the diorama scale, without
competing with the islands for attention.

🔓 **Logo and wordmark do not exist yet.** To be created in the Phase 5 art pass from the established palette
and font. Grey-box and early builds use plain Roboto text as a placeholder.

### 8.3 Grey-box first

**No art assets until the mechanics are proven fun.** All development starts with primitive shapes and
flat colours from the brand palette. Pretty trees cannot tell you whether placement feels good, and art
built on mechanics that later change is wasted work.

Using the real palette from day one means the grey-box looks *intentional* rather than grey.

| Element | Grey-box colour |
|---|---|
| Starter block | Dark Green `#478026` |
| Finish | Dark Red `#ab2a2a` |
| Standard block | Dark Blue `#3185a9` |
| Long block | Yellow `#e1b122` |
| Terrain | Light Green `#82ba61` |
| Water | Light Blue `#75b1cb` |
| Invalid placement | Light Red `#eb5d5d`, translucent |

### 8.3.1 Shading: banded cel shading

**Light is quantised into 2–3 bands instead of a smooth gradient.** One custom spatial shader, reused across
everything. Cheap on mobile — it only replaces the lighting calculation, adds no passes.

**⚠️ Real shadows stay.** This is the constraint that governs the whole shading approach: §8.1 makes
ground-contact shadows load-bearing, because orthographic projection gives the player no other way to tell a
resting block from a hovering one. Cel shading and strong shadows are compatible — a hard-edged banded shadow
reads *better* than a soft gradient one, not worse.

**What is therefore forbidden:** any shading approach that removes shadows, softens ground contact, or replaces
lit shading with flat ambient colour. Fully unshaded flat colour was considered and rejected for exactly this
reason. If a future art idea would weaken block-to-ground contact, it is a gameplay regression and needs a
different solution.

**No outlines.** Inverted-hull and screen-space outlines were both considered and declined. Low-poly silhouettes
separate well enough on flat colour with shadows, and skipping outlines saves a draw pass per object, avoids
shimmer at phone resolution, and keeps the Mobile renderer viable. Revisit only if shapes prove hard to read on
device — outlines on blocks alone would be the cheapest version.

### 8.3.2 Water

**Opaque flat colour with a foam shoreline.**

- **Flat, opaque** Light Blue. No transparency — that avoids sorting bugs and fill-rate cost on mobile, both of
  which buy nothing here.
- **A white foam band where water meets land.** This single detail is what makes stylised water read as water,
  far more than surface animation does. Usually achieved by comparing scene depth near the shoreline.
- **No waves or surface animation.** Deliberately: water is background, and Pillar 1 says the falling chain is
  what the player should be watching. Animated water competes with it.

**Water is a hazard first and scenery second.** Blocks that fall in are lost for the run (§4.10). It must *read*
as dangerous — the foam line doubles as a visual warning marking the island edge.

🔓 **Depth-texture access is more constrained on Godot's Mobile renderer than on Forward+**, and which renderer
we ship is still open (§16 #1). The foam effect and the renderer choice are now linked — FO-007 must test the
foam shader, not just measure frame rate. If depth turns out to be unavailable, the fallback is a painted foam
band baked into the terrain edge geometry, which costs nothing at runtime but has to be authored per piece.

### 8.4 Brand palette

From the spreadsheet. **Font: Roboto.**

| Name | Hex | | Name | Hex |
|---|---|---|---|---|
| Yellow | `#e1b122` | | Dark Green | `#478026` |
| Light Yellow | `#ffdc74` | | Light Green | `#82ba61` |
| Dark Blue | `#3185a9` | | Black | `#313336` |
| Light Blue | `#75b1cb` | | Grey | `#c6c6c6` |
| Dark Red | `#ab2a2a` | | White | `#f9f6f0` |
| Light Red | `#eb5d5d` | | | |

### 8.5 Target art direction

The Jan 2024 Unity prototype establishes the look and remains the reference: **stylised low-poly**,
bright and clean, saturated but not garish. Pine trees, wooden bridges, rock outcrops, a cabin,
split-rail fences, snow patches, flat-shaded water. Readable silhouettes; no texture detail competing
with the blocks. Warm and inviting rather than realistic.

Soft directional light with clear shadows. **Shadows are functional** — they help the player judge
block spacing — so they are gameplay, not polish.

### 8.6 Art sourcing — resolve at Phase 5

What's needed is a **modular kit** (§7.10.1) plus **theme kits** mapping slots to models (§7.11) — not a
general asset library. That narrows the search considerably: pieces must snap together on a consistent grid,
and each slot needs one model per theme.

**The original Unity project and its art are gone.** Starting fresh, so there is nothing to salvage and the
cheapest option is off the table.

1. **Buy or find a Godot-compatible low-poly kit** (glTF/FBX). Must permit commercial use and store
   distribution. Judge candidates on whether pieces tile cleanly on a grid, not on how pretty the screenshots
   are — a beautiful pack whose pieces don't snap together is useless here.
2. **Model bespoke assets** in Blender. Full control; becomes the project bottleneck.
3. **CSG placeholders in Godot** as a stopgap for any piece not yet sourced (§7.10.1). Because collision lives
   on the piece and the slot, a placeholder can be swapped for real art without touching a single tuned level.

**Recommended combination:** CSG placeholders immediately so level design can start this week, and shop for a
kit in parallel. The slot system means the two never block each other.

**Rejected: heightmap terrain plugins.** Terrain3D and similar are built for landscapes from 64 m to 65 km,
with LOD and texture blending. Our islands are ~20 m diorama-scale, hand-crafted and flat-shaded. Heightmaps
also can't produce overhangs, undercuts or the cliffs the prototype had, and they fight the stylised look. The
current Terrain3D stable build is also documented against Godot 4.4–4.6+ rather than 4.7. Wrong tool for this
job.

### 8.7 🔓 Deferred: colour accessibility

The prototype's green starter and red finish are the **worst possible colour pair** for the most common
form of colour blindness, affecting roughly 8% of men. Decision: **not a priority now.**

**Half of this is already solved.** §4.2 makes the finish a **chest**, which is a completely different silhouette
from a domino — so the green/red pair is no longer carrying the meaning by itself. Shape does the work; colour
reinforces it.

What's left is the starter, which is still a domino distinguished only by colour. The cheap fix is to give it a
marker, arrow or base plate so it reads differently in shape too. Free if decided while the art is being made,
expensive as a later bolt-on. Worth settling at Phase 5 rather than treating as an afterthought.

---

## 9. App flow and meta screens

**Roughly a third of the project's UI work sits outside the puzzle itself.** Plan these as real work, not
as an afterthought — each screen needs layout, navigation, state and visual design.

### 9.1 Flow

```
Logo splash  →  Main menu  →  World map  →  Level select  →  Level
```

- **Logo splash** — brief, skippable by tapping. Uses the wordmark from §8.2 once it exists; plain Roboto
  text until then.
- **Main menu** — the front door.
- **World map** — cloud-covered overview of worlds (§7.6).
- **Level select** — the ten-island route for a world (§7.7).
- **Level** — the game.

Every screen has an unambiguous way back. Nothing is a dead end.

### 9.2 Main menu

| Item | Notes |
|---|---|
| **Play / Continue** | Primary button. Goes to the world map, or straight back into a level left mid-build (§4.11). |
| **Settings** | Also reachable from the world map, but players expect it here. |
| **Achievements and diamonds** | Progress and balance visible from the front door, so the meta-game has presence rather than being buried. |

**Not on the main menu:** the diamond shop preview. There is nothing buyable at launch (§5.5), so it stays
tucked inside the achievements/diamonds screen rather than advertised on the front page.

### 9.3 Screens

**At launch:**

| Screen | Contents |
|---|---|
| **World map** | Cloud-covered overview, worlds revealed as reached, star progress toward gates (§7.6) |
| **Logo splash** | Brief, tap-skippable. Wordmark once it exists (§8.2) |
| **Main menu** | Play/Continue, Settings, Achievements & diamonds (§9.2) |
| **Level select** | Ten island nodes per world, **rolling reveal window** — up to *(highest completed + 3)* visible and playable out of order — dotted-line route, stars per node (§7.7) |
| **Settings** | Audio, **haptics toggle**, graphics, tutorial progress, reset progress |
| **Achievements** | List, progress, diamond rewards (§5.7) |
| **Diamond balance** | Visible, with a shop preview marked coming soon (§5.5) |

**First content update:** skins shop (§5.6).

**Cut:** plate collection (§5.8).

---

## 10. Audio

Disproportionately important: the *clack* of a falling chain is most of this game's satisfaction.

- **Impact sounds** — pitch and volume driven by impact force, so a big collapse sounds different from
  a single tap. Cheap to build, enormous perceived-quality return. **Do not leave this to the end**; it
  changes how the core loop feels, not just how it sounds. Pairs with haptics (§6.5) driven by the same
  force value.
- **Music** — Wouter already has the tracks: **one theme with a variant per world/land**, so the soundtrack
  stays recognisably Fall Over while each world feels its own. A real identity advantage over a set of
  unrelated tracks, and worth protecting as worlds are added.
- **Music ducks during the run.** The theme keeps playing but drops to a low background level while the
  chain falls, so the impacts come through. The clacks are the best sound in the game; give them room, then
  bring the music back up when the run ends.
- **Ambient sound** — water, wind, birds. Wanted, marked optional. Adds a great deal of place for modest
  effort, and pairs naturally with the ocean setting (§8.1).
- UI sounds for placement, selling, undo, clear-all confirmation, win and fail.
- Any randomness in audio — pitch variation on impacts — must be seeded and kept outside the physics path
  (§13.1 item 3).

---

## 11. Save data

Structure adapted from the spreadsheet's *JSON Saves* sheet. **A version field is mandatory from the
first commit**, so adding fields later never wipes a player's progress.

**Global**

- Save format version
- Selected skin (unused until skins ship)
- Unlocked block types
- Achievements and their progress
- **Diamonds** — balance, and which star payouts have already been claimed
- Settings: audio, haptics, graphics, tutorial progress
- Player stats: total blocks placed, levels completed, stars earned, skins unlocked, total play time
  (aggregate lifetime stat only — never shown during a level, never scored; §5.9)

**Per world**

- Name, music track, cumulative star total, gate state

**Per level**

- Completion state
- Best star rating (never decreases)
- Best coins-left score
- **In-progress layout** — placed blocks, coins spent, so a level can be resumed mid-build (§4.11)
- Fly-through seen flag

**Not stored:** plates (cut, §5.8) · per-level run time or any timing (§5.9)

Monetisation seams (§13.5) mean entitlement flags must be addable without a migration.

---

## 12. Analytics — none

No analytics, telemetry or tracking of any kind until a business model is decided (§13.5). This keeps
the privacy-policy and consent burden at zero.

⚠️ Consequence worth knowing: **there is no data on where players stall.** Combined with §7.9's no-help
decision, the only way to discover a wall is manual playtesting (Phase 7). That makes playtesting
non-optional rather than nice-to-have.

---

## 13. Technical constraints

### 13.1 Simulation reliability

Domino chains are chaotic: a fraction of a degree in the first block compounds into hit-or-miss by the
twentieth. The approach is **reliable, not bit-exact**:

1. **Fixed physics tick.** Physics runs on a fixed timestep (Godot default: 60/sec). *All* gameplay
   logic — win detection, settle detection, scoring — runs on the physics tick. Nothing may depend on
   frame delta.
2. **Survive slow devices without slow-motion.** Godot caps physics steps per rendered frame
   (`physics/common/max_physics_steps_per_frame`, default 8). Exceeding it does **not** drop ticks or
   diverge the simulation — the tick sequence stays intact and physics falls behind wall-clock, so the
   run visibly plays in **slow motion** (Godot's docs call this the *physics spiral of death*). Fix:
   fewer active bodies, or a lower tick rate. Must be tested on a low-end device — a chain that crawls
   is nearly as bad as one that fails.
3. **No randomness in the simulation.** No random impulses, no spawn jitter. Any randomness — visual
   effects, audio pitch variation, haptics — must be seeded and kept strictly outside the physics path.

   Caveat: even so, run-to-run results on one device are *very likely* identical but not *guaranteed*.
   Solvers can vary contact resolution order, and floating-point addition isn't associative. In
   practice this sits far below the threshold that flips a domino outcome — but "identical every time"
   is a strong expectation, not a mathematical guarantee. Item 4 is what actually protects the player.
4. **Design margin.** Every level ships with a stored **reference solution** — the layout the designer
   intends — which must pass with comfortable margin, never barely squeak through. Concretely: it
   should still complete when every block's position is nudged and every rotation rocked by a small
   tolerance. That tolerance is established by device testing and then becomes a hard authoring rule.
   *(This is also what makes a hint system nearly free later — §7.9.)*
5. **Automated fragility testing.** A headless script runs each level's reference solution many times
   (target: 200) and flags any level that fails even once. Catches fragile levels before players do.

**Explicitly out of scope:** bit-identical results across devices and CPU architectures. That needs
fixed-point maths or a custom solver — weeks of work, permanent constraints on physics features, and
only justified by physics-verified leaderboards or shared replays.

**Note how §4.7's no-stacking rule supports this.** Stacked bodies are the least stable configuration
in any solver; forbidding stacking removes the largest single source of simulation unreliability.

🔓 **Physics backend, to decide in Phase 0 by measurement.** Godot 4 offers two real options via
`physics/3d/physics_engine`:

- **GodotPhysics3D** — default, fully supported.
- **Jolt Physics** — integrated since 4.4. Godot's own docs recommend it for **stacked-body stability**
  and **cylinder shapes**. Cylinders are planned (§4.4), so this matters even though we don't stack.
  But the integration is documented as **experimental** and is not a drop-in replacement.

A domino chain is essentially a stress test of toppling-body stability. "Experimental" on the thing the
whole game depends on is a real risk. Decide by testing a real chain on a real phone.

### 13.2 Physics interpolation

Godot has an optional physics interpolation setting (3D support added in 4.4, off by default) that
smooths rendering when render rate and physics tick don't align. **Decision: enable it**, for how the
falling chain looks — revisit only if it causes visible problems.

One caveat: interpolation renders objects one to two ticks in the past. Invisible for watching a chain
fall, but gameplay logic must read physics state and never interpolated visual transforms — consistent
with §13.1 item 1.

### 13.3 Data-driven design

Block types and levels are **data, not code**. Adding either must not require writing a script.

A level stores:

- **Island layout** — which modular kit pieces (§7.10.1) and where
- **Obstacle slots** — which semantic slots (§7.11) and where. **Never specific models.**
- Starter placement and impulse direction; finish placement
- Coin amount for the level
- Available block types — must be a subset of what the assigned world has unlocked (§7.10.5)
- **Second and third star coin thresholds**
- Fly-through camera positions, **orthographic sizes** and duration (§6.4)
- The **recorded reference solution** (§7.10.3)
- **Required block types and mechanics** — used to validate world reassignment (§7.10.5)

**A level does not store its theme.** Theme resolves from the world it is assigned to (§7.11), which is what
makes levels reorderable late in development.

A **world** stores: name; music track variant; **theme kit** (the slot → model mapping); block types it
unlocks; cumulative star gate threshold; and its ordered list of levels.

### 13.4 Performance

| Target | Value |
|---|---|
| Frame rate | 60 fps on mid-range Android; never below 30 |
| Max simultaneously active rigid bodies | 🔓 TBD by device testing in Phase 0 |
| Level load time | Under 2 seconds |

Blocks at rest must sleep, so physics cost scales with the *active front* of the chain rather than total
block count. This matters more with branching, where several fronts are live at once.

### 13.5 Monetisation seams

Business model **deliberately deferred**. Two seams are left open now, because retrofitting later means
restructuring level flow and migrating save data:

- Level flow passes through a single choke point where an interstitial or rewarded hook could later be inserted.
- **The win screen reserves space for a share button**, disabled and unbuilt. Sharing a screenshot of a finished
  chain is deferred (§5.11), but leaving the slot means adding it later doesn't mean redesigning the screen.
- Save data can carry entitlement flags without a migration.

**Seams only.** No ad SDK, no IAP code, no analytics, no tracking until the model is decided.

⚠️ **Note the constraint §5.1 places on this.** Selling coins, blocks or capability is permanently ruled
out. Hints — the usual rewarded-ad reward — are currently rejected (§7.9). **So no compatible
rewarded-ad hook exists in the design as it stands.** The realistic options are:

- Paid up front
- Free demo (world 1) with a paid unlock for the rest
- **Selling diamonds, restricted to skin purchases only.** This is the one sink that doesn't touch
  capability. ⚠️ It must be *restricted*, not general: diamonds also unlock bonus levels early (§5.4), so
  freely purchasable diamonds would let real money bypass a star gate. That is buying progression, which
  §1.2 rules out. Either purchased diamonds are spendable on skins alone, or the early-unlock sink is
  removed. Do not ship general diamond sales without resolving this.

Worth knowing now rather than discovering it in Phase 7.

---

## 14. Feature idea pool

The spreadsheet's Features sheet holds 42 mechanic ideas. They are **content seeds, not commitments** —
the source to draw from when a world needs its one new idea (§7.1), and the natural source of Discovery
achievements (§5.7). Kept here so none are lost, and kept *out* of the backlog so they don't masquerade
as planned work.

**Terrain and obstacles:** rivers to cross · lava to avoid · cliffs and holes · snow and ice (slippery)
· wind · fans (as blocks or obstacles) · tight spaces · small beams to cross · mirror maze · pyramid
interior maze with booby traps · underwater · space (no gravity)

**Triggered mechanisms:** catapult · spring trap (and button-activated variant) · swing · bombs · doors
· levers and buttons · bridges that open and close · hammer · funnel · pipes (with balls) · cannon on a
pirate ship · magnet (with a metal block) · **turntables** (rotating discs, listed on the spreadsheet as "turning
plates like records" — renamed here because *plate* now means something that was cut, §5.8) · checkpoints
(🔓 §16 #30 — unclear what these mean when a chain runs in one continuous push)

**Physics set-pieces:** skiing down a mountain · playground slide · bridge collapses under weight ·
place a block in a boat and float it · bouncy ball · balloon · house of cards · torpedo · cross the road
(cars)

**Structures and set dressing:** pirate ship · castle · circus (minigames?)

**Economy and routing:** ~~pick up coins in a level~~ — **ruled out.** Coins are the level's budget and
are spent before the run starts (§4.6), so collecting more mid-run has nothing to buy, and adding coins
mid-level is forbidden by §5.1. · Pay for a shortcut (a pirate at a gate) — 🔓 paying with what? Same
problem; needs a different resource to work.

**Tools:** rope · drawing tools for long runs (choose block type, spacing, draw a path or
point-to-point) · measuring tape · pre-built line of blocks · placeable stairs and ramps

---

## 15. Decision log — things deliberately cut

Recorded so they aren't accidentally reintroduced, and so the reasoning survives.

| Cut | Why | Reversible? |
|---|---|---|
| Plates (§5.8) | Stars already carry completion and performance | Easily |
| Time tracking (§5.9) | A clock makes a puzzle game feel like pressure | Easily |
| In-level coin collectibles (§14) | Coins are spent before the run; nothing to buy mid-run | Needs a second currency |
| Player character | Skins apply to blocks; an avatar is a whole art category | Expensive |
| Block stacking (§4.7) | Stacked bodies are the least stable thing in any physics engine | Possible via purpose-built platforms |
| Hints and skip (§7.9) | The rolling reveal window (§7.7) gives stuck players somewhere to go instead | Cheap — reference solutions already exist |
| One-level-at-a-time reveal | Reinstates a hard wall; §5.3.1 explains why | Only alongside adding hints or skip |
| Skins at launch (§5.6) | Mechanics first | Planned for update 1 |
| Daily rewards (§5.10) | Rewards opening the app rather than playing | Easily |
| "Indian" skin (§5.6) | Risks caricature; store review sensitivity | Not recommended |
| Analytics (§12) | Zero privacy burden | Needs a privacy policy |
| Fixed-inventory levels (§4.6) | Coins already reach the same puzzles via price and availability | Easily, but would need a second scoring model |
| Domino pips on blocks (§8.1) | Plain blocks read cleanly at any zoom and skin freely | Easily, if screenshots test badly |
| Level names (§7.7) | Numbers cost nothing to author or translate | Easily |
| Placement reach indicator (§4.7) | Spacing by eye is the skill being tested | Cheap — watch playtests |
| Maximum run duration (§4.9.2) | Drag plus two detection rules judged sufficient | A handful of lines |
| Perspective projection (§8.1) | Orthographic keeps spacing legible at any distance | Expensive — art is designed around it |
| Freeform terrain sculpting (§7.10.1) | Modular pieces are faster, consistent, physically predictable and re-themeable | Possible, but loses re-theming |
| Heightmap terrain plugins (§8.6) | Built for kilometre-scale landscapes; no overhangs; fights the low-poly look | Not recommended |
| Baking theme into a level (§7.10.5) | Prevents reordering levels during difficulty tuning | Would break reorderability |
| Collision on the art mesh (§7.11) | Theme swaps would silently change physics and break tuned levels | **Never** |
| Shipping one layout under several themes (§7.11) | Players read a reskin as padding | Possible for bonus levels |

---

## 16. Open decisions

Everything unresolved, roughly in the order it needs answering. **Nobody working a story may resolve
one of these independently — they are all Wouter's call.**

| # | Decision | Needed by |
|---|---|---|
| 1 | Renderer: Mobile vs Forward+ | Phase 0 |
| 2 | Physics backend: GodotPhysics3D vs Jolt | Phase 0 |
| 3 | Minimum Android API level | Phase 0 |
| 4 | Active rigid body ceiling | Phase 0 |
| 5 | ~~Unit scale~~ — **RESOLVED:** 1 unit = 10 cm, **and gravity scaled to 98** (§4.4.1) | Resolved |
| 6 | Rotation swipe **sensitivity**, and **how the player finishes** rotating (§4.7) — the gesture itself is now decided | Phase 1 |
| 7 | ~~Panning while a block is selected~~ — **RESOLVED:** auto edge-pan (§6.1) | Resolved |
| 8 | ~~How deselection works~~ — **RESOLVED:** palette toggle *and* a cancel button (§6.1) | Resolved |
| 9 | ~~Editing a placed block~~ — **RESOLVED:** radial ring of move/rotate/sell (§6.1) | Resolved |
| 10 | ~~What counts as triggering the finish~~ — **RESOLVED:** a chest, any hit counts, but it must trace back to the starter (§4.2) | Resolved |
| 11 | ~~Stars on inventory levels~~ — **RESOLVED:** inventory levels cut entirely; coins only (§4.6) | Resolved |
| 12 | ~~Auto-skip the fly-through on completed levels~~ — **RESOLVED:** no, always play it, always skippable (§6.4) | Resolved |
| 13 | Full block catalogue: confirm costs, and Bridge/Rope/Fragile specs | Phase 3 |
| 14 | What "Standard Block 1" was in the prototype | Phase 3 |
| 15 | Skateboard / coin / bottle — blocks, obstacles or props? | Phase 3 |
| 16 | Replay or slow-motion review of a run | Phase 3 |
| 17 | Which four mechanics land in world 1 vs world 2, and where branching enters | Phase 4 |
| 18 | **Cumulative star thresholds** per world gate and per bonus level | Phase 6 |
| 19 | **Diamond payout and price figures** | Phase 6 |
| 20 | The specific achievement list and its diamond values | Phase 6 |
| 21 | First-time prompts for later mechanics (Ball, Turnaround, branching, undo) | Phase 4 |
| 22 | Art sourcing route | Phase 5 |
| 23 | Colour accessibility approach (§8.7) | Phase 5 |
| 24 | Business model — note §13.5: no rewarded-ad hook exists as designed | Phase 7 |
| 25 | Skins at update 1: which sets, and their prices | Post-launch |
| 26 | Is time attack permitted in bonus levels, given the flat cut in §5.9 | Post-launch |
| 27 | ~~Help for stuck players~~ — **RESOLVED:** rolling reveal window (§7.7). No hints, no skip | Resolved |
| 28 | **Reveal window size** — 3 is a starting guess; tune on real levels | Phase 6 |
| 38 | **Force threshold for propagating the *live* flag** (§4.2.1) | Phase 2 |
| 39 | **Compact-island footprint limit** in Godot units — falls out of FO-011's default orthographic size (§7.9.1) | Phase 1 |
| 40 | Whether an early level should *require* rotation, as insurance against a skipped tutorial prompt (§7.8) | Phase 6 |
| 29 | What "checkpoints" means when a chain runs in one continuous push (§14) | If used |
| 30 | What currency "pay for a shortcut" would use, given coins are pre-spent (§14) | If used |
| 31 | **Drag/damping values** per block type — governs how runs end and how they feel (§4.9.2) | Phase 0 |
| 32 | Logo and wordmark design (§8.2) | Phase 5 |
| 33 | Which kit to buy or model, once CSG placeholders are in place (§7.10.1) | Phase 5 |
| 34 | ~~Initial kit piece list~~ — **RESOLVED:** six basics (§7.10.1) | Resolved |
| 35 | ~~Full slot vocabulary~~ — **RESOLVED:** six types to start (§7.11). The theme-kit *mapping table* per world is still Phase 5 work | Resolved |
| 36 | When to build the in-game authoring mode (§7.10) | After 5 levels exist |
| 37 | Handling a player stuck on three *consecutive* levels — widen the window, or count completed levels rather than highest completed (§7.7) | On evidence |

Note on #18, #19 and #20: these were previously marked Phase 4 but cannot be answered until real levels
exist and difficulty is known, so they sit in Phase 6. Phase 4 builds the *systems*; Phase 6 sets the
*numbers*.

**Under review on evidence:** §5.5 diamonds shipping without a sink · §4.7 no placement aid · §4.9.2 no
maximum run duration.

---

## 17. Reference material

- **Prototype videos** (Unity 2022.3.17f1, project timestamps Jan 2024):
  - *Prototype A* — bare green plane, green starter, red finish, `Wallet: 20` decrementing 20 → 18 →
    15, STANDARD / LONG palette buttons.
  - *Prototype B* — full stylised island: water, pine forest, wooden bridges, cabin, fences, rock
    formations, snow. Three palette buttons (Standard Block / Long Block / Standard Block 1). A long
    block placed as a ramp. `Wallet: 9`.
- **Project Overview.xlsx** — nine sheets: Themes, JSON Saves, Skins, Block Types, Features, Brand
  Guidelines, Levels, Level Overview (Map), Level Creation Checklist. Absorbed at v0.2. Treated as
  inspiration, not specification.
- **Existing level authoring checklist** (from that spreadsheet), superseded by the level data model in
  §13.3: set up start block and tag it `Start`; set up victory block and tag it `Victory`; set level
  wallet amount; set available blocks; set both fly-through camera positions; set fly-through duration;
  add level to the list.
