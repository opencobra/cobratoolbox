% The COBRAToolbox: testConfigureSetupThermoModelInputs.m
%
% Purpose:
%     - test the configureSetupThermoModelInputs function
%
% Authors:
%     - Jacek Wachowiak

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testConfigureSetupThermoModelInputs'));
cd(fileDir);

% test variables
model = getDistributedModel('Recon3DModel_Dec2017.mat');
model.csense(1:size(model.S,1),1)='E';
model.metFormulas{strcmp(model.mets,'h[i]')}='H';
model.metFormulas(cellfun('isempty',model.metFormulas)) = {'R'};
if isfield(model,'metCharge')
  model.metCharges = double(model.metCharge);
  model=rmfield(model,'metCharge');
end

% function outputs
model = configureSetupThermoModelInputs(model);

% tests
assert(abs(model.T -  298.15) < 1e-4)
assert(abs(model.confidenceLevel -0.95) < 1e-4)
assert(isequal(model.compartments, {'c'; 'e'; 'g'; 'i'; 'l'; 'm'; 'n'; 'r'; 'x'}))
assert(isequal(model.ph, 7 * ones(9,1)))
assert(isequal(model.is, zeros(9,1)))
assert(isequal(model.chi, zeros(9,1)))

% change to old directory
cd(currentDir);
