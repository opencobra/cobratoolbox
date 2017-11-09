% The COBRAToolbox: testOptGene.m
%
% Purpose:
%     - test the optGene function
%
% Authors:
%     - Jacek Wachowiak

%Test PResence of optimisation Toolbox required for this function
v = ver;
optPres = any(strcmp('Global Optimization Toolbox', {v.Name})) && license('test','Optimization_Toolbox');
assert(optPres,sprintf('The Optimization Toolbox is not installed or not licensed on your system.\nThis function might work with other non linear solvers, but they are not tested.'))


global CBTDIR
% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testOptGene'));
cd(fileDir);

% test variables
model = readCbModel([CBTDIR filesep 'test' filesep 'models' filesep 'mat' filesep 'ecoli_core_model.mat']);
targetRxn = model.rxns{39}; % Succinate
fructose_substrateRxn = model.rxns{26}; %Fructose, even though this has no incluence whatsoever.
generxnList = model.rxns(setdiff([1:95],[11,13,26,39])); %Everything besides the ATP Maintenance, The biomass reaction and the substrate and target reactions.

solverPkgs = {'ibm_cplex','gurobi'};
tested = false;
for k = 1:length(solverPkgs)

    % set the solver
    solverOK = changeCobraSolver(solverPkgs{k}, 'LP', 0)  && changeCobraSolver(solverPkgs{k}, 'MILP', 0);

    % save the version information of MATLAB toolboxes
    v = ver;
    
    if solverOK == 1
        basicsolution = optimizeCbModel(model);
        tested = true;
        fprintf('Testing optGene using %s ...\n',solverPkgs{k});
        % function outputs
        % requires Global Optimization Toolbox
        %Set the rng, for reproducability
        rng(0);
        [x, population, scores, optGeneSol] = optGene(model, targetRxn, fructose_substrateRxn,generxnList, 'StallTimeLimit',5,'TimeLimit',15);
        %Check, that we get the expected solution from a previous run.
        optSols = population((optGeneSol.scores == min(optGeneSol.scores)),:); %Get the set of optimal Solutions.
        optReacs = sum(optSols,1) == max(sum(optSols,1));
        model2 = model;
        model2.lb(ismember(model2.rxns,generxnList(optReacs))) = 0;
        model2.ub(ismember(model2.rxns,generxnList(optReacs))) = 0;
        sol = optimizeCbModel(model2);
        %Lets only assert, that we have some improvement.
        assert(sol.full(39) -basicsolution.full(39) > 0);            
    end
end

assert(tested,sprintf('This method is only tested with gurobi and ibm_cplex but should work with other solvers as well.\n To test it please add your prefered solver to the list in this test and rerun the test'));
% close the open windows
close all
fprintf('Done.\n');
% change to old directory
cd(currentDir);
