% The COBRAToolbox: testAnalyzeGCdesign.m
%
% Purpose:
%     - test the analyzeGCdesign function
%
% Function under test:
%     src/design/analyzeGCdesign.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - optimisation on ecoli_core_model, loaded through getDistributedModel.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Jacek Wachowiak
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.

% save the current path
currentDir = pwd;


%This tests requires gurobi
requireOneSolverOf = {'tomlab_cplex', 'ibm_cplex', 'gurobi'};
solverPkgs = prepareTest('needsLP',true,'needsQP',true,'requireOneSolverOf', requireOneSolverOf);


% initialize the test
fileDir = fileparts(which('testAnalyzeGCdesign'));
cd(fileDir);

% test variables
model = getDistributedModel('ecoli_core_model.mat');
changeCobraSolver(solverPkgs.LP{1}, 'LP');
fprintf('Reducing model with %s ...\n',solverPkgs.LP{1})

modelRed = reduceModel(model);
selectedRxns = modelRed.rxns(22:25);
target = modelRed.rxns(20); % 'EX_ac(e)'
deletions = modelRed.rxns(21);


% function outputs
% solver change due to instability of qpng
% to be changed with gurobi

for k = 1:numel(solverPkgs.QP)
    changeCobraSolver(solverPkgs.QP{k}, 'QP');
    if any(ismember(solverPkgs.QP{k}, solverPkgs.LP))
        changeCobraSolver(solverPkgs.QP{k}, 'LP');
    end
    fprintf('Testing AnalyzeGCdesign with %s ...\n',solverPkgs.LP{k})
    improvedRxnsM = {};
    intermediateSlnsM = {};
    [improvedRxns, intermediateSlns] = analyzeGCdesign(modelRed, selectedRxns, target, deletions);

    for i=2:8
        [improvedRxns2, intermediateSlns2] = analyzeGCdesign(modelRed, selectedRxns, target, deletions, i, i);
        improvedRxnsM{end+1} = improvedRxns2;
        intermediateSlnsM{end+1} = intermediateSlns2;
    end

    % tests
    assert(isequal({'EX_akg(e)', 'EX_co2(e)', 'EX_etoh(e)'}, improvedRxns));
    assert(isequal({'EX_acald(e)'}, intermediateSlnsM{7}{1}));
end

%% An empty deletion list is rejected
assert(verifyCobraFunctionError('analyzeGCdesign', 'inputs', {modelRed, selectedRxns, target, {}}, ...
                                'testMessage', 'no knockout reactions defined'));

%% A vertical deletion list is turned into a horizontal one
twoDeletions = modelRed.rxns(21:22);
improvedVertical = analyzeGCdesign(modelRed, selectedRxns(1:2), target, twoDeletions, 2);
improvedHorizontal = analyzeGCdesign(modelRed, selectedRxns(1:2), target, twoDeletions', 2);
assert(isequal(improvedVertical, improvedHorizontal));

%% A lethal initial design starts from an objective of zero
% In the reduced model the glucose uptake is the irreversible reaction EX_glc(e)_r. Without it
% the maintenance flux of ATPM cannot be supplied, so the model is infeasible; the search then
% replaces the deletion by a viable one.
lethalDeletion = {'EX_glc(e)_r'};
solLethal = optimizeCbModel(changeRxnBounds(modelRed, lethalDeletion, 0, 'b'));
assert(solLethal.stat ~= 1);
improvedFromLethal = analyzeGCdesign(modelRed, selectedRxns, target, lethalDeletion);
solImproved = optimizeCbModel(changeRxnBounds(modelRed, improvedFromLethal, 0, 'b'));
assert(solImproved.stat == 1);

% output a success message
fprintf('Done.\n');

% change to old directory
cd(currentDir);
