% The COBRAToolbox: testDualRCostDefinition.m
%
% Purpose:
%     - Tests the definition of the shadow price (dual) and reduced cost (rcost)
%       when performing FBA in the COBRA Toolbox with different solvers and
%       prints the results
%
% Author: Almut Heinken, 11/2017

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testDualRCostDefinition'));
cd(fileDir);

% load the model
model = getDistributedModel('ecoli_core_model.mat');

% change constraints to have both types of reduced costs in the solution
model=changeRxnBounds(model,'EX_o2(e)',-30,'b');

solverSummary = {};
solvers={'glpk', 'gurobi', 'pdco', 'tomlab_cplex', 'ibm_cplex', 'matlab'};

% Find the index for a metabolite and a reaction that would increase the flux through the objective
% function (BOF) with increased availability/flux.
% So here the shadow prices and reduced costs should indicate value towards
% the objective function.
incObjMet=find(strcmp(model.mets,'glc-D[e]'));
incObjRxn=find(strcmp(model.rxns,'EX_glc(e)'));
solverSummary{1,2}='ShadowPrice_IncreasedObjective';
solverSummary{1,3}='ReducedCost_IncreasedObjective';
% Now ind the index for a metabolite and a reaction that would decrease the flux through the objective
% function (BOF) with increased availability/flux.
% So here the shadow prices and reduced costs should indicate that the
% metabolite/flux is in excess and needs to be removed.
decObjMet=find(strcmp(model.mets,'o2[e]'));
decObjRxn=find(strcmp(model.rxns,'EX_o2(e)'));
solverSummary{1,4}='ShadowPrice_DecreasedObjective';
solverSummary{1,5}='ReducedCost_DecreasedObjective';

% print the results on the screen
fprintf('SP=Shadow prices\n')
fprintf('RC=Reduced costs\n')
fprintf('OF=Objective function\n')

% test the definition of shadow price and reduced cost in all solvers
for i=1:length(solvers)
    solverOK=changeCobraSolver(solvers{i},'LP', 0);
    if solverOK
        solverSummary{i+1,1}=solvers{i};
        FBA=optimizeCbModel(model,'max');
        solverSummary{i+1,2}=FBA.dual(incObjMet);
        solverSummary{i+1,3}=FBA.rcost(incObjRxn);
        solverSummary{i+1,4}=FBA.dual(decObjMet);
        solverSummary{i+1,5}=FBA.rcost(decObjRxn);

        fprintf('%6s\t%6s\n',solvers{i})
        fprintf('solver summary\n')
        % shadow prices
        if solverSummary{i+1,2}>0
            fprintf('SP is positive for metabolites that increase OF flux\n')
        elseif solverSummary{i+1,2}<0
            fprintf('SP is negative for metabolites that increase OF flux\n')
        elseif solverSummary{i+1,2}==0
            fprintf('SP is zero for metabolites that increase OF flux\n')
        end
        if solverSummary{i+1,4}>0
            fprintf('SP is positive for metabolites that decrease OF flux\n')
        elseif solverSummary{i+1,4}<0
            fprintf('SP is negative for metabolites that decrease OF flux\n')
        elseif solverSummary{i+1,4}==0
            fprintf('SP is zero for metabolites that decrease OF flux\n')
        end
        % reduced costs
        if solverSummary{i+1,3}>0
            fprintf('RC is positive for reactions that increase OF flux\n')
        elseif solverSummary{i+1,3}<0
            fprintf('RC is negative for reactions that increase OF flux\n')
        elseif solverSummary{i+1,3}==0
            fprintf('RC is zero for reactions that increase OF flux\n')
        end
        if solverSummary{i+1,5}>0
            fprintf('RC is positive for reactions that decrease OF flux\n')
        elseif solverSummary{i+1,5}<0
            fprintf('RC is negative for reactions that decrease OF flux\n')
        elseif solverSummary{i+1,5}==0
            fprintf('RC is zero for reactions that decrease OF flux\n')
        end
    end
end

% change the directory
cd(currentDir)
