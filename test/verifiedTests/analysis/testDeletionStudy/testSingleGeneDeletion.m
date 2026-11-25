% The COBRAToolbox: testSingleGeneDeletion.m
%
% Purpose:
%     - singleGeneDeletion knocks out each gene of a list in turn (deleteModelGenes) and
%       computes the growth of the deletion strain by FBA, MOMA or linear MOMA, returning
%       growth rates, growth ratios, the constrained reactions and the strain fluxes; with
%       uniqueGene = 1 all alternate transcripts of a gene (gene.1, gene.2, ...) are deleted
%       together. Quarantined: no behaviour of singleGeneDeletion is asserted until the
%       defect below is fixed.
%
% Function under test:
%     src/analysis/deletion/singleGeneDeletion.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - LP (and QP for MOMA) on a toy model.
%
% Coverage exemptions:
%     every line - singleGeneDeletion is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Unique gene deletion also deletes the transcripts of other genes whose
%       identifier starts with the same characters
%       SEVERITY: wrong-result
%       TRIGGER: singleGeneDeletion(model, 'FBA', [], false, 1) on the toy model EX_A ( -> A,
%         ub 10), R1 (A -> B, rule 1.1), R2 (A -> B, rule 10.1), BIO (B -> , objective)
%       OBSERVED: (R2025a, gurobi, 2026-11-25) grRateKO = [0 10] and delRxns{1} = {'R1';
%         'R2'}: the transcripts of gene 1 are looked up with strmatch('1', model.genes),
%         a prefix match that also returns 10.1, so the deletion of gene 1 deletes gene 10 too
%       EXPECTED: grRateKO = [10 10] and delRxns{1} = {'R1'}: R1 and R2 are parallel, so
%         deleting only the transcripts of gene 1 (1.1) leaves the growth of 10 through R2
%       LINES: 92
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSingleGeneDeletion'));
cd(fileDir);

% declare the requirements of this test; nothing that calls singleGeneDeletion runs while it
% is quarantined, so no solver is required yet
prepareTest();

% change the directory
cd(currentDir)
