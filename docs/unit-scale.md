# Unit scale

Resolves PRD open decision #5 (§4.4, §16 #2-adjacent). Every piece of level and block geometry depends
on this — it must not be revisited casually.

## Decision

**1 Godot unit = 10 cm, so a Standard Block is 40 × 20 × 5 cm.**

This matches the PRD's own recommendation in §4.4. Concretely: block dimensions are authored directly in
Godot units using the ratios from the block catalogue (e.g. Standard Block = 4 × 2 × 0.5 Godot units),
and those units are understood to represent 10 cm each — chunky, stylised, oversized dominoes, consistent
with the diorama-scale visual identity (§8.1).

## Why

- Matches the toy-diorama look the game is going for — real domino proportions (45 × 24 × 7 mm) would be
  tiny and fussy; PRD explicitly wants playful scale, not realism.
- Keeps rigid body dimensions in the range Godot's physics is actually tuned for. Godot assumes roughly
  1 unit = 1 metre for solver stability and default thresholds (sleep velocity, contact margins); shrinking
  block dimensions down to literal centimetre-scale Godot units (e.g. a 0.4-unit-tall block) is exactly the
  "very small scales" case the PRD warns behaves badly.
- **No accompanying change needed.** FO-003's test scene already spawns blocks using the catalogue ratios
  directly as Godot units (`block_height = 4.0`, etc.), so it already conforms to this decision as built —
  nothing to retrofit.

## Gravity and scale

Godot's default gravity (9.8 units/s²) is applied uniformly regardless of what a unit is defined to mean.
A block that is "4 Godot units tall" physically behaves like a 4-metre object falling under real gravity —
the "1 unit = 10 cm" label is a semantic/authoring convention (it tells a level designer how big an island
needs to be to read as 6 metres across), it does not change simulated physics. This is *why* Wouter's first
playtest of FO-003 read as "a bit slow": a 4-unit object topples at the rate physics expects of something
4 metres tall, independent of what we call the unit. Recorded here so nobody re-derives it later.

## Not done

FO-008's original acceptance criteria called for testing FO-003's chain at three scale interpretations
(1 cm, 10 cm, and 1 m per unit, ratio held fixed) and judging each on device before choosing. **That
comparison was not run.** Wouter opted to adopt the PRD's recommended value directly rather than run the
three-way comparison. Recorded so this shortcut is visible, not silent — if the chosen scale ever feels
wrong later, the 1 cm and 1 m alternatives were never actually eliminated by testing, only by
recommendation.

## Applies to

Every later story that authors geometry — islands, kit pieces, obstacle slots, block catalogue entries —
uses this scale as given. FO-003's damping/feel values were tuned at this scale and should be revisited
together with it, not independently, if the scale is ever reopened.

## Gravity (FO-019)

**`physics/3d/default_gravity` = 98, not the Godot default of 9.8.**

Blocks are authored 10× larger than the real objects they represent (this document's whole point), and
Godot applies gravity as though 1 unit = 1 metre regardless of what we call a unit. Without compensating,
a block "4 units tall" falls at the rate physics expects of an actual 4-metre object — about 3× too slowly
(toppling time scales with the square root of height). Confirmed exactly this in Wouter's first FO-003
playtest ("a bit slow") and again mechanically in headless testing before this change.

**Fix:** scale gravity by the same factor as the size exaggeration — 10× bigger objects need 10× stronger
gravity to fall at the rate the eye expects, the same principle as speeding up footage of a scale model.

**Confirmed on Wouter's own live playtest after the change: fall speed now reads correctly.** This is the
one criterion in FO-019 that requires a human judgement and it's been made — see BACKLOG FO-019 findings
for the rest (damping re-tuning, a known unresolved jitter issue, and why it isn't chased further here).
