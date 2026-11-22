% The COBRAToolbox: testPHbalanceProtons.m
%
% Purpose:
%     - pHbalanceProtons adjusts the proton coefficient of each internal reaction so that it
%       balances the average number of hydrogen ions bound by the reactants (aveHbound), keeping the
%       reconstruction matrix in Srecon. A test would check the new proton coefficients against a
%       hand calculation on small createModel models.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns):
%       the documented call without the optional massImbalance stops with an error (first defect
%       below), so this file makes no assertion about the function.
%
% Function under test:
%     src/reconstruction/modelGeneration/massBalance/pHbalanceProtons.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - hand-built createModel models with aveHbound, no solver.
%
% Coverage exemptions:
%     every line - pHbalanceProtons is quarantined for the defect below
%     (feature 20261113-142115-test-backfill-tiers).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The default of massImbalance uses nRxn before it is defined
%       SEVERITY: error
%       TRIGGER: model = createModel({'r1'}, {'r1'}, {'a[c] -> b[c]'}) with compartments {'c'},
%       metCompartments {'c'; 'c'}, SIntRxnBool true, aveHbound [1; 1], metFormulas {'CH'; 'CH'},
%       metCharges [0; 0]; pHbalanceProtons(model)
%       OBSERVED: 'Unrecognized function or variable 'nRxn'.' at line 57 (MATLAB R2025a); nRxn is
%       set at line 72
%       EXPECTED: massImbalance is optional; every reaction is treated as mass balanced
%       LINES: 57
%     - DEFECT: A proton-driven reaction uses an undefined or stale proton index
%       SEVERITY: wrong-result
%       TRIGGER: an internal reaction whose protons are in more compartments than its other
%       metabolites, e.g. ATPS4r (adp[c] + 4 h[e] + pi[c] <=> atp[c] + h2o[c] + 3 h[c])
%       OBSERVED: line 248 reads indexHRxn, which is only set at line 270 for an earlier reaction,
%       so it is undefined (error) or points to the proton of the previous reaction (read from the
%       code)
%       EXPECTED: the proton of the compartment of the other metabolites is adjusted, as the
%       comment above line 248 says
%       LINES: 248
%     - DEFECT: The missing-formula warning tests the whole formula list
%       SEVERITY: error
%       TRIGGER: a model in which some, but not all, metFormulas are empty
%       OBSERVED: line 108 strcmp(model.metFormulas, '') returns a vector, so the branch runs only
%       when every formula is empty; otherwise line 115 calls numAtomsOfElementInFormula('', 'H')
%       for an empty formula, which errors indexing formula(1) at its line 38 (read from the code)
%       EXPECTED: the formula of metabolite m is tested (model.metFormulas{m}) and the metabolite
%       gets NaN with the warning (lines 109-113)
%       LINES: 108-115
%     - DEFECT: The report file is never closed
%       SEVERITY: cosmetic
%       TRIGGER: printLevel < 0
%       OBSERVED: line 124 opens the file and no fclose follows (read from the code)
%       EXPECTED: the file is closed before returning
%       LINES: 124
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPHbalanceProtons'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined, so this file needs no
% solver, MATLAB toolbox or particular operating system; the call is the standard opening of
% a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
