% The COBRAToolbox: testCheckBalance.m
%
% Purpose:
%     - checkBalance(model, element, printLevel, fileName, missingFormulaeBool) counts the atoms
%       of one element in every metabolite formula (E) and returns the net change per reaction
%       dE = S' * E, with NaN for the reactions that involve a metabolite without a usable
%       formula and for those metabolites in E; it lists them on screen or in a file.
%       Quarantined: no behaviour of checkBalance is asserted until the defect below is fixed.
%
% Function under test:
%     src/reconstruction/modelGeneration/massBalance/checkBalance.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model look-up, no solver; a test would use a hand-built model with S, mets and
%     metFormulas (or ecoli_core_model) and a tempname folder for the printLevel -1 file.
%
% Coverage exemptions:
%     every line - checkBalance is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: With exactly one metabolite without a formula, the wrong reactions are set to NaN
%       SEVERITY: wrong-result
%       TRIGGER: model.S = sparse([-1 0 0; 1 -1 0; 0 1 -1; 0 0 1]), model.mets = {'a'; 'b'; 'c';
%         'd'}, model.metFormulas = {'C2'; 'C2'; ''; 'C2'}, [dE, E] = checkBalance(model, 'C', 0)
%       OBSERVED: MATLAB R2025a, 2026-11-16: dE = [NaN -2 2] and E = [2 2 NaN 2]. With a single
%         missing formula model.S(missingFormulaeBool, :) is a 1 x n row and any() of it is a
%         scalar, so line 92 sets dE(1) to NaN (whenever that metabolite is in some reaction)
%         instead of the reactions that use it. With two missing formulas ({'C2'; ''; ''; 'C2'})
%         dE = [NaN NaN NaN] is correct
%       EXPECTED: dE = [0 NaN NaN]: reaction 1 (a -> b) is balanced and reactions 2 and 3 involve
%         c, as the OUTPUTS section says (isnan(dE(n)) when the reaction involves a metabolite
%         without a formula)
%       LINES: 92
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCheckBalance'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
