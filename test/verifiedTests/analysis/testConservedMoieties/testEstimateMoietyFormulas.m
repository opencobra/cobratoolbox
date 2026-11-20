% The COBRAToolbox: testEstimateMoietyFormulas.m
%
% Purpose:
%     - estimateMoietyFormulas(L, E, elements) estimates the elemental composition of each
%       moiety as round(L \ E), drops the electron column 'e', sorts the elements
%       alphabetically and writes one formula per moiety (element symbol followed by its count,
%       count 1 omitted). The test builds E = L*M0 from hand-chosen moiety compositions M0 and
%       a full-column-rank L, so L \ E = M0 exactly and the formulas follow by hand; it checks
%       the electron column and unsorted elements, rounding of a perturbed E, multi-digit counts
%       and a moiety made only of electrons.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns; severity audit T009a): M is not the documented r x p matrix in the input
%       element order (defect below), so no assertion about the function is made; the checks
%       described above are the plan for the test once the defect is resolved.
%
% Function under test:
%     src/analysis/topology/conservedMoieties/estimateMoietyFormulas.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built matrices.
%
% Coverage exemptions:
%     every line - estimateMoietyFormulas is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers, severity audit T009a)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: M is not the r x p matrix the documentation describes
%       SEVERITY: wrong-result
%       TRIGGER: [f, M] = estimateMoietyFormulas([1 0; 1 1; 0 1], [2 4 1 0; 4 6 1 1; 2 2 0 1],
%         {'e', 'H', 'C', 'O'})
%       OBSERVED: M = [1 4 0; 0 2 1] (R2025a, 2026-11-15): the electron column is removed and
%         the columns are sorted to C, H, O (lines 26 and 29), so M is r x 3 and its columns no
%         longer follow the input elements
%       EXPECTED: OUTPUT: "M: An r x p estimated elemental matrix for moieties" (here 2 x 4 in
%         the order e, H, C, O), or a documentation that says M follows the sorted elements
%         without 'e'. Severity audit 2026-11-15: p = numel(elements) in input order; M is
%         returned r x (p-1) with "e" removed and columns sorted (lines 24-29), so a caller
%         indexing M by the input elements reads wrong columns; no src caller uses M
%       LINES: 26, 29
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15; severity audit
%       2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testEstimateMoietyFormulas'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
