# Integration blueprint

How survey-reels plugs into the earthwatch-suite. **Documented only** — no other repository is modified by this package. Each section is a wiring recipe for a future change in the owning repo.

## 1. survey-monitor: a reel runner hook

survey-monitor's scheduled runs (`survey-suite/survey-monitor`) already write `RunSummary` per site. A reel hook fits naturally:

- After a monitor run completes for a site whose config carries `currents:` + `animation:`, call `reels.sites.recipe_from_site_file(site_yaml)` then `reels.runner.run_recipe(recipe, work_dir)`.
- `output/run-summary.json` from survey-reels already mirrors `RunSummary` fields (`site_id`, `site_name`, `timestamp`, `passes_processed`, `passes_skipped`, `alerts_fired`, `alerts`, `errors`), so monitor's existing summary readers accept it unchanged. Reel-specific keys (`video_path`, `recipe_sha`, `animate_preset`, …) are additive.
- Suggested cadence: weekly reels (model windows are days, not satellite passes), not per-pass.

## 2. survey-alerts: MP4 attachments

survey-alerts builds PDF/HTML digests from `AlertEvent`s. To attach a finished reel:

- Read `output/run-summary.json`; `video_path` gives the published MP4, `<video>.provenance.json` the sidecar.
- Embed as a linked attachment in the HTML digest (`<video controls src="...">`) and as a file attachment / link in the PDF digest (reportlab `Paragraph` with link, or attach via the SMTP MIME layer survey-alerts already uses for PDFs).
- Recommended: attach only on `info`-level "reel ready" digests, not on every alert, to keep email sizes sane.

## 3. survey-sites: schema evolution

- `currents:` block — proposed by survey-currents, read by `reels.sites`.
- `animation:` block — proposed by survey-reels (see `docs/SITE_CONFIG.md` and `reels.sites.animation_block_spec()`).
- Both are additional properties under site-config v1, so a future schema v1.1 can adopt them without breaking v1 readers.

## 4. survey-qgis: static frames as layers

`work/frames/*.png` are plain georeferenced-agnostic rasters with known bboxes (the recipe `bbox`). A future `reels_snapshot` QGIS Processing algorithm can load a chosen frame as a raster layer styled by the matching survey-flow colormap. Out of scope for v0.1.0.

## 5. earthwatch-suite registry

Suggested registry entry (for the meta-repo's module table):

| module | version | role |
|---|---|---|
| survey-currents | 0.1.0 | model-data acquisition (NOAA OFS / CMEMS) |
| survey-flow | 0.1.0 | particle-advection frame renderer |
| survey-animate | 0.1.0 | frames → video encoder |
| survey-reels | 0.1.0 | recipe-driven orchestration + delivery |

Pipeline: `imagery → change → monitor → alerts` gains a parallel branch `models → flow → animate → reels → alerts`.

## Failure policy

- Missing peer → `PeerMissing` naming the exact `pip install` command; the run fails at the first stage needing it, earlier artifacts are kept.
- Network failure in fetch → stage marked `failed` in `run-state.json` with the exception; re-run retries only that stage.
- Encoder missing → `survey-animate` raises its own `EncoderUnavailable`; surfaced unchanged.
- A corrupt `run-state.json` is discarded and the run restarts cleanly (never a crash).
