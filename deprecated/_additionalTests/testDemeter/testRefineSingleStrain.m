% The COBRAToolbox: testRefineSingleStrain.m
%
% Purpose:
%     - tests that a single reconstruction refined through DEMETER captures
%     the known properties of the strain and passes quality control tests.
%
% Author:
%     - Almut Heinken - September 2021
%
% Note:
%     - The solver libraries must be included separately

% initialize the test
fileDir = fileparts(which('testRefineSingleStrain'));
cd(fileDir);

global CBTDIR

% define the path to the draft reconstruction
draftFolder = [CBTDIR filesep 'papers' filesep '2021_demeter' filesep 'exampleDraftReconstructions'];
modelName='Lactobacillus_brevis_EW.RAST.fbamodel.sbml';

% define path to file with taxonomic information
infoFilePath = [CBTDIR filesep 'papers' filesep '2021_demeter' filesep 'example_infoFile.xlsx'];
infoFile = readInputTableForPipeline(infoFilePath);

% propagate experimental data
[infoFilePath,inputDataFolder] = prepareInputData(infoFilePath);

%% Step 2: refinement pipeline
% create an appropriate ID for the model
microbeID=adaptDraftModelID(modelName);

% load the model
draftModel = readCbModel([draftFolder filesep modelName]);

% create the model
[model,summary]=refinementPipeline(draftModel,microbeID, infoFilePath, inputDataFolder);

% Test of growth rates
% test aerobic and anaerobic growth on unlimited medium (consisting of 
% every compound the model can transport) and on a complex medium. The
% model should be able to grow aerobically and on the complex medium.
biomassReaction = model.rxns{find(strncmp(model.rxns,'bio',3)),1};
[AerobicGrowth, AnaerobicGrowth] = testGrowth(model, biomassReaction);
assert(AerobicGrowth(1,1) > 0.000001 && AerobicGrowth(1,2) > 0.000001 && AnaerobicGrowth(1,1) > 0.000001)

% Test of ATP production
% Test ATP production under aerobic and anaerobic conditions on a complex
% medium. ATP production should not be higher than 150 mmol/g dry weight/hr
% aerobically and 100 mmol/g dry weight/hr.
[atpFluxAerobic, atpFluxAnaerobic] = testATP(model);
assert(atpFluxAerobic(1,1) < 150 && atpFluxAerobic(1,1) < 100)

% Testing of model predictions against experimental and comparativs data
% run the test suite on the model
testResults = runTestsOnModel(model, microbeID, inputDataFolder);
% ensure there are no false negatives
fields = fieldnames(testResults);
fields(find(~contains(fields,'FalseNegatives')),:)=[];

for i=1:length(fields)
    assert(size(testResults.(fields{i}),1) < 2)
end
