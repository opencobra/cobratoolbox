% The COBRAToolbox: testFVA.m
%
% Purpose:
%     - testFVA tests the functionality of flux variability analysis
%       basically performs FVA and checks solution against known solution.
%
% Authors:
%     - Original file: Joseph Kang 04/27/09
%     - CI integration: Laurent Heirendt January 2017
%     - Vmin, Vmax test: Marouen Ben Guebila 24/02/17
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAddLoopLawConstraints.m'));
cd(fileDir);

% set the tolerance
tol = 1e-4;

loopToyModel = createToyModelForgapFind();
LPproblem = buildLPproblemFromModel(loopToyModel);
nRxns = numel(loopToyModel.rxns);
solverPkgs = {'tomlab_cplex', 'gurobi', 'ibm_cplex','glpk'};
methods = [1,2];
options = [false, true];
R4objective = double(ismember(loopToyModel.rxns,'R4')); %This should not be able to carry flux under looplaw constraints.
NormalObjective = double(loopToyModel.c ~= 0);

for k = 1:length(solverPkgs)
    solverOk = changeCobraSolver(solverPkgs{k},'MILP',0);
    if solverOk
        for method = methods
            for reduce_vars = options
                %Test original objective
                LPproblem.c = NormalObjective;
                MILPProblem = addLoopLawConstraints(LPproblem,loopToyModel,1:nRxns,method,reduce_vars);
                sol = solveCobraMILP(MILPProblem);
                assert(sol.obj == 1000); %This can carry a flux of 1000
                assert(all(sol.full(ismember(loopToyModel.rxns,{'R4','R5','R6'})) == 0)); %The loop is not part of the solution and can't carry flux.
                LPproblem.c = R4objective;
                MILPProblem = addLoopLawConstraints(LPproblem,loopToyModel,1:nRxns,method,reduce_vars);
                sol = solveCobraMILP(MILPProblem);
                assert(sol.obj == 0); %There can't be any flux on this.
            end
        end
    end
end


% define the solver packages to be used to run this test
fprintf('Done.\n');

% change the directory
cd(currentDir)
