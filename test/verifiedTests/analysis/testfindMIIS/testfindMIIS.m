% The COBRAToolbox: testfindMIIS.m
%
% Purpose:
%     - testfindMIIS tests the debugging tool findMIIS that takes as input
%     an infeasible model and returns to  Minimal Irreducible Infeasible
%     Submodel
%
% Author:
%     - Marouen BEN GUEBILA 02/12/2017

global CBTDIR

% Define requirements for the test
prepareTest('requiredSolvers',{'ibm_cplex'}) %Could this also use tomlab cplex??
% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testfindMIIS'));
cd(fileDir);    


% Build infeasible model
rxnForms = {' -> A','A -> B','B -> C', 'B -> D','D -> C','C ->'};
rxnNames = {'R1','R2','R3','R4','R5', 'R6'};
model = createModel(rxnNames, rxnNames,rxnForms);
model.lb(3) = 1;
model.lb(4) = 2;
model.ub(6) = 2;

%findMIIS (works with IBM CPLEX)
solverOK = changeCobraSolver('ibm_cplex');

if solverOK
    res = findMIIS(model);

    %test results
    assert(isequal(res.rxns,[3;4;6]))
    assert(isequal(res.mets,[3;4]))
end
%%
% change the directory
cd(currentDir)
