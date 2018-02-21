% The COBRAToolbox: testfeasOpt.m
%
% Purpose:
%     - testfeasOpt tests the function feasOpt that minimally
%     relaxes an infeasible model in three different modes
%
% Author:
%     - Marouen BEN GUEBILA 02/12/2017

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testfeasOpt'));
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

%sets relaxation weights
%do not relax steady-state
lhs=zeros(1,length(model.b));
rhs=zeros(1,length(model.b));
%relax only bounds
lb =ones(1,length(model.rxns));
ub =ones(1,length(model.rxns));


if solverOK
    %loop through modes
    for mode=[0,1,2,3,4,5]
        res = feasOpt(model,lhs,rhs,lb,ub,mode);

        %test results
        assert(isequal(model.S*res.v,zeros(length(model.b),1)))
    end
end
%%
% change the directory
cd(currentDir)