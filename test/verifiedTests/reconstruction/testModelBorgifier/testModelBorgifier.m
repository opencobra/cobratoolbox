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

global CBTDIR
pth=which('initCobraToolbox.m');
CBTDIR = pth(1:end-(length('initCobraToolbox.m')+1));

% status is 0 if failed, 1 when all scripts run successfully.
status = 0 ;

% initialize the test
cd(fileparts(which('testModelBorgifier.m')));

% load the models as well as comparision information
fprintf('modelBorgifier: Loading Ecoli core model.\n')
Cmodel = getDistributedModel('ecoli_core_model.mat','Ecoli_core');
fprintf('modelBorgifier: Loading iIT341 model.\n')
Tmodel = getDistributedModel('iIT341.xml','iIT341');

% verify models are appropriate for comparison and test success
fprintf('modelBorgifier: Testing Cmodel verification... ')
try
    Cmodel = verifyModelBorg(Cmodel, 'keepName');
catch
    fprintf('failed.\n')
    return
end
if isfield(Cmodel, 'rxnID')
    fprintf('success.\n')
else
    fprintf('failed.\n')
    return
end
assert(isfield(Cmodel, 'rxnID'))

fprintf('modelBorgifier: Testing Tmodel verification... ')
try
    Tmodel = verifyModelBorg(Tmodel, 'keepName');
catch
    fprintf('failed.\n')
    return
end
if isfield(Tmodel, 'rxnID')
    fprintf('success.\n')
else
    fprintf('failed.\n')
    return
end
assert(isfield(Tmodel, 'rxnID'))

% Test building of the template model
fprintf('modelBorgifier: Testing Tmodel building... ')
try
    Tmodel = buildTmodel(Tmodel);
catch
    fprintf('failed.\n')
    return
end
if isfield(Tmodel, 'Models')
    fprintf('success.\n')
else
    fprintf('failed.\n')
    return
end
assert(isfield(Tmodel, 'Models'))

% compare models and test success
fprintf('modelBorgifier: Testing model comparison... ')
try
    [Cmodel, Tmodel, score, Stats] = compareCbModels(Cmodel, Tmodel);
catch
    fprintf('failed.\n')
    return
end
if sum(sum(sum(score))) ~= 0
    fprintf('success.\n')
else
    fprintf('failed.\n')
    return
end
assert(sum(sum(sum(score))) ~= 0)

% this loads rxnList and metList, which would normally be made by the GUI
fprintf('modelBorgifier: Loading test matching arrays.\n')
load('testModelBorgifierData.mat');
% [rxnList, metList, Stats] = reactionCompare(Cmodel, Tmodel, score);

% merge models (based off of loaded match arrays) and test success
fprintf('modelBorgifier: Testing model merging and extraction... ')
try
    [TmodelC, Cspawn, Stats] = mergeModelsBorg(Cmodel, Tmodel, rxnList, metList, Stats, score);
catch
    fprintf('failed.\n')
    return
end
if isfield(Stats, 'uniqueMetabolites')
    fprintf('success.\n')
else
    fprintf('failed.\n')
    return
end
assert(isfield(Stats, 'uniqueMetabolites'))
status = 1 ; % everything is cool.

% change the directory back
cd(currentDir)

return
