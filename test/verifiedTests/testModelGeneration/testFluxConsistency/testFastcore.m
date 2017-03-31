% The COBRAToolbox: testFastcore.m
%
% Purpose:
%     - testFastcore tests the functionality of Fastcore
%
% Authors:
%     - Ronan Fleming, August 2015
%     - Thomas Pfau, May 2016
%     - Sylvain Arreckx, March 2017
%

% define global paths
global path_GUROBI
global CBTDIR

% save the current path
currentDir = pwd;

addpath(genpath(path_GUROBI));

solverOK = changeCobraSolver('gurobi6', 'LP');

if solverOK
    % load a model
    load('FastCoreTest.mat');
    model = ConsistentRecon2;

    % randomly pick some reactions
    epsilon = 1e-4;
    for printLevel = [0:2]
        fprintf(' Running Fastcore with printLevel=%d\n', printLevel);
        A = fastcore(coreInd, model, epsilon, printLevel);
    end

    % test, whether all of the core fluxes can carry flux
    reducedmodel = removeRxns(model, setdiff(model.rxns, model.rxns(A)));
    corereacs = intersect(reducedmodel.rxns, model.rxns(coreInd));
    reducedmodel.csense(1:numel(reducedmodel.mets)) = 'E';
    reducedmodel.c(:) = 0;
    [minFlux, maxFlux] = fluxVariability(reducedmodel, [], [], corereacs);

    assert(all(minFlux < epsilon | maxFlux > epsilon))
end

% change the directory
cd(currentDir)
