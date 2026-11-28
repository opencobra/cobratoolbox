% The COBRAToolbox: testGoodInitialPoint.m
%
% Purpose:
%     - goodInitialPoint solves 4*n LPs (minimum and maximum of every reaction, then of a
%       random objective with weight 1 on every reaction in turn) and returns random convex
%       combinations of the 4*n optimal flux vectors. The test checks the size of the output
%       and, for every point, the invariants derived by hand: steady state S*v = 0, the flux
%       bounds, and strict interiority (every reaction reaches 0 at its minimum and a positive
%       maximum among the vertices, and every vertex has a positive weight, so every
%       coordinate lies strictly between its bounds). The point itself is random and is not
%       pinned.
%
% Function under test:
%     src/dataIntegration/fluxomics/goodInitialPoint.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - LP solves on hand-built models; every available LP solver among gurobi and
%     glpk. One model has 100 reactions, the smallest size that reaches the progress output
%     of lines 33 and 45 (printed every 100 reactions).
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGoodInitialPoint'));
cd(fileDir);

% require an LP solver; skip gracefully if none is available
solvers = prepareTest('needsLP', true, 'useSolversIfAvailable', {'gurobi', 'glpk'});

% the solver selection is saved and restored; any global created while reading it or by the
% solver interfaces is removed at the end
globalsBefore = who('global');
initialSolverState = CobraSolverState.get();

% fix the random generator for repeatable runs and restore it afterwards
previousRng = rng;
rng(39);

% feasibility tolerance of the LP solutions; the output is an average of LP vertices, so it
% keeps their accuracy
tol = 1e-6;

% a hand-built network with 100 reactions: R1 takes up A (at most 10), R2..R100 each drain
% A (at most 1). The minimum of every reaction is 0, the maximum of R1 is 10 and of the
% others 1
nRxns = 100;
largeModel = struct();
largeModel.S = sparse([1, -ones(1, nRxns - 1)]);
largeModel.b = 0;
largeModel.csense = 'E';
largeModel.mets = {'A'};
largeModel.rxns = strcat('R', strtrim(cellstr(num2str((1:nRxns)'))));
largeModel.lb = zeros(nRxns, 1);
largeModel.ub = [10; ones(nRxns - 1, 1)];
largeModel.c = zeros(nRxns, 1);
largeModel.osenseStr = 'max';

% a three-reaction network for the default number of points
smallModel = struct();
smallModel.S = sparse([1, -1, -1]);
smallModel.b = 0;
smallModel.csense = 'E';
smallModel.mets = {'A'};
smallModel.rxns = {'R1'; 'R2'; 'R3'};
smallModel.lb = [0; 0; 0];
smallModel.ub = [2; 1; 1];
smallModel.c = [0; 0; 0];
smallModel.osenseStr = 'max';

for k = 1:length(solvers.LP)
    solverOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);
    if solverOK
        fprintf('   Testing goodInitialPoint using %s ... \n', solvers.LP{k});

        %% three points of a 100-reaction model (progress output of lines 33 and 45)
        % each column is a convex combination of feasible vertices, so it satisfies the
        % steady state and the bounds; strict interiority follows from the vertex argument
        % in the header
        rng(1);
        points = goodInitialPoint(largeModel, 3);
        assert(isequal(size(points), [nRxns 3]));
        assert(all(all(abs(largeModel.S * points) < tol)));
        assert(all(all(points > largeModel.lb + tol)));
        assert(all(all(points < largeModel.ub - tol)));
        % the points differ, because the weights are drawn anew for each point
        assert(norm(points(:, 1) - points(:, 2)) > tol);

        %% default number of points
        % n omitted gives one point, with the same invariants
        rng(2);
        point = goodInitialPoint(smallModel);
        assert(isequal(size(point), [3 1]));
        assert(abs(smallModel.S * point) < tol);
        assert(all(point > smallModel.lb + tol));
        assert(all(point < smallModel.ub - tol));
    end
end

% leave the solver selection and the random generator as they were found
CobraSolverState.restore(initialSolverState);
newGlobals = setdiff(who('global'), globalsBefore);
if ~isempty(newGlobals)
    clear('global', newGlobals{:});
end
rng(previousRng);

% change the directory
cd(currentDir)
