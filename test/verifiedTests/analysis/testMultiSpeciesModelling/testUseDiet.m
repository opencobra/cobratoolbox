% The COBRAToolbox: testUseDiet.m
%
% Purpose:
%     - useDiet closes the uptake of every exchange reaction of a model (Diet_EX_ for
%       microbiota models, EX_ otherwise) and then sets the lower (and, with a third column,
%       the upper) bounds of the exchanges listed in a diet table. The function is
%       QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns): a diet
%       with fewer rows than columns stops with an index error (defect below), so no
%       assertion about the function is made.
%
% Function under test:
%     src/analysis/multiSpecies/microbiomeModelingToolbox/pairwiseInteractionModeling/useDiet.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a test would use a hand-built model (createModel) with exchange reactions, no
%     solver.
%
% Coverage exemptions:
%     every line - useDiet is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A diet with fewer rows than columns stops with an index error
%       SEVERITY: error
%       TRIGGER: useDiet(model, {'EX_a(e)', '-5', '10'}) or useDiet(model, {'EX_a(e)', '-5',
%         '10'; 'EX_b(e)', '-2', '3'}) on a model with the exchanges EX_a(e), EX_b(e), EX_c(e)
%         (createModel); likewise one constraint with two columns
%       OBSERVED: "Index in position 1 exceeds array bounds. Index must not exceed 1." (two
%         rows: "... must not exceed 2.") at line 54 (MATLAB R2025a): the loop of line 52
%         runs to length(dietConstraints), the larger dimension of the cell array, so it
%         reads rows the diet does not have; a diet with three rows and three columns is
%         applied correctly (lower bounds -5, -2, -1 and upper bounds 10, 3, 1)
%       EXPECTED: the bounds of the listed exchanges set, whatever the number of rows
%       LINES: 52-54
%     - DEFECT: Numeric bounds become NaN
%       SEVERITY: limitation
%       TRIGGER: useDiet(model, {'EX_a(e)', -5; 'EX_b(e)', -2}), bounds given as numbers
%       OBSERVED: the lower bounds of EX_a(e) and EX_b(e) are NaN (MATLAB R2025a):
%         str2double of a double is NaN; the same bounds as text ('-5', '-2') give -5 and -2
%       EXPECTED: numeric bounds applied as they are, or rejected with a message
%       LINES: 54, 57, 62, 65
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testUseDiet'));
cd(fileDir);

% declare the requirements of this test: a Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system; the function is quarantined, so nothing below calls it
prepareTest();

% change the directory
cd(currentDir)
