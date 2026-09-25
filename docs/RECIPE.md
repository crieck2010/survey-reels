# Recipe schema — `survey-reels.recipe/1.0`

A recipe is a JSON/YAML mapping describing one reel. Unknown fields are ignored on read (forward compatibility); unknown **major** schema versions are rejected.

## Fields

| Field | Type | Default | Description |
|---|---|---|---|
| `name` | string (required) | — | reel name; also the output file stem |
| `source` | enum | `synthetic` | `noaa-ofs` \| `cmems` \| `synthetic` |
| `ofs_code` | string | `LMHOFS` | NOAA OFS model code (noaa-ofs only) |
| `model_date` | string | `""` | `YYYY-MM-DD`; empty = latest available |
| `cycle` | string | `"00"` | model run cycle (noaa-ofs only) |
| `hours` | int[] | `[0,6,12,18]` | forecast hours to stack (noaa-ofs only) |
| `cmems_preset` | string | `global-physics-daily` | survey-currents CMEMS preset (cmems only) |
| `start` / `end` | string | `""` | ISO datetimes (cmems only, required) |
| `bbox` | float[4] | Lake Michigan south basin | `[min_lon, min_lat, max_lon, max_lat]` |
| `n_frames` | int | `48` | frames to render |
| `flow_style` | enum | `reel-dark` | `reel-dark` \| `reel-light` \| `print` |
| `flow_size` | string | `reel` | survey-flow size preset |
| `n_particles` | int | `1500` | advected particles per frame |
| `seed` | int | `7` | deterministic particle seeding |
| `animate_preset` | enum | `reel` | `reel` \| `wide` \| `square` \| `preview` |
| `fps` | number | `30.0` | output frame rate |
| `title` / `subtitle` | string | `""` | burned-in title card text |
| `output` | string | `reel.mp4` | output file name (extension picks format) |
| `site_id` / `site_name` | string | `""` | echoed into run-summary.json |

## Validation rules

- `name` must be non-empty.
- `bbox` must be 4 finite numbers with min < max, in geographic range.
- `n_frames`, `n_particles` positive integers; `fps` positive.
- `noaa-ofs` requires ≥1 non-negative forecast hour.
- `cmems` requires `start` and `end`.

## Cache key

`recipe_hash(recipe)` = SHA-256 over the canonical JSON (sorted keys, compact separators) of `to_dict()`. Changing any field changes the key and invalidates cached stages.

## Example

See `examples/lake-michigan-reel.yaml` and `ReelRecipe.example_recipe()`.
