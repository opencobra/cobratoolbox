% The COBRAToolbox: testOptGeneFitness.m
%
% Purpose:
%     - optGeneFitness(rxn_vector_matrix, model, targetRxn, rxnListInput, isGeneList) is the
%       fitness function of the optGene genetic algorithm: for each row of the population it
%       knocks out the selected reactions (or genes, with deleteModelGenes), maximises growth
%       with solveCobraLP and, when growth is at least 0.1, returns minus the minimal
%       production of targetRxn at the growth rate less 0.01 (0 when above -1e-3). Rows with
%       more knock-outs than the global MaxKnockOuts, or with growth below 0.1, get 0; results
%       are cached in the global java.util.Hashtable HTABLE. The function is QUARANTINED
%       (Constitution III-Defects, quarantine in back-fill campaigns): a knock-out that makes
%       the model infeasible stops it with an error; no assertion about the function is made.
%
% Function under test:
%     src/design/optGeneFitness.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - two LPs per population row on a hand-built model; a test would declare
%     prepareTest('needsLP', true) and loop over the LP solvers (gurobi on the reference
%     machine).
%
% Coverage exemptions:
%     every line - optGeneFitness is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A knock-out that makes the model infeasible stops the function with an error
%       SEVERITY: error
%       TRIGGER: global HTABLE MaxKnockOuts; HTABLE = java.util.Hashtable; MaxKnockOuts = 2;
%         model = createModel({'EX_A'; 'R1'; 'R3'; 'BIO'; 'EX_P'; 'ATPM'}, {'EX_A'; 'R1';
%         'R3'; 'BIO'; 'EX_P'; 'ATPM'}, {' -> A'; 'A -> B'; 'A -> B + P'; 'B -> '; 'P -> ';
%         'B -> '}, 'lowerBoundList', [0 0 0 0 0 1], 'upperBoundList', [10 1000 1000 1000
%         1000 1000]); model = changeObjective(model, 'BIO');
%         optGeneFitness([1 1], model, 'EX_P', {'R1'; 'R3'}, false)
%       OBSERVED: (R2025a, gurobi, 2026-11-23) "Unable to perform assignment because the left
%         and right sides have a different number of elements." at line 91: solveCobraLP
%         returns stat 0 and obj = [] for the infeasible knock-out model, the status is not
%         checked, [] < .10 is false, and growthrate - gamma = [] is assigned to one lower bound
%       EXPECTED: fitness 0 for that row, as for any knock-out that does not reach the growth
%         rate 0.1 (optGeneFitnessTilt, which optGene uses, skips such rows: it checks
%         isempty(solKO.x))
%       LINES: 70, 74, 91
%     - DEFECT: The global hash table HTABLE is required but not documented
%       SEVERITY: limitation
%       TRIGGER: clear global HTABLE; optGeneFitness([1 0], model, 'EX_P', {'R1'; 'R3'},
%         false) with a model as above without ATPM
%       OBSERVED: (R2025a, gurobi, 2026-11-23) MATLAB:structRefFromNonStruct "Dot indexing is
%         not supported for variables of this type." at line 136; the function works only
%         after the caller sets global HTABLE = java.util.Hashtable (optGene does); the
%         global MaxKnockOuts is used without documentation as well
%       EXPECTED: the globals documented in the help text, or an empty cache created when
%         HTABLE is not set
%       LINES: 131-136
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testOptGeneFitness'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined and not called, so no
% solver is needed; the call is the standard opening of a COBRA test and the place where the
% requirement (an LP solver) is added when the defect is fixed
prepareTest();

% change the directory
cd(currentDir)
