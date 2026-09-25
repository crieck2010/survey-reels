#!/usr/bin/env bash
# Fully offline end-to-end demo: synthetic currents -> flow frames -> MP4.
# Needs the peer packages installed: survey-currents, survey-flow, survey-animate.
set -euo pipefail
WORK="${1:-/tmp/reels_demo}"
rm -rf "$WORK"
reels demo --work-dir "$WORK"
echo "---"
ls -la "$WORK/output"
