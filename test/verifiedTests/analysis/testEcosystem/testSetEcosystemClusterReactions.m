% The COBRAToolbox: testSetEcosystemClusterReactions.m
%
% Purpose:
%     - setEcosystemClusterReactions sets eco.rxn2cluster, the reactions of the community
%       model used for qualitative flux variability analysis and clustering: a given list
%       (checked against the model, stored sorted, no flux variability analysis), or by
%       default the non-blocked reactions, found by flux variability analysis with
%       optPercentage 0 (a reaction is blocked when |minFlux| < tol and |maxFlux| < tol),
%       stored sorted in rxn2cluster and in model order in eco.nonBlocked.
%     - Expected values are derived by hand from the five-reaction community model below:
%       R2 and R3 consume metabolites that nothing produces, so they are blocked, and the
%       other three reactions have the flux range [0, 10] (the supply EX_A limits them).
%
% Function under test:
%     src/analysis/ecosystem/setEcosystemClusterReactions.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - flux variability analysis (LP) with every available LP solver among gurobi
%     and glpk, on a hand-built five-reaction model; the ecosystem structure is hand-built
%     with the only field the function reads (model).
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
fileDir = fileparts(which('testSetEcosystemClusterReactions'));
cd(fileDir);

% note the globals that exist now: the solver interface (parameter globals) and showprogress
% create globals, which are removed at the end
globalsBefore = who('global');

% the default call runs flux variability analysis: an LP solver is required
solvers = prepareTest('needsLP', true, 'useSolversIfAvailable', {'gurobi', 'glpk'});
initialSolverState = CobraSolverState.get();

% community model: EX_A supplies at most 10 A, R1 converts A to B, BIO removes B; R2 needs C
% and R3 removes D, and neither C nor D is produced, so R2 and R3 are blocked
rxnIds = {'EX_A'; 'R1'; 'R2'; 'BIO'; 'R3'};
model = createModel(rxnIds, rxnIds, {' -> A'; 'A -> B'; 'C -> B'; 'B -> '; 'D -> '}, ...
    'upperBoundList', [10; 1000; 1000; 1000; 1000], 'printLevel', 0);
model = changeObjective(model, 'BIO');
eco = struct('model', model);

%% a given list of reactions: no flux variability analysis, the list is sorted

% a given list is stored sorted (ASCII order) as a column, and nonBlocked is not set; the
% list is not checked for blocked reactions (R2 is blocked)
ecoList = setEcosystemClusterReactions(eco, 'rxnList', {'R2', 'BIO', 'EX_A'}, 'printLevel', 0);
assert(isequal(ecoList.rxn2cluster, {'BIO'; 'EX_A'; 'R2'}));
assert(~isfield(ecoList, 'nonBlocked'));
% the other fields are kept
assert(isequal(ecoList.model, model));

% a string array is accepted, and printLevel 1 prints the number of reactions
ecoString = setEcosystemClusterReactions(eco, 'rxnList', ["R1", "BIO"], 'printLevel', 1);
assert(isequal(ecoString.rxn2cluster, {'BIO'; 'R1'}));

% a reaction that is not in the community model is an error that names it
assert(verifyCobraFunctionError('setEcosystemClusterReactions', 'inputs', ...
    {eco, 'rxnList', {'R1', 'missing'}}, ...
    'testMessage', 'The following reactions are not in the community model: missing'));

for k = 1:numel(solvers.LP)
    solverOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);
    if solverOK
        fprintf('   Testing setEcosystemClusterReactions using %s ... \n', solvers.LP{k});

        %% default: the non-blocked reactions found by flux variability analysis

        % R2 and R3 carry no flux in any steady state; the other reactions reach 10, far above
        % the default tolerance 1e-7, so the classification is exact for any LP solver
        ecoDefault = setEcosystemClusterReactions(eco, 'printLevel', 0);
        assert(isequal(ecoDefault.nonBlocked, {'EX_A'; 'R1'; 'BIO'}));
        assert(isequal(ecoDefault.rxn2cluster, {'BIO'; 'EX_A'; 'R1'}));

        % the default verbosity (1) prints the message on the missing flux coupling results;
        % an empty list is the default, so it also triggers the analysis
        ecoVerbose = setEcosystemClusterReactions(eco, 'rxnList', {});
        assert(isequal(ecoVerbose.rxn2cluster, ecoDefault.rxn2cluster));

        %% the tolerance decides what is blocked

        % with tol = 20 every reaction (flux range within [0, 10]) is blocked, so the list is
        % empty
        ecoTol = setEcosystemClusterReactions(eco, 'tol', 20, 'printLevel', 0);
        assert(isempty(ecoTol.rxn2cluster) && isempty(ecoTol.nonBlocked));
    end
end

% restore the solver state
CobraSolverState.restore(initialSolverState);

% remove the globals created during the test
newGlobals = setdiff(who('global'), globalsBefore);
for k = 1:numel(newGlobals)
    clearvars('-global', newGlobals{k});
end

% change the directory
cd(currentDir)
