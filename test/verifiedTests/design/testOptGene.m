% The COBRAToolbox: testOptGene.m
%
% Purpose:
%     - test the optGene function
%
% Authors:
%     - Jacek Wachowiak

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

solverPkgs = {'ibm_cplex'};
solComps = {{'CO2t', 'PFL'}, 1.0238};

for k = 1:length(solverPkgs)

    % set the solver
    solverOK = changeCobraSolver(solverPkgs{k}, 'LP', 0)  && changeCobraSolver(solverPkgs{k}, 'MILP', 0);

    % save the version information of MATLAB toolboxes
    v = ver;
    
    if solverOK == 1 && any(strcmp('Global Optimization Toolbox', {v.Name})) && license('test','Optimization_Toolbox')
        fprintf('Testing optGene using %s ...\n',solverPkgs{k});
        % function outputs
        % requires Global Optimization Toolbox
        %Set the rng, for reproducability
        rng(0);
        [x, population, scores, optGeneSol] = optGene(model, targetRxn, fructose_substrateRxn,generxnList, 'StallTimeLimit',5,'TimeLimit',15);
        %Check, that we get the expected solution from a previous run.
        assert(isempty(setxor(optGeneSol.rxnList,solComps{k,1}))); %Check that the set is correct
        %And that the optimum is correct.
        assert(abs(min(optGeneSol.scores)+solComps{k,2}) < 1e-4); %Check, that the optimium is correct, within precision.
        optSols = population((optGeneSol.scores == min(optGeneSol.scores)),:); %Get the set of optimal Solutions.
        optReacs = sum(optSols) == max(sum(optSols,1));
        %The smallest possible solution from this run is 3 reactions.
        assert(isempty(setxor(generxnList(optReacs),solComps{k,1})));
        model2 = model;
        model2.lb(ismember(model2.rxns,generxnList(optReacs))) = 0;
        model2.ub(ismember(model2.rxns,generxnList(optReacs))) = 0;
        sol = optimizeCbModel(model2);
        %And if we turn them off, we get the expected by product formation.
        assert(-sol.x(39) == min(scores));
    else
        if solverOK
            v = ver;
            optPres = any(strcmp('Global Optimization Toolbox', {v.Name})) && license('test','Optimization_Toolbox');
            assert(optPres,sprintf('The Optimization Toolbox is not installed or not licensed on your system.\nThis function might work with other non linear solvers, but they are not tested.'))
        else
            assert(false,sprintf('The tested solver (ibm_cplex) is not installed on your system.\nThis function might work with other solvers, but they are not tested.'))
        end
    end
end
% close the open windows
close all
fprintf('Done.\n');
% change to old directory
cd(currentDir);
