% The COBRAToolbox: testGetExchangedMetaboliteTable.m
%
% Purpose:
%     - getExchangedMetaboliteTable maps each metabolite to its EX_<met> reaction, corrects
%       exchange reactions whose coefficient is zero, optionally reorders the table onto a list
%       of exchange reactions together with the columns of a matrix L, and plots the result. A
%       test would check the table, the corrected model and the reordered L on a hand-built
%       model.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns):
%       the documented call without reordering always stops (defect below), so this file makes
%       no assertion about the function.
%
% Function under test:
%     src/base/getExchangedMetaboliteTable.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - look-up on a small hand-built model, no solver.
%
% Coverage exemptions:
%     every line - getExchangedMetaboliteTable is quarantined for the defect below
%     (feature 20261113-142115-test-backfill-tiers).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: exRxnsOrdered = {} stops the call
%       SEVERITY: error
%       TRIGGER: model = createModel({'EX_a', 'EX_b', 'R1'}, {'', '', ''}, {'a <=> ', 'b <=> ',
%       'a -> b'}); model.metNames = model.mets; getExchangedMetaboliteTable(model, {}, eye(2))
%       OBSERVED: MATLAB R2025a: "Unrecognized function or variable 'exchangeMetsL'." at line 85;
%       exchangeMetsL is assigned only inside the reordering branch (lines 66-82) but always
%       plotted (lines 84-85)
%       EXPECTED: the table and the model returned (documented: "pass {} to skip reordering")
%       LINES: 66-85
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetExchangedMetaboliteTable'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined, so this file needs no
% solver, MATLAB toolbox or particular operating system; the call is the standard opening of
% a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
