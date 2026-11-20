% The COBRAToolbox: testFormula2mets.m
%
% Purpose:
%     - formula2mets returns the metabolites of a reaction formula (parsed by parseRxnFormula)
%       with the compartment in square brackets removed, in the order of the formula,
%       duplicates kept.
%     - Expected lists are read off the formulas by hand.
%
% Function under test:
%     src/reconstruction/rBioNet/formula2mets.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-written formulas.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFormula2mets'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% irreversible formula with coefficients: names without compartments, in order

% strings are compared exactly
metabolites = formula2mets('2 atp[c] + h2o[c] -> adp[c] + 0.5 pi[c] + h[c]');
assert(isequal(metabolites, {'atp', 'h2o', 'adp', 'pi', 'h'}));

%% reversible formula with a leading compartment: that compartment is removed as well

assert(isequal(formula2mets('[m] : A + 2 B <=> C'), {'A', 'B', 'C'}));

%% transport: the same metabolite in two compartments appears twice; '-' in names is kept

assert(isequal(formula2mets('glc-D[e] -> glc-D[c]'), {'glc-D', 'glc-D'}));

%% names without a compartment are returned unchanged

assert(isequal(formula2mets('A + B --> C'), {'A', 'B', 'C'}));

% change the directory
cd(currentDir)
