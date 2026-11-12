% The COBRAToolbox: testConvertModel2Metstructure.m
%
% Purpose:
%     - convertModel2Metstructure converts the metabolite annotation of a COBRA model into a
%     metabolite structure with one entry per metabolite (compartment suffix removed), recording the
%     source of every annotation.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/dataIntegration/metaboAnnotator/buildMetStruct/convertModel2Metstructure.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below; the function calls a script, so this was measured
%     with the profiler (tools/measureProfile.m of the coverage feature), not the coverage plugin.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A metabolite with a hyphen is overwritten by its next compartment
%       SEVERITY: wrong-result
%       TRIGGER: a metabolite abbreviation with a hyphen in more than one compartment
%       OBSERVED: the check for an existing entry uses the name with the hyphen but the entry is stored
%         with an underscore, so the last occurrence overwrites the entry (originalID a-b[e], not a-b[c])
%       EXPECTED: the first occurrence defines the entry, as for all other metabolites
%       LINES: 36, 38
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testConvertModel2Metstructure'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

model.modelID = 'M1';
model.mets = {'glc_D[c]'; 'glc_D[e]'; 'pyr[c]'};
model.metNames = {'D-glucose'; 'D-glucose'; 'pyruvate'};
model.metFormulas = {'C6H12O6'; 'C6H12O6'; 'C3H3O3'};
model.metKEGGID = {'C00031'; 'C00031'; 'C00022'};

%% one entry per metabolite regardless of the compartment

evalc('metStruct = convertModel2Metstructure(model);');
assert(isequal(fieldnames(metStruct), {'VMH_glc_D'; 'VMH_pyr'}));

%% annotation and its source

evalc('metStruct = convertModel2Metstructure(model);');
assert(strcmp(metStruct.VMH_glc_D.VMHId, 'glc_D'));
% the first occurrence of the metabolite defines the entry
assert(strcmp(metStruct.VMH_glc_D.originalID, 'glc_D[c]'));
assert(strcmp(metStruct.VMH_glc_D.metNames, 'D-glucose'));
assert(strcmp(metStruct.VMH_glc_D.metNames_source, 'M1'));
assert(strcmp(metStruct.VMH_glc_D.chargedFormula, 'C6H12O6'));
assert(strcmp(metStruct.VMH_glc_D.keggId, 'C00031'));
assert(strcmp(metStruct.VMH_pyr.metNames, 'pyruvate'));
assert(strcmp(metStruct.VMH_pyr.keggId, 'C00022'));

%% numeric annotation, identifier prefixes and a hyphen in the abbreviation
modelAnnotated.modelID = 'M2';
modelAnnotated.mets = {'glc-D[c]'; 'pyr[c]'};
modelAnnotated.metNames = {'D-glucose'; 'pyruvate'};
modelAnnotated.metFormulas = {'C6H12O6'; 'C3H3O3'};
% a numeric field cannot be indexed with braces, so it is copied by its row
modelAnnotated.metCharges = [0; -1];
modelAnnotated.metChEBIID = {'CHEBI:4167'; 'CHEBI:15361'};
modelAnnotated.metBioCycID = {'META:Glucopyranose'; 'META:PYRUVATE'};

metStruct = convertModel2Metstructure(modelAnnotated);

% the hyphen, which a field name cannot hold, becomes an underscore
assert(isequal(fieldnames(metStruct), {'VMH_glc_D'; 'VMH_pyr'}));
assert(strcmp(metStruct.VMH_glc_D.VMHId, 'glc_D'));
assert(strcmp(metStruct.VMH_glc_D.originalID, 'glc-D[c]'));
% the numeric charge and its source
assert(metStruct.VMH_glc_D.charge == 0 && metStruct.VMH_pyr.charge == -1);
assert(strcmp(metStruct.VMH_pyr.charge_source, 'M2'));
% the database prefixes are removed from the identifiers
assert(strcmp(metStruct.VMH_glc_D.cheBIId, '4167'));
assert(strcmp(metStruct.VMH_pyr.biocyc, 'PYRUVATE'));
% fields the model does not hold exist and are NaN
assert(isnan(metStruct.VMH_pyr.keggId));

% change the directory
cd(currentDir)
