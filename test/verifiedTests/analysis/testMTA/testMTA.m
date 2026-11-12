% The COBRAToolbox: testMTA.m
%
% Purpose:
%     - Check the functions MTA and rMTA using different solvers
%
% Function under test:
%     src/analysis/rMTA/MTA.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - optimisation (MIQP) on a toy model.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Luis V. Valcarcel 2018-12-17
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%

global CBTDIR

solversToUse = prepareTest('needsMIQP',true, 'needsQP', true, 'useSolversIfAvailable', {'tomlab_cplex', 'ibm_cplex', 'gurobi'}, 'excludeSolvers', {'qpng'});
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
solverPkgs = solversToUse.MIQP;

% Test solving for different solvers
for k = 1:length(solverPkgs)
    fprintf(' -- Running testMTA using the solver interface: %s ... ', solverPkgs{k});

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
        fullScore = TSscore;
        fullGenes = deletedGenes;

        % Calculate MTA by reaction knock-outs: one score per reaction, the same signs as the genes
        [TSscoreRxn,deletedRxns] = MTA(model,rxnFBS,Vref, 0.66, 0.01, 'rxnKO',1, 'printLevel',0);
        assert(isequal(deletedRxns, model.rxns));
        assert(TSscoreRxn(strcmp(deletedRxns,'r2'))<0)
        assert(TSscoreRxn(strcmp(deletedRxns,'r4'))>0)

        % a list of reactions: repeated names count once, the scores are those of the full run
        [TSscoreList,deletedList] = MTA(model,rxnFBS,Vref, 0.66, 0.01, 'rxnKO',1, 'listKO',{'r4','r2','r2'}, 'printLevel',0);
        assert(isequal(deletedList, {'r2';'r4'}));
        assert(norm(TSscoreList - TSscoreRxn(ismember(model.rxns,{'r2','r4'}))) < 1e-4);

        % a list of genes without transcript separator: the names of model.genes
        [TSscoreList,deletedList] = MTA(model,rxnFBS,Vref, 0.66, 0.01, 'listKO',{'g4.1','g2.1','g4.1'}, 'printLevel',0);
        assert(isequal(deletedList, {'g2.1';'g4.1'}));
        assert(TSscoreList(strcmp(deletedList,'g4.1'))>0)

        % a list of transcripts with a separator: reduced to the gene, as in the full run
        [TSscoreList,deletedList] = MTA(model,rxnFBS,Vref, 0.66, 0.01, 'SeparateTranscript','.', 'listKO',{'g2.1','g2.2','g4.1'}, 'printLevel',0);
        assert(isequal(deletedList, {'g2';'g4'}));
        assert(norm(TSscoreList - fullScore(ismember(fullGenes,{'g2','g4'}))) < 1e-4);

        % names that are not in the model are refused
        assert(verifyCobraFunctionError('MTA', 'inputs', {model,rxnFBS,Vref, 0.66, 0.01, 'rxnKO',1, 'listKO',{'rX'}}, ...
                                        'testMessage', 'Reactions in listKO are not in the model'));
        assert(verifyCobraFunctionError('MTA', 'inputs', {model,rxnFBS,Vref, 0.66, 0.01, 'listKO',{'gX'}}, ...
                                        'testMessage', 'Genes in listKO are not in the model'));
        assert(verifyCobraFunctionError('MTA', 'inputs', {model,rxnFBS,Vref, 0.66, 0.01, 'SeparateTranscript','.', 'listKO',{'gX.1'}}, ...
                                        'testMessage', 'Genes in listKO are not in the model'));

        % a temporary file left by an interrupted run is picked up: the current alpha is repeated,
        % the wrong scores stored in the file are overwritten and the file is removed at the end
        i = 2; %#ok<NASGU> counters of the interrupted run, as saved by MTA
        i_alpha = 1; %#ok<NASGU>
        TSscore = -5 * ones(numel(fullGenes), 1); %#ok<NASGU>
        Vres = {zeros(numel(model.rxns), numel(fullGenes))}; %#ok<NASGU>
        save('temp_MTA.mat', 'i', 'i_alpha', 'TSscore', 'Vres');
        [TSscore,deletedGenes] = MTA(model,rxnFBS,Vref, 0.66, 0.01, 'SeparateTranscript','.', 'printLevel',0);
        assert(isequal(deletedGenes, fullGenes));
        assert(norm(TSscore(isfinite(TSscore)) - fullScore(isfinite(fullScore))) < 1e-4);
        assert(isequal(isfinite(TSscore), isfinite(fullScore)));
        assert(~isfile('temp_MTA.mat'));

        % Calculate rMTA  and check solutions
        [TSscore,deletedGenes] = rMTA(model,rxnFBS,Vref, 0.4, 0.01, 'SeparateTranscript','.');
        if 0
            %TODO
            %this test does not pass, though it did originally, contacted
            %F. Planes to debug
            assert(TSscore.rTS(strcmp(deletedGenes,'g2'))<0)
        end
        assert(TSscore.rTS(strcmp(deletedGenes,'g4'))>0)
        
        % Calculate rMTA by certain reactions
        [TSscore,deletedGenes] = rMTA(model,rxnFBS,Vref, 0.4, 0.01, 'rxnKO',1, 'listKO',{'r2', 'r3', 'r6'}); 
        if 0
            assert(TSscore.rTS(strcmp(deletedGenes,'r2'))<0)
        end
        assert(TSscore.rTS(strcmp(deletedGenes,'r3'))>0)
        
        % Calculate rMTA by certain genes
        [TSscore,deletedGenes] = rMTA(model,rxnFBS,Vref, 0.4, 0.01, 'SeparateTranscript','.', 'listKO',{'g2', 'g4'});
        if 0
            assert(TSscore.rTS(strcmp(deletedGenes,'g2'))<0)
        end
        assert(TSscore.rTS(strcmp(deletedGenes,'g4'))>0)
        
        % Calculate old rMTA  and check solutions
        [TSscore,deletedGenes] = rMTA(model,rxnFBS,Vref, 0.4, 0.01, 'SeparateTranscript','.', 'deprecated_rTS',1);
        if 0
            assert(TSscore.old_rTS(strcmp(deletedGenes,'g2'))<0)
        end
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
assert(norm(epsilon - [0 0.0754 0 0.0744 0 0 0]')<1e-2)
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
fileToRemove = '0';
if isfile(fileToRemove)
    delete(fileToRemove);
end

% Set seed to default value
rng('default')
% change the directory
cd(currentDir)
