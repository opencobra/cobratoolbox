% The COBRAToolbox: testDoubleGeneDeletion.m
%
% Purpose:
%     - doubleGeneDeletion removes the genes whose single deletion is lethal
%       (singleGeneDeletion), then knocks out every pair of the remaining genes (all pairs of
%       one list, or every gene of geneList1 with every gene of geneList2) and computes the
%       growth of the double deletion strain by FBA, MOMA or linear MOMA, returning the growth
%       rate matrix and the growth ratio matrix. Quarantined: no behaviour of
%       doubleGeneDeletion is asserted until the defect below is fixed.
%
% Function under test:
%     src/analysis/deletion/doubleGeneDeletion.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - LP (and QP for MOMA) on a toy model.
%
% Coverage exemptions:
%     every line - doubleGeneDeletion is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: With two different gene lists the growth rates are written to the transposed
%       position of the result matrix, so pairs get the growth rate of another pair
%       SEVERITY: wrong-result
%       TRIGGER: doubleGeneDeletion(model, 'FBA', {'g1'; 'g2'}, {'g3'; 'g4'}) on the toy model
%         EX_A ( -> A, ub 10), R1 (A -> B, ub 4, rule g1), R2 (A -> B, rule g2), R3 (B -> C,
%         rule g3), R4 (B -> C, ub 6, rule g4), BIO (C -> , objective)
%       OBSERVED: (R2025a, gurobi, 2026-11-25) grRateKO = [6 4; 4 4]: entry (1, 2) of the
%         pair g1-g4 holds 4, the growth rate of the pair g2-g3. Rows index geneList1 and
%         columns geneList2, but the loop also writes each rate to (geneNo2, geneNo1) (lines
%         167 and 179), which is the position of the pair geneList1{geneNo2}-geneList2{geneNo1},
%         and a later pair overwrites the correct value
%       EXPECTED: grRateKO = [6 10; 4 4] (g1-g3: R2 and R4 give 6; g1-g4: R2 and R3 give 10;
%         g2-g3: R1 and R4 give 4; g2-g4: R1 and R3 give 4)
%       LINES: 167, 170, 179
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testDoubleGeneDeletion'));
cd(fileDir);

% declare the requirements of this test; nothing that calls doubleGeneDeletion runs while it
% is quarantined, so no solver is required yet
prepareTest();

% change the directory
cd(currentDir)
