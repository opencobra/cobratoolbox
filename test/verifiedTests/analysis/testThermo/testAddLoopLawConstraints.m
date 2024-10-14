% The COBRAToolbox: testAddLopLawConstraints.m
%
% Purpose:
%     - test, whether added constraints actually lead to loopless
%     solutions.
%
% Authors:
%     - Thomas Pfau Oct 2017
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAddLoopLawConstraints.m'));
cd(fileDir);

% set the tolerance
tol = 1e-4;

loopToyModel = createToyModelForgapFind();
LPproblem = buildOptProblemFromModel(loopToyModel);
nRxns = numel(loopToyModel.rxns);
solverPkgs = {'tomlab_cplex', 'gurobi', 'ibm_cplex','glpk'};
methods = [1,2];
options = [false, true];
R4objective = double(ismember(loopToyModel.rxns,'R4')); %This should not be able to carry flux under looplaw constraints.
NormalObjective = double(loopToyModel.c ~= 0);

for k = 1:length(solverPkgs)
    solverOk = changeCobraSolver(solverPkgs{k}, 'all', 0);
    if solverOk
        fprintf([' > Running testAddLoopLawConstraints with ' solverPkgs{k} '...']);
        for method = methods
            for reduce_vars = options
                %Test original objective
                LPproblem.c = NormalObjective;
                MILPProblem = addLoopLawConstraints(LPproblem,loopToyModel,1:nRxns,method,reduce_vars);
                sol = solveCobraMILP(MILPProblem);
                assert(abs(sol.obj - 1000) < tol); %This can carry a flux of 1000
                assert(all(abs(sol.full(ismember(loopToyModel.rxns,{'R4','R5','R6'}))) < tol)); %The loop is not part of the solution and can't carry flux.
                LPproblem.c = R4objective;
                MILPProblem = addLoopLawConstraints(LPproblem,loopToyModel,1:nRxns,method,reduce_vars);
                sol = solveCobraMILP(MILPProblem);
                assert(abs(sol.obj) < tol); %There can't be any flux on this.
            end
        end
        fprintf('Done.\n');
    end
end

% define the solver packages to be used to run this test
fprintf('Done.\n');

%Remove the output, to keep the toolbox updateable.
fileName = [fileDir filesep 'MILPProblem.mat'];
if exist(fileName, 'file') == 2
    delete(fileName);
end

% change the directory
cd(currentDir)
