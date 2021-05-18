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

% Load reference data
load('refData_generateChemicalDatabase.mat')

%% Add external information in the model

inputData = [fileDir filesep 'metaboliteIds.xlsx'];
replace = false;
[model, hasEffect] = addMetInfoInCBmodel(model, inputData, replace);

assert(isequal(model, model1), 'The identifiers are different')
assert(hasEffect, 'The function addMetInfoInCBmodel din not have effect')

%% Set optional variables according the software installed

options.outputDir = [currentDir filesep 'tmpDB'];
options.printlevel = 0;

if cxcalcInstalled && oBabelInstalled && javaInstalled
    options.adjustToModelpH = true;
    options.onlyUnmapped = false;
else
    options.adjustToModelpH = false;
    options.onlyUnmapped = true;
end

[info, model] = generateChemicalDatabase(model, options);

if cxcalcInstalled && oBabelInstalled && javaInstalled
    assert(isequal(model, model2), 'The model ouput is different')
    assert(isequal(info, info1), 'The database report is different')
else
    assert(isequal(model, model3), 'The model ouput is different')
    assert(isequal(info, info2), 'The database report is different')
end

rmdir([currentDir filesep 'tmpDB'], 's')