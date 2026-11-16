% The COBRAToolbox: testPopulateModelMetStr.m
%
% Purpose:
%     - populateModelMetStr copies the identifiers and properties of a metabolite structure
%       (matched to model.mets by originalID or VMHId) into the corresponding COBRA model fields
%       (table translateMetStr2COBRAmodel), sets metSBOTerms, prefixes ChEBI identifiers and
%       converts identifier fields to text. The function is quarantined for the defect below:
%       a translated field that the model does not have is created with too few entries. This
%       file only opens the test; it asserts nothing about the function.
%
% Function under test:
%     src/dataIntegration/metaboAnnotator/buildMetStruct/populateModelMetStr.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation; no solver.
%
% Coverage exemptions:
%     every line - populateModelMetStr is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A field missing from the model is created with one entry per metabolite up to the last match only
%       SEVERITY: wrong-result
%       TRIGGER: pm = createModel({'R1'}, {'R1'}, {'glc_D + atp + datp -> h2o + adp'});
%         n = numel(pm.mets); pm.metKEGGID = repmat({''}, n, 1); pm.metChEBIID = repmat({''},
%         n, 1); pm.metCharges = zeros(n, 1); ms.VMH_glc_D = struct('VMHId', 'glc_D',
%         'metNames', 'D-Glucose', 'keggId', 'C00031', 'cheBIId', '4167', 'charge', '-1',
%         'drugbank', NaN); ms.VMH_atp = struct('VMHId', 'atp', 'metNames', 'ATP', 'keggId',
%         'C00002', 'cheBIId', NaN, 'charge', -4, 'drugbank', 'DB00171');
%         out = populateModelMetStr(pm, ms)
%       OBSERVED: (R2025a, 2026-11-16) the model has 5 metabolites (adp, atp, datp, glc_D,
%         h2o) but out.metDrugbank is 4-by-1 ({'DB00171'} for atp at index 2, {[NaN]} for
%         glc_D at index 4, [] in between), same with replaceAllHits = 1: line 79 creates the
%         field as [] and lines 83/87/90 grow it only up to the matched index; columnVector does
%         not pad it, so the returned model is inconsistent (field length differs from mets)
%       EXPECTED: a created field with one (empty) entry per metabolite, filled at the matches
%       LINES: 79, 83, 87, 90
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPopulateModelMetStr'));
cd(fileDir);

% declare the requirements of this test. This test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
