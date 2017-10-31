% The COBRAToolbox: testFASTCC.m
%
% Purpose:
%     - test FASTCC algorithm
%
% Authors:
%     - Original file: Thomas Pfau, May 2016
%     - Fix by @fplanes July 2017
%     - CI integration: Laurent Heirendt July 2017
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFASTCC'));
cd(fileDir);

%load a model
model = readCbModel('FastCoreTest.mat','modelName','modelR204');

%randomly pick some reactions
epsilon = 1e-4;
printLevel = 2;
modeFlag = 0;


% define the solver packages to be used to run this test
solverPkgs = {'ibm_cplex', 'gurobi', 'tomlab_cplex'};

k = 1;
while k < length(solverPkgs)+1 % note: only run with 1 solver, not with all 3

    % change the COBRA solver (LP)
    solverOK = changeCobraSolver(solverPkgs{k}, 'LP', 0);
    if solverOK == 1
        fprintf('   Testing FASTCC using %s ... \n', solverPkgs{k});

        A = fastcc(model, epsilon, printLevel,modeFlag);

        assert(numel(A) == 5317)

        % end the loop
        k = length(solverPkgs);
    end
    k = k + 1;

    % output a success message
    fprintf('Done.\n');
end

% change the directory
cd(currentDir)
