% The COBRAToolbox: testAnnotateSBOTerms.m
%
% Purpose:
%     - annotateSBOTerms gives every metabolite the SBO term 'simple chemical', every gene the
%       term 'gene', and every reaction an SBO term chosen from its identifier (exchange, demand,
%       sink, biomass) or from the compartments of its formula (metabolic or transport). The
%       function is quarantined for the defect below: on a model without these fields the
%       metabolite and gene terms are returned as rows. This file only opens the test; it
%       asserts nothing about the function.
%
% Function under test:
%     src/reconstruction/refinement/annotateSBOTerms.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model annotation (ecoli_core_model); no solver.
%
% Coverage exemptions:
%     every line - annotateSBOTerms is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: metSBOTerms and geneSBOTerms are created as rows, not m x 1 and g x 1
%       SEVERITY: wrong-result
%       TRIGGER: model = getDistributedModel('ecoli_core_model.mat') (no metSBOTerms or
%         geneSBOTerms field); model = annotateSBOTerms(model)
%       OBSERVED: (R2025a, 2026-11-16) size(model.metSBOTerms) = [1 72] and
%         size(model.geneSBOTerms) = [1 137] while mets is 72 x 1 and genes 137 x 1; verifyModel
%         reports "inconsistentFields: metSBOTerms: Size of metSBOTerms was 72. Expected 1".
%         Lines 33 and 38 grow a new field along the second dimension; only rxnSBOTerms is turned
%         into a column (line 84)
%       EXPECTED: m x 1 and g x 1 cell arrays, as the OUTPUT documentation says
%       LINES: 32-39
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAnnotateSBOTerms'));
cd(fileDir);

% declare the requirements of this test. This test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
