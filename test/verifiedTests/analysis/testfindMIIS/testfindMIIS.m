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
global ILOG_CPLEX_PATH

addpath(genpath(ILOG_CPLEX_PATH));

%Test presence of required toolboxes.
v = ver;
bioPres = any(strcmp('Bioinformatics Toolbox', {v.Name})) && license('test','bioinformatics_toolbox');
assert(bioPres,sprintf('The Bioinformatics Toolbox required for this function is not installed or not licensed on your system.'))

statPres = (any(strcmp('Statistics and Machine Learning Toolbox', {v.Name})) || any(strcmp('Statistics Toolbox', {v.Name}))) && license('test','Statistics_Toolbox');
assert(statPres,sprintf('The Statistics and Machine Learning Toolbox required for this function is not installed or not licensed on your system.'))


% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testfindMIIS'));
cd(fileDir);    


% Build infeasible model
rxnForms = {' -> A','A -> B','B -> C', 'B -> D','D -> C','C ->'}
rxnNames = {'R1','R2','R3','R4','R5', 'R6'};
model = createModel(rxnNames, rxnNames,rxnForms)
model.lb(3) = 1;
model.lb(4) = 2;
model.ub(6) = 2;

%findMIIS (works with IBM CPLEX)
changeCobraSolver('ibm_cplex');
res = findMIIS(model);

%test results
assert(isequal(res.rxns,[3;4;6]))
assert(isequal(res.mets,[3;4]))
%%
% change the directory
cd(currentDir)
