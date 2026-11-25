% The COBRAToolbox: testComputeParetoOptimality.m
%
% Purpose:
%     - computeParetoOptimality finds the ranges of two reactions, fixes each in turn at steps
%       of dinc over its range while maximising the other, returns the Pareto frontier (step,
%       flux of rxn1, flux of rxn2), the LP solutions and, with FVAflag, fastFVA ranges, and
%       plots the frontier.
%     - Once the defect below is fixed, the test should use a createModel network in which
%       both reactions share one limited uptake (rxn1 + rxn2 <= 10, frontier derived by hand),
%       check the frontier rows and the flux solutions (S * v = 0, bounds), the reaction names
%       as cell and as character arrays (both label branches), the documented positional and
%       the name-value forms of dinc and FVAflag, an unbounded second reaction (NaN rows), the
%       empty CBT_LP_SOLVER branch with a stand-in for initCobraToolbox, and close the figure;
%       FVAflag needs ibm_cplex (fastFVA). Quarantined: no behaviour of
%       computeParetoOptimality is asserted until the defect below is fixed; this file only
%       opens the test.
%
% Function under test:
%     src/analysis/multiSpecies/microbiomeModelingToolbox/pairwiseInteractionModeling/computeParetoOptimality.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - LPs on a hand-built createModel network, every available LP solver.
%
% Coverage exemptions:
%     every line - computeParetoOptimality is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The documented positional dinc and FVAflag stop with an error
%       SEVERITY: error
%       TRIGGER: computeParetoOptimality(model, {'R1'}, {'R2'}, 5), the USAGE form (model, rxn1,
%         rxn2, dinc, FVAflag), with model = createModel({'EX_A', 'R1', 'R2', 'S1', 'S2'},
%         {'EX_A', 'R1', 'R2', 'S1', 'S2'}, {' -> A', 'A -> P', 'A -> Q', 'P -> ', 'Q -> '},
%         'upperBoundList', [10 1000 1000 1000 1000], 'printLevel', 0)
%       OBSERVED: (R2025a, gurobi, 2026-11-25) MATLAB:InputParser:ParamMustBeChar "Expected a
%         string scalar or character vector for the parameter name." at line 58: dinc and
%         FVAflag are declared with addParameter (name-value only)
%       EXPECTED: the positional form of the USAGE line accepted (addOptional), or the USAGE
%         documenting the name-value form
%       LINES: 55-56, 58
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testComputeParetoOptimality'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined and not called, so no
% solver is needed; the call is the standard opening of a COBRA test and the place where the
% requirement (an LP solver) is added when the defect is fixed
prepareTest();

% change the directory
cd(currentDir)
