% The COBRAToolbox: testAnalyzeGCdesign.m
%
% Purpose:
%     - test the analyzeGCdesign function
%
% Authors:
%     - Jacek Wachowiak

% save the current path
currentDir = pwd;


%This tests requires gurobi
requireOneSolverOf = {'tomlab_cplex','ibm_cplex', 'gurobi'};
solverPkgs = prepareTest('needsQP',true,'requireOneSolverOf', requireOneSolverOf); 


% initialize the test
fileDir = fileparts(which('testAnalyzeGCdesign'));
cd(fileDir);

% test variables
model = getDistributedModel('ecoli_core_model.mat');
modelRed = reduceModel(model);
selectedRxns = modelRed.rxns(22:25);
target = modelRed.rxns(20); % 'EX_ac(e)'
deletions = modelRed.rxns(21);


% function outputs
% solver change due to instability of qpng
% to be changed with gurobi

for k = 1:numel(solverPkgs.QP)
    changeCobraSolver(solverPkgs.QP{k}, 'QP');
    improvedRxnsM = {};
    intermediateSlnsM = {};            
    [improvedRxns, intermediateSlns] = analyzeGCdesign(modelRed, selectedRxns, target, deletions);
    
    for i=2:8
        [improvedRxns2, intermediateSlns2] = analyzeGCdesign(modelRed, selectedRxns, target, deletions, i, i);
        improvedRxnsM{end+1} = improvedRxns2;
        intermediateSlnsM{end+1} = intermediateSlns2;
    end
    
    % tests
    assert(isequal({'EX_akg(e)', 'EX_co2(e)'}, improvedRxns));
    assert(isequal({'EX_acald(e)'}, improvedRxnsM{7}));
    assert(isequal({'EX_acald(e)'}, intermediateSlnsM{7}{1}));
end

% change to old directory
cd(currentDir);
