% The COBRAToolbox: testDeltaG0concFluxConstraintBounds.m
%
% Purpose:
%     - deltaG0concFluxConstraintBounds derives bounds on the standard transformed and the
%       transformed Gibbs energies of formation of each metabolite (from dfGt0, its uncertainty
%       and the concentration bounds), then of each reaction (with a group-contribution
%       uncertainty from a group incidence matrix), optionally adds the proton and electrical
%       potential terms of transport reactions, and sets the thermodynamic directionality and
%       bounds of the internal reactions. The function is QUARANTINED (Constitution III-Defects,
%       quarantine in back-fill campaigns): every call stops at line 307 because the group
%       incidence function it calls does not exist on the MATLAB path; no assertion about the
%       function is made.
%
% Function under test:
%     src/analysis/thermo/thermoDirectionality/deltaG0concFluxConstraintBounds.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - no solver; a test would hand-build a two-compartment model with every field the
%     function reads and derive the bounds by hand.
%
% Coverage exemptions:
%     every line - deltaG0concFluxConstraintBounds is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: every call stops with an undefined function createGroupIncidenceMatrix_old
%       SEVERITY: error
%       TRIGGER: model = createModel({'r1'; 'r2'; 'EX_a'}, {'r1'; 'r2'; 'EX_a'}, {'a[e] -> a[c]';
%         'a[c] -> b[c]'; 'a[e] <=> '}, 'lowerBoundList', [0; -10; -10], 'upperBoundList',
%         [10; 10; 10], 'printLevel', 0); then model.concMin = 1e-5 * ones(3, 1);
%         model.concMax = 1e-2 * ones(3, 1); model.dfGt0 = [-10; -10; -20];
%         model.dfGt0Source = {'GC'; 'GC'; 'GC'}; model.dfGt0GroupContUncertainty = ones(3, 1);
%         model.T = 310.15; model.imBalancedMass = {''; ''; ''}; model.imBalancedCharge =
%         zeros(3, 1); model.SIntRxnBool = [true; true; false]; model.metFormulas = {'C'; 'C';
%         'C'}; model.metCharges = zeros(3, 1); deltaG0concFluxConstraintBounds(model, 0, 0,
%         'x.txt', model.mets, struct('groups', {{}}))
%       OBSERVED: "Undefined function 'createGroupIncidenceMatrix_old' for input arguments of
%         type 'struct'." at line 307 (R2025a, 2026-11-20); which('createGroupIncidenceMatrix_old')
%         is empty: the only function of that name is declared inside
%         createGroupIncidenceMatrix_jankowski.m, and MATLAB resolves a function by its file name
%       EXPECTED: the group incidence matrix is computed and the function returns the model with
%         the bounds and directionality documented in OUTPUT; no input can reach the lines after
%         line 307
%       LINES: 307
%
% Authors:
%     - Generated for feature 20261120-151023-doc-matches-code, 2026-11-20.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testDeltaG0concFluxConstraintBounds'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined, so nothing is run;
% the call is the standard opening of a COBRA test
prepareTest();

% change the directory
cd(currentDir)
