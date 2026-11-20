% The COBRAToolbox: testMapFormula.m
%
% Purpose:
%     - mapFormula writes the formula of each reaction of rxnList found in a CellDesigner map
%       structure (species names of base and secondary reactants joined by ' + ', '->' or
%       '<=>' by reversibility, then the products), one formula per drawing of a reaction,
%       and returns the reactions found, the reactions of rxnList absent from the map and the
%       reaction names drawn more than once. Expected formulas are written by hand from the
%       documentation.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): the severity audit T009a raised the first defect below (an intended input
%       that fails when used), so this file makes no assertion about the function. The checks
%       of the wave 11 version of this test (git history) are to be restored once the defect
%       is fixed.
%
% Function under test:
%     src/visualization/metabolicCartography/mapFormula.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built map structure.
%
% Coverage exemptions:
%     every line - mapFormula is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers, severity audit T009a). Before the quarantine the
%     test reached every executable line.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Fails instead of returning empty lists when no listed reaction is in the map
%       SEVERITY: error
%       TRIGGER: a map without the reactions of rxnList, e.g. mapFormula(map, {'RX'}) with any
%         map structure whose rxnName does not contain 'RX', such as the four-reaction map
%         (HEX1, PGI, HEX1, PFK) of the wave 11 version of this test (also with the first
%         output only)
%       OBSERVED: MATLAB R2025a prints 'Attention : 1 reaction(s) not present in the map!!!'
%         and raises 'Output argument "formulaList" (and possibly others) not assigned a value
%         in the execution with "mapFormula" function.'; formulaList and rxnsList are assigned
%         only inside the loop over the present reactions.
%       EXPECTED: empty formulaList and rxnsList, absentRxns = {'RX'}, duplicatedRxns empty;
%         absentRxns is a documented output and line 41 prints 'Attention : N reaction(s) not
%         present in the map!!!', so absent reactions are an intended input, which fails when
%         every listed reaction is absent (severity audit T009a)
%       LINES: 51, 99-100
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.
%     - Converted to the quarantine layout after the severity audit 2026-11-15 (T009a).
%     - Help text of mapFormula corrected to match the code (feature 20261120-151023-doc-matches-code), 2026-11-20.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMapFormula'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
