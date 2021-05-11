%% Cretate a validated training model for thermochemical estimation 
%% *Author: Ronan Fleming, German Preciat, Leiden University*
%% *Reviewers:* 
%% INTRODUCTION
% 
%% PROCEDURE
%% Configure the environment
% All the installation instructions are in a separate .md file named vonBertalanffy.md 
% in docs/source/installation
% 
% With all dependencies installed correctly, we configure our environment, verfy 
% all dependencies, and add required fields and directories to the matlab path.

aPath = which('initVonBertalanffy');
basePath = strrep(aPath,'vonBertalanffy/initVonBertalanffy.m','');
addpath(genpath(basePath))
folderPattern=[filesep 'old'];
method = 'remove';
editCobraToolboxPath(basePath,folderPattern,method)
aPath = which('initVonBertalanffy');
basePath = strrep(aPath,'vonBertalanffy/initVonBertalanffy.m','');
addpath(genpath(basePath))
folderPattern=[filesep 'new'];
method = 'add';
editCobraToolboxPath(basePath,folderPattern,method)

initVonBertalanffy
%% Load the training data

printLevel=1;
forceMolReplacement=0;
trainingModel = createTrainingModel([],[],forceMolReplacement,printLevel);
%% 
% Check that the training data reactions are elementally balanced

% use the chemical formulas from the InChIs to verify that each and every
% reaction is balanced.
%trainingModel = balanceReactionsInTrainingData(trainingModel);
fileName =[pwd filesep 'trainingData_'];
[training_massImbalance, training_imBalancedMass, training_imBalancedCharge, training_imBalancedRxnBool, elements, training_missingFormulaeBool, training_balancedMetBool]...
    = checkMassChargeBalance(trainingModel, -1, fileName);
%% 
% Identify the reactions that (a) do not involve metabolites without formulae, 
% (b) are mass imbalanced ignoring H, (c ) are not formation reactions.

removeBool = ~any(isnan(training_massImbalance),2) & sum(training_massImbalance(:,~strcmp(elements,'H')),2)~=0 & (sum(trainingModel.S~=0,1)~=1)';
T=array2table([find(removeBool),training_massImbalance(removeBool,:)],'VariableNames',['j',elements]);
disp(T)
%% 
% Reverse Legendre Transform the training data

% apply the reverse Legendre transform for the relevant training observations (typically apparent reaction Keq from TECRDB)
use_model_pKas_by_default = false;
if use_model_pKas_by_default
    %TODO load model
    trainingModel = reverseTransformTrainingData(trainingModel, use_model_pKas_by_default,model);
else
    % TODO analyse dependency on trainingModel.Model2TrainingMap
    trainingModel = reverseTransformTrainingData(trainingModel);
end
%% 
% Save the training model to a cache for future use

aPath = which('driver_createTrainingModel.mlx');
aPath = strrep(aPath,['new' filesep 'driver_createTrainingModel.mlx'],['cache' filesep]);
save([aPath 'trainingModel.mat'],'trainingModel')
%% 
% 
% 
%