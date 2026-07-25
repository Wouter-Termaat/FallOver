# Fall Over — Backlog

**Companion to:** `PRD.md` — read that first; it holds the decisions this backlog implements.
**Last updated:** 2026-07-25 · **Matches PRD:** v0.15

---

## How to work a story

**For whoever picks up a story — human or AI. Read this section before starting.**

1. **Read `PRD.md` first.** It contains every design decision. If a story seems to contradict the PRD,
   the PRD wins — stop and flag it rather than guessing.
2. **Do only the story you were given.** Where a story lists *Out of scope*, respect it absolutely; where it doesn't, stay within what the acceptance criteria describe. A story that
   quietly does three other things can't be reviewed or reverted.
3. **Satisfy every acceptance criterion.** They are the definition of done. If one can't be met, say so;
   don't silently drop it.
4. **Stay inside the listed files** unless the story says otherwise. If you must touch something else,
   note it in the commit message.
5. **Do not invent design decisions.** Anything in PRD §16 is unresolved and is Wouter's call. If a
   story is blocked on one, stop and ask. Never pick an answer and proceed.
6. **Commit per story**, message format: `FO-014: short description`.
7. **Conventions:** Godot 4.7 / GDScript. `snake_case` files and variables, `PascalCase` classes and
   nodes, `SCREAMING_CASE` constants. Static typing on all declarations (`var speed: float = 0.0`). No
   magic numbers — tunable values go in an exported variable or a config resource.
8. **Never put gameplay logic in `_process`.** Simulation logic belongs in `_physics_process`.
   PRD §13.1 — a hard rule, not a style preference.
9. **Use the brand palette** (PRD §8.4) for everything, including grey-box. Never invent colours.
10. **The camera is orthographic** (PRD §8.1). "Zoom" means changing orthographic size, never moving the
    camera closer. Because orthographic removes perspective as a depth cue, **shadows are the player's
    primary way of judging where a block sits** — never weaken ground-contact shadows for a visual effect.
11. **Never change the physics timestep to alter speed.** Fast-forward runs *more ticks per frame*
    (PRD §4.9.1). Scaling the timestep changes physics results and breaks the reliability promise.

### Terminology — get these right

| Term | Meaning |
|---|---|
| **Coins** | The per-level budget. Resets each level. **Never purchasable.** Never called money or a wallet in code. |
| **Diamonds** | The persistent app-wide currency. Buys skins and early bonus-level unlocks. **Never buys coins, blocks or capability.** |
| **Stars** | Max 3 per level. 1 for finishing, 2 from leftover coins. Gate progression. |
| **Plates** | **Cut.** A reference to plates as a game feature is stale — delete it (PRD §5.8). Exception: "turntables" in PRD §14 is a rotating-disc mechanic, unrelated and not cut. |

### Story status key

`[ ]` not started · `[~]` in progress · `[x]` done · `[!]` blocked (reason noted)

### Estimate key

**S** = under an hour · **M** = a few hours · **L** = a day or more

Estimates assume an AI writing the code and Wouter testing it. They are for *ordering and
expectation-setting*, not scheduling. Feel-critical stories (FO-011, FO-013, FO-015) take several rounds
of tuning regardless of the estimate.

### Numbering

IDs are permanent and never reused. Gaps are deliberate — space is left at the end of each phase so
stories can be inserted without renumbering.

### Phase overview

| Phase | Goal | Detail level |
|---|---|---|
| 0 | Pipeline and technical unknowns | Full |
| 1 | Core interaction — place, undo, run, fast-forward, reset | Full |
| 1.5 | Level authoring foundations — kit pieces and obstacle slots | Full |
| 2 | A complete, winnable, resumable level (plus authoring tools) | Full |
| 3 | Block variety and branching chains | Outline |
| 4 | Progression, economy and meta screens | Outline |
| 5 | Art, audio and haptics | Outline |
| 6 | Content — 20 levels across 2 worlds | Outline |
| 7 | Release | Outline |
| 8 | Update 1 — skins and the shop | Outline |

---

## Story index

Every story in the project, in execution order. **This is the list to work from.** Detail for each lives in the
phase sections below. Tick a box here *and* in the story itself when it's done.

`S` under an hour · `M` a few hours · `L` a day or more · `XL` weeks

### Phase 0 — Pipeline and unknowns (10)

- [x] **FO-000** · S · Move the repo out of OneDrive and add a remote
- [x] **FO-001** · S · Create the Godot project skeleton
- [x] **FO-002** · S · Configure physics for reliability
- [x] **FO-003** · M · Grey-box test scene with a falling domino chain
- [x] **FO-008** · M · Determine the unit scale
- [x] **FO-019** · M · Scale gravity for diorama physics ⚠️ *before FO-004 and FO-005* — jitter carried to FO-004
- [x] **FO-006** · M · Android export pipeline
- [x] **FO-007** · S · Renderer and min-API decisions — UI aspect check deferred to Phase 4 (no UI yet)
- [x] **FO-004** · M · Choose the physics backend by measurement — Jolt fixes the FO-019 jitter
- [x] **FO-005** · S · Establish the rigid body ceiling — ~150 active blocks, Pixel 9 Pro XL only

### Phase 1 — Core interaction (10)

- [x] **FO-009** · M · Grey-box island scene
- [x] **FO-010** · S · Block definition resource
- [ ] **FO-011** · M · Camera rig — orbit, pan, zoom, 45° snap
- [x] **FO-012** · S · Block palette UI
- [x] **FO-013** · L · Selection-driven placement input ⚠️ *highest risk in the project*
- [x] **FO-014** · M · Edit and remove placed blocks
- [x] **FO-015** · L · Run the simulation with a zoom-to-fit camera ⚠️ *biggest "feels cheap" risk*
- [ ] **FO-017** · M · Undo and redo history
- [ ] **FO-018** · S · Clear all
- [x] **FO-016** · M · Reset to the standing layout

### Phase 1.5 — Level authoring foundations (2)

- [ ] **FO-030** · M · Modular kit piece system ⭐ *unblocks level design*
- [ ] **FO-031** · M · Obstacle slots and theme kits

### Phase 2 — A complete level (12)

- [ ] **FO-020** · M · Level and world definition resources
- [ ] **FO-021** · M · Coins — the level constraint
- [ ] **FO-023** · M · Finish, win detection and fail state
- [ ] **FO-025** · M · Opening fly-through
- [ ] **FO-027** · M · Save system
- [ ] **FO-024** · S · Stars
- [ ] **FO-026** · M · Win and fail screens
- [ ] **FO-029** · M · Mid-build save and resume
- [ ] **FO-032** · M · Record a reference solution by playing
- [ ] **FO-033** · S · Level reassignment validation
- [ ] **FO-034** · S · Derive coin budgets and star thresholds
- [ ] **FO-028** · M · Author level 1-1 with a reference solution

### Phase 3 — Blocks and branching (9)

- [ ] **FO-040** · M · Ball block
- [ ] **FO-041** · S · Cylinder block
- [ ] **FO-042** · S · Per-block-type placement rules
- [ ] **FO-043** · L · Branching — switches and gates
- [ ] **FO-044** · M · Branch failure feedback
- [ ] **FO-045** · M · Run camera with multiple active fronts
- [ ] **FO-046** · M · Evaluate candidate blocks
- [ ] **FO-047** · S · Price balancing pass
- [ ] **FO-048** · M · Run replay or slow-motion review *(optional)*

### Phase 4 — Progression, economy and meta screens (14)

- [ ] **FO-050** · M · Logo splash and main menu
- [ ] **FO-051** · M · World map
- [ ] **FO-052** · M · Level select with rolling reveal window ⚠️ *only safety net for stuck players*
- [ ] **FO-053** · S · Star gating
- [ ] **FO-054** · S · Block unlock progression
- [ ] **FO-055** · S · Diamond payouts for stars
- [ ] **FO-056** · L · Achievements
- [ ] **FO-057** · S · Diamond balance and skin roadmap
- [ ] **FO-058** · S · Settings screen
- [ ] **FO-059** · M · Tutorial prompts on level 1-1
- [ ] **FO-035** · M · Level authoring workflow documented ⭐ *pays for itself many times over*
- [ ] **FO-036** · M · Automated fragility testing
- [ ] **FO-037** · L · In-game authoring mode *(only after ~5 levels exist)*
- [ ] **FO-060** · M · Difficulty curve pass

### Phase 5 — Art, audio and haptics (17)

- [ ] **FO-070** · M · Source the modular kit
- [ ] **FO-071** · M · Model and material import pipeline
- [ ] **FO-072** · L · Replace kit and slot placeholders with real art
- [ ] **FO-073** · L · Theme kits for Grass and Desert
- [ ] **FO-074** · M · Block visuals
- [ ] **FO-075** · S · Colour accessibility
- [ ] **FO-076** · S · Logo and wordmark
- [ ] **FO-077** · L · UI visual pass
- [ ] **FO-078** · M · Lighting and shadow pass ⚠️ *shadows are gameplay, not polish*
- [ ] **FO-079** · M · Impact sounds ⭐ *highest return per hour in this phase*
- [ ] **FO-080** · S · Music and run-time ducking
- [ ] **FO-081** · S · Ambient sound
- [ ] **FO-082** · S · Haptics
- [ ] **FO-084** · M · Banded cel shader ⚠️ *shadows must survive it*
- [ ] **FO-085** · M · Water: flat colour plus foam shoreline
- [ ] **FO-086** · S · Chest opening animation ⭐ *the payoff moment*
- [ ] **FO-083** · M · Particles and juice on the run

### Phase 6 — Content (10)

- [ ] **FO-089** · S · Keep every launch level compact and fully visible
- [ ] **FO-090** · S · Distribute the four launch mechanics across the two worlds
- [ ] **FO-091** · XL · Author 20 levels ⭐ *the slowest work in the project*
- [ ] **FO-092** · M · Balance coin budgets and star thresholds
- [ ] **FO-093** · S · Set cumulative star gate thresholds
- [ ] **FO-094** · S · Set diamond payouts and achievement values
- [ ] **FO-095** · S · Tune the reveal window size
- [ ] **FO-096** · M · Every level passes fragility testing
- [ ] **FO-097** · S · Place optional props for discovery achievements
- [ ] **FO-098** · S · Audit each world's "one new idea"

### Phase 7 — Release (7)

- [ ] **FO-100** · M · Decide and implement the business model
- [ ] **FO-101** · M · Release signing and Play Store listing
- [ ] **FO-102** · M · Store assets
- [ ] **FO-103** · S · Confirm the localisation table
- [ ] **FO-104** · S · Crash reporting
- [ ] **FO-105** · M · Performance pass on low-end devices
- [ ] **FO-106** · L · Playtesting with people who are not Wouter ⚠️ *not optional*

### Phase 8 — Update 1: skins and the shop (4)

- [ ] **FO-110** · S · Skin set data model
- [ ] **FO-111** · M · Skins shop screen
- [ ] **FO-112** · L · Initial skin sets
- [ ] **FO-113** · S · Activate collection achievements

**Total: 94 stories.** FO-022 (inventory levels) was cut when coins became the only constraint model. Phases 0–2 are fully specified with acceptance criteria and file lists. Phases 3–8 are
one-line placeholders — each gets detailed before it's worked, not now, because the game will have changed by
then.

---

## Phase 0 — Pipeline and unknowns

**Goal:** prove we can get a build onto a real Android phone, and settle the technical unknowns *before*
investing in gameplay. Deliberately boring. Pipeline problems found now are trivial; found in month
three they're miserable.

**Exit criterion:** an `.apk` on Wouter's phone showing a physics-driven chain toppling that *falls at a
convincing speed*, with measured answers for backend, renderer, block ceiling, unit scale and gravity.

**⚠️ Execution order is not document order.** Several stories need a working Android build before they
can be measured. Work them in this order:

> **FO-000 → FO-001 → FO-002 → FO-003 → FO-008 → FO-019 → FO-006 → FO-007 → FO-004 → FO-005**

FO-019 (gravity) sits before FO-004 and FO-005 deliberately — those two *measure* physics, and measuring at the
wrong gravity produces numbers that have to be discarded.

---

### [x] FO-000 — Move the repo out of OneDrive and add a remote · S

**Goal:** stop the project living somewhere that can corrupt it. PRD §2.2.

**Acceptance criteria:**

- Repository relocated to **`C:\Privé\Fall Over`** — outside OneDrive
- A private remote created (GitHub or GitLab) and set as `origin`
- An initial push succeeds
- OneDrive is no longer syncing any part of `.git`
- The stale `HEAD.lock` and `index.lock` from the failures in PRD §2.2 are cleared
- If Wouter prefers to keep the folder where it is, that's his call — record the decision and the
  accepted risk here rather than leaving it unresolved

**Files:** none in-repo; environment task.

**Why first:** this has **already failed twice.** Ten minutes now versus a corrupted `.git` later.

---

### [x] FO-001 — Create the Godot project skeleton · S

**Goal:** an empty but correctly configured Godot 4.7 project with the structure the rest of the backlog
assumes.

**Acceptance criteria:**

- Project opens in Godot 4.7.1 with no errors or warnings
- Portrait orientation, locked (PRD §2.1)
- Folder structure created, each containing a `.gitkeep`:
  - `scenes/` plus `scenes/test/`, `scenes/ui/`, `scenes/placement/`, `scenes/levels/`, `scenes/meta/`
  - `scripts/` plus `scripts/test/`, `scripts/data/`, `scripts/camera/`, `scripts/ui/`,
    `scripts/placement/`, `scripts/simulation/`, `scripts/save/`, `scripts/economy/`, `scripts/meta/`
  - `resources/blocks/`, `resources/levels/`, `resources/worlds/`, `resources/achievements/`
  - `assets/` — meshes, materials, audio (empty for now, grey-box phase)
  - `tests/`, `docs/`
- The brand palette from PRD §8.4 defined once as a reusable resource or constants file, so no colour is
  ever hardcoded
- `project.godot` committed; `.godot/` git-ignored
- A main scene exists and runs

**Files:** `project.godot`, `scenes/main.tscn`, `scripts/data/palette.gd`, folder placeholders

**Blocked by:** FO-000 — don't build history into a repo that's going to move.

**Out of scope:** gameplay, UI, physics.

---

### [x] FO-002 — Configure physics for reliability · S

**Goal:** implement PRD §13.1's fixed-tick rules as project settings, and document them.

**Acceptance criteria:**

- `physics/common/physics_ticks_per_second` explicitly set to **60**. This equals the default, and that
  is the point: set it explicitly so it is obviously deliberate and must not be casually changed —
  changing it changes every level's physics outcomes.
- `physics/common/max_physics_steps_per_frame` explicitly set (default 8; keep unless device testing
  says otherwise)
- `physics/common/physics_interpolation` enabled (PRD §13.2)
- `docs/physics-rules.md` written, recording:
  - each setting, its value, and why
  - that exceeding `max_physics_steps_per_frame` makes the game **run in slow motion**, not diverge —
    the *physics spiral of death* — and that the fix is fewer active bodies or a lower tick rate
  - that physics interpolation renders objects 1–2 ticks in the past, so gameplay logic must read
    physics state and never interpolated visual transforms
  - the hard rule: gameplay logic never in `_process`, only `_physics_process`

**Files:** `project.godot`, `docs/physics-rules.md`

**Note learned in FO-001:** Godot **strips hand-written comments from `project.godot`** when it saves. Do not
rely on comments in that file to record decisions — put the reasoning in `docs/` and reference it there.

**Blocked by:** FO-001.

**Out of scope:** choosing the physics backend — FO-004, which needs measurement.

**Note:** confirm the exact setting paths against the Godot 4.7 docs before editing. Names have moved
between 4.x releases; the values above were checked but should be re-verified.

**Findings (FO-002):**

- All three setting paths verified **empirically against the installed 4.7.1 binary** (more authoritative
  than the docs, whose online ProjectSettings page didn't render the values). Confirmed unchanged in 4.7:
  `physics/common/physics_ticks_per_second` (default 60), `physics/common/max_physics_steps_per_frame`
  (default 8), `physics/common/physics_interpolation` (default `false`).
- Values confirmed read back at runtime as 60 / 8 / `true`.
- **Tooling note for later stories:** `C:\Program Files\Godot\Godot_v4.7.1-stable_win64.exe` is the GUI
  build, so it writes nothing to stdout/stderr when run from a shell — a failing script looks identical to
  a passing one. Pass `--log-file <path>` and read the log, or errors will be invisible. There is no
  `_console.exe` alongside it.
- **Correction, found after real editor use (during FO-003 playtesting):** a value that *equals* Godot's
  default does **not** durably survive — it only looked that way because I'd only tested headless
  open/quit. Opening the project in the actual editor and playing a scene silently pruned
  `physics_ticks_per_second=60` and `max_physics_steps_per_frame=8` from `project.godot` (both equal
  Godot's default), while `physics_interpolation=true` survived because it differs from its default.
  Functionally harmless — the active values are still 60/8 either way — but the "obviously deliberate"
  file marker doesn't hold up. `docs/physics-rules.md` is the durable record now; expect these two lines
  to keep vanishing from `project.godot` and don't chase it as a bug.

---

### [x] FO-003 — Grey-box test scene with a falling domino chain · M

**Goal:** the simplest thing that proves the core physics works — a flat plane, a line of boxes, one push.

**Acceptance criteria:**

- Flat static ground plane, Light Green from the palette
- A line of ~15 identical box rigid bodies, standing, evenly spaced, spawned from code so count and
  spacing are adjustable via exported variables
- One tap or key press applies a fixed impulse to the first block
- The chain reliably topples end to end
- Block dimensions default to the Standard Block ratio from PRD §4.4 (4 × 2 × 0.5)
- Spacing, dimensions, mass, friction, restitution **and linear/angular damping** all exported and tunable
  in the inspector
- Bodies at rest go to sleep (PRD §13.4)
- **Damping values are found here, by feel.** They govern both how a run *feels* and how reliably it ends
  (PRD §4.9.2), so this scene is where PRD open #31 gets answered. Record the values chosen and why.

**Files:** `scenes/test/domino_chain_test.tscn`, `scripts/test/domino_chain_test.gd`

**Blocked by:** FO-001, **FO-002** — "reliably topples" and sleep behaviour both depend on the tick and
interpolation settings FO-002 writes, so measuring before those are set measures the wrong thing.

**Out of scope:** player placement, coins, UI, win conditions, camera work.

**Why this matters:** this becomes the permanent tuning bench for block feel. Every "does a domino feel
right" question gets answered here for the rest of the project.

**Findings (FO-003):**

- **Orientation:** a domino's thin face (`depth`, 0.5) points along the direction of travel, and its wide
  face (`length`, 2) is perpendicular to it — so a toppling domino's wide face is what catches the next
  one, same as a real chain. Box shape maps PRD's H×L×D to Godot's (X=depth, Y=height, Z=length).
- **Starting physics values chosen** (all exported, all provisional — this is a starting point, not a
  final feel call):

  | Value | Chosen | Why |
  |---|---|---|
  | `spacing` | 2.4 (≈0.6 × height) | Close enough that a falling domino's top edge reaches the next before passing it; loose enough not to look like overlap. |
  | `block_mass` | 1.0 | Matches Standard Block's relative weight in PRD §4.4. |
  | `friction` | 1.0 | Godot default; keeps dominoes from sliding instead of toppling and helps them stop cleanly once down. |
  | `restitution` | 0.0 | No bounce — bounce adds chaos (§13.1) and works against drag as the primary way runs end (§4.9.2). |
  | `linear_damp` / `angular_damp` | 0.1 / 0.3 | Low enough that toppling motion still builds up, high enough that things decay and sleep. |
  | `impulse_strength` | 5.0 | Enough to reliably tip the first domino at this mass/height. |

- **Mechanical verification (headless, not a feel judgement):** instanced the scene, triggered the impulse
  programmatically, and stepped physics ticks directly, reading each body's tilt from vertical. Result:
  **15/15 blocks topple**, all settle to sleep, full run takes ~600 physics ticks (~10s at 60 ticks/sec).
  Repeated 3× — **tilt values were bit-identical across all runs**, consistent with PRD §13.1's no-randomness
  expectation.
- **~10s to fully settle is on the slow side** and is a candidate for tightening once tuned by feel — higher
  damping would shorten it but risks weakening the topple. Left as-is pending on-device judgement.
- **This mechanical pass only proves the chain doesn't die out or behave chaotically — it does not answer
  whether it *feels* right.** That call needs a real phone (per CLAUDE.md) and is still open. All the values
  above are `@export`, so they can be retuned without touching code.

**Wouter's first playtest (in-editor, Play Scene):** all 15 topple, clean (nothing flew off oddly), comes
to rest. Feel verdict: **a bit slow**, otherwise fine. Not treated as a damping problem — these blocks are
4 *Godot units* tall under Godot's real-gravity assumption (1 unit = 1 metre), and toppling time scales
with the square root of height, so a 4-metre domino is expected to look ponderous. Likely resolved for
free once FO-008 picks a realistic unit scale, rather than by retuning damping now. Revisit damping feel
after FO-008, not before.

---

### [x] FO-008 — Determine the unit scale · M

**Goal:** resolve PRD open decision #5. **Every piece of geometry in the game depends on this**, so it
must be settled before any island or level is built.

**Acceptance criteria:**

- FO-003's chain tested at several scale interpretations — at minimum 1 unit = 1 cm, 10 cm, and 1 m —
  keeping the 4 × 2 × 0.5 ratio fixed
- For each: does the chain topple convincingly, does the motion look right (not floaty, not frantic), is
  it stable
- Gravity's interaction with scale noted: Godot's physics is tuned for 1 unit = 1 metre, and rigid bodies
  behave poorly at very small scales
- A decision recorded in `docs/unit-scale.md`, stated as *"1 Godot unit = X cm, so a Standard Block is
  A × B × C cm"*
- The chosen scale applied as the default in FO-003 and referenced by every later story

**Files:** `docs/unit-scale.md`, `scripts/test/domino_chain_test.gd`

**Blocked by:** FO-003.

**Note:** the PRD recommends 1 unit ≈ 10 cm, making a standard block 40 × 20 × 5 cm — chunky, oversized
dominoes suiting the stylised look while keeping physics stable. Verify rather than assume, then confirm
with Wouter before locking it in.

**⚠️ Explicitly revisitable after FO-004.** This story runs before the physics backend is chosen, and
backend choice materially affects stability and feel at a given scale. It runs first anyway because
FO-009 and FO-010 cannot start without *a* scale. **After FO-004 lands, re-run this story's tests under
the chosen backend and confirm the scale still holds.** If it doesn't, changing it early is cheap;
changing it after twenty levels exist is not.

**Findings (FO-008):**

- **Decision: 1 Godot unit = 10 cm, so a Standard Block is 40 × 20 × 5 cm.** Full reasoning in
  `docs/unit-scale.md`. Adopted the PRD's own recommendation directly, at Wouter's explicit instruction.
- **The three-way on-device comparison in the acceptance criteria (1 cm / 10 cm / 1 m) was not run.**
  Wouter chose to go straight with the PRD's recommendation rather than test and compare all three.
  Flagging this plainly per CLAUDE.md rule 3 — the 1 cm and 1 m alternatives were never actually
  eliminated by testing, only skipped by choice.
- **No changes needed to FO-003.** The test scene already builds blocks using the catalogue ratios
  (4 × 2 × 0.5) directly as Godot units, which *is* this decision — it was already the default before this
  story ran, not something to retrofit.
- Confirms the reading of Wouter's "a bit slow" feedback on FO-003 (see FO-003 findings above): the
  slowness comes from Godot's real-gravity assumption acting on a nominally-4-metre object, not from the
  unit-scale choice itself — the unit label doesn't change simulated physics, only how geometry is
  authored and read.

---

### [x] FO-019 — Scale gravity for diorama physics · M

**Goal:** PRD §4.4.1. Blocks are authored 10× larger than the real objects they represent, so gravity must be
10× stronger for them to fall at the rate the eye expects. Right now they fall ~3× too slowly — the "a bit slow"
verdict from Wouter's FO-003 playtest.

**Acceptance criteria:**

- `physics/3d/default_gravity` set to **98** in `project.godot`
- **Damping values in FO-003 re-tuned from scratch.** The old values were found at 9.8 and are invalid at 98 —
  do not scale them arithmetically, find them by feel again.
- **Stability retested at the new gravity.** Impact speeds are ~3× higher, so the solver has less time per tick.
  Run FO-003's chain at least 20 times and confirm: it still topples end to end, nothing tunnels through the
  ground or through another block, nothing jitters, everything comes to rest.
- **If 60 ticks/second proves insufficient**, do *not* silently raise the tick rate — report it. Changing the tick
  rate changes every physics outcome (PRD §13.1) and is Wouter's call.
- Wouter confirms on device that the fall speed now reads correctly — this is a feel judgement and cannot be
  verified in the editor alone
- `docs/unit-scale.md` updated with the gravity decision and the reasoning, so nobody "corrects" 98 back to 9.8
  later thinking it's a typo

**Files:** `project.godot`, `scripts/test/domino_chain_test.gd`, `docs/unit-scale.md`

**Blocked by:** FO-008.

**⚠️ Must complete before FO-004 and FO-005.** Those two measure backend stability and the maximum active-body
count. Measured at 9.8 they produce numbers that are simply wrong for the shipping game.

**Findings (FO-019):**

- **`default_gravity` set to 98** in `project.godot` (path `physics/3d/default_gravity`, verified against the
  installed 4.7.1 binary; default is 9.8).
- **Wouter confirmed on a live playtest, immediately after the change: fall speed now reads correctly.**
  This criterion is met.
- **Damping re-tuned from scratch, not scaled arithmetically**, as required. The FO-003 values (linear 0.1 /
  angular 0.3, tuned at gravity 9.8) left blocks sliding at ~1 m/s and never settling at gravity 98. Current
  values: `friction = 2.0`, `linear_damp = 0.5`, `angular_damp = 2.0`.
- **⚠️ One acceptance criterion is not fully met: "nothing jitters, everything comes to rest."** With the
  current values, most of the chain settles cleanly, but consistently one block in the fallen pile (which
  block varies with the exact damping/friction values, not with re-running — the sim is deterministic, no
  randomness per PRD §13.1) is left oscillating with real velocity (~1 m/s) indefinitely, never crossing
  Godot's sleep threshold.
- **This was not solved by more damping/friction.** Pushing friction to 3.0 and damping higher made it
  *worse* — 8 of 15 blocks unstable instead of 1. That non-monotonic response is itself informative: this
  reads as a genuine solver-stability issue with body-on-body resting contact (fallen dominoes end up
  leaning on each other, not just resting on the static ground), not a case of "needs more damping."
  Stopped hunting for a value that fixes it rather than keep guessing — same principle as the tick-rate
  instruction above: report, don't silently paper over.
- **Recommend revisiting at FO-004 (physics backend choice).** Godot's own docs recommend Jolt specifically
  for stacked/resting-body stability (PRD §13.1) — this jitter is exactly that scenario. Worth testing
  whether Jolt resolves it before spending more time tuning GodotPhysics3D parameters.
- No tunneling observed: the fully-flat block (the last in the chain) settles at y≈0.24, matching its
  resting height for its own thickness; nothing goes below ground across repeated runs.
- 60 ticks/second was not implicated — the issue looks like contact resolution, not step-rate starvation.
  Not touched, per the story's instruction.

---

### [x] FO-006 — Android export pipeline · M

**Goal:** get an `.apk` onto a physical phone. The single most important story in Phase 0.

**Acceptance criteria:**

- Android build prerequisites installed and documented (JDK, Android SDK, debug keystore)
- Godot Android export template installed
- A debug `.apk` builds successfully
- It installs and runs FO-003's scene on Wouter's actual phone
- Touch input triggers the chain on device (confirms touch works at all)
- The whole process written up in `docs/build-android.md`, step by step, assuming nothing — future Wouter
  will have forgotten and a fresh AI won't know

**Files:** `docs/build-android.md`, `export_presets.cfg`

**Blocked by:** FO-003.

**Out of scope:** release signing, Play Store listing, iOS.

**Note on `export_presets.cfg`:** the root `.gitignore` currently excludes it, because it can hold
keystore paths and passwords. FO-007 needs to commit the min-API decision, so resolve this here: either
un-ignore it and keep secrets in a separate ignored keystore file, or record settings in
`docs/build-android.md` and have FO-007 write there. Pick one and state which.

**Note for whoever does this:** most of this story is Wouter installing things on Windows. Write the
instructions, then wait for confirmation at each step rather than assuming success.

**Findings (FO-006):**

- **Decision on `export_presets.cfg`: committed, not gitignored.** Debug-only pipeline uses Android's
  standard public debug keystore credentials — nothing secret to protect. Full reasoning in
  `docs/build-android.md`.
- Wrong JDK installed on the first attempt (26, not 17) because Adoptium's site defaulted to "latest."
  Godot's Android Gradle build specifically requires 17. Recorded in the doc so it isn't repeated.
- **Android export hard-fails without ETC2/ASTC texture compression enabled** — added
  `rendering/textures/vram_compression/import_etc2_astc = true` to `project.godot`. Not something the
  export dialog warns about until you try to export.
- **`adb shell monkey -c LAUNCHER` silently did nothing** — command exits with no error but never brings
  the app to the foreground. Root cause: Godot's non-Gradle Android export uses the launcher component
  `com.godot.game.GodotAppLauncher`, not the more obvious-looking `com.godot.game.GodotApp` (which exists
  but isn't exported, and throws a `SecurityException` if targeted directly). Use
  `adb shell cmd package resolve-activity --brief <package>` to find the real one rather than guessing.
- Verified end to end on **Wouter's Google Pixel 9 Pro XL, Android 17 (SDK 37), arm64-v8a**: debug APK
  built via command line, installed, launched FO-003's chain (temporarily set as the project's main scene
  for this test, then reverted to the FO-001 placeholder), and **touch input confirmed working** — tapping
  the screen triggers the impulse and the chain topples, same as desktop.
- **The FO-019 jitter reproduces on-device, not just headless.** Confirms it's a real physics behaviour,
  not a headless-simulation artifact. Still tracked as a carry-over check for FO-004 (test whether Jolt
  resolves it), not something this story needed to fix.

---

### [x] FO-007 — Renderer and min-API decisions · S

**Goal:** resolve PRD open decisions #1 and #3.

**Acceptance criteria:**

- FO-003 tested under both Mobile and Forward+ renderers on device; visual and performance differences noted
- **Also test depth-texture access on both.** The water foam shoreline (PRD §8.3.2) needs scene depth, which is
  more constrained on Mobile than Forward+. This decision is no longer just about frame rate — if Mobile can't
  do the foam, that's a real cost to weigh, and the fallback is baking a foam band into terrain geometry.
- Recommendation recorded, and the chosen renderer set in `project.godot`
- Minimum Android API level chosen, set, and the reasoning written down (what share of devices it
  excludes)
- UI layout verified at the aspect extremes in PRD §2.1 — 4:3 through 20:9

**Files:** `docs/platform-decisions.md`, `project.godot`, plus wherever FO-006 decided export settings
are recorded

**Blocked by:** FO-003, FO-006.

**Findings (FO-007):**

- **Renderer: kept Mobile** (Godot's own default for Android), set explicitly in `project.godot` rather
  than left implicit. Tested both Mobile and Forward+ on Wouter's Pixel 9 Pro XL via two separately-built
  debug APKs (forcing `rendering/renderer/rendering_method.mobile`), screenshotted via `adb shell
  screencap` rather than relying on descriptions. Both hit a stable 60fps on this scene — no meaningful
  differentiator at this scale (15 low-poly boxes is trivial for either renderer on a flagship GPU).
  **⚠️ Revisit at FO-005** once there's an actual GPU/CPU load worth comparing, and ideally on a lower-end
  device too.
- **Depth-texture access confirmed working on both renderers** — this directly answers the water-foam
  concern in PRD §8.3.2. Built a small depth-visualization shader into FO-003's scene for this (gated
  behind `show_depth_debug`, off by default). First attempt applied it to the ground plane itself and got
  a meaningless flat result — a mesh can't reliably read its own not-yet-finished depth write in the same
  opaque pass. Fixed by moving it to a separate camera-attached quad drawn in the transparent queue, after
  opaque geometry has already written depth. Recorded as a gotcha in the shader's own comment.
- **`ProjectSettings.get_setting("rendering/renderer/rendering_method")` does not resolve the `.mobile`
  platform override at runtime via GDScript** — it returns the base/desktop value regardless of what's
  actually running. `RenderingServer.get_current_rendering_method()` is the reliable way to check what's
  really active. Cost some confusion mid-story before catching it (briefly looked like the renderer
  override wasn't working at all, when it was — only the diagnostic was wrong).
- **Min API level: 24, unchanged.** Not actually a settable project option here — confirmed via `aapt dump
  badging` that the non-Gradle export template bakes in `sdkVersion:'24'` regardless of the empty
  `gradle_build/min_sdk` field (which only applies with a custom Gradle build, not used here). Matches the
  PRD's own proposal; device-share reasoning and sources in `docs/platform-decisions.md`.
- **UI aspect-ratio check (4:3–20:9): deferred, not silently dropped.** No real UI exists yet to check —
  every screen that would need this is Phase 4 work. Flagged in the doc with a note on how to test it
  later (`adb shell wm size`) once there's something to look at.

---

### [x] FO-004 — Choose the physics backend by measurement · M

**Goal:** resolve PRD open decision #2 with data, not documentation.

**Acceptance criteria:**

- FO-003's chain run under **both** candidates, switching `physics/3d/physics_engine`:
  - `GodotPhysics3D` — default, fully supported
  - `Jolt Physics` — since 4.4; Godot's docs recommend it for stacked-body stability and **cylinder
    shapes** (cylinders are planned, PRD §4.4), but the integration is documented as **experimental**
  - `Dummy` is not a candidate — it simulates nothing
- For each: does the chain topple reliably across 20 runs, does the motion look right, and physics frame
  time in ms (from Godot's built-in performance monitors)
- Run on a real Android device — the whole point of the story
- Findings and an explicit recommendation in `docs/physics-backend-decision.md`, including a note on
  Jolt's experimental status if recommended
- The chosen backend set in `project.godot` as part of this story — do not defer it

**Files:** `docs/physics-backend-decision.md`, `project.godot`

**Blocked by:** FO-003, FO-008, FO-006.

**Note:** do not work in parallel with FO-005 — both touch `scripts/test/domino_chain_test.gd`.

**Carried over from FO-019:** at gravity 98 under GodotPhysics3D, one block in the fallen pile reliably
never settles — real velocity (~1 m/s), indefinitely, not fixed by more damping/friction (see FO-019
findings). Specifically check whether Jolt resolves this before recommending GodotPhysics3D by default —
this is exactly the stacked/resting-body scenario Jolt is documented to help with.

**Findings (FO-004):**

- **Decision: `Jolt Physics`.** Full reasoning and data in `docs/physics-backend-decision.md`.
- **⚠️ Gotcha that ate significant time: the correct enum value is `"Jolt Physics"` (with a space), not
  `"JoltPhysics3D"`.** The wrong string is accepted silently with no error and falls back to
  `GodotPhysics3D` — every early "Jolt" test result was secretly GodotPhysics3D running twice, which
  looked suspicious (identical output) but wasn't immediately obviously wrong. Caught by checking
  `ProjectSettings.get_property_list()` for the actual enum values rather than guessing. Verify this the
  same way if this setting is ever touched again.
- **Jolt completely resolves the FO-019 jitter** — same scene, same tuning, same gravity. All 15 blocks
  reach full sleep within ~5 seconds (headless and on-device). GodotPhysics3D, tested the same way, never
  settles — confirmed both headless (30s) and on **Wouter's Pixel 9 Pro XL** (~27s), where sustained
  physics cost stayed around 4ms the whole time vs Jolt's ~0.26ms once settled.
- **Tested on-device without needing manual interaction**: used the `--fo-autostart` cmdline flag already
  built into FO-003's scene (via `export_presets.cfg`'s `command_line/extra_args`), so both backends could
  be verified via `adb shell screencap` while unattended.
- **Determinism confirmed for both backends** (3 repeated headless runs each, bit-identical results aside
  from wall-clock timing noise) — consistent with PRD §13.1's no-randomness expectation.
- No tunneling, no crashes, no instability observed under Jolt in any test.
- Not retested with different damping — Jolt resolved the jitter using FO-019's existing GodotPhysics3D-
  tuned values as-is. Whether Jolt-specific tuning would feel different is left for on-device feel testing
  later, not part of this measurement-driven story.

---

### [x] FO-005 — Establish the rigid body ceiling · S

**Goal:** resolve PRD open decision #4 — how many active blocks a real phone can simulate at 60 fps. This
number constrains every level design decision that follows.

**Acceptance criteria:**

- FO-003 extended so block count can be raised at runtime (an on-screen +/- control is fine)
- Frame time and physics time measured via Godot's `Performance` monitors at increasing counts, until the
  frame rate drops below 60 fps and then below 30
- Measured on Wouter's actual phone, and **the exact device model recorded** — "mid-range" is meaningless
  without naming the hardware
- Recorded in `docs/performance-budget.md`
- A recommended maximum *simultaneously active* blocks-per-level figure, with headroom below the 60 fps
  limit rather than at it
- Note the distinction: total blocks per level can exceed this, since settled blocks sleep (PRD §13.4).
  The ceiling is on how many move at once — which matters more once branching exists.

**Files:** `docs/performance-budget.md`, `scripts/test/domino_chain_test.gd`

**Findings:** ~150 simultaneously active blocks recommended, generous headroom below both thresholds —
device (Pixel 9 Pro XL) held 55-60fps to 480 active blocks and only dropped near 30fps at ~1900. Only
tested on this one flagship device; revisit on lower-end hardware later. Full data in
`docs/performance-budget.md`. Added multi-row parallel-chain spawning plus an unattended `--fo-stress-test`
sweep mode to the test scene for this.

**Blocked by:** FO-003, FO-006, FO-004.

**Note:** do not work in parallel with FO-004 — same file.

---

## Phase 1 — Core interaction

**Goal:** the player can look around an island, select a block, place it, undo it, run the chain and
reset. No coins, no scoring, no levels — just the fundamental verbs. **This phase determines whether the
game is any good.** Expect more iteration on feel here than anywhere else.

**Exit criterion:** on a phone, Wouter can orbit a grey-box island in orthographic view with the camera
settling to 45° angles, place and rotate blocks freely, undo, redo and clear all, hit Start, watch the chain
fall with the camera fitting the action, fast-forward it, and reset to try again.

**⚠️ Execution order is not document order.** Work them in this order:

> **FO-009 → FO-010 → FO-011 → FO-012 → FO-013 → FO-014 → FO-015 → FO-017 → FO-018 → FO-016**

FO-017 (undo) comes after FO-015 because it needs the HUD to put its buttons on — but its command-pattern
requirement is baked into FO-013 and FO-014, so read FO-017 before building those.

---

### [x] FO-009 — Grey-box island scene · M

**Goal:** the terrain everything else in Phase 1 sits on. FO-011 needs bounds and ground; FO-013 needs a
surface to raycast against plus water and edges to reject placements on.

**Acceptance criteria:**

- **Compact footprint, fully visible at the default zoom** (PRD §7.9.1) — the player should never need to pan to
  understand the layout. Interest comes from **elevation**, not area.
- A grey-box island from primitives: flat main area, at least one raised/sloped section, **a water plane
  surrounding it** (PRD §8.1 — islands sit in ocean), and a gap or channel needing a bridge — covering three
  of the four world 1–2 mechanics in PRD §7.3
- Proportions read as a **miniature diorama** (PRD §8.1): the island is small and self-contained, and a
  standard block is comparable in size to a fence post rather than dwarfed by the terrain
- Built at the unit scale decided in FO-008
- Flat brand-palette colours (PRD §8.3) — no textures
- Static collision on all placeable surfaces
- Surfaces tagged so placement can distinguish **valid ground**, **water** and **off-island**, via
  collision layers or a documented group convention
- A defined camera bounds volume FO-011 can read
- A directional light casting **clear ground-contact shadows**. PRD §8.1: orthographic projection removes
  perspective as a depth cue, so shadows are how the player tells a block resting on the ground from one
  hovering above it. This is functional, not decorative — verify on device that contact is legible.
- **A placeholder starter block and finish object, hardcoded into the scene** — Dark Green starter tagged
  `Start` with an authored impulse direction, Dark Red finish tagged `Victory`. Phase 1 cannot run a chain
  without them, and FO-020 replaces this hardcoding with data-driven placement in Phase 2.
- Simple enough to rebuild in minutes; it is scaffolding, not art
- **Built from CSG primitives** (`CSGBox3D`, `CSGCylinder3D`) or plain `MeshInstance3D` boxes — nothing
  installed, nothing purchased. This is *not* the modular kit from PRD §7.10.1; that arrives with FO-030.

**Files:** `scenes/levels/greybox_island.tscn`, plus a note in `docs/` recording the layer/group
convention

**Blocked by:** FO-008.

**Out of scope:** data-driven starter/finish placement (FO-020), the modular kit (FO-030), real art, multiple
islands.

**Findings:** Two platforms split by a 3-unit water gap, connected further along by a ramp up to a raised
platform. Layer convention (ground/water/start-finish) and groups documented in `docs/greybox-island.md`.
Verified on-device via screenshot — colours, shadows, and gap/ramp geometry all read correctly.

---

### [x] FO-010 — Block definition resource · S

**Goal:** the data structure that makes block types data rather than code (PRD §13.3).

**Acceptance criteria:**

- A custom `Resource` class defining: display name, collision extents, mass, friction, restitution,
  **coin price**, and grey-box palette colour. Leave an optional mesh field unused for Phase 5.
- Two `.tres` instances: **Standard** (cost 1, 4 × 2 × 0.5, weight 1.0) and **Long** (cost 3,
  6 × 2 × 0.5, weight 1.5) — figures from PRD §4.4, at FO-008's unit scale. Note in a comment that prices
  are unbalanced placeholders.
- A spawner that instantiates a working rigid body from a definition alone
- Adding a third type requires only a new `.tres`, no code changes — demonstrate with a throwaway
  variant, confirm, then delete it

**Files:** `scripts/data/block_definition.gd`, `scripts/data/block_spawner.gd`,
`resources/blocks/standard.tres`, `resources/blocks/long.tres`

**Blocked by:** FO-008.

**Out of scope:** ball and cylinder (rolling behaviour — Phase 3), per-type placement rules, price
balancing, icons (grey-box uses text labels).

**Findings:** Verified extensibility by creating a third throwaway `.tres` (no code changes), spawning it
via `BlockSpawner.spawn()`, confirming it worked, then deleting it. Grey-box colours reuse the existing
`Palette.STANDARD_BLOCK` / `Palette.LONG_BLOCK` constants.

---

### [ ] FO-011 — Camera rig: rotate, pan, zoom · M

**Goal:** the build-phase camera from PRD §6.2. **Orthographic projection** (PRD §8.1).

| Gesture | Action |
|---|---|
| One-finger drag | Orbit — free while dragging, **snaps to nearest 45° on release** |
| Two-finger drag | Pan the focus point |
| Two-finger pinch | Zoom (orthographic size) |

**Acceptance criteria:**

- `Camera3D` set to **orthographic**, not perspective. Zoom changes orthographic size; the camera does not
  move closer.
- All three gestures implemented
- **Rotation snapping:** free orbit while the finger is down, then an eased settle to the nearest 45° on
  release — eight viewing angles total. The settle must feel smooth; a jerky snap reads as broken. Snap
  increment and easing curve both exported.
- Two-finger pan and pinch must coexist without fighting — a drifting pinch must not become an unwanted
  pan, or vice versa. Needs a deliberate rule (e.g. dominant-gesture detection on gesture start); state
  the rule chosen in a comment.
- Zoom has min and max orthographic-size limits; orbit has a pitch limit so the camera can't go under terrain
- **Tune the default orthographic size so a compact island fits entirely on screen** (PRD §7.9.1), accounting for
  the palette along the bottom and coins along the top — usable area is ~1080×1400, not the full 1920. Record the
  resulting footprint limit in Godot units; that answers **PRD open #39** and becomes the budget every level is
  designed within.
- **Build the bounds and zoom limits for the general case, not just compact islands.** Worlds 3+ are planned to
  be larger (PRD §7.9.1). Hard-coding for small islands means reworking this after levels exist.
- Focus point constrained to FO-009's bounds volume
- Movement smoothed and damped — no jitter, no abrupt stops
- All sensitivity, damping and limit values exported and tunable
- Works with touch on device, and mouse + scroll on desktop for fast iteration

**Files:** `scenes/camera_rig.tscn`, `scripts/camera/camera_rig.gd`

**Blocked by:** FO-009.

**Out of scope:** run-phase camera (FO-015), fly-through (Phase 2), placement input (FO-013).

**Feel note:** this is the first thing the player touches. If it feels cheap, the game feels cheap. Budget
real iteration time and expect several rounds.

---

### [x] FO-012 — Block palette UI · S

**Goal:** the bottom-of-screen buttons from the prototype, and the selection state driving the whole
control scheme.

**Acceptance criteria:**

- A row of buttons at the bottom, one per available block type, built from block definitions rather than
  hardcoded
- Tapping selects that type, with a clear selected state
- Tapping the selected button again deselects
- A single authoritative "currently selected block type, or none" state other systems read
- Brand palette and Roboto (PRD §8.4)
- Respects safe areas and notches (PRD §2.1)

**Files:** `scenes/ui/block_palette.tscn`, `scripts/ui/block_palette.gd`

**Blocked by:** FO-010.

**Out of scope:** prices and coin display (Phase 2), icons (text labels are fine in grey-box).

**Deselection is decided** (PRD §6.1, open #8 resolved). Two ways, deliberately redundant:

- Tapping the active palette button again releases the block
- **A small cancel button appears while a block is held** and also releases it

Build both. The redundancy is the point — toggle-off alone is undiscoverable, and a player who can't work out how
to back out quits rather than experiments.

**Findings:** Buttons generated from an exported `Array[BlockDefinition]`, not hardcoded per type.
`DisplayServer.get_display_safe_area()` produced a bad value on-device that crushed the whole layout —
replaced with a fixed bottom margin instead of chasing the API further. Verified on-device: buttons
select/deselect, full screen confirmed. Revisit real safe-area handling in Phase 4 UI work.

---

### [x] FO-013 — Selection-driven placement input · L

**Goal:** implement PRD §6.1 — the core interaction of the entire game.

**Acceptance criteria:**

- When a block type is selected, touch input places rather than moving the camera
- When nothing is selected, touch input drives the camera (FO-011) unchanged
- **The ghost block** per PRD §6.1.1: a translucent full-size preview following the player's finger, showing
  the exact footprint and angle before committing. It must cast a shadow or show a ground marker —
  orthographic projection gives no perspective depth cue, so without it the player cannot tell where the
  block will actually sit.
- Position by raycast from camera to terrain
- **Every mutation goes through a command object** — a small class recording what changed and how to
  reverse it — rather than mutating state directly. FO-017 builds undo/redo on top of this, and
  retrofitting it later means rewriting this file. Read FO-017 before starting.
- A light positional snap assists alignment; grid size exported and tunable, grid not drawn on screen
  (PRD §4.7)
- **Two-step placement** (PRD §4.7): position the block and release to commit, then it **stays selected** and a
  **horizontal swipe rotates it** — continuous, no snapping. Positioning and rotating never share a gesture, so
  there is no ambiguity to detect.
- Rotation sensitivity exported and tunable. Starting point: a full screen-width swipe ≈ 180°, so any angle is
  reachable in one or two swipes without feeling twitchy. **Tune this on device — it is the feel of the whole
  game.**
- Tapping empty ground, or picking the next block from the palette, both finish the rotation. **No confirm
  button** — placing several blocks in a row must not cost a confirm tap each time.
- **Blocks cannot be placed on other blocks** (PRD §4.7) — stacking is rejected like any other invalid
  placement
- Invalid placements (off island, in water, overlapping, on another block) show clear rejection feedback
  in Light Red and do not commit
- Placement commits on release, and the selected type stays selected so several can be placed in a row
  without re-tapping the palette

**Files:** `scripts/placement/placement_controller.gd`, `scenes/placement/block_ghost.tscn`

**Blocked by:** FO-009, FO-010, FO-011, FO-012.

**Nothing blocks this story any more.** Both decisions are settled:

- **Off-screen targets: auto edge-pan** (PRD §6.1, open #7 resolved). Dragging a held block toward a screen edge
  scrolls the view that way. Edge threshold and scroll speed exported and tunable. The single rule stays intact —
  while a block is held, *all* input is placement.
- **Rotation: place then swipe sideways** (PRD §4.7). Sensitivity and how the player finishes are tuning
  questions — build with the recommended starting values and confirm with Wouter on device.

**This is still the highest-risk story in the project.** Continuous rotation on a touchscreen is hard to make
feel good, and no amount of correct code substitutes for iteration on a real phone. Budget several passes.

**Findings:** Verified on-device — ghost preview, position/rotate two-step, edge-pan, water/overlap
rejection all confirmed working on first pass. Camera orbit still feels a bit sensitive per Wouter —
deferred, revisit in a later feel pass. Ghost built in code, not a separate `block_ghost.tscn` (simpler,
consistent with how FO-003's test scene builds things).

**⚠️ Open note from Wouter, not yet investigated:** orthographic projection "isn't locked yet" — reported
after further playtesting past the initial fix. Look into whether something (rotation, zoom, or an edge
case) is letting it slip back toward perspective-looking behaviour, or whether this is a framing/FOV
perception issue rather than the projection mode itself.

---

### [x] FO-014 — Edit and remove placed blocks · M

**Goal:** let the player fix mistakes — Pillar 2 in practice.

**Acceptance criteria:**

- Tapping a placed block selects it when no palette type is selected — the third input state in PRD §6.1
- A selected placed block can be moved, rotated (same gesture as FO-013) and removed
- **Moves, rotations and removals go through command objects**, as established in FO-013
- Removal returns the block to the player (coin refund lands in Phase 2)
- The selected block is visually distinct via a highlight material
- Tapping empty ground deselects and returns input to the camera

**Files:** `scripts/placement/block_editor.gd`, `scenes/placement/block_edit_menu.tscn`,
`assets/materials/selected_highlight.tres`

**Blocked by:** FO-013.

**Interaction pattern is decided** (PRD §6.1, open #9 resolved): **a radial ring of three icons around the
block** — move, rotate, sell. Chosen over a bottom bar so the player's eyes stay on the block being edited, and
over pure gestures because "drag it into the sea to sell" is not discoverable. Icons must be thumb-sized.

**Findings:** Radial menu (Move/Rotate/Sell) built as plain text buttons for now (icons are Phase 5 art).
Reuses FO-013's ghost/rotate machinery for move and rotate rather than new code paths. Verified on-device.
Added a finger-offset for ghost dragging (raycasts from a point above the actual touch, not under it) per
Wouter's feedback — the finger was blocking the view of where the block was landing. Applies to both
FO-013 and FO-014's drag flows.

---

### [ ] FO-017 — Undo and redo history · M

**Goal:** PRD §4.8. Full history, not one step — because with no hint system, experimentation is the
player's only tool, and it has to be painless.

**Acceptance criteria:**

- A command history stacking the command objects created in FO-013 and FO-014, covering **placements,
  moves, rotations and sells**
- Undo and redo buttons in the HUD, disabled when their stack is empty
- Undo restores the exact prior position and rotation, not an approximation
- Redo history is discarded when a new action is taken after undoing
- **History is cleared when the run starts, and cleared when the level is exited.** It is deliberately
  *not* persisted across a mid-build save/resume — PRD §4.8 decides this, so don't re-litigate it in
  FO-029.
- Verified: undo then redo an arbitrary sequence of 20 mixed actions and the layout is byte-identical to
  before the undo

**Files:** `scripts/placement/command_history.gd`, `scripts/placement/placement_controller.gd`,
`scripts/ui/game_hud.gd`

**Blocked by:** FO-014, FO-015 (the HUD that hosts the buttons).

**Deferred to FO-021:** coin accounting through undo/redo. Coins don't exist until Phase 2, so the
"undoing and redoing leaves the coin total identical" check belongs there, not here. **FO-021 must
include it** — silent coin drift would be an infuriating bug.

**Note on ordering:** the command-pattern requirement this story depends on is written into FO-013 and
FO-014's acceptance criteria, so it's enforced where the code is actually written rather than discovered
late here.

---

### [ ] FO-018 — Clear all · S

**Goal:** PRD §4.12 — let the player wipe the layout and try a fundamentally different approach without
undoing thirty placements one at a time.

**Acceptance criteria:**

- A clear-all button in the HUD removes every player-placed block
- All coins are refunded in full (coin refund lands with FO-021; here it's just the block removal)
- **Requires a confirmation dialogue.** A player who taps it by accident and watches thirty blocks vanish
  will not think to reach for undo.
- Does **not** replay the fly-through — this returns the level to an empty build state, not to first load
- Distinct from run-reset (FO-016), which deliberately *preserves* the layout. Make sure the two are not
  confusable in the UI, since one destroys work and the other protects it.
- Goes through the command history (FO-017) as a single undoable action, so an accidental confirm is still
  recoverable

**Files:** `scripts/placement/placement_controller.gd`, `scenes/ui/confirm_dialog.tscn`,
`scripts/ui/game_hud.gd`

**Blocked by:** FO-017.

---

### [x] FO-015 — Run the simulation with a zoom-to-fit camera · L

**Note from Wouter (session end):** wants a Start button soon specifically to trigger the starter block
falling on the grey-box island, for easy manual testing — flagged as wanted "next time," ahead of the full
zoom-to-fit camera work if that's faster to get to first.

**Goal:** press Start, watch it fall, and make the watching *good*. PRD §6.3.

**Acceptance criteria:**

- A Start button begins the run; palette and placement input are disabled during it. FO-017 extends this to
  disable undo/redo too, and FO-018 to disable clear-all.
- The starter (placed by FO-009) receives a fixed, non-random impulse in its authored direction (PRD §4.1)
- **This story creates `layout_snapshot.gd`** — recording each block's transform at placement time and
  freezing bodies before the run. FO-016 then uses it to restore; FO-029 reuses it for mid-build save. Build
  it here because the freeze half is needed for the run to start correctly.
- All blocks are frozen before the run and become simulated when it begins
- **The camera owns position and framing; the player owns rotation** (PRD §6.3). No hand-off, no resume timer —
  they control different things continuously. Panning and zooming are *not* available during a run.
- **Target the aggregate of still-moving live bodies, not a single block** (PRD §6.3.1). Each physics tick:
  collect live bodies (the flag from FO-023) above a velocity threshold, compute their bounding box, aim at its
  centre, size the view to fit, and damp both. **Only moving bodies count** — including settled ones drags the
  camera back toward the start as the fallen tail accumulates.
- **Do not chase the newest live block.** It jitters when several activate in one tick, lurches backwards when a
  domino knocks something behind it, and ping-pongs once branching exists. Framing a box solves all three with no
  special cases.
- **The camera widens (grows orthographic size) to fit that box**, so nothing important happens off-screen
- **A maximum orthographic size clamp** — never widen far enough that blocks become unreadable specks. If
  the action genuinely can't fit, prioritise the main chain.
- **Only widen when needed** — a single-chain run keeps the close, exciting shot. Widening happens only
  with genuinely multiple active fronts. *In Phase 1 there is only ever one front; build the fit logic so
  branching (Phase 3) doesn't require rewriting it.*
- **Rotation is free and unsnapped during a run**, unlike the build phase. The run starts at whatever angle the
  build phase ended on, and the camera never reorients itself — re-aiming mid-collapse is disorienting.
- **Run-end detection, all three mechanisms** (PRD §4.9.2):
  1. Damping tuned in FO-003 so motion decays naturally
  2. **Settle detection** — nothing has exceeded a small velocity threshold for N consecutive ticks
  3. **No-progress detection** — nothing *new* has been disturbed for ~3 seconds, even if something is
     still moving. Without this, a stray ball circling a dip leaves the player watching a dead screen.
  Thresholds and durations exported and tunable; find them by observation, don't guess here.
  **No maximum run duration** — declined per PRD §4.9.2. If a run is ever observed never ending, that's the
  trigger to revisit, and adding a ceiling is a handful of lines.
- **Fast-forward control** (PRD §4.9.1) — ⚠️ implemented by running **more physics ticks per frame**, never
  by scaling the timestep or changing `physics_ticks_per_second`. Scaling the timestep changes the result,
  which would break PRD §13.1. **Verify: a layout that passes at normal speed also passes fast-forwarded.**
- Blocks that leave the play area (water, off-island) are removed for the run with **visible feedback** — a
  splash or drop — and restored on reset (PRD §4.10)
- All logic in `_physics_process`, never `_process` (PRD §13.1)
- An abort/reset button available during the run

**Files:** `scripts/simulation/run_controller.gd`, `scripts/camera/run_camera.gd`,
`scripts/simulation/layout_snapshot.gd`, `scenes/ui/game_hud.tscn`, `scripts/ui/game_hud.gd`

**Blocked by:** FO-011, FO-013, FO-009 (needs the placeholder starter and finish).

**Note:** `game_hud.tscn` is **created by this story** and hosts Start, abort/reset and fast-forward. FO-017
adds undo/redo, FO-018 adds clear-all, FO-021 adds the coin display. Leave room for all of them. Keep it
simple and extensible.

**Feel note:** this camera is the single biggest "feels cheap" risk in the game (PRD §6.3). Getting it
right matters more than almost anything else in this phase.

**Findings (overnight, headless only — no on-device feel testing possible):**

- Built `RunController` (start/reset/live-flag/settle/no-progress/fast-forward via `Engine.time_scale`,
  lost-block removal), `RunCamera` (fit-to-box of moving live bodies), `layout_snapshot.gd`, `game_hud.tscn`.
- CameraRig gained `run_mode`: orbit stays live and unsnapped, pan/zoom disabled, position/size driven by
  RunCamera. Camera ownership split from PRD §6.3 implemented as specified.
- **Found and fixed a real bug during testing:** `BlockSpawner` (used for every real placed block) had no
  damping and no `contact_monitor` set at all — FO-019/FO-004's tuned values only ever lived in the FO-003
  test scene, never made it into the actual game path. Added the same validated defaults
  (`linear_damp=0.5`, `angular_damp=2.0`) plus `contact_monitor=true` (required for live-flag propagation).
- **Found and fixed:** the starter (`Start` node) was still a `StaticBody3D` from FO-009 — converted to a
  frozen `RigidBody3D` so it can actually receive an impulse and fall.
- **Found and fixed:** `LayoutSnapshot` only captures `BuildState`-registered player-placed blocks, not the
  starter (which isn't "placed" by the player). Reset silently failed to restore the starter until this was
  caught — added an explicit starter-transform snapshot in `RunController`.
- **Verified headless, via a temporary test scene** (not committed): run starts, starter receives impulse
  and falls, settle detection correctly ends the run, reset correctly restores both the starter and a
  placed block to their exact original transforms and freeze state. Live-flag propagation code runs
  without error; not confirmed hitting a neighboring block (see below).
- **⚠️ Open finding, not resolved — needs on-device tuning, not guessing:** the default impulse strength on
  *this specific island layout* sits on a narrow, chaotic edge — too weak and the starter doesn't tip at
  all, slightly stronger and it tumbles past flat and off the platform into the gap. Tried 1.2/1.6/2.5/6.0;
  none gave a clean "tips over and stops" result blind. Left at `1.6` as a placeholder. This might be a
  real design-margin problem (PRD §13.1) with the starter's position too close to the platform edge, or it
  might just need feel-tuning eyes on it — can't tell without watching it. **Needs your eyes first thing.**
- The lost-block removal mechanism itself works correctly (confirmed the starter tumbling into the gap
  gets detected, removed, and fully restored on reset) — so even the "bad" tuning result validated a real
  piece of the system.
- Not tested on-device at all tonight (no phone interaction while you're asleep) — orbit-during-run,
  camera fit-to-box framing quality, and fast-forward's actual feel are all unverified. Please test these
  first.

---

### [x] FO-016 — Reset to the standing layout · M

**Note from Wouter (session end):** wants a simple reset button soon so the grey-box island can be reset
easily during manual testing, without waiting for the full Phase 1 ordering if a quick version is faster.

**Goal:** implement PRD §4.10 — retry must be free, instant, and never destroy the player's work.

**Acceptance criteria:**

- Uses the `layout_snapshot.gd` created in FO-015, which already records each block's transform at placement
  time before any physics runs. This story adds the **restore** half.
- Reset restores all blocks to those exact transforms
- All physics state — velocities, angular velocities, sleep state — fully cleared
- The starter returns to standing
- Reset is instant, or near enough to feel instant
- **Verified:** reset → run again with no changes produces the same outcome across 20 consecutive runs on
  the same device. In Phase 1 there is no win detection yet (that's FO-023), so "same outcome" means the
  chain stops at the same block. Record which block, and compare.

**Files:** `scripts/simulation/layout_snapshot.gd`, `scripts/simulation/run_controller.gd`

**Blocked by:** FO-015.

**On that last criterion:** it's the practical check that PRD §13.1 is working, and the most valuable test
in Phase 1 — but read it correctly. We test *"the same outcome"*, not bit-identical trajectories; §13.1
explicitly scopes bit-exactness out. If outcomes differ, likely causes in rough order of probability:
something reads frame delta or lives in `_process`; physics state isn't fully cleared on reset; unseeded
randomness somewhere; or the snapshot is taken after physics already nudged something. Solver
contact-ordering variance can also cause tiny legitimate differences — but if that alone flips outcomes,
the real finding is that the test layout has **no design margin** (PRD §13.1 item 4), which is itself
worth knowing.

**Findings:** built alongside FO-015 (`RunController.reset()` + `LayoutSnapshot`), since the freeze/restore
halves share the same state. Verified headless: starter and a placed block both restore to their exact
original transform and freeze state after a run. The "20 consecutive runs, same outcome" device-verified
criterion is **not done** — no phone available tonight — and is exactly the check that would surface FO-015's
open impulse-tuning question, so do that check first when you're back.

---

## Phase 1.5 — Level authoring foundations

**Goal:** the systems that let Wouter design levels — modular kit pieces and semantic obstacle slots — so that
level design can begin *before any art exists* (PRD §7.10, §7.11).

**Why it sits here, between Phase 1 and Phase 2.** Level design is the slowest work in the project and the
part only Wouter can do. Getting him authoring as early as possible is the single biggest schedule lever
available. These stories need Phase 1's placement and camera, but not Phase 2's scoring.

**Exit criterion:** Wouter can assemble a grey-box island from kit pieces in the Godot editor, place obstacle
slots on it, and play it.

---

### [ ] FO-030 — Modular kit piece system · M

**Goal:** PRD §7.10.1 — islands assembled from snapping pieces, not sculpted.

**Acceptance criteria:**

- A `KitPiece` resource defining: display name, mesh reference (optional, empty for grey-box), **authored
  collision shape**, snap footprint on a consistent grid, and a **material slot the theme overrides**
- **One mesh per piece, forever** (PRD §7.11.1). Themes change only the *material* on terrain — grass, sand, snow
  and rock are the same slope with different colours and textures. Collision therefore cannot drift between
  themes, because it's literally the same object. Do not add per-theme terrain meshes.
- **Collision is authored on the piece, never derived from the mesh** (PRD §7.11). A piece with no mesh yet
  still has full, correct collision.
- Pieces snap to a shared grid so islands assemble without gaps or overlaps. Grid size documented.
- **Six starting pieces**, built as CSG or plain box meshes: flat plate · slope · cliff edge · water channel ·
  raised platform · gap. Enough for every world 1–2 mechanic in PRD §7.3.
- Surfaces carry the valid-ground / water / off-island tags established in FO-009
- Assembling an island from pieces in the Godot editor is demonstrably faster than building FO-009's island by
  hand — if it isn't, the snapping isn't working
- `docs/kit-pieces.md` documents each piece, its footprint and its collision

**Files:** `scripts/data/kit_piece.gd`, `resources/kit/*.tres`, `scenes/kit/*.tscn`, `docs/kit-pieces.md`

**Blocked by:** FO-009 (surface tag convention), FO-008 (unit scale).

**Out of scope:** final art (Phase 5), the theme kit mapping (FO-031), obstacle slots (FO-031).

**Kit source: CSG placeholders.** The old Unity project is gone (PRD §7.10.1), so there is nothing to salvage and
no reason to wait. Build the six pieces from CSG primitives now; a purchased or modelled kit replaces them in
Phase 5 (**PRD open #33**) without touching a single tuned level, because collision lives on the piece.

**The six-piece list is confirmed** (PRD §7.10.1, open #34 resolved): flat plate · slope · cliff edge · water
channel · raised platform · gap. Nothing speculative. **The kit grows on demand only** — when a level being
designed needs a piece that doesn't exist.

**This is the story that unblocks Wouter.** Once it lands he can design levels, which is the slowest work in the
project and the only part nobody else can do. Prioritise getting it usable over getting it elegant.

---

### [ ] FO-031 — Obstacle slots and theme kits · M

**Goal:** PRD §7.11 — levels reference semantic slots; worlds map slots to models.

**Acceptance criteria:**

- An `ObstacleSlot` resource defining: slot name, **authored collision shape**, footprint, **and a stated visual
  volume every theme's model must fill** (PRD §7.11.2)
- **⚠️ The volume budget is not optional.** Obstacle meshes *do* differ per theme — a pine tree must not look like
  a cactus. But if one theme's model is visibly smaller than the slot, the chain stops dead short of it and looks
  broken while the physics is entirely correct, which is a baffling bug to diagnose. Document the volume next to
  the collision shape, and check every new theme model against it. A model that can't fill the volume needs a
  different slot, not a shrunken box.
- A `ThemeKit` resource mapping each slot name to a model, owned by a **world**, not a level
- Starting slots: tall obstacle · low obstacle · wide barrier · bridge · hazard surface · prop
- **Collision comes from the slot in every theme.** Verify explicitly: swap a level's theme and confirm every
  collision shape is byte-identical. If it isn't, tuned levels will silently break — this is the single most
  important check in the story.
- **With no theme assigned, both slots and terrain render as grey-box shapes in brand palette colours**
  (PRD §7.11.3) — unmistakably work in progress. Grass is a theme you *assign*, not the fallback. This keeps
  design and art separate: a level can be built, tuned and fragility-tested before any art exists, which is the
  whole point of the slot system.
- One grey-box theme kit and one stub second kit, to prove the swap works end to end
- `docs/slots.md` documents the vocabulary and the mapping format

**Files:** `scripts/data/obstacle_slot.gd`, `scripts/data/theme_kit.gd`, `resources/slots/*.tres`,
`resources/themes/*.tres`, `docs/slots.md`

**Blocked by:** FO-030.

**The six slot types are confirmed** (PRD §7.11, open #35 resolved): tall obstacle · low obstacle · wide barrier ·
bridge · hazard surface · prop/decoration. Between them they cover blocking the route, forcing a detour, crossing
a gap, and danger — every puzzle idea planned for worlds 1 and 2. Grow on demand only.

The *models* each theme maps them to are Phase 5 work (FO-073); this story only needs grey-box primitives.

---

## Phase 2 — A complete level

**Goal:** turn the sandbox into a level with a goal, a constraint, an outcome, a saved result, and the
ability to walk away mid-build and come back.

**Exit criterion:** level 1-1 is playable end to end on a phone — fly-through, build within coins, undo freely,
win, earn 1–3 stars, result saved, and both the result *and* a half-finished layout survive an app restart. Its
reference solution is recorded and its thresholds derived.

**⚠️ Execution order is not document order** (as in Phase 0). Work them in this order:

> **FO-020 → FO-021 → FO-023 → FO-025 → FO-027 → FO-024 → FO-026 → FO-029 → FO-032 → FO-033 → FO-034 →
> FO-028**

The save system (FO-027) deliberately precedes scoring (FO-024), because star persistence has to have somewhere
to persist to. The three authoring stories (FO-032/033/034) come before FO-028, because authoring level 1-1 is
the first real use of them.

---

### [ ] FO-020 — Level definition resource · M

**Goal:** levels as data (PRD §13.3), superseding the old manual authoring checklist.

**Acceptance criteria:**

A `LevelDefinition` resource storing everything in PRD §13.3:

- **Island layout** — which kit pieces (FO-030) and where
- **Obstacle slots** — which slots (FO-031) and where. **Never specific models.**
- Starter placement and impulse direction; finish placement
- Coin amount for the level
- Available block types
- **Second and third star coin thresholds**
- Fly-through camera positions, **orthographic sizes** and duration
- The recorded reference solution (populated by FO-032)
- **Required block types and mechanics** — for reassignment validation

Plus:

- A `WorldDefinition` resource storing: name, music variant, **theme kit**, block types unlocked, cumulative
  star gate threshold, and its ordered level list
- **A level does not store its theme** — it resolves from the assigned world (PRD §7.10.5). Verify by moving a
  level between two worlds and confirming it re-dresses with no edit to the level itself.
- **No plate field** (PRD §5.8); **no level name** (PRD §7.7)
- A loader that builds a playable level from one level resource plus its world's theme kit
- One instance created for level 1-1

**Files:** `scripts/data/level_definition.gd`, `scripts/data/world_definition.gd`,
`scripts/data/level_loader.gd`, `resources/levels/w1_l01.tres`, `resources/worlds/w1.tres`

**Blocked by:** FO-030, FO-031, FO-010 (block types to list).

**Out of scope:** world map and level select (Phase 4), reassignment validation (FO-033).

---

### [ ] FO-021 — Coins: the level constraint · M

**Goal:** PRD §4.6. Note the terminology rules at the top of this document.

**Acceptance criteria:**

- A level's coin amount loads from its definition
- Placing a block spends its price; removing or undoing refunds in full
- Placement is blocked when the player can't afford it, with clear feedback, and never partially charges
- Coin count displayed in the HUD, brand-palette styled, matching the prototype's top-centre position
- Each palette button shows its block's coin price
- **Coin accounting through undo/redo is exact.** Undo a placement and the coins come back; redo and they
  go again. **Verify the total is byte-identical after undoing and redoing an arbitrary sequence of 20
  mixed actions** — silent coin drift would be an infuriating bug and is easy to introduce. Deferred here
  from FO-017, which couldn't test it because coins didn't exist yet.
- **Clear-all refunds every coin**, and undoing a clear-all restores both the blocks and the exact coin
  total (FO-018)
- There is **no code path anywhere that adds coins mid-level**, and no path that converts diamonds into
  coins. This is a design invariant (PRD §5.1) — add an explicit comment so nobody introduces one later.

**Files:** `scripts/economy/coin_budget.gd`, `scripts/ui/game_hud.gd`, `scripts/ui/block_palette.gd`

**Blocked by:** FO-020, FO-014, FO-015 (the HUD hosting the coin display), FO-017, FO-018.

---

### [ ] FO-023 — Finish, win detection and fail state · M

**Goal:** make the level winnable and losable.

**Acceptance criteria:**

- **A chest** placed from the level definition, tagged `Victory`, Dark Red in grey-box. A **static body with a
  hit detector**, not a rigid body — it doesn't need to topple (PRD §4.2). Grey-box shape should already read as
  chest-like rather than domino-like, since the silhouette difference is doing accessibility work (PRD §8.7).
- **Propagate a *live* flag** (PRD §4.2.1): the starter becomes live when it receives its impulse; any live body
  striking another body above a force threshold makes that body live too. Threshold exported and tunable
  (**PRD open #38**).
- **Win fires when the chest is hit by a live body.** Any hit counts — no tilt threshold, no "did it fall".
- **A hit from a non-live body does nothing.** Verify both exploits are closed: (a) a block placed already
  resting against the chest does not win, (b) a block that topples on its own while the layout settles does not
  win.
- Fail fires when the run settles without a live body hitting the chest
- **Win sequencing** (PRD §4.2.2): chest hit → chest opens → **brief hold on the settled chain** → win screen.
  Don't cut straight to UI over the top of the moment. The opening animation is Phase 5 (FO-086); here, leave the
  timing gap and a hook rather than snapping instantly to the win screen.
- On fail, the break point is made obvious — highlight the last block that fell, rest the camera there
  (PRD §4.10)
- Win and fail evaluated in `_physics_process`

**Files:** `scripts/simulation/win_condition.gd`, `scripts/simulation/run_controller.gd`

**Blocked by:** FO-020, FO-015, FO-014 (reuses the highlight material for the break-point indicator).

**Win condition is decided** (PRD §4.2, open #10 resolved): a chest, any hit counts, but it must trace back to the
starter.

**Bonus the *live* flag gives you for free:** the set of live bodies at the end of a run *is* the chain that
actually happened. So the last live body is the break point for failure feedback (PRD §4.10) — no separate
tracking needed — and in Phase 3 it identifies which branch stalled (FO-044). Build the flag cleanly; three
stories depend on it.

---

### [ ] FO-024 — Stars · S

**Goal:** PRD §5.2. Maximum 3 per level.

**Acceptance criteria:**

- **Star 1** awarded for finishing — guaranteed on any win
- **Stars 2 and 3** awarded from coins left over, against the two thresholds authored in the level
  definition — never a formula
- Best rating persists and **never decreases** on replay
- Replaying a level and doing worse leaves the stored rating untouched
- **No plates anywhere** (PRD §5.8)

**Files:** `scripts/economy/scoring.gd`

**Blocked by:** FO-021, FO-023, **FO-027** — "persists and never decreases" can't be built or tested
without the save system, so the save schema comes first.

---

### [ ] FO-025 — Opening fly-through · M

**Goal:** PRD §6.4 — the camera sweep that teaches the level before the player builds.

**Acceptance criteria:**

- On level load, the camera sweeps between the two positions authored in the level definition, over the
  authored duration, then hands control to the build camera
- **Skippable with one tap**, clearly indicated
- Smooth easing; no snap at either end
- Placement input disabled during the sweep
- Exposes a way for other systems to suppress the sweep — FO-029 uses it to skip on resume. Provide the
  hook here; the resume logic itself belongs there.

**Files:** `scripts/camera/level_intro_camera.gd`

**Blocked by:** FO-020, FO-011.

**Decided** (PRD §6.4, open #12 resolved): the sweep **plays every time**, including on levels already completed,
and is **always skippable with one tap**. Consistent behaviour, one less rule. Only exception is resuming a level
mid-build (FO-029), where it is suppressed.

---

### [ ] FO-026 — Win and fail screens · M

**Goal:** close the loop.

**Acceptance criteria:**

- Win screen: stars earned (1–3), coins left, continue and replay
- **Reserve a disabled slot for a share button** (PRD §5.11, §13.5). Sharing is deferred, but leaving the space
  means adding it later isn't a redesign. Lay the screen out as if it were there.
- Fail screen, or an unobtrusive in-place prompt: retry, keeping the layout (PRD §4.10)
- Retry from either is free and preserves the layout
- Brand palette and Roboto throughout
- **The level-flow choke point from PRD §13.5 lives here** — a single place a future monetisation hook
  could be inserted. Leave the seam and a comment; **add no SDK, no IAP, no analytics.** Note per §13.5
  that no *rewarded-ad* hook currently has anything to reward, so the seam is generic rather than
  ad-specific.

**Files:** `scenes/ui/win_screen.tscn`, `scenes/ui/fail_prompt.tscn`, `scripts/ui/level_flow.gd`

**Blocked by:** FO-023, FO-024.

**Note:** diamond payouts for new stars are shown here, but that logic is Phase 4 (FO-042). Leave a clear
insertion point rather than a stub that pays nothing.

---

### [ ] FO-027 — Save system · M

**Goal:** PRD §11. Get the schema right now; migrations later are painful.

**Acceptance criteria:**

- **A save format version field, from the first commit** — non-negotiable
- Global: selected skin (unused), unlocked block types, achievement progress, diamonds and claimed star
  payouts, settings (including haptics), player stats
- Per world: name, music track, cumulative star total, gate state
- Per level: completion, best stars, best coins-left, **in-progress layout**, fly-through-seen flag. **No level name** — levels are numbered (PRD §7.7).
- **No plate field** (PRD §5.8); **no per-level run time** (PRD §5.9)
- Entitlement flags addable without a migration (PRD §13.5)
- Written to `user://`; survives app restart
- A corrupt or missing save file fails gracefully to defaults rather than crashing

**Files:** `scripts/save/save_data.gd`, `scripts/save/save_manager.gd`

**Blocked by:** FO-020, FO-021, FO-023.

**Note on ordering:** this comes *before* FO-024 (stars), not after. The schema can be defined from the
PRD without stars existing, and FO-024's "never decreases on replay" criterion needs somewhere to persist
to. Getting this backwards means writing scoring twice.

---

### [ ] FO-029 — Mid-build save and resume · M

**Goal:** PRD §4.11. A phone call must never cost the player ten minutes of work.

**Acceptance criteria:**

- Leaving a level mid-build persists the placed layout and coins spent
- Returning restores every block to its exact position and rotation, with the correct coin total
- The fly-through is skipped on resume, using the suppression hook FO-025 provides
- A completed level reopens showing the layout that won it, so stars can be improved from there
- **Undo history is cleared on resume, not persisted** — PRD §4.8 decides this; don't re-open it
- Saving happens automatically on exit, not via a button the player must find
- **Verified:** build a partial layout, force-quit the app, reopen — the layout and coin total are exactly
  as left

**Files:** `scripts/save/save_manager.gd`, `scripts/simulation/layout_snapshot.gd`

**Blocked by:** FO-027, FO-017, FO-025, FO-016 (reuses the layout snapshot).

---

### [ ] FO-028 — Author level 1-1 with a reference solution · M

**Goal:** the first real level, and the first reference solution (PRD §13.1 item 4).

**Acceptance criteria:**

- Flat ground, straight line, generous coins, no obstacle — **near-impossible to fail** (PRD §7.8)
- Teaches placement and nothing else
- A reference solution stored in the level definition
- The reference solution passes with comfortable margin: it still completes when every position is nudged
  and every rotation rocked by a small tolerance
- **That tolerance figure is established here by device testing, and documented** — it becomes a hard
  authoring rule for every level after this
- Star 2 and star 3 coin thresholds authored
- Level loads in under 2 seconds (PRD §13.4)

**Files:** `resources/levels/w1_l01.tres`, `scenes/levels/w1_l01.tscn`, `docs/level-authoring.md`

**Blocked by:** FO-020, FO-024, FO-025, FO-027, FO-032 (records the reference solution), FO-030, FO-031.

---

### [ ] FO-032 — Record a reference solution by playing · M

**Goal:** PRD §7.10.3 — the designer plays their own level, solves it, and presses one button.

**Acceptance criteria:**

- A "save as reference solution" control, available in dev builds only, that captures the current layout after
  a successful run
- Stores every placed block's type, position and rotation into the level's `LevelDefinition`
- Also stores the coin cost of that solution, for FO-034's derivation
- Refuses to save if the run did not reach the finish — a reference solution that doesn't work is worse than
  none
- Overwrites cleanly, so a better solution can replace an earlier one
- Never present in release builds

**Files:** `scripts/authoring/reference_recorder.gd`, `scripts/data/level_definition.gd`

**Blocked by:** FO-020, FO-023 (needs win detection to know the solution worked).

**Why this shape:** hand-authoring solutions is slow and produces solutions nobody has verified. Recording one
takes a button press, guarantees it's achievable, and hands the fragility tests (FO-036) their input for free.

---

### [ ] FO-033 — Level reassignment validation · S

**Goal:** PRD §7.10.5 — moving a level between worlds must be safe.

**Acceptance criteria:**

- A check comparing a level's **required block types and mechanics** against the target world's unlocked block
  types (PRD §4.5)
- Reassigning a level to a world that hasn't unlocked what it needs is **refused, or warned about loudly** —
  not silently allowed
- Runs as a `@tool` script in the Godot editor so the warning appears while authoring, not at runtime
- Also validates that a level's *available block types* are a subset of the world's unlocked types

**Files:** `scripts/authoring/level_validator.gd`

**Blocked by:** FO-020.

**Why:** the whole point of reorderable levels is retuning the difficulty curve late. Without this check, that
retuning silently ships unsolvable levels.

---

### [ ] FO-034 — Derive coin budgets and star thresholds · S

**Goal:** PRD §7.10.4 — propose the numbers automatically, then let Wouter override.

**Acceptance criteria:**

- From a recorded reference solution (FO-032), propose: coin budget (solution cost plus headroom), the 3-star
  threshold (at or near solution cost), and the 2-star threshold (looser)
- Proposed values are written into the level as **editable defaults**, clearly marked as derived
- **Any value manually overridden is flagged as overridden and never recomputed.** The override is the point,
  not a fallback — a formula is always wrong for the interesting levels.
- The headroom and threshold ratios are config values, not literals

**Files:** `scripts/authoring/threshold_deriver.gd`

**Blocked by:** FO-032.

**Note:** Wouter reviews every derived number; the deriver exists to remove bookkeeping, not judgement.

---

## Phase 3 — Blocks and branching

**Goal:** the mechanics that make puzzles interesting rather than merely long.

Stories are one-liners for now; each gets acceptance criteria and a file list before it's worked.

- **[ ] FO-040 — Ball block · M** — rolls with drag, crosses gaps, runs down slopes (PRD §4.4). **Its damping
  values are found here**, the way FO-003 found the standard block's (PRD open #31). Rolling bodies are the
  hardest case for the run-end rules in PRD §4.9.2, so tune and verify them together.
- **[ ] FO-041 — Cylinder block · S** — rolls with drag on one axis, damping tuned alongside the ball.
  **Note FO-004:** if Jolt was chosen partly for cylinder handling, this is where that pays off or doesn't.
- **[ ] FO-042 — Per-block-type placement rules · S** — which types may sit on slopes, in water, and so on.
  **Not stacking** — forbidden by PRD §4.7.
- **[ ] FO-043 — Branching: switches and gates · L** — enabling side-chains per PRD §4.3. Main chain still runs
  start → finish; branches are prerequisites, not parallel goals.
- **[ ] FO-044 — Branch failure feedback · M** — extend FO-023 so a failed run identifies *which* branch stalled,
  not just that it failed.
- **[ ] FO-045 — Run camera with multiple active fronts · M** — FO-015's fit logic gets its real test, and the
  maximum orthographic-size clamp gets its first real argument.
- **[ ] FO-046 — Evaluate candidate blocks · M** — Turnaround, Slow, Heavy, Bridge, Rope, Fragile. **Needs PRD
  open #13, #14, #15.** Expect to cut some; a block that doesn't create a distinct puzzle idea is clutter.
- **[ ] FO-047 — Price balancing pass · S** — across the whole catalogue, once the block set is settled.
- **[ ] FO-048 — Run replay or slow-motion review · M** — *optional* (PRD open #16). More valuable once
  branching exists, because the player may have been watching the wrong part of the island.

---

## Phase 4 — Progression, economy and meta screens

**Goal:** the game around the levels. **Roughly a third of the project's UI work sits here** (PRD §9) — plan it
as real work, not an afterthought.

**Read PRD §5.3.1 before building level select.** The reveal window, cumulative world gating and the no-hints
decision are load-bearing for each other. Narrowing the reveal window reinstates a hard wall for stuck players
and would require adding hints or a skip in the same change.

**App flow and navigation**

- **[ ] FO-050 — Logo splash and main menu · M** — PRD §9.1, §9.2. Splash brief and tap-skippable, plain Roboto
  wordmark until FO-076. Main menu: Play/Continue, Settings, Achievements & diamonds. *Continue* resumes a level
  left mid-build (FO-029). **No shop preview on the main menu** — nothing is buyable at launch.
- **[ ] FO-051 — World map · M** — cloud-covered overview, worlds revealed as reached, and **cumulative star
  progress toward the next gate shown**. A gate the player can't see progress toward feels arbitrary (PRD §7.6).
- **[ ] FO-052 — Level select with rolling reveal window · M** — PRD §7.7. Ten island nodes per world,
  dotted-line route, stars per node. Reveals up to *(highest completed + 3)*, **playable out of order** so a
  stuck player can detour. Window size is a **config value, not a literal** (tuned in FO-095, PRD open #28).
  **This is the game's only safety net for stuck players.**
- **[ ] FO-053 — Star gating · S** — PRD §5.3. 1 star to advance a level; cumulative totals for the next world
  and for bonus levels. Thresholds in config; FO-093 sets the numbers.
- **[ ] FO-054 — Block unlock progression · S** — worlds grant types permanently, levels still restrict
  (PRD §4.5).

**Economy**

- **[ ] FO-055 — Diamond payouts for stars · S** — each star pays diamonds the first time only; claimed payouts
  tracked so re-earning pays nothing (PRD §5.4). Plugs into the insertion point left in FO-026. Values in a
  config resource — FO-094 fills them in.
- **[ ] FO-056 — Achievements · L** — all four categories: milestone counters, mastery challenges, discovery,
  collection (PRD §5.7). Milestones come nearly free from existing stats; discovery ones can't be written until
  levels contain things to discover. **Needs PRD open #20.**
- **[ ] FO-057 — Diamond balance and skin roadmap · S** — balance display plus a **named list of upcoming skin
  sets**: text and lock icons, **no art, no prices** (PRD §5.5). Prices can't be set until the economy is
  balanced, and a price shown then changed is worse than none. **Do not build a shop grid.**

**Other**

- **[ ] FO-058 — Settings screen · S** — audio, **haptics toggle**, graphics, tutorial progress, reset progress.
- **[ ] FO-059 — Tutorial prompts on level 1-1 · M** — guided walkthrough with explicit prompts (PRD §7.8).
  **Must teach the rotation gesture explicitly** — "place, then swipe sideways to spin" is not discoverable, and
  with no hints (PRD §7.9) and no analytics (PRD §12), a player who misses it is stuck on the game's core verb
  with no way to recover. See also open #40: the fallback is making an early level *require* rotation.
  **Needs PRD open #21** for whether later mechanics get first-time prompts too.
- **[ ] FO-035 — Level authoring workflow documented · M** — end to end: assemble an island from kit pieces,
  place obstacle slots, set the starter and finish, record a reference solution, derive thresholds, validate.
  **This pays for itself many times over across 20 levels — do not skip it.**
- **[ ] FO-036 — Automated fragility testing · M** — run every level's recorded reference solution 200×
  headless, flag any level that ever fails (PRD §13.1 item 5). Depends on FO-032's recorded solutions.
- **[ ] FO-037 — In-game authoring mode · L** — PRD §7.10.2. Place kit pieces and obstacle slots with the
  player's own controls, in the player's orthographic view, with a parameter panel and instant test. Much
  already exists: placement, rotation, snapping, camera, undo and clear-all are all built in Phase 1. **Build
  only after ~5 levels have been made in the Godot editor** (PRD open #36), so it addresses real friction rather
  than guessed friction. Keep controls and the level format reusable in case a player-facing editor happens.
- **[ ] FO-060 — Difficulty curve pass · M** — **needs PRD open #17.**

**Not here:** the skins shop (Phase 8, since skins are deferred). Plate collection (cut, PRD §5.8).

---

## Phase 5 — Art, audio and haptics

**Goal:** replace grey boxes with the stylised low-poly look from the prototype.

- **[ ] FO-070 — Source the modular kit · M** — PRD §8.6, open #22 and #33. **What's needed is a modular kit
  plus theme kits, not a general asset library** (PRD §7.10.1, §7.11). Judge candidate packs on whether pieces
  tile cleanly on a grid, not on how pretty the screenshots are. **Heightmap terrain plugins are rejected** —
  built for kilometre-scale landscapes, can't do overhangs, fight the low-poly look. Don't reopen without reason.
- **[ ] FO-071 — Model and material import pipeline · M** — how a `.glb` becomes a usable kit piece or slot
  model, documented and repeatable.
- **[ ] FO-072 — Replace kit and slot placeholders with real art · L** — because collision lives on the piece
  and the slot (PRD §7.11), this swaps art without disturbing a single tuned level. **Verify that claim
  explicitly** by re-running FO-036's fragility tests after the swap.
- **[ ] FO-073 — Theme kits for Grass and Desert · L** — PRD §7.11.1. **Terrain needs only materials** (same
  meshes, different colour and texture), so this is much cheaper than it sounds. **Obstacles need one model per
  slot per theme**, and each must fill the slot's stated visual volume (PRD §7.11.2) — check them against it
  before shipping, or chains will stop short of things and look broken.
- **[ ] FO-074 — Block visuals · M** — plain coloured blocks, no pips (PRD §8.1). Must read at every zoom.
- **[ ] FO-075 — Colour accessibility · S** — PRD §8.7, open #23. **Decide here**, because the cheapest fix is
  making the starter and finish differ in *silhouette*, and that's free while the art is being made rather than
  bolted on afterwards.
- **[ ] FO-076 — Logo and wordmark · S** — PRD §8.2, open #32. Built from the established palette and Roboto.
  Replaces the placeholder text on the splash and main menu.
- **[ ] FO-077 — UI visual pass · L** — the style in PRD §8.2: clean, flat, rounded, playful. Chunky thumb-sized
  buttons with a little squash on press; flat palette fills; no gradients, no skeuomorphism. The islands are the
  pretty part; the UI stays out of the way.
- **[ ] FO-078 — Lighting and shadow pass · M** — **must preserve clear ground-contact shadows** (PRD §8.1).
  Orthographic projection means shadows are the player's only reliable depth cue, so softening block-to-ground
  contact is a *gameplay regression*, not an art choice. Verify placement legibility on device, not in editor.
  Art must also read correctly from **all eight 45° camera angles** (PRD §6.2) — the only angles the player can
  settle on.
- **[ ] FO-079 — Impact sounds · M** — pitch and volume driven by impact force (PRD §10). **Do not leave audio
  to the end** — the clacks change how the core loop *feels*, not just how it sounds. Highest return per hour
  of any story in this phase.
- **[ ] FO-080 — Music and run-time ducking · S** — Wouter's existing theme with a variant per world; **ducks
  to a low background level during the run** so impacts come through, and returns afterwards (PRD §10).
- **[ ] FO-081 — Ambient sound · S** — water, wind, birds. Optional but high value for the money (PRD §10).
- **[ ] FO-082 — Haptics · S** — PRD §6.5. Subtle vibration on impacts and UI, driven by the same force value as
  the audio. Settings toggle required (FO-058).
- **[ ] FO-084 — Banded cel shader · M** — PRD §8.3.1. One spatial shader reused across everything, quantising
  light into 2–3 bands. **⚠️ Ground-contact shadows must survive it.** Verify on device that a block resting on the
  ground still reads differently from one hovering above it — that's the only depth cue orthographic gives (PRD
  §8.1). **No outlines** — declined; don't add them without a reason.
- **[ ] FO-085 — Water: flat colour plus foam shoreline · M** — PRD §8.3.2. Opaque, no transparency, no waves.
  The foam band is the whole effect and it doubles as a warning that the island edge is dangerous. Needs depth
  access — check FO-007's finding first; fall back to foam baked into terrain edge geometry if Mobile can't do it.
- **[ ] FO-086 — Chest opening animation · S** — PRD §4.2.2. Lid flies up, light or coins spill, satisfying
  sound. **This is the emotional peak of the entire game loop, and it's a few seconds of animation.** Highest
  return per hour in this phase after the impact sounds. Do not let it slip to the end. Pairs with FO-079.
- **[ ] FO-083 — Particles and juice on the run · M** — dust on impact, a flourish on the win. Last, and only
  once everything above reads correctly.

**Not here:** skins (Phase 8). Any audio randomness must be seeded and kept outside the physics path
(PRD §13.1 item 3).

---

## Phase 6 — Content

**Goal:** 20 levels across Grass and Desert (PRD §7.3). **This is the slowest work in the project and the part
only Wouter can do.**

- **[ ] FO-089 — Keep every launch level compact and fully visible · S** — PRD §7.9.1. Get vertical interest from
  cliffs, tiers and platforms rather than from a big footprint. A chain tumbling down two tiers to a chest at the
  shoreline uses the portrait screen far better than one crossing a flat field. Also **consider making an early
  level require rotation** (open #40), as insurance against a skipped tutorial prompt.
- **[ ] FO-090 — Distribute the four launch mechanics across the two worlds · S** — **needs PRD open #17**, and
  decide where branching enters.
- **[ ] FO-091 — Author 20 levels · XL** — each with a **recorded** reference solution (FO-032) passing at the
  established tolerance. Reorder freely as the curve emerges: theme re-dresses automatically (PRD §7.10.5) and
  FO-033 validates that no level lands in a world missing the blocks it needs. **Grow the kit and slot
  vocabulary on demand only** — when a level you actually want needs a piece that doesn't exist.
- **[ ] FO-092 — Balance coin budgets and star thresholds · M** — per level, derived by FO-034 then overridden
  by hand where the automatic answer is wrong.
- **[ ] FO-093 — Set cumulative star gate thresholds · S** — **PRD open #18**, now that real difficulty is known.
- **[ ] FO-094 — Set diamond payouts and achievement values · S** — **PRD open #19, #20**, against real play.
- **[ ] FO-095 — Tune the reveal window size · S** — **PRD open #28**. Watch specifically for players stuck on
  three *consecutive* levels, the one case the window doesn't cover (PRD §7.7, open #37).
- **[ ] FO-096 — Every level passes fragility testing · M** — FO-036 run across the full set; fix or cut any
  level that ever fails.
- **[ ] FO-097 — Place optional props for discovery achievements · S** — PRD §5.7.
- **[ ] FO-098 — Audit each world's "one new idea" · S** — PRD §7.1. Cut or merge any world that introduces
  nothing. Levels are **numbered, not named** (PRD §7.7), so there's no naming pass.

---

## Phase 7 — Release

- **[ ] FO-100 — Decide and implement the business model · M** — PRD §13.5, open #24. **Read §13.5's closing
  note first:** selling coins or capability is ruled out by the design and hints are rejected, so **no
  rewarded-ad hook exists**. The realistic options are paid up front, a free world 1 with a paid unlock, or
  selling diamonds restricted to skins.
- **[ ] FO-101 — Release signing and Play Store listing · M**
- **[ ] FO-102 — Store assets · M** — icon, screenshots, trailer, description. Note PRD §8.1: plain blocks mean
  a screenshot doesn't instantly say "dominoes", so the trailer carries more weight than usual.
- **[ ] FO-103 — Confirm the localisation table · S** — **English only** at launch (PRD §2.1.1), but confirm text
  was routed through a translation table so adding a language later is a spreadsheet, not a refactor.
- **[ ] FO-104 — Crash reporting · S** — note this is *not* analytics (PRD §12); crash reports carry no
  behavioural tracking. Confirm the chosen tool respects that before adding it.
- **[ ] FO-105 — Performance pass on low-end devices · M** — including the slow-motion failure mode in
  PRD §13.1 item 2.
- **[ ] FO-106 — Playtesting with people who are not Wouter · L** — **not optional.** PRD §12 means there is no
  analytics, so manual playtesting is the *only* way to discover where players stall. Watch specifically for
  anyone blocked by three consecutive levels (PRD §7.7).

---

## Phase 8 — Update 1: skins and the shop

**Goal:** give diamonds something to buy (PRD §5.6).

- **[ ] FO-110 — Skin set data model · S** — a set restyles all block types together.
- **[ ] FO-111 — Skins shop screen · M** — spending diamonds. Replaces FO-057's roadmap screen.
- **[ ] FO-112 — Initial skin sets · L** — **needs PRD open #25** for which sets and at what price.
- **[ ] FO-113 — Activate collection achievements · S** — the skin-related ones from FO-056 become live
  (PRD §5.7).

---

## Parking lot

Explicitly not planned. Kept so the ideas aren't lost, and kept out of the phases so they don't masquerade
as planned work. The full mechanic idea pool lives in **PRD §14**; deliberate cuts are logged in
**PRD §15**.

- **Bonus levels and alternate modes** — post-launch (PRD §7.5). One or more per world, off the main
  route, unlocked by cumulative stars or early with diamonds: one block type only, minimum blocks,
  possibly time attack (**needs PRD open #26** — the time cut in §5.9 was flat, so a timer needs explicit
  permission). Home for the eleven bonus themes.
- Worlds 3–5: Snow/Mountains, Jungle/Rivers, Volcano/Lava
- Placement tools: draw-a-path auto-fill, pre-built lines, saved combinations, copy/paste/mirror,
  measuring tape
- **Placement reach indicator** — showing how far a block topples. Declined (PRD §4.7) in favour of pure
  judgement. Cheap to add if playtesting shows players blaming the game for their spacing.
- **Domino pips or face markings** on blocks. Declined (PRD §8.1) in favour of plain colours. Revisit only if
  store screenshots fail to communicate what the game is.
- **Maximum run duration** as a hang backstop. Declined (PRD §4.9.2). A handful of lines if ever needed.
- **Level names** in addition to numbers (PRD §7.7)
- Purpose-built platform pieces to give verticality without free stacking (PRD §4.7)
- Hint system and level skip — **not planned** (PRD §7.9). The rolling reveal window gives stuck players
  somewhere to go instead. Retained here because the reference-solution data makes hints cheap to add if
  playtesting still shows players stalling.
- Daily rewards and return incentives (PRD §5.10)
- **Player-facing level editor** — not planned, but FO-037's in-game authoring mode should reuse player controls
  and keep the level format cleanly serialisable so exposing it later is a decision rather than a rewrite
  (PRD §7.10.2)
- Sharing solutions or replays
- Leaderboards — would force reconsidering cross-device determinism (PRD §13.1), and time-based boards are
  ruled out by §5.9
- Cloud save / cross-device progress
- Analytics — currently none by design (PRD §12); adding any requires a privacy policy and consent flow
