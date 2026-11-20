% The COBRAToolbox: testAddFlux.m
%
% Purpose:
%     addFlux sets the width of the reaction links of a parsed CellDesigner structure from the
%     absolute fluxes of the listed reactions (8, 6, 5, 4, 3 or 0 by flux relative to the largest).
%     The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns):
%     reactions found under their R_ name with (e) and reactions stored under their own ID are left
%     unchanged (defects below), so no assertion about the function is made.
%
% Function under test:
%     src/visualization/cellDesigner/addFlux.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model look-up without a solver; a test would use a createModel model, a
%     hand-built flux vector and a hand-built parsed structure.
%
% Coverage exemptions:
%     every line - addFlux is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Reaction IDs with (e) are not converted to the _e field name
%       SEVERITY: wrong-result
%       TRIGGER: ref.r_info.ID = {'re1','x','R1'; 're2','y',[]}; ref.re1.width = {1}; ref.R_EX_glc_e.width = {1}; ref.R2.width = {1}; m = createModel({'R1','EX_glc(e)','R2'}, {'R1','EX_glc(e)','R2'}, {'A -> B','B -> ','A <=> '}); sol.x = [2; 1; 0.5]; [r, nf] = addFlux(m, sol, ref, {'R1','EX_glc(e)','R2'})
%       OBSERVED: nf = [2 8; 1 4; 0.5 4] but r.R_EX_glc_e.width = {1} and the message "error ! the listRxn{2}" is printed (the condition isempty(strfind(newRxnName,'(e)')) is inverted, so '(e)' is never replaced)
%       EXPECTED: r.R_EX_glc_e.width = {4} (code: strrep(newRxnName,'(e)','_e'))
%       LINES: 142-144
%     - DEFECT: A reaction whose structure field is named by the reaction ID itself is left unchanged
%       SEVERITY: wrong-result
%       TRIGGER: same call as above
%       OBSERVED: r.R2.width = {1} (when isfield(ref, listRxn{r}) holds nothing is done)
%       EXPECTED: r.R2.width = {4}, the width computed for R2 (0.5 / 2 = 0.25, class 4)
%       LINES: 140
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAddFlux'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
