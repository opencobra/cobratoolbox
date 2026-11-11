% The COBRAToolbox: testOptGene.m
%
% Purpose:
%     - test the optGene function
%
% Authors:
%     - Jacek Wachowiak

% Check requirements

% (optGene uses cobraGa, so the Global Optimization Toolbox is not required)
solvers = prepareTest('needsLP', true, 'needsMILP', true);
% If we have more than one solver per type (LP/MILP), only use those that
% are available for both.
if numel(solvers.LP) > 1 && numel(solvers.MILP) > 1
    commonSolvers = intersect(solvers.LP, solvers.MILP);
    if ~isempty(commonSolvers)  % If there is any such solver
        solvers.MILP = commonSolvers;
        solvers.LP = commonSolvers;
    else  % Use only one solver. otherwise we can get into troubles.
        solvers.LP = solvers.LP(1);
        solvers.MILP = solvers.MILP(1);
    end
end
% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testOptGene'));
cd(fileDir);

% test variables
model = getDistributedModel('ecoli_core_model.mat');
targetRxn = model.rxns{39};  % Succinate
fructose_substrateRxn = model.rxns{26};  % Fructose, even though this has no incluence whatsoever.
generxnList = model.rxns(setdiff([1:95], [11, 13, 26, 39]));  % Everything besides the ATP Maintenance, The biomass reaction and the substrate and target reactions.

klt=min([length(solvers.LP),length(solvers.MILP)]);
for k = 1:klt
    changeCobraSolver(solvers.LP{k}, 'LP', 0);
    changeCobraSolver(solvers.MILP{k}, 'MILP', 0);
    fprintf(' -- Running testOptGene using the solver interfaces: LP: %s ; MILP: %s... ', solvers.LP{k}, solvers.MILP{k});
    basicsolution = optimizeCbModel(model);
    % function outputs
    % Set the rng, for reproducability
    rng(0);
    % a generation limit (besides the time limits) makes the run reproducible with rng(0) and fast
    [x, population, scores, optGeneSol] = optGene(model, targetRxn, fructose_substrateRxn, generxnList, 'StallTimeLimit', 15, 'TimeLimit', 30, 'Generations', 20);
    % Check, that we get the expected solution from a previous run.
    optSols = population((optGeneSol.scores == min(optGeneSol.scores)), :);  % Get the set of optimal Solutions.
    % bit-string populations are double 0/1 (as ga documents), so convert before indexing
    optReacs = logical(optSols(1, :));
    model2 = model;
    model2.lb(ismember(model2.rxns, generxnList(optReacs))) = 0;
    model2.ub(ismember(model2.rxns, generxnList(optReacs))) = 0;
    sol = optimizeCbModel(model2);
    % Lets only assert, that we have some improvement.
    assert(sol.v(39) - basicsolution.v(39) > 0);

end
% close the open windows
close all

% Remove the output, to keep the toolbox updateable.
delete([fileDir filesep 'MILPProblem.mat']);

fprintf('Done.\n');
% change to old directory
cd(currentDir);
