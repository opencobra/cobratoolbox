% The COBRAToolbox: testModel2JSON.m
%
% Purpose:
%     - Test the model2JSON function, ensuring it correctly converts any COBRA
%       model structure to a JSON file. The validity of the
%       generated JSON file is confirmed by isValidJSON function.
%     - Also verify a reaction assigned to more than one subsystem has
%       every subsystem name written out (not only the first), and that a
%       reaction with a single subsystem (either legacy shape) is unaffected.
%
% Authors:
%     - Farid Zare, 24/08/14
%

% Save the current path and initialize the test
currentDir = cd(fileparts(which(mfilename)));

% Determine the test path for references
testPath = pwd;

% Initiate the test
fprintf(' -- Running testModel2JSON ... \n');

% Run the code for 5 different models
modelNames = {'ecoli_core_model.mat', 'Recon1.0model.mat', 'Recon2.v05.mat',...
    'Abiotrophia_defectiva_ATCC_49176.mat', 'Recon3DModel_301.mat', 'iJO1366.mat'};

% Ensure the model2JSON can produce valid JSON files for all the models
for i = 1:numel(modelNames)
    model = getDistributedModel(modelNames{i});

    % Run the function being tested
    fileName = 'testModel_output.json';
    model2JSON(model, fileName);

    % Check to see if the file is valid
    [isValid] = isValidJSON(fileName);

    % Clean up (delete the generated JSON file)
    delete(fileName);

    assert(isValid, ['The model ' modelNames{i} ' produced an invalid JSON file.'])
end

% A reaction assigned to more than one subsystem MUST have every name
% written out, not only the first (FR-001, SC-001)
model = getDistributedModel('ecoli_core_model.mat');
multiSubsystemRxn = model.rxns{1};
modelMulti = model;
modelMulti.subSystems{1} = {'Glycolysis', 'Pentose Phosphate'};
fileName = 'testModel2JSON_multiSubsystem.json';
model2JSON(modelMulti, fileName);
txt = fileread(fileName);
delete(fileName);

% Isolate the JSON object for the reaction under test so a legitimate
% "Pentose Phosphate Pathway" entry elsewhere in the model cannot mask a
% dropped name for this specific reaction
idStart = strfind(txt, ['"' multiSubsystemRxn '"']);
window = txt(idStart(1):min(idStart(1) + 2000, numel(txt)));
subsystemValue = regexp(window, '"subsystem":"([^"]*)"', 'tokens', 'once');
subsystemValue = subsystemValue{1};
assert(contains(subsystemValue, 'Glycolysis') && contains(subsystemValue, 'Pentose Phosphate'), ...
    'model2JSON dropped a subsystem name for a reaction assigned to more than one subsystem.');

% A reaction with exactly one subsystem, in either legacy single-subsystem
% shape, MUST be written out unchanged (FR-002)
singleSubsystemRxn = model.rxns{2};
expectedSingleName = model.subSystems{2};
modelSingleCell = model;
modelSingleCell.subSystems{2} = {expectedSingleName};
fileName = 'testModel2JSON_singleSubsystem.json';
model2JSON(modelSingleCell, fileName);
txt = fileread(fileName);
delete(fileName);
idStart = strfind(txt, ['"' singleSubsystemRxn '"']);
window = txt(idStart(1):min(idStart(1) + 2000, numel(txt)));
subsystemValue = regexp(window, '"subsystem":"([^"]*)"', 'tokens', 'once');
assert(strcmp(subsystemValue{1}, expectedSingleName), ...
    'model2JSON changed the output for a reaction with a single subsystem.');

% Change the directory back to the original
cd(currentDir);

% output a success message
fprintf('Done.\n');
