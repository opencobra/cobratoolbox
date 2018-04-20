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

summaryTable = {};
solvers = {'matlab', 'glpk', 'gurobi', 'pdco', 'tomlab_cplex', 'ibm_cplex', 'mosek'};

% Find the index for a metabolite and a reaction that would increase the flux through the objective
% function (BOF) with increased availability/flux.
% So here the shadow prices and reduced costs should indicate value towards
% the objective function.
incObjMet = find(strcmp(model.mets, 'glc-D[e]'));
incObjRxn = find(strcmp(model.rxns, 'EX_glc(e)'));
summaryTable{1, 2} = 'SP_IncreasedObjective';
summaryTable{1, 3} = 'RC_IncreasedObjective';

% Now find the index for a metabolite and a reaction that would decrease the flux through the objective
% function (BOF) with increased availability/flux.
% So here the shadow prices and reduced costs should indicate that the
% metabolite/flux is in excess and needs to be removed.
decObjMet = find(strcmp(model.mets, 'o2[e]'));
decObjRxn = find(strcmp(model.rxns, 'EX_o2(e)'));
summaryTable{1, 4} = 'SP_DecreasedObjective';
summaryTable{1, 5} = 'RC_DecreasedObjective';

% print the results on the screen
fprintf('SP = Shadow prices\n')
fprintf('RC = Reduced costs\n')
fprintf('OF = Objective function\n')

% test the definition of shadow price and reduced cost in all solvers
for i = 1:length(solvers)

    % change the LP solver
    solverOK = changeCobraSolver(solvers{i}, 'LP', 0);
    summaryTable{i + 1, 1} = solvers{i};

    % run the tests if the solver is available
    if solverOK
        FBA = optimizeCbModel(model, 'max');
        FBA
        %
%                          * f - Objective value
%                          * v - Reaction rates (Optimal primal variable, legacy FBAsoltion.x)
%                          * y - Dual
%                          * w - Reduced costs
%                          * s - Slacks
%                          * stat - Solver status in standardized form:
        summaryTable{i + 1, 2} = FBA.y(incObjMet);
        summaryTable{i + 1, 3} = FBA.w(incObjRxn);
        summaryTable{i + 1, 4} = FBA.y(decObjMet);
        summaryTable{i + 1, 5} = FBA.w(decObjRxn);

        % compare all solvers
        assert(summaryTable{i + 1, 2} > 0);  % SP is positive for metabolites that increase OF flux
        assert(summaryTable{i + 1, 4} < 0);  % SP is negative for metabolites that decrease OF flux
        assert(summaryTable{i + 1, 3} > 0);  % RC is positive for reactions that increase OF flux
        assert(summaryTable{i + 1, 5} < 0);  % RC is negative for reactions that decrease OF flux

        fprintf(['\n > Solver summaryTable: ', solvers{i}, '\n'])

        % shadow prices
        outputSummary(summaryTable, i, 2, 'increase', 'SP');
        outputSummary(summaryTable, i, 4, 'decrease', 'SP');

        % reduced costs
        outputSummary(summaryTable, i, 3, 'increase', 'RC');
        outputSummary(summaryTable, i, 5, 'decrease', 'RC');
    end
end

% print out the summaryTable table
fprintf('\n > summaryTable table: \n\n');
T = cell2table(summaryTable(2:end, :));
T.Properties.VariableNames = {'Solvername', summaryTable{1, 2}, summaryTable{1, 3}, summaryTable{1, 4}, summaryTable{1, 5}};
disp(T);

% change the directory
cd(currentDir)


