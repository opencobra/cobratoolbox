% The COBRAToolbox: testCheckGeneMCS.m
%
% Purpose:
%     - checkGeneMCS checks each gene minimal cut set (gMCS): it knocks out all its genes
%       (deleteModelGenes, optionally grouping isoforms by a separator) and records the
%       objective value (cut set when below 100 * feasTol), and for sets of more than one gene
%       it knocks out every subset with one gene less (minimal when every subset keeps the
%       objective above the threshold).
%     - Once the defects below are fixed, the test should use a createModel network with two
%       isozymes g1, g2 of the only route to the objective (cut set {g1, g2}, minimal; {g1}
%       not a cut set; {g1, g2, g3} a cut set that is not minimal), isoform genes 555.1, 555.2
%       with separator '.', the empty and omitted gMCSs (warning and NaN outputs), and the
%       genes reported as making a set not minimal, all derived by hand. Quarantined: no
%       behaviour of checkGeneMCS is asserted until the defects below are fixed; this file
%       only opens the test.
%
% Function under test:
%     src/analysis/gMCS/checkGeneMCS.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - LPs on a hand-built createModel network, every available LP solver.
%
% Coverage exemptions:
%     every line - checkGeneMCS is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: An empty or omitted gMCSs leaves the outputs unassigned, so a call requesting
%         them stops
%       SEVERITY: error
%       TRIGGER: [IsCutSet, IsMinimal, geneNotMinimal] = checkGeneMCS(model, {}) with any
%         model, e.g. createModel({'EX_A', 'R1', 'R2', 'BIO'}, {'EX_A', 'R1', 'R2', 'BIO'},
%         {' -> A', 'A -> B', 'A -> B', 'B -> '}, 'grRuleList', {'', 'g1', 'g2', ''},
%         'printLevel', 0)
%       OBSERVED: (R2025a, gurobi, 2026-11-25) warning "There is no gMCS to check", then
%         MATLAB:unassignedOutputs "Output argument "IsCutSet" (and possibly others) not
%         assigned a value in the execution with "checkGeneMCS" function." The branch sets
%         BiomassCutSet and BiomassMinimal (NaN) but not IsCutSet and IsMinimal
%       EXPECTED: the outputs returned (NaN), as the branch for an empty gMCSs intends
%       LINES: 43-47
%     - DEFECT: geneNotMinimal lists the genes that are needed, not those that make the set
%         not minimal
%       SEVERITY: wrong-result
%       TRIGGER: [IsCutSet, IsMinimal, geneNotMinimal] = checkGeneMCS(model, {{'g1'; 'g2'}})
%         with the model above, objective BIO (changeObjective), EX_A upper bound 10
%       OBSERVED: (R2025a, gurobi, 2026-11-25) IsCutSet = 1 and IsMinimal = 1 (the set is a
%         minimal cut set), but geneNotMinimal{1} = {'g1'; 'g2'}: line 79 keeps the genes
%         whose removal from the set leaves an objective above the threshold, i.e. the genes
%         the cut set needs
%       EXPECTED: an empty list for a minimal gMCS; the genes that can be removed while the
%         rest stays a cut set (objective below the threshold) otherwise
%       LINES: 79
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCheckGeneMCS'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined and not called, so no
% solver is needed; the call is the standard opening of a COBRA test and the place where the
% requirement (an LP solver) is added when the defect is fixed
prepareTest();

% change the directory
cd(currentDir)
