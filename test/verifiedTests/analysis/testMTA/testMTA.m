% The COBRAToolbox: testMTA.m
%
% Purpose:
%     - Check the functions MTA and rMTA using different solvers
%
% Authors:
%     - Luis V. Valcarcel 2018-12-17
%

global CBTDIR
% prepareTest('needsMIQP', true, 'useSolversIfAvailable', {'tomlab_cplex', 'ibm_cplex', 'gurobi'});
prepareTest('needsQP', true, 'useSolversIfAvailable', {'tomlab_cplex', 'ibm_cplex', 'gurobi'});

% save the current path
currentDir = pwd;

% initialize the test
testDir = fileparts(which('testMTA'));
cd(testDir);

% define the solver packages to be used to run this test
solverPkgs = {'ibm_cplex', 'tomlab_cplex', 'gurobi'};

% Create Toy example model
ReactionFormulas = {' -> A', 'A -> B', 'A -> C', 'C -> D',...
    'A -> D', 'D -> B', 'B -> '};
ReactionNames = {'r1', 'r2', 'r3', 'r4', 'r5', 'r6', 'r7'};
grRuleList = {'g1.1 & g6.1', 'g2.1 | g2.2', '', 'g4.1', 'g5.1', 'g6.1', ''};
lowerbounds = [0, 0, 0, -20, 0, 0, 0];
upperbounds = [20, 20, 20, 20, 20, 20, 20];
model = createModel(ReactionNames, ReactionNames, ReactionFormulas,...
'lowerBoundList', lowerbounds, 'upperBoundList', upperbounds,...
'grRuleList', grRuleList);
model = changeObjective(model,'r7');

% Generate reference flux and rxnFBS
Vref = [10, 1, 8, 8, 1, 9, 10]';
rxnFBS = [0, 1, 0, -1, 0, 0, 0]';

% Check calculateGeneKOMatrix
geneKO = calculateGeneKOMatrix(model, '.', 0);
assert(all(ismember(geneKO.genes,{'g1','g2','g4','g5','g6'})));
assert(all(ismember(geneKO.rxns,model.rxns)));
assert(all(ismember(find(geneKO.matrix),[1 9 18 26 29 34])));

% Check errors when missing argument
assert(verifyCobraFunctionError('MTA', 'inputs', {model}))
assert(verifyCobraFunctionError('MTA', 'inputs', {model, rxnFBS}))
assert(verifyCobraFunctionError('MTA', 'inputs', {model, rxnFBS, Vref, 'a'}))
assert(verifyCobraFunctionError('MTA', 'inputs', {model, rxnFBS, Vref, 0.5, 'a'}))

% Check errors when missing argument
assert(verifyCobraFunctionError('rMTA', 'inputs', {model}))
assert(verifyCobraFunctionError('rMTA', 'inputs', {model, rxnFBS}))
assert(verifyCobraFunctionError('rMTA', 'inputs', {model, rxnFBS, Vref, 'a'}))
assert(verifyCobraFunctionError('rMTA', 'inputs', {model, rxnFBS, Vref, 0.5, 'a'}))


% Test solving for different solvers
for k = 1:length(solverPkgs)
    fprintf(' -- Running testGeneMCS using the solver interface: %s ... ', solverPkgs{k});

    solverOK = changeCobraSolver(solverPkgs{k}, 'all', 0);

    if solverOK || strcmp(solverPkgs{k},'ibm_cplex')
        % Calculate MTA and check solutions
        [TSscore,deletedGenes] = MTA(model,rxnFBS,Vref, 0.66, 0.01, 'SeparateTranscript','.');
        assert(TSscore(strcmp(deletedGenes,'g2'))<0)
        assert(TSscore(strcmp(deletedGenes,'g4'))>0)
        
        % Calculate rMTA  and check solutions
        [TSscore,deletedGenes] = rMTA(model,rxnFBS,Vref, 0.4, 0.01, 'SeparateTranscript','.');
        assert(TSscore.rTS(strcmp(deletedGenes,'g2'))<0)
        assert(TSscore.rTS(strcmp(deletedGenes,'g4'))>0)
    else
        warning('The test testMTA cannot run using the solver interface: %s. The solver interface is not installed or not configured properly.\n', solverPkgs{k});
    end

    % output a success message
    fprintf('Done.\n');
end

% change the directory
cd(currentDir)
