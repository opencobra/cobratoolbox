% The COBRAToolbox: testSteadyComSubroutines.m
%
% Purpose:
%     - SteadyComSubroutines dispatches the helper routines of SteadyCom, SteadyComFVA and
%       SteadyComPOA: initialize, solveCobraLP_arg, infoCom2indCom, rxnList2objMatrix, updateLPcom
%       and getParams. A test would check each routine on a hand-built two-organism community model.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns):
%       'initialize' stops with an error for a community model that has only the documented infoCom
%       (defect below), so this file makes no assertion about the function.
%
% Function under test:
%     src/analysis/multiSpecies/SteadyCom/subroutines/SteadyComSubroutines.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a hand-built community model, no solver (getCobraSolverParams reads parameter
%     values only).
%
% Coverage exemptions:
%     every line - SteadyComSubroutines is quarantined for the defect below
%     (feature 20261113-142115-test-backfill-tiers).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: 'initialize' reads modelCom.indCom before building it from infoCom
%       SEVERITY: error
%       TRIGGER: SteadyComSubroutines('initialize', modelCom) with modelCom having S, b, c, lb,
%       ub, rxns, mets and infoCom (fields spBm, EXcom, EXsp, spAbbr, rxnSps, metSps) but no
%       indCom, e.g. a one-reaction model with infoCom.spBm = {'r'}
%       OBSERVED: 'Unrecognized field name "indCom".' at line 72 (MATLAB R2025a): lines 72-73 use
%       modelCom.indCom before the test of line 76, so lines 76-83 never build it
%       EXPECTED: indCom is derived from infoCom (line 82), as the header says (at least one of
%       infoCom and indCom is needed)
%       LINES: 72-73, 76-83
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSteadyComSubroutines'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined, so this file needs no
% solver, MATLAB toolbox or particular operating system; the call is the standard opening of
% a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
