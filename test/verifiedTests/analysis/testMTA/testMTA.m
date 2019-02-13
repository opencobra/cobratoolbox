% The COBRAToolbox: testMTA.m
%
% Purpose:
%     - Check the functions MTA and rMTA using different solvers
%
% Authors:
%     - Luis V. Valcarcel 2018-12-17
%

global CBTDIR

solversToUse = prepareTest('needsQP', true, 'useSolversIfAvailable', {'tomlab_cplex', 'ibm_cplex', 'gurobi'}, 'excludeSolvers', {'qpng'});
% Note: the solver QPNG cannot be used with this test

% save the current path
currentDir = pwd;

% initialize the test
testDir = fileparts(which('testMTA'));
cd(testDir);

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

% define the solver packages to be used to run this test
solverPkgs = solversToUse.QP;

% Test solving for different solvers
for k = 1:length(solverPkgs)
    fprintf(' -- Running testGeneMCS using the solver interface: %s ... ', solverPkgs{k});

    % Eliminate temp files if they exist
    if exist([currentDir filesep 'temp_MTA.mat'], 'file')
        delete temp_MTA.mat
    end
    if exist([currentDir filesep 'temp_rMTA.mat'], 'file')
        delete temp_rMTA.mat
    end

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
        
        % Calculate rMTA by certain reactions
        [TSscore,deletedGenes] = rMTA(model,rxnFBS,Vref, 0.4, 0.01, 'rxnKO',1, 'listKO',{'r2', 'r3', 'r6'}); 
        assert(TSscore.rTS(strcmp(deletedGenes,'r2'))<0)
        assert(TSscore.rTS(strcmp(deletedGenes,'r3'))>0)
        
        % Calculate rMTA by certain genes
        [TSscore,deletedGenes] = rMTA(model,rxnFBS,Vref, 0.4, 0.01, 'SeparateTranscript','.', 'listKO',{'g2', 'g4'});
        assert(TSscore.rTS(strcmp(deletedGenes,'g2'))<0)
        assert(TSscore.rTS(strcmp(deletedGenes,'g4'))>0)
        
        % Calculate old rMTA  and check solutions
        [TSscore,deletedGenes] = rMTA(model,rxnFBS,Vref, 0.4, 0.01, 'SeparateTranscript','.', 'deprecated_rTS',1);
        assert(TSscore.old_rTS(strcmp(deletedGenes,'g2'))<0)
        assert(TSscore.old_rTS(strcmp(deletedGenes,'g4'))>0)
    else
        warning('The test testMTA cannot run using the solver interface: %s. The solver interface is not installed or not configured properly.\n', solverPkgs{k});
    end

    % output a success message
    fprintf('Done.\n');
end

% Test additional auxiliary functions: calculateEPSILON
% 1- calculate samples using Elementary Flux modes
EFM = [1 0 1 1 0 1 1;
    1 0 0 0 1 1 1;
    1 1 0 0 0 0 1]';
assert(norm(model.S* EFM(:,1)) < 1e-3)
assert(norm(model.S* EFM(:,2)) < 1e-3)
assert(norm(model.S* EFM(:,3)) < 1e-3)
% 2- Calculate samples
rng(12345); % set seed for obtaining always the same solution
samples = rand(3,2000);
samples(:,3) = samples(:,3)/10;
samples = samples*20/max(sum(samples,1));
samples = EFM * samples;
% 3- calculate epsilon
epsilon = calculateEPSILON(samples, rxnFBS);
assert(norm(epsilon - [0 0.0754 0 0.0744 0 0 0]')<1e-4)
% 4- Check errors when missing argument
assert(verifyCobraFunctionError('calculateEPSILON', 'inputs', {samples}))
assert(verifyCobraFunctionError('calculateEPSILON', 'inputs', {samples, 'a'}))

% Test additional auxiliary functions: diffexprs2rxnFBS
% 1- Generate differential expression for this dataset
% Differential expression is Source vs Target
diff_exprs = struct();
diff_exprs.gene = {'g2', 'g4', 'g10'}';
diff_exprs.logFC = [-1 +1 -1]';
diff_exprs.pval = [1e-3 1e-4 1e-5]';
diff_exprs = struct2table(diff_exprs);
% 2- Calculate rxnFBS
rxnFBS_test = diffexprs2rxnFBS(model, diff_exprs, Vref, 'SeparateTranscript','.');
assert(norm(rxnFBS_test - rxnFBS)<1e-4)
% 4- Check errors when missing argument
assert(verifyCobraFunctionError('diffexprs2rxnFBS', 'inputs', {model}))
assert(verifyCobraFunctionError('diffexprs2rxnFBS', 'inputs', {model, diff_exprs}))
assert(verifyCobraFunctionError('diffexprs2rxnFBS', 'inputs', {model, diff_exprs, Vref}))

fprintf('Done.\n');

% remove the file created during the test
delete('0');

% Set seed to default value
rng('default')
% change the directory
cd(currentDir)
