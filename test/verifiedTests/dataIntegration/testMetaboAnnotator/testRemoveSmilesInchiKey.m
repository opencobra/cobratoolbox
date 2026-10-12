% The COBRAToolbox: testRemoveSmilesInchiKey.m
%
% Purpose:
%     - removeSmilesInchiKey sets the InChIKey and/or SMILES of metabolites that have an InChI string to NaN, and can regenerate them from the InChI string.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/dataIntegration/metaboAnnotator/buildMetStruct/removeSmilesInchiKey.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Lines 46-53 and 56-63 of removeSmilesInchiKey.m (the branches that regenerate SMILES / InChIKey from the InChI string (generateSmiles, generateInchiKey true)) call the external converter convertInchiString2format, which needs an external chemistry tool; those lines are not covered here. The test only uses generateSmiles = generateInchiKey = false.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRemoveSmilesInchiKey'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% three metabolites: a has an InChI string; b has NaN; c has an empty text
metabolites.a = struct('inchiString', 'InChI=1S/x', 'inchiKey', 'K', 'smile', 'S');
metabolites.b = struct('inchiString', NaN, 'inchiKey', 'K2', 'smile', 'S2');
metabolites.c = struct('inchiString', '', 'inchiKey', 'K3', 'smile', 'S3');

%% remove both the InChIKey and the SMILES

[result, idsAdded] = removeSmilesInchiKey(metabolites, true, true, false, false, false);
% only metabolite a (with an InChI string) is changed
assert(isnan(result.a.inchiKey) && isnan(result.a.smile));
assert(strcmp(result.a.inchiString, 'InChI=1S/x'));
% b and c are left alone
assert(isequaln(result.b, metabolites.b));
assert(isequaln(result.c, metabolites.c));
% nothing was generated
assert(isempty(idsAdded));

%% remove only the InChIKey, or only the SMILES

result = removeSmilesInchiKey(metabolites, true, false, false, false, false);
assert(isnan(result.a.inchiKey) && strcmp(result.a.smile, 'S'));
result = removeSmilesInchiKey(metabolites, false, true, false, false, false);
assert(strcmp(result.a.inchiKey, 'K') && isnan(result.a.smile));

%% remove nothing

result = removeSmilesInchiKey(metabolites, false, false, false, false, false);
assert(isequaln(result, metabolites));

% change the directory
cd(currentDir)
