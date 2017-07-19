% The COBRAToolbox: testCoupleRxnList2Rxn.m
%
% Purpose:
%     - tests the basic functionality of coupleRxnList2Rxn
%
% Authors:
%     - Original file: Almut Heinken - March 2017
%     - CI integration: Laurent Heirendt - March 2017
%
global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCoupleRxnList2Rxn'));
cd(fileDir);

% test coupling constraints
load([CBTDIR, filesep, 'test' filesep 'models' filesep 'ecoli_core_model.mat'], 'model');

% remove ATPM constraint so no infeasible model is generated
model = changeRxnBounds(model, 'ATPM', 0, 'l');

% couple E. coli reactions (except exchanges and biomass) to biomass
rxnC = 'Biomass_Ecoli_core_w_GAM';
rxnList = model.rxns(find(~strncmp('EX_', model.rxns, 3)));

rxnList(strmatch('Biomass', rxnList), :) = [];

c = 400;
u = 0.01;
[modelCoupled] = coupleRxnList2Rxn(model, rxnList, rxnC, c, u);

% test if the coupling constraints work
% expected that the absolute flux through one reaction cannot be higher than (flux through rxnC*c)+u
% constrain flux through rxnC to a random value between 0.01 and 0.1
constrFlux = rand * 0.1;
modelCoupled = changeRxnBounds(modelCoupled, rxnC, constrFlux, 'u');

% set the tolerance
tol = 1e-4;

%test solver packages
solverPkgs = {'tomlab_cplex', 'gurobi6', 'glpk'};

for k = 1:length(solverPkgs)

    % change the COBRA solver (LP)
    solverOK = changeCobraSolver(solverPkgs{k}, 'LP', 0);

    if solverOK == 1
        fprintf('   Testing coupleRxnList2Rxn using %s ... ', solverPkgs{k});

        % optimize a random coupled reaction 100 times
        for i = 1:100
            rxnInd = rxnList{randi(length(rxnList), 1), 1};
            modelCoupled = changeObjective(modelCoupled, rxnInd);
            solution = solveCobraLP(modelCoupled);
            assert(abs(solution.obj) <= (constrFlux * c) + u + tol)
        end

        % now do the same test for the uncoupled model-should fail
        model = changeRxnBounds(model, rxnC, constrFlux, 'u');

        for i = 1:100
            rxnInd = rxnList{randi(length(rxnList), 1), 1};
            model = changeObjective(model, rxnInd);
            solution = solveCobraLP(modelCoupled);
            assert(abs(solution.obj) <= (constrFlux * c) + u + tol)
        end
    end

    % output a success message
    fprintf('Done.\n');
end

% change the directory
cd(currentDir)
