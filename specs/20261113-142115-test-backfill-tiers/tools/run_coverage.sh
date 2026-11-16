#!/bin/bash
# usage: run_coverage.sh <list file> <output jsonl> [timeout seconds]
# Runs measureCoverage on a list of "<test>|<source>" lines through the memory-capped MATLAB
# wrapper of the reference machine (feature 20261113-142115-test-backfill-tiers).
set -u
REPO=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
TOOLS="$REPO/specs/20261113-142115-test-backfill-tiers/tools"
LIST=$(realpath "$1"); OUT=$(realpath -m "$2"); TIMEOUT=${3:-3600}; IDLE=${4:-900}
cd "$REPO"
# the session is killed when no record has been appended to OUT for IDLE seconds (a hanging test)
touch "$OUT"
# a private temporary directory per session, so that the leftover check of measureCoverage sees
# only this session's files (several MATLAB sessions share the machine's /tmp)
SESSION_TMP=$(mktemp -d)
TMPDIR="$SESSION_TMP" "${MATLAB_SAFE:-$HOME/.local/bin/matlab-safe}" --timeout "$TIMEOUT" --idle-file "$OUT" --idle-timeout "$IDLE" -batch \
  "initCobraToolbox(false); changeCobraSolver('gurobi', 'all', 0); addpath('$TOOLS'); measureCoverage('$LIST', '$OUT')" 2>&1 \
  | grep -E "^(COVREC|Error|MATLAB-SAFE)"
rm -rf "$SESSION_TMP"
