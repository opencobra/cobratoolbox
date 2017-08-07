% The COBRAToolbox: testGenerateRules.m
%
% Purpose:
%     - testGenerateRules tests generateRules
%
% Authors:
%     - Initial Version: Uri David Akavia - August 2017

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGenerateRules'));
cd(fileDir);

modelsToTry = {'Acidaminococcus_intestini_RyC_MR95.mat', 'Acidaminococcus_sp_D21.mat', 'Recon1.0model.mat', 'ecoli_core_model.mat', 'modelReg.mat'};
%fileList = dir([CBTDIR filesep 'test' filesep 'models' filesep '*.mat']);

for i=1:length(modelsToTry)
    model = readCbModel([CBTDIR filesep 'test' filesep 'models' filesep modelsToTry{i}]);
    fprintf('Beginning model %s\n', fileList(i).name);
    model2 = generateRules(model);
    model.rules = strrep(model.rules, '  ', ' ');
    model.rules = strrep(model.rules, ' )', ')');
    model.rules = strrep(model.rules, '( ', '(');
    assert(all(strcmp(model.rules, model2.rules)));
    fprintf('Succesfully completed model %s\n', fileList(i).name);
end