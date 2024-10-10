% The COBRAToolbox: testGenerateChemicalDatabase.m
%
% Purpose:
%     - tests the generateChemicalDatabase function using the Citric Acid 
%       Cycle E. coli Core Model
%

global CBTDIR

% define the features required to run the test
requiredSoftwares = {'cxcalc', 'obabel', 'java'};

% require the specified toolboxes and solvers, along with a UNIX OS
solversPkgs = prepareTest('requiredSoftwares', requiredSoftwares);

fprintf('   Testing generateChemicalDatabase ... \n' );

% Save the current path
currentDir = pwd;
mkdir([currentDir filesep 'tmpDB'])

% Load the E. coli Core Model TCA rxns
load ecoli_core_model.mat
model.mets = regexprep(model.mets, '\-', '\_');
rxnsToExtract = {'AKGDH', 'CS', 'FUM', 'ICDHyr', 'MDH', 'SUCOAS'};
model = extractSubNetwork(model, rxnsToExtract);

% initialize the test
fileDir = fileparts(which('testGenerateChemicalDatabase.m'));

%% Add external information in the model

inputData = [fileDir filesep 'metaboliteIds.txt'];
replace = false;
[model, hasEffect] = addMetInfoInCBmodel(model, inputData, replace);

%% Set optional variables according the software installed

options.outputDir = [currentDir filesep 'tmpDB'];
options.printlevel = 0;

[info, model] = generateChemicalDatabase(model, options);

rmdir([currentDir filesep 'tmpDB'], 's')

% Load reference data
load('refData_generateChemicalDatabase.mat')
assert(isequal(model, modelRef), 'The model ouput is different')
assert(isequal(info, infoRef), 'The database report is different')
