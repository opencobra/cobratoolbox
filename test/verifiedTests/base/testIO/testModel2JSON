% The COBRAToolbox: testModel2JSON.m
%
% Purpose:
%     - Test the model2JSON function, ensuring it correctly converts any COBRA
%       model structure to a JSON file. The validity of the
%       generated JSON file is confirmed by isValidJSON function
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

% Change the directory back to the original
cd(currentDir);

% output a success message
fprintf('Done.\n');
