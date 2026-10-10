> [!IMPORTANT]
> **Consolidated into [EarthWatch-Suite](https://github.com/crieck2010/earthwatch-suite)**  
> This engine has been consolidated into the unified [EarthWatch-Suite monorepo](https://github.com/crieck2010/earthwatch-suite). Active development, bug fixes, releases, and unified testing now live in earthwatch-suite. This repository is preserved as an archive.

# survey-reels

**Thin orchestration engine for mapped.earth-style animated current/temperature reels** — the fourth and final module of the earthwatch-suite flow-field animation program.

One recipe → pull current fields → render flow frames → encode video → deliver. All heavy lifting stays in the three optional peer packages; this repo is the recipe schema, the resumable 4-stage runner, the content-addressed cache, and the integration blueprint wiring it all into the earthwatch suite.

## The pipeline

```
reel.yaml ──▶ fetch ──▶ render ──▶ encode ──▶ deliver
              (survey-currents)  (survey-flow)  (survey-animate)   (video + run-summary.json)
```

Peers are **optional and duck-typed**: if one is missing you get a clear `pip install` message, never a bare `ImportError`. The offline demo runs with all three peers installed.

## Install

```bash
pip install survey-reels
# peers (needed to actually run reels):
pip install survey-currents survey-flow survey-animate
```

## Quickstart

```bash
# 1. Write an example recipe
reels recipe-new --out lake.yaml

# 2. Validate it
reels recipe-show lake.yaml

# 3. Run it end to end (fetch → render → encode → deliver)
reels run lake.yaml --work-dir reel_work

# 4. Fully offline demo (synthetic currents, no network)
reels demo --work-dir demo_work
```

Or from Python:

```python
from reels.recipe import ReelRecipe, example_recipe
from reels.runner import run_recipe

result = run_recipe(example_recipe(), "reel_work")
print(result.video_path, result.ok)
```

## Recipe

```yaml
name: lake-michigan-week
source: noaa-ofs            # noaa-ofs | cmems | synthetic
ofs_code: LMHOFS
cycle: "00"
hours: [0, 6, 12, 18, 24, 30, 36, 42]
bbox: [-87.9, 41.6, -86.7, 42.9]   # min_lon, min_lat, max_lon, max_lat
n_frames: 48
flow_style: reel-dark        # reel-dark | reel-light | print
n_particles: 1500
seed: 7
animate_preset: reel         # reel | wide | square | preview
fps: 30.0
title: "Lake Michigan surface currents"
subtitle: "NOAA LMHOFS model · colored by water temperature"
output: lake-michigan-reel.mp4
```

Re-runs are **resumable**: `run-state.json` tracks each stage, so a second run with an unchanged recipe skips everything; change the recipe and it re-runs from the first affected stage.

## Docs

- `docs/ARCHITECTURE.md` — module map and design decisions
- `docs/RECIPE.md` — the recipe schema specification
- `docs/SITE_CONFIG.md` — building recipes from survey-sites configs + the proposed `animation:` block
- `docs/INTEROP.md` — the integration blueprint (survey-monitor hook, survey-alerts attachment, earthwatch-suite registry)

## Interop

| Peer | Used for | Required? |
|---|---|---|
| survey-currents | `CurrentField` fetch (NOAA OFS / CMEMS / synthetic) | only for real runs |
| survey-flow | `render_animation` + frame manifest | only for real runs |
| survey-animate | `render_video` from manifest | only for real runs |
| survey-sites | `reels from-site <site.yaml>` builds recipes from site configs | no |
| survey-monitor | `run-summary.json` mirrors its `RunSummary` fields | no (documented wiring) |
| survey-alerts | finished MP4s attach to PDF/HTML reports | no (documented wiring) |

## License

MIT — see [LICENSE](LICENSE).
