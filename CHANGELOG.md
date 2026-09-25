# Changelog

## v0.1.0 — 2026-09-25

Initial release. Thin orchestration engine for mapped.earth-style animated current/temperature reels — module 4 of 4 in the flow-field animation program.

- `ReelRecipe` dataclass: validated recipe schema (`survey-reels.recipe/1.0`), YAML I/O, canonical SHA-256 cache key.
- `run_recipe`: 4-stage pipeline (fetch → render → encode → deliver) with `run-state.json` resumability — completed stages are skipped, changed recipes re-run from the first affected stage.
- Content-addressed `Cache` for fetched fields and rendered frames (plain directory tree, safe to delete).
- `sites.py`: read-only survey-sites adapter (`reels from-site`); proposes the `animation:` site-config block (spec in docs/SITE_CONFIG.md, machine-readable via `animation_block_spec()`).
- `deliver.py`: publishes video + provenance sidecar, writes `run-summary.json` (`survey-reels.run-summary/1.0`) mirroring survey-monitor's `RunSummary` fields.
- Peers (`survey-currents`, `survey-flow`, `survey-animate`) are optional and duck-typed; `PeerMissing` gives the exact install command. Stage functions are injectable for offline testing.
- `docs/INTEROP.md`: integration blueprint (survey-monitor reel hook, survey-alerts MP4 attachment, site-config schema evolution, earthwatch-suite registry entry).
- CLI: `run`, `recipe-new`, `recipe-show`, `from-site`, `demo`, `cache-clear`.
- 46 tests, fully offline; end-to-end offline demo verified (`examples/run_demo.sh`).
