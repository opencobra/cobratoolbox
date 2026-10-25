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
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

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

% change the directory
cd(currentDir)
