% The COBRAToolbox: testliftModel.m
%
% Purpose:
%     - tests
%
% Authors:
%     - Original file: Thomas Pfau - Sept 2017
%
% Note:
%     - The solver libraries must be included separately

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testliftModel.m'));
cd(fileDir);

%get the default tolerances.
tol = getCobraSolverParams('LP','optTol');

% load the model
toy = createToyModelForLifting(0);

%Create the lifted LP.
liftedLPProblem = liftModel(toy);

%The following reactions should be equal if the lifting was correct:
NecessarilyEqual = ismember(toy.rxns,{'R1','R2','R3','EX_A','EX_E'});

%Now, run solvers.
% define the solver packages to be used to run this test
solverPkgs = {'gurobi6', 'tomlab_cplex', 'ibm_cplex', 'glpk'};

for k = 1:length(solverPkgs)
    
    % change the COBRA solver (LP)
    solverOK = changeCobraSolver(solverPkgs{k}, 'LP', 0);
    
    if solverOK == 1
        fprintf('   Testing model lifting using %s ... \n', solverPkgs{k});
        sol = optimizeCbModel(toy)
        assert(abs(sol.f-1e6) < tol);
        
        %Without coupling the max objective is 1e6
        solLifted = solveCobraLP(liftedLPProblem);
        
        assert(all(abs(solLifted.full(NecessarilyEqual)-sol.full(NecessarilyEqual)) < tol));
        
    end
    
end

% load the model - With a coupling constraint.
toy = createToyModelForLifting(1);

%Create the lifted LP.
liftedLPProblem = liftModel(toy);

for k = 1:length(solverPkgs)
    
    % change the COBRA solver (LP)
    solverOK = changeCobraSolver(solverPkgs{k}, 'LP', 0);
    
    if solverOK == 1
        fprintf('   Testing model lifting with coupling using %s ... \n', solverPkgs{k});
        sol = optimizeCbModel(toy);
        %Now, the maximum value is 1e3, due to coupling.
        assert(abs(sol.f-1e3) < tol);
        
        %Without coupling the max objective is 1e6
        solLifted = solveCobraLP(liftedLPProblem);
        
        assert(all(abs(solLifted.full(1:numel(toy.rxns))-sol.full) < tol));
        
    end
    
end

%Test, whether the file IO function works
save('toy.mat','toy')
liftModel(toy,1000,0,'toy',fileDir);
load('L_toy.mat');
assert(isSameCobraModel(LPproblem,liftedLPProblem));

%Clean up.
delete('toy.mat','L_toy.mat');

fprintf('Done...\n')

%Switch back to original folder
cd(currentDir)