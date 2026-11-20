% The COBRAToolbox: testCalculateMCS.m
%
% Purpose:
%     - calculateMCS(model_struct, n_mcs, max_len_mcs, varargin) enumerates minimal cut sets
%       of the model's objective reaction with the CPLEX solution pool (Cplex.populate),
%       optionally restricted to a reaction set (rxn_set) and to cut sets containing a
%       given reaction (KO); without a working IBM CPLEX it stops with the error
%       COBRA:calculateMCS:requiresCplex. The function is QUARANTINED (Constitution
%       III-Defects, quarantine in back-fill campaigns): a reaction set given as a row cell
%       array together with KO stops with an error; no assertion about the function is made.
%
% Function under test:
%     src/analysis/gMCS/calculateMCS.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - the enumeration needs IBM ILOG CPLEX (solution pool, indicator constraints),
%     which is not installed on the reference machine (gurobi is the only commercial
%     solver); a test would set the SOLVERS global by hand and use a stand-in Cplex class.
%
% Coverage exemptions:
%     every line - calculateMCS is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A row cell array rxn_set together with KO stops with an error
%       SEVERITY: error
%       TRIGGER: model = createModel({'R1', 'R2', 'R3', 'R4'}, {'R1', 'R2', 'R3', 'R4'},
%         {' -> A', 'A <=> B', 'A -> B', 'B -> '}); model.c(4) = 1;
%         calculateMCS(model, 10, 2, 'KO', 'R2', 'rxn_set', {'R1', 'R3'}) with IBM CPLEX
%         installed and working (here: global SOLVERS with SOLVERS.ibm_cplex.installed = 1
%         and .working = 1, restored afterwards)
%       OBSERVED: (R2025a, 2026-11-17; the error comes before any CPLEX call)
%         "Dimensions of arrays being concatenated are not consistent."
%         (MATLAB:catenate:dimensionMismatch) at line 139, rxn_set = [rxn_set; {KO}]; the
%         column {'R1'; 'R3'} reaches the Cplex call, and the row form without KO too
%       EXPECTED: OPTIONAL INPUTS document rxn_set as a "Cell array containing the set of
%         reactions" (validated by iscell), so a row cell array is accepted and KO is added
%         to the set
%       LINES: 139
%     - DEFECT: The enumeration writes tmp.mat into the current folder
%       SEVERITY: cosmetic
%       TRIGGER: any call that reaches the enumeration loop (IBM CPLEX installed)
%       OBSERVED: (R2025a, 2026-11-17, with a stand-in Cplex class whose populate returns an
%         empty pool) calculateMCS(model, 10, 2, 'printLevel', 0) on the model above leaves
%         tmp.mat (mcs = [], mcs_time 4 x 2) in the current folder; lines 305 and 521 save it
%         after every populate round, overwriting a file of that name, and never remove it
%       EXPECTED: no undocumented file in the user's current folder
%       LINES: 305, 521
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-17.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCalculateMCS'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined, so nothing calls it
% and no solver is declared; the call is the standard opening of a COBRA test and the place
% where the requirements are added when the defect is fixed
prepareTest();

% change the directory
cd(currentDir)
