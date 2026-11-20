#!/bin/bash
# Fails (exit 1) when the staged changes add machine-specific text: home or temporary-folder
# paths, user or e-mail names, licence or key material. Run before every commit of the
# back-fill (feature 20261113-142115-test-backfill-tiers); chain the commit with &&.
hits=$(git diff --cached -U0 -- . ':(exclude)specs/20261113-142115-test-backfill-tiers/tools/privacy_check.sh' | grep '^+' | grep -v '^+++' \
  | grep -i -E "/home/[a-z][a-z0-9_-]*/|/tmp/claude|/Users/[A-Za-z]|@gmail|gurobi\.lic|BEGIN [A-Z ]*PRIVATE KEY|password\s*=" \
  | grep -v "/home/seqc_user/")
if [ -n "$hits" ]; then
  echo "PRIVACY CHECK FAILED:"; echo "$hits" | cut -c1-200 | head -20; exit 1
fi
echo "privacy check passed"
