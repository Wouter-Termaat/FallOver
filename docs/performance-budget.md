# Performance budget

Resolves PRD open decision #4. FO-005.

## Device tested

**Google Pixel 9 Pro XL** (flagship, 2024/2025). Only device available for this project so far — the
number below is a starting ceiling, not a guarantee for lower-end hardware. Retest on a mid/low-range
device before locking level design against this number for real.

## Method

Extended FO-003's scene to spawn multiple parallel domino chains (`row_count`) that all trigger
simultaneously, rather than a single chain — a single chain never has more than a handful of blocks
actively moving at once regardless of length, so it can't stress-test *simultaneous* active bodies.
Swept row counts via an unattended on-device test (`--fo-stress-test`), sampling FPS and frame/physics
time for 1.5s per step.

## Results

| Rows | Active blocks | Min FPS | Max frame (ms) |
|---|---|---|---|
| 2–32 | 30–480 | 55–60 | 23–84 |
| 48 | 720 | 49 | 74 |
| 64 | 960 | 49 | 141 |
| 96 | 1440 | 43 | 177 |
| 128 | 1920 | 32 | 222 |

(The `rows=1` and `rows=48` readings showed anomalous 1–3 fps min values — first-phase app/shader warm-up,
not real simulation cost; ignored.)

## Recommendation

**Design levels to keep simultaneously active blocks under ~150.** This device holds 60fps comfortably to
~480 active blocks and doesn't drop near 30fps until ~1900+ — 150 leaves generous headroom under both
thresholds, and no realistic level (single chain, or a few branches) approaches this count. Total blocks
*per level* can be far higher than this, since settled blocks sleep (PRD §13.4) — the ceiling is only on
how many move at once, which matters most once branching (§4.3) creates multiple simultaneous fronts.

**Revisit once a lower-end device is available.** This number is only validated on a flagship phone.
