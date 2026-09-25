# Architecture

## Position in the program

survey-reels is module 4 of 4 in the flow-field animation program:

1. **survey-currents** — acquires `CurrentField` (u/v + water temperature) from NOAA OFS / CMEMS.
2. **survey-flow** — advects particles through the field, renders PNG frames + `manifest.json` (`survey-flow.frame-manifest/1.0`).
3. **survey-animate** — encodes frames/manifest to MP4/GIF/WebM with presets.
4. **survey-reels** (this repo) — orchestrates 1→2→3 from a single recipe and delivers the result.

## Design decisions

**Thin orchestrator, fat peers.** Every domain operation (fetching NetCDFs, particle advection, ffmpeg encoding) lives in the peer packages. survey-reels owns only: the recipe schema, stage sequencing, resumability, caching, site-config adaptation, and delivery. This keeps the dependency graph shallow and lets each peer evolve independently.

**Optional peers via duck typing.** `_peers.py` resolves peer callables lazily and raises `PeerMissing` with an install command when one is absent. The runner additionally accepts injected `fetch_fn`/`render_fn`/`encode_fn`/`load_field_fn`, so the pipeline is fully testable offline and embeddable without the peers.

**Resumable runs.** `run_recipe` persists a `RunState` (`run-state.json`, schema `survey-reels.run-state/1.0`) with per-stage status and artifact paths. A stage whose artifact still exists is skipped. The recipe hash is stored alongside; a changed recipe invalidates downstream stages. Crash mid-render → re-run resumes at render.

**Content-addressed cache.** `Cache` keys fetched fields and rendered frames by the recipe SHA-256. Re-running an unchanged recipe never re-downloads model data. The cache is a plain directory tree — safe to delete.

**Stable interchange formats.** Between stages: `field.json` (CurrentField JSON), `manifest.json` (frame manifest), MP4 + `<video>.provenance.json`. Final output: `run-summary.json` (schema `survey-reels.run-summary/1.0`) mirroring survey-monitor's `RunSummary` fields so downstream tooling can treat a reel run like any other monitor run.

## Module map

```
src/reels/
  __init__.py    public surface: ReelRecipe, run_recipe, RunResult
  _peers.py      lazy peer resolution + PeerMissing
  recipe.py      ReelRecipe dataclass, validation, YAML, recipe_hash
  runner.py      4-stage pipeline, RunState, resumability
  cache.py       content-addressed file cache
  sites.py       survey-sites site.yaml -> ReelRecipe adapter
  deliver.py     publish video + run-summary.json
  cli.py         thin argparse adapter
```

## Scaling notes

- Frame rendering dominates cost; survey-flow owns that (parallelism is its roadmap, not ours).
- The cache makes repeated recipe tweaks (style, preset, title) cheap: fetch/render are skipped, only encode re-runs.
- `run_recipe` accepts a `progress(stage, done, total)` callback for UI embedding.
- No threads or processes are spawned here; the runner is single-threaded and deterministic given a fixed seed.
