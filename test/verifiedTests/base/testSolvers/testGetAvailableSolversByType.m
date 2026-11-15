% The COBRAToolbox: testGetAvailableSolversByType.m
%
% Purpose:
%     - getAvailableSolversByType() lists, for every problem type in the global OPT_PROB_TYPES,
%       the solvers of the global SOLVERS that are marked working and support that type, plus
%       the field ALL with every working solver. This test sets both globals to hand-built
%       values (a working solver, a solver that is not working and a type without solver)
%       whose expected result follows from the definition,
%       then checks the result for the real globals against SOLVERS itself, and restores the
%       globals.
%
% Function under test:
%     src/base/solvers/getSetSolver/getAvailableSolversByType.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model and no solver (the solver lists are hand-built; nothing is solved).
%
% Coverage exemptions:
%     Lines 17-19: the call of initCobraToolbox when SOLVERS or OPT_PROB_TYPES is empty is the
%     input skipped for the cosmetic defect below (III-Defects).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The output of initCobraToolbox is not silenced
%       SEVERITY: cosmetic
%       TRIGGER: global SOLVERS; SOLVERS = []; getAvailableSolversByType()
%       OBSERVED: the full initCobraToolbox output is printed (banner, solver checks, "Saving the
%       MATLAB path ... Done.", the solver summary table); ENV_VARS on lines 17 and 19 is a local
%       variable (not declared global), so setting ENV_VARS.printLevel has no effect
%       EXPECTED: initCobraToolbox runs with the global ENV_VARS.printLevel false, then restored
%       LINES: 17, 19
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetAvailableSolversByType'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% save the globals the function reads, to restore them at the end
global SOLVERS OPT_PROB_TYPES
savedSolvers = SOLVERS;
savedTypes = OPT_PROB_TYPES;

%% hand-built solvers: only working solvers are listed, under each type they support

OPT_PROB_TYPES = {'LP', 'MILP', 'QP'};
SOLVERS = struct();
SOLVERS.alpha = struct('working', true, 'type', {{'LP', 'QP'}});
SOLVERS.beta = struct('working', false, 'type', {{'LP', 'MILP'}});
SOLVERS.gamma = struct('working', 1, 'type', {{'MILP', 'LP'}});
solvers = getAvailableSolversByType();
% one field per problem type, in the order of OPT_PROB_TYPES, then ALL
assert(isequal(fieldnames(solvers), {'LP'; 'MILP'; 'QP'; 'ALL'}));
assert(isequal(solvers.LP, {'alpha', 'gamma'}));
assert(isequal(solvers.MILP, {'gamma'}));
assert(isequal(solvers.QP, {'alpha'}));
assert(isequal(solvers.ALL, {'alpha', 'gamma'}));

%% a problem type that no working solver supports stays an empty cell

OPT_PROB_TYPES = {'LP', 'NLP'};
SOLVERS = struct('alpha', struct('working', true, 'type', {{'LP'}}), ...
    'beta', struct('working', false, 'type', {{'NLP'}}));
solvers = getAvailableSolversByType();
assert(iscell(solvers.NLP) && isempty(solvers.NLP));
assert(isequal(solvers.LP, {'alpha'}) && isequal(solvers.ALL, {'alpha'}));

%% the globals of this session: the result agrees with SOLVERS

SOLVERS = savedSolvers;
OPT_PROB_TYPES = savedTypes;
solvers = getAvailableSolversByType();
solverNames = fieldnames(SOLVERS);
isWorking = cellfun(@(name) logical(SOLVERS.(name).working), solverNames);
assert(isequal(solvers.ALL(:), solverNames(isWorking)));
for i = 1:numel(OPT_PROB_TYPES)
    probType = OPT_PROB_TYPES{i};
    supports = cellfun(@(name) any(strcmp(SOLVERS.(name).type, probType)), solverNames);
    assert(isequal(sort(solvers.(probType)(:)), sort(solverNames(isWorking & supports))), probType);
end

% restore the globals and the directory
SOLVERS = savedSolvers;
OPT_PROB_TYPES = savedTypes;
cd(currentDir)
