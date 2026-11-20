% The COBRAToolbox: testDiffexprs2rxnFBS.m
%
% Purpose:
%     - diffexprs2rxnFBS turns a table of differentially expressed genes (gene, logFC, pval)
%       into the reaction direction changes (+1 forward, -1 backward, 0 unchanged) that rMTA
%       uses: genes pass the logFC and pval thresholds, their sign is flipped (target versus
%       source), mapped onto reactions through the GPR rules (AND = min, OR = max), and the
%       sign is flipped again for reactions whose reference flux is negative. This test uses
%       the toy model of testMTA (seven reactions, transcript-level genes g1.1, g2.1, g2.2,
%       ...) and checks hand-derived results for transcripts joined by SeparateTranscript,
%       for gene-level identifiers with thresholds and a negative reference flux, and the
%       errors for genes absent from the model and for an invalid option.
%
% Function under test:
%     src/analysis/rMTA/diffexprs2rxnFBS.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a hand-built model with GPR rules (createModel), no solver.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testDiffexprs2rxnFBS'));
cd(fileDir);

% declare the requirements of this test: a Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system
prepareTest();

%% toy model with transcript-level genes (g2.1 and g2.2 are transcripts of g2)

reactionFormulas = {' -> A', 'A -> B', 'A -> C', 'C -> D', 'A -> D', 'D -> B', 'B -> '};
reactionNames = {'r1', 'r2', 'r3', 'r4', 'r5', 'r6', 'r7'};
grRules = {'g1.1 & g6.1', 'g2.1 | g2.2', '', 'g4.1', 'g5.1', 'g6.1', ''};
model = createModel(reactionNames, reactionNames, reactionFormulas, ...
    'lowerBoundList', [0 0 0 -20 0 0 0], 'upperBoundList', 20 * ones(1, 7), ...
    'grRuleList', grRules, 'printLevel', 0);
assert(isequal(sort(model.genes), sort({'g1.1'; 'g2.1'; 'g2.2'; 'g4.1'; 'g5.1'; 'g6.1'})));
assert(size(model.rxnGeneMat, 1) == numel(model.rxns) && size(model.rxnGeneMat, 2) == numel(model.genes));

%% gene identifiers joined to the transcripts of the model through SeparateTranscript

% g2 is down in the source (logFC -1): both transcripts become +1 after the sign flip, so r2
% (g2.1 | g2.2) is +1; g4 is up (logFC +1): g4.1 becomes -1, so r4 is -1; g10 is not in the
% model and is dropped; the default thresholds keep all three (|logFC| > 0, pval <= 0.05)
diffExprs = struct2table(struct('gene', {{'g2'; 'g4'; 'g10'}}, 'logFC', [-1; 1; -1], ...
    'pval', [1e-3; 1e-4; 1e-5]));
Vref = [10; 1; 8; 8; 1; 9; 10];
rxnFBS = diffexprs2rxnFBS(model, diffExprs, Vref, 'SeparateTranscript', '.');
assert(isequal(rxnFBS, [0; 1; 0; -1; 0; 0; 0]));

%% gene-level identifiers, thresholds and a negative reference flux

% g5.1 fails the pval threshold (0.2 > 0.05); g1.1, g6.1 and g2.1 are up (logFC 2, 2, 3 > 1)
% and become -1, so r1 (g1.1 & g6.1, min) and r6 (g6.1) are -1 and r2 (g2.1 | g2.2, max) is
% -1 before the reference flux of r2 (-1 < 0) flips it to +1; r4 and r5 have no change
diffExprs = struct2table(struct('gene', {{'g1.1'; 'g6.1'; 'g5.1'; 'g2.1'}}, ...
    'logFC', [2; 2; 1.5; 3], 'pval', [0.01; 0.01; 0.2; 0.01]));
Vref = [10; -1; 8; 8; 1; 9; 10];
rxnFBS = diffexprs2rxnFBS(model, diffExprs, Vref, 'logFC', 1, 'pval', 0.05);
assert(isequal(rxnFBS, [-1; 1; 0; 0; 0; -1; 0]));

%% errors: no gene of the table is in the model; an option value that is not a scalar

diffExprsUnknown = struct2table(struct('gene', {{'zz'}}, 'logFC', 2, 'pval', 0.01));
assert(verifyCobraFunctionError('diffexprs2rxnFBS', 'inputs', {model, diffExprsUnknown, Vref}, ...
    'testMessage', 'Gene ID are not in the model. Revise gene ID in input table or SeparateTranscript option parameter'));
assert(verifyCobraFunctionError('diffexprs2rxnFBS', 'inputs', {model, diffExprs, Vref, 'logFC', [1 2]}));

% change the directory
cd(currentDir)
