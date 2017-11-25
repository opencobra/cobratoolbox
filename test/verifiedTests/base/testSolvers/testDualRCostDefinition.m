% The COBRAToolbox: testDualRCostDefinition.m
%
% Purpose:
%     - Tests the definition of the shadow price (dual) and reduced cost (rcost)
%       when performing FBA in the COBRA Toolbox with different solvers and
%       prints the results
%
% Authors: - Almut Heinken, 11/2017 (original file)
%          - Laurent Heirendt, 11/2017 (integration)

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testDualRCostDefinition'));
cd(fileDir);

% load the model
model = getDistributedModel('ecoli_core_model.mat');

% change constraints to have both types of reduced costs in the solution
model = changeRxnBounds(model, 'EX_o2(e)', -30, 'b');

summary = {};
solvers = {'glpk', 'gurobi', 'pdco', 'tomlab_cplex', 'ibm_cplex', 'matlab', 'mosek'};

% Find the index for a metabolite and a reaction that would increase the flux through the objective
% function (BOF) with increased availability/flux.
% So here the shadow prices and reduced costs should indicate value towards
% the objective function.
incObjMet = find(strcmp(model.mets, 'glc-D[e]'));
incObjRxn = find(strcmp(model.rxns, 'EX_glc(e)'));
summary{1, 2} = 'SP_IncreasedObjective';
summary{1, 3} = 'RC_IncreasedObjective';

% Now find the index for a metabolite and a reaction that would decrease the flux through the objective
% function (BOF) with increased availability/flux.
% So here the shadow prices and reduced costs should indicate that the
% metabolite/flux is in excess and needs to be removed.
decObjMet = find(strcmp(model.mets, 'o2[e]'));
decObjRxn = find(strcmp(model.rxns, 'EX_o2(e)'));
summary{1, 4} = 'SP_DecreasedObjective';
summary{1, 5} = 'RC_DecreasedObjective';

% print the results on the screen
fprintf('SP = Shadow prices\n')
fprintf('RC = Reduced costs\n')
fprintf('OF = Objective function\n')

% test the definition of shadow price and reduced cost in all solvers
for i = 1:length(solvers)

    % change the LP solver
    solverOK = changeCobraSolver(solvers{i}, 'LP', 0);
    summary{i + 1, 1} = solvers{i};

    % run the tests if the solver is available
    if solverOK
        FBA = optimizeCbModel(model, 'max');
        summary{i + 1, 2} = FBA.dual(incObjMet);
        summary{i + 1, 3} = FBA.rcost(incObjRxn);
        summary{i + 1, 4} = FBA.dual(decObjMet);
        summary{i + 1, 5} = FBA.rcost(decObjRxn);

        % compare all solvers
        assert(summary{i + 1, 2} > 0); % SP is positive for metabolites that increase OF flux
        assert(summary{i + 1, 4} < 0); % SP is negative for metabolites that decrease OF flux
        assert(summary{i + 1, 3} > 0); % RC is positive for reactions that increase OF flux
        assert(summary{i + 1, 5} < 0); % RC is negative for reactions that decrease OF flux

        fprintf(['\n > Solver summary: ', solvers{i}, '\n'])
        % shadow prices
        outputSummary(summary, i, 2, 'increase', 'SP');
        outputSummary(summary, i, 4, 'decrease', 'SP');

        % reduced costs
        outputSummary(summary, i, 3, 'increase', 'RC');
        outputSummary(summary, i, 5, 'decrease', 'RC');
    end
end

% print out the summary table
fprintf('\n > Summary table: \n\n');
T = cell2table(summary(2:end, :));
T.Properties.VariableNames = {'Solvername', summary{1,2}, summary{1, 3}, summary{1, 4}, summary{1, 5}};
disp(T);

% change the directory
cd(currentDir)

function outputSummary(summary, i, k, variation, shadRed)
% internal function to print out a summary

    if summary{i + 1, k} > 0
        fprintf([' + ', shadRed, ' is positive for metabolites that ', variation, ' OF flux\n']);
    elseif summary{i + 1, k} < 0
        fprintf([' - ', shadRed, ' is negative for metabolites that ', variation, ' OF flux\n']);
    elseif summary{i + 1, k} == 0
        fprintf([' * ', shadRed, ' is zero for metabolites that ', variation, ' OF flux\n']);
    end
end