# Platform decisions

Resolves PRD open decisions #1 (renderer) and #3 (minimum Android API level). FO-007.

## Renderer: Mobile (kept as Godot's own default)

**Decision: Android uses the Mobile renderer** (`rendering/renderer/rendering_method.mobile = "mobile"`),
Desktop keeps Forward+. Set explicitly in `project.godot` rather than left implicit, even though it
matches Godot's own out-of-the-box default for this platform-override key — same reasoning as FO-002's
tick rate: explicit signals deliberate, and is harder to change by accident.

### How this was tested

FO-003's domino chain scene got two additions for this story (kept in
`scripts/test/domino_chain_test.gd`, gated behind `show_perf_overlay` and `show_depth_debug` export flags,
off unless explicitly enabled — the shipped scene behaves exactly as before):

- An on-screen readout of FPS, frame time, and physics time (`Performance` monitors), so device performance
  is visible without a debugger attached.
- A depth-texture visualization: a semi-transparent quad parented to the camera, shaded by a small custom
  shader that samples `hint_depth_texture` and renders scene depth as a grayscale gradient. This has to be
  a **separate** object drawn in the transparent queue, not the ground plane itself — a mesh cannot
  reliably read its own not-yet-finished depth write from the same opaque pass. (First attempt applied it
  directly to the ground and got a flat, meaningless result for exactly this reason.)

Built two Android debug APKs from the command line, forcing each renderer via
`rendering/renderer/rendering_method.mobile`, and tested both on **Wouter's Pixel 9 Pro XL** (screenshots
taken via `adb shell screencap`, pulled and inspected directly rather than relying on a verbal description
— a static readout of "does it look different" is where description got confusing).

### Findings

| | Mobile | Forward+ |
|---|---|---|
| FPS | 60 (stable) | 60 (stable) |
| Frame time (`TIME_PROCESS`) | ~15ms | ~19ms |
| Physics time | not comparable — captured at different points in the run, physics load depends on how many bodies are colliding at that instant, not on renderer choice | — |
| Depth-texture sampling | **Works** — clean gradient, dominoes read as distinct depth bands against background | **Works** — visually equivalent result |
| Crashes / errors | None | None (first screenshot attempt was blank purely because Forward+'s first-frame shader compile takes a few seconds longer — not a fault, just needed to wait) |

**No meaningful differentiator was found at this scale.** A 15-box scene is trivial for either renderer on
a flagship GPU (Mali-G715 here) — both hit the 60fps ceiling with room to spare. The frame-time gap (15ms
vs 19ms) favours Mobile slightly but isn't conclusive on its own.

**The depth-texture concern from PRD §8.3.2 is resolved**: both renderers can sample scene depth
successfully, so the water foam shoreline shader is not blocked by this choice on this device. The
renderer decision is therefore **not** the water-foam blocker the PRD worried it might be.

### Why Mobile anyway

Given no measured downside on a high-end device, and Mobile is Godot's own recommended choice for phones
generally (lower baseline GPU/driver overhead matters more on mid- and low-range hardware, which is where
frame-rate headroom actually gets spent) — keep the default rather than override it for a device that
isn't representative of the target audience's low end.

**⚠️ Revisit at FO-005.** This story's scene has almost no rendering load — 15 low-poly boxes, flat
materials, one light. FO-005's rigid-body stress test will load the GPU and CPU far harder and is a much
better place to catch a real renderer-driven frame-rate difference, especially since FO-005 should
eventually be tested on a lower-end device too, not just this flagship. If Mobile starts showing strain
there that Forward+ wouldn't, that's the moment to reopen this.

## Minimum Android API level: 24 (fixed by the export template, not a project setting)

**Decision: API 24 (Android 7.0, released August 2016).**

This isn't actually a choice made via a project setting — Godot's non-Gradle Android export templates
(the ones this project uses, see `docs/build-android.md`) have min/target SDK baked in. Confirmed via:

```
aapt dump badging build/android/FallOver-debug.apk
```

which reports `sdkVersion:'24'` `targetSdkVersion:'36'` regardless of the empty `gradle_build/min_sdk`
field in `export_presets.cfg` (that field only applies if `gradle_build/use_gradle_build` is enabled,
which it isn't here — see FO-006).

### Why 24 is fine to accept as-is

This matches the PRD's own proposal in §2.1. By 2026, Android 7 (API 24) is a decade-old release.
Current distribution data ([TelemetryDeck](https://telemetrydeck.com/survey/android/Android/sdkVersions/),
[AndroidHeadlines](https://www.androidheadlines.com/2026/01/android-version-distribution-numbers-2025-2026-market-share.html))
shows the active install base has moved almost entirely past it — Android 7 itself sits at roughly 6% and
falling, and versions actually *below* API 24 make up a vanishingly small remainder, well under 2% of
active devices. Raising the floor further would exclude essentially nobody meaningful today while gaining
nothing, since the template's min SDK isn't the limiting factor for anything this project needs.

**If a custom Gradle build is ever adopted** (not planned; would only become relevant for a native plugin
`docs/build-android.md` doesn't currently need), the `gradle_build/min_sdk` field in `export_presets.cfg`
would need setting explicitly at that point — it's currently empty and inert.

## UI layout at aspect extremes (4:3 through 20:9): deferred, not skipped

**Not verified in this story, and not silently dropped — there is no real UI yet to check.** Every screen
that would need this check (world map, level select, in-level HUD, block palette) is Phase 4 work. The
project's stretch settings are already configured (`window/stretch/mode = "canvas_items"`,
`window/stretch/aspect = "expand"`), which is the right starting point, but confirming actual layouts
survive 4:3 through 20:9 needs actual layouts to inspect. Revisit this once Phase 4's meta screens exist —
`adb shell wm size <W>x<H>` on a real device is a workable way to test extreme aspect ratios without
needing physical devices of each shape, noted here for whoever picks this up.
