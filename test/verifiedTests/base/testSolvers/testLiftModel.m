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

DefaultValues =   [10;1000000;1000000;0;-10;1000000;0;0];

%Now, run solvers.
% define the solver packages to be used to run this test
solverPkgs = {'gurobi', 'tomlab_cplex', 'ibm_cplex', 'glpk'};

for k = 1:length(solverPkgs)

    % change the COBRA solver (LP)
    solverOK = changeCobraSolver(solverPkgs{k}, 'LP', 0);

    if solverOK == 1
        fprintf('   Testing model lifting using %s ... \n', solverPkgs{k});
        sol = optimizeCbModel(toy);
        if sol.stat == 1
                assert(abs(sol.f-1e6) < tol);
        else
            %Now, we got an issue that the original problem is unsolveable
            %test the lifted problem only.
            sol.v = DefaultValues;
        end
        %Without coupling the max objective is 1e6
        solLifted = solveCobraLP(liftedLPProblem);

        assert(all(abs(solLifted.full(NecessarilyEqual) - sol.v(NecessarilyEqual)) < tol));

    end

end

% load the model - With a coupling constraint.
toy = createToyModelForLifting(1);

%Create the lifted LP.
liftedLPProblem = liftModel(toy);

%Init Default Values, if the original model poses issues.
DefaultValues = [0.01;1000;1000;0.01;-0.01;1000;-0.01;0.01];


for k = 1:length(solverPkgs)

    % change the COBRA solver (LP)
    solverOK = changeCobraSolver(solverPkgs{k}, 'LP', 0);

    if solverOK == 1
        fprintf('   Testing model lifting with coupling using %s ... \n', solverPkgs{k});
        sol = optimizeCbModel(toy);
        %Now, the maximum value is 1e3, due to coupling.
        if sol.stat == 1
            assert(abs(sol.f-1e3) < tol);
        else
            %Now, we got an issue that the original problem is unsolveable
            %test the lifted problem only.
            sol.v = DefaultValues;
        end


        %Without coupling the max objective is 1e6
        solLifted = solveCobraLP(liftedLPProblem);

        assert(all(abs(solLifted.full(1:numel(toy.rxns))-sol.v) < tol));

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
