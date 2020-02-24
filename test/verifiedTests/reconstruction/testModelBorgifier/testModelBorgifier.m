% The COBRAToolbox: <testNameOfSrcFile>.m
%
% Purpose:
%     - The purpose is to test the major functionality of modelBorgifier
%       using two models provided with the toolbox.
%
% Authors:
%     - Original File: JT Sauls June 21 2017
%

% save the current path
currentDir = pwd;

% initialize the test
cd(fileparts(which('testModelBorgifier.m')));

% load the models as well as comparision information
fprintf('modelBorgifier: Loading Ecoli core model.\n')
Cmodel = getDistributedModel('ecoli_core_model.mat','Ecoli_core');
fprintf('modelBorgifier: Loading iIT341 model.\n')
Tmodel = getDistributedModel('iIT341.xml','iIT341');

% verify models are appropriate for comparison and test success
fprintf('modelBorgifier: Testing Cmodel verification...\n')
Cmodel = verifyModelBorg(Cmodel, 'keepName');
assert(isfield(Cmodel, 'rxnID'))

fprintf('modelBorgifier: Testing Tmodel verification...\n')
Tmodel = verifyModelBorg(Tmodel, 'keepName');
assert(isfield(Tmodel, 'rxnID'));

% Test building of the template model
fprintf('modelBorgifier: Testing Tmodel building...\n')
Tmodel = buildTmodel(Tmodel);
assert(isfield(Tmodel, 'Models'))

% compare models and test success
fprintf('modelBorgifier: Testing model comparison...\n')
[Cmodel, Tmodel, score, Stats] = compareCbModels(Cmodel, Tmodel);
assert(sum(sum(sum(score))) ~= 0)

% this loads rxnList and metList, which would normally be made by the GUI
fprintf('modelBorgifier: Loading test matching arrays.\n')
load('testModelBorgifierData.mat');
%[rxnList, metList, Stats] = reactionCompare(Cmodel, Tmodel, score);

% merge models (based off of loaded match arrays) and test success
fprintf('modelBorgifier: Testing model merging and extraction...\n')
if usejava('awt')
    mode='p';%avoid input
    [TmodelC, Cspawn, Stats] = mergeModelsBorg(Cmodel, Tmodel, rxnList, metList, Stats, score, mode);
    assert(isfield(Stats, 'uniqueMetabolites'));
end

% change the directory back
cd(currentDir)

return
