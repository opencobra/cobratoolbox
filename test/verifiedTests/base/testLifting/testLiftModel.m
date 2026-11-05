% The COBRAToolbox: testLiftModel.m
%
% Purpose:
%     - liftModel builds the LP of a model and replaces its large coefficients by sequences of
%       well scaled rows. The test checks that the lifted LP has the optimum of the original
%       model, that the file interface works, and which default fields the function fills in.
%
% Function under test:
%     src/base/solvers/rescale/liftModel.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - toy model, LP solver.
%
% Coverage exemptions:
%     Lines 52-53: unreachable, buildOptProblemFromModel always returns the field A.
%     Lines 66-67: unreachable, buildOptProblemFromModel always returns the field b.
%     Line 72: unreachable, buildOptProblemFromModel always returns the field osense.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Original file: Thomas Pfau - Sept 2017
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%
% Note:
%     - The solver libraries must be included separately

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testLiftModel'));
cd(fileDir);

% require an LP solver; skip gracefully if none is available
solvers = prepareTest('needsLP', true, 'useSolversIfAvailable', {'gurobi', 'glpk'});
initialSolverState = CobraSolverState.get();

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
solverPkgs = solvers.LP;

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

%% an empty model is loaded from the file (done in a temporary folder)
scratchDir = tempname;
mkdir(scratchDir);
save([scratchDir filesep 'toy.mat'], 'toy');
liftedFromFile = liftModel([], 1000, 0, 'toy', scratchDir);
assert(isequal(size(liftedFromFile.A), size(liftedLPProblem.A)));
assert(max(abs(liftedFromFile.A(:) - liftedLPProblem.A(:))) < 1e-9);
assert(exist([scratchDir filesep 'L_toy.mat'], 'file') == 2);
rmdir(scratchDir, 's');

%% a model with extra columns has no csense in its problem: the function assumes equalities
toyE = struct();
toyE.S = [1, -1; 0, 1];
toyE.rxns = {'R1'; 'R2'};
toyE.mets = {'A'; 'B'};
toyE.b = [0; 0];
toyE.c = [0; 1];
toyE.lb = [0; 0];
toyE.ub = [10; 10];
toyE.csense = ['E'; 'E'];
toyE.osenseStr = 'max';
toyE.E = [0; 1];
toyE.evars = {'x1'};
toyE.evarlb = 0;
toyE.evarub = 1;
toyE.evarc = 0;
liftedE = liftModel(toyE, 1000, 0);
assert(isequal(full(liftedE.A), [1, -1, 0; 0, 1, 1]));
assert(all(liftedE.csense == 'E'));

% leave the solver selection as it was found
CobraSolverState.restore(initialSolverState);

fprintf('Done...\n')

%Switch back to original folder
cd(currentDir)
