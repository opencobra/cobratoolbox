% The COBRAToolbox: testGenerateChemicalDatabase.m
%
% Purpose:
%     - tests the generateChemicalDatabase function using the Citric Acid 
%       Cycle E. coli Core Model
%

fprintf('   Testing generateChemicalDatabase ... \n' );

% Save the current path
currentDir = pwd;
mkdir([currentDir filesep 'tmpDB'])

% Check external software
[cxcalcInstalled, ~] = system('cxcalc');
cxcalcInstalled = ~cxcalcInstalled;
[oBabelInstalled, ~] = system('obabel');
[javaInstalled, ~] = system('java');

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

if any([~cxcalcInstalled ~oBabelInstalled ~javaInstalled])
    error('To test the function CXCALC, Open Babel and JAVA must be installed to test the function generateChemicalDatabase')
end

[info, model] = generateChemicalDatabase(model, options);

rmdir([currentDir filesep 'tmpDB'], 's')

% Load reference data
load('refData_generateChemicalDatabase.mat')
assert(isequal(model, modelRef), 'The model ouput is different')
assert(isequal(info, infoRef), 'The database report is different')
