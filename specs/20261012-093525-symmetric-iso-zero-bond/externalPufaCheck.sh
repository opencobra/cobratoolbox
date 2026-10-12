#!/usr/bin/env bash
# External check of feature 20261012-093525-symmetric-iso-zero-bond (tasks.md T017, spec SC-003,
# quickstart step 4): reconXmoieties pufa prefix n = 514 and the full pufa subsystem, hydrogen-free
# RXN files, moiety graphs on, with this branch's COBRA Toolbox on the MATLAB path.
# Logs go to results/20261012-093525-symmetric-iso-zero-bond/ in this repository.
set -u
repoRoot=$(cd "$(dirname "$0")/../.." && pwd)
out=$repoRoot/results/20261012-093525-symmetric-iso-zero-bond
runDir=/home/jackmcgoldrick/repos/reconXmoieties/results/ki001_strip_h
sub=/home/jackmcgoldrick/repos/ReconXKG-cidev/ReconXKGtoCobra/models/subsystemSubModels/subsystemSubModels.mat
pathCheck="addpath(genpath('$repoRoot/src/analysis/topology/reactingMoieties')); fprintf('COBRA classify: %s\n', which('classifySubgraphIsomorphism'));"
cd "$runDir"
echo "$(date -Is) start pufa n=514 (cap 30 min); load: $(uptime)" >> "$out/T017.log"
SUBMODELS_MAT=$sub PUFA_N=514 RUNS=B timeout 1800 matlab -batch "$pathCheck run('runPufaNoH.m'); fprintf('fallbacks %d\n', classifySubgraphIsomorphism('getFallbackCount'))" > "$out/T017_pufa514.log" 2>&1
rc=$?
echo "$(date -Is) end pufa n=514 exit $rc $(grep -h 'NOH run B\|fallbacks' "$out/T017_pufa514.log" | tr '\n' ' ')" >> "$out/T017.log"
echo "$(date -Is) start full pufa (cap 60 min); load: $(uptime)" >> "$out/T017.log"
SUBSYS=pufa CORPUS=noH GRAPHS=1 timeout 3600 matlab -batch "$pathCheck run('runSubsysNoH.m'); fprintf('fallbacks %d\n', classifySubgraphIsomorphism('getFallbackCount'))" > "$out/T017_pufaFull.log" 2>&1
rc=$?
echo "$(date -Is) end full pufa exit $rc $(grep -h 'SUB RESULT\|SUB built\|fallbacks' "$out/T017_pufaFull.log" | tr '\n' ' ')" >> "$out/T017.log"
