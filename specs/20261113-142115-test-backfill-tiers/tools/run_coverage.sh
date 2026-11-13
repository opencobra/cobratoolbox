#!/bin/bash
# usage: run_coverage.sh <list file> <output jsonl> [timeout seconds]
# Runs measureCoverage on a list of "<test>|<source>" lines through the memory-capped MATLAB
# wrapper of the reference machine (feature 20261113-142115-test-backfill-tiers).
set -u
REPO=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
TOOLS="$REPO/specs/20261113-142115-test-backfill-tiers/tools"
LIST=$(realpath "$1"); OUT=$(realpath -m "$2"); TIMEOUT=${3:-3600}
cd "$REPO"
"${MATLAB_SAFE:-$HOME/.local/bin/matlab-safe}" --timeout "$TIMEOUT" -batch \
  "initCobraToolbox(false); changeCobraSolver('gurobi', 'all', 0); addpath('$TOOLS'); measureCoverage('$LIST', '$OUT')" 2>&1 \
  | grep -E "^(COVREC|Error|MATLAB-SAFE)"
