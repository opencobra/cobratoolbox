% The COBRAToolbox: testFASTCORE
%
% Purpose:
%     - test FASTCORE algorithm
%
% Authors:
%     - Ronan Fleming, August 2015
%     - Modified by Thomas Pfau, May 2016
%     - Fix by @fplanes July 2017
%     - CI integration: Laurent Heirendt July 2017
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFASTCORE'));
cd(fileDir);


% define the solver packages to be used to run this test
solverPkgs = {'ibm_cplex', 'gurobi', 'tomlab_cplex'};

%load a model
model = readCbModel('FastCoreTest.mat','modelName','ConsistentRecon2');
load('FastCoreTest.mat','coreInd');

k = 1;
while k < length(solverPkgs)+1 % note: only run with 1 solver, not with all 3

    % change the COBRA solver (LP)
    solverOK = changeCobraSolver(solverPkgs{k}, 'LP', 0);
    if solverOK == 1
        fprintf('   Testing FASTCORE using %s ... \n', solverPkgs{k});

        %randomly pick some reactions
        epsilon=1e-4;
        printLevel=0;
        A = fastcore(model, coreInd, epsilon, printLevel);

        %test, whether all of the core fluxes can carry flux
        reducedmodel = removeRxns(model,setdiff(model.rxns,A.rxns));
        corereacs = intersect(reducedmodel.rxns,model.rxns(coreInd));
        reducedmodel.csense(1:numel(reducedmodel.mets)) = 'E';
        reducedmodel.c(:) = 0;
        [minFlux,maxFlux] = fluxVariability(reducedmodel,[],[],corereacs);

        assert(all(minFlux < epsilon | maxFlux > epsilon))

        % end the loop
        k = length(solverPkgs);
    end
    k = k + 1;

    % output a success message
    fprintf('Done.\n');
end

% change the directory
cd(currentDir)
