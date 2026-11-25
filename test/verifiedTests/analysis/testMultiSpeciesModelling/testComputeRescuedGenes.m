% The COBRAToolbox: testComputeRescuedGenes.m
%
% Purpose:
%     - computeRescuedGenes relaxes the ATP maintenance reactions of a joint model of two
%       organisms, computes the wild-type objective of each organism in the joint and in the
%       single model (partner reactions closed), deletes each gene of each original model, keeps
%       the deletions that reduce the single-model objective, recomputes them in the joint
%       model and reports the genes whose deletion is lethal or growth-impairing alone but
%       rescued by the partner.
%     - Once the defect below is fixed, the test should use two createModel organisms that
%       share a lumen compartment, with a lethal gene rescued by the partner, a growth-impairing
%       gene (reduction derived by hand) rescued by the partner, a lethal gene not rescued, a
%       gene with no effect (isozyme) and a deletion that does not lower the objective, the
%       missing rxnGeneMat built, ATPM relaxed (wild type derived by hand), and the
%       non-optimal branches (an unbounded joint deletion). Quarantined: no behaviour of
%       computeRescuedGenes is asserted until the defect below is fixed; this file only opens
%       the test.
%
% Function under test:
%     src/analysis/multiSpecies/microbiomeModelingToolbox/pairwiseInteractionModeling/computeRescuedGenes.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - LPs on a hand-built joint model of two createModel organisms, every available LP
%     solver.
%
% Coverage exemptions:
%     every line - computeRescuedGenes is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Genes with a growth reduction of only 10 to 50 percent are reported as rescued
%         growth-impaired genes, against the documented threshold of more than 50 percent
%       SEVERITY: wrong-result
%       TRIGGER: two organisms with the reactions IEX_Au A[u] -> A[c], IEX_Bu B[u] <=> B[c],
%         IEX_Cu C[u] <=> C[c], R_B A[c] -> B[c] (gene xL), R_C1 A[c] -> C[c] (gene xI, ub 2),
%         R_C2 A[c] -> C[c] (ub 8), biomass B[c] + C[c] -> ; joint model with lumen exchange
%         EX_A (lb -20); computeRescuedGenes('modelJoint', joint, 'OriModel1', model1,
%         'OriModel2', model2, 'Rxn1', 'org1_biomass', 'Rxn2', 'org2_biomass', 'nameTag1',
%         'org1_', 'nameTag2', 'org2_')
%       OBSERVED: (R2025a, gurobi, 2026-11-25) deleting x1I lowers the single-model biomass
%         from 10 to 8 (ratio 0.8, a 20 percent reduction) and the joint one not at all (ratio
%         1); RescuedGenes.org1_biomass.RescuedGrowthImpairedGenes = {'x1I'}. Lines 254 and 276
%         test grRatioSingle < 0.9
%       EXPECTED: per the OUTPUTS help (genes whose deletion "is lethal or causes >50% growth
%         reduction in single but not pairwise model"), no gene with a single-model ratio of
%         0.5 or more in the list
%       LINES: 254, 276
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testComputeRescuedGenes'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined and not called, so no
% solver is needed; the call is the standard opening of a COBRA test and the place where the
% requirement (an LP solver) is added when the defect is fixed
prepareTest();

% change the directory
cd(currentDir)
