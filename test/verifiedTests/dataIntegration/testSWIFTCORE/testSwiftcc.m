% The COBRAToolbox: testSwiftcc.m
%
% Purpose:
%     - swiftcc(S, rev, solver) returns the indices of the flux consistent reactions of a
%       network: the blocked irreversible reactions come from one LP (blocked, entries -1 of
%       the last n entries of result.x), the blocked reversible reactions from a QR
%       factorisation of the remaining columns (a reversible reaction is consistent when its
%       row of the null space basis of S is not zero). The test checks, for every solver, the
%       consistent indices on hand-built networks whose blocked reactions are derived by hand
%       below (a dead end, a metabolite never produced, irreversible reactions blocked only by
%       their direction, a network without blocked reaction, a network where every reaction is
%       blocked), with the default solver argument, a legacy solver name and an explicit COBRA
%       solver name. The legacy test testSWIFTCORE.m (a test of swiftcore) also calls swiftcc,
%       comparing it with fastcc on ecoli_core_model.
%
% Function under test:
%     src/dataIntegration/transcriptomics/SWIFTCORE/swiftcc.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - one LP per call on hand-built networks of up to 5 metabolites and 8 reactions,
%     every available LP solver among gurobi and glpk.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSwiftcc'));
cd(fileDir);

% the function solves an LP: require an LP solver and use gurobi and glpk where available
globalsBefore = who('global');
solvers = prepareTest('needsLP', true, 'useSolversIfAvailable', {'gurobi', 'glpk'});
initialSolverState = CobraSolverState.get();

% Network 1, metabolites A, B, C, D, X:
%   R1 (-> A), R2 (A -> B), R3 (B ->), R5 (D -> B), R7 (X -> A), R8 (X -> B) irreversible;
%   R4 (A <=> C) and R6 (A <=> B) reversible.
% By hand: R1, R2, R3 form the path -> A -> B ->, and R6 can carry A -> B in parallel to R2,
% so R1, R2, R3, R6 are consistent. C occurs only in R4, so v4 = 0 (blocked reversible). D
% occurs only in R5, so v5 = 0 (blocked irreversible). X is consumed by R7 and R8 and
% produced by none: -v7 - v8 = 0 with v7, v8 >= 0 forces v7 = v8 = 0 (blocked irreversible,
% only by their direction: without it B -> X -> A would be a steady state).
S1 = sparse([1, -1,  0, -1,  0, -1,  1,  0; ...   % A
             0,  1, -1,  0,  1,  1,  0,  1; ...   % B
             0,  0,  0,  1,  0,  0,  0,  0; ...   % C
             0,  0,  0,  0, -1,  0,  0,  0; ...   % D
             0,  0,  0,  0,  0,  0, -1, -1]);     % X
rev1 = [0; 0; 0; 1; 0; 1; 0; 0];
expectedConsistent1 = [1; 2; 3; 6];

% Network 2, metabolites A, B: R1 (-> A), R2 (A -> B) irreversible, R3 (B <=>) reversible;
% the path -> A -> B <=> carries flux through every reaction, so all are consistent
S2 = sparse([1, -1,  0; ...
             0,  1, -1]);
rev2 = [0; 0; 1];

% Network 3, metabolites A, B: R1 (-> A) and R2 (A -> B) irreversible; B has no outlet, so
% both are blocked and no reaction is consistent
S3 = sparse([1, -1; ...
             0,  1]);
rev3 = [0; 0];

for k = 1:numel(solvers.LP)
    solverName = solvers.LP{k};
    solverOK = changeCobraSolver(solverName, 'LP', 0);
    assert(solverOK == 1);
    fprintf('   Testing swiftcc using %s ... \n', solverName);

    %% no solver argument: the default 'linprog' (line 32) is a legacy name for blocked, which
    % then uses the configured COBRA LP solver; the indices are the hand-derived ones
    % (integers: exact comparison)
    consistent = swiftcc(S1, rev1);
    assert(isequal(consistent, expectedConsistent1));

    %% a legacy solver name gives the same consistent reactions
    consistent = swiftcc(S1, rev1, 'gurobi');
    assert(isequal(consistent, expectedConsistent1));

    %% the current COBRA solver named explicitly gives the same consistent reactions
    consistent = swiftcc(S1, rev1, solverName);
    assert(isequal(consistent, expectedConsistent1));

    %% a network without blocked reaction: every index is returned
    consistent = swiftcc(S2, rev2, solverName);
    assert(isequal(consistent, [1; 2; 3]));

    %% every reaction blocked: no index is returned
    consistent = swiftcc(S3, rev3, solverName);
    assert(isempty(consistent));
end

% restore the solver state and remove the globals created by this test
CobraSolverState.restore(initialSolverState);
newGlobals = setdiff(who('global'), globalsBefore);
for iGlobal = 1:numel(newGlobals)
    clear('global', newGlobals{iGlobal});
end

% change the directory
cd(currentDir)
