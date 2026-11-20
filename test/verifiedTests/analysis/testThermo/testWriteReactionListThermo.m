% The COBRAToolbox: testWriteReactionListThermo.m
%
% Purpose:
%     - writeReactionListThermo writes one tab-delimited line per reaction (index, identifier,
%       rxn(j).officialName, equation, lb, ub) for the reactions start:stop, with a waitbar. A
%       test would compare the file written in a tempname folder with the text worked out from
%       a hand-built model, for two, three and four arguments.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): an exchange reaction written as uptake loses its arrow (first defect
%       below), so this file makes no assertion about the function.
%
% Function under test:
%     src/analysis/thermo/directionalityReport/writeReactionListThermo.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - hand-built model, a text file and a waitbar, no solver.
%
% Coverage exemptions:
%     every line - writeReactionListThermo is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: No arrow for an irreversible exchange reaction that has a product
%       SEVERITY: wrong-result
%       TRIGGER: writeReactionListThermo(model, 'out.txt') with a reaction 'EX_a' (or 'Exch_a')
%       whose column of S has a positive entry and lb >= 0, e.g. S(:, 2) = [1; 0; 0], lb = 0,
%       ub = 5
%       OBSERVED: the line "2<TAB>EX_a<TAB>name 2<TAB>1 a<TAB>0 <TAB>5 <TAB>" (MATLAB R2025a): the
%       exchange branch of line 51 prints ' <==> ' only when there is no product (line 54) and
%       nothing otherwise, so the equation has no arrow
%       EXPECTED: an arrow between the two sides (' --> ' as for other irreversible reactions,
%       line 58)
%       LINES: 51-56
%     - DEFECT: Non-integer stoichiometric coefficients are printed in exponent form
%       SEVERITY: cosmetic
%       TRIGGER: a reaction with a coefficient 0.5, e.g. S(:, 5) = [-0.5; 0; 1]
%       OBSERVED: "5.000000e-01 a --> 1 c" (MATLAB R2025a): the format '%d' of lines 41 and 62
%       falls back to %e for non-integers
%       EXPECTED: "0.5 a --> 1 c"
%       LINES: 41, 62
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testWriteReactionListThermo'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined, so this file needs no
% solver, MATLAB toolbox or particular operating system; the call is the standard opening of
% a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
