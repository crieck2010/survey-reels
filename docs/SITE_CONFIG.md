# Site configs → recipes

`reels from-site <site.yaml>` builds a `ReelRecipe` from a survey-sites site config (schema `site-config/v1`). survey-sites is **never modified** — this is a read-only adapter. Fields survey-sites doesn't know are ignored by it.

## Mapping

| Site config | Recipe field |
|---|---|
| `site_id` | `name`, `site_id` |
| `name` | `site_name`, default title |
| `geometry.bbox` | `bbox` |
| `currents.source` | `source` (`noaa-ofs` \| `cmems` \| `synthetic`) |
| `currents.ofs_code` / `currents.cycle` / `currents.hours` | `ofs_code` / `cycle` / `hours` |
| `currents.preset` | `cmems_preset` |
| `currents.start` / `currents.end` | `start` / `end` |
| `animation.*` | `n_frames`, `flow_style`, `flow_size`, `n_particles`, `seed`, `animate_preset`, `fps`, `title`, `subtitle`, `output` |

CLI `--out` defaults to `reel.yaml`. Programmatic overrides:

```python
from reels.sites import recipe_from_site_file
recipe = recipe_from_site_file("sites/coast/site.yaml",
                               overrides={"animate_preset": "wide"})
```

## Proposed `animation:` block

The `currents:` block was proposed by survey-currents (`examples/site-currents.yaml`). survey-reels proposes the companion `animation:` block below for a future site-config schema version. It is **read by survey-reels only** and ignored by survey-sites v1 (which permits additional properties).

```yaml
# inside site.yaml
animation:
  n_frames: 48
  flow_style: reel-dark        # reel-dark | reel-light | print
  flow_size: reel              # survey-flow size preset
  n_particles: 1500
  seed: 7
  animate_preset: reel         # reel | wide | square | preview
  fps: 30.0
  title: "Lake Michigan surface currents"   # default: "<site name> surface currents"
  subtitle: "NOAA LMHOFS model · colored by water temperature"
  output: lake-michigan-reel.mp4            # default: "<site_id>-reel.mp4"
```

The machine-readable spec is available at runtime via `reels.sites.animation_block_spec()`.
