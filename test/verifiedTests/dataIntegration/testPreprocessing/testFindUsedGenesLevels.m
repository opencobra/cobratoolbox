% The COBRAToolbox: testFindUsedGenesLevels.m
%
% Purpose:
%     - findUsedGenesLevels looks up, for every gene of a model, its expression level (and
%     significance) in an expression data set, using NaN for genes without data and the mean for
%     genes with several entries.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/dataIntegration/transcriptomics/preprocessing/findUsedGenesLevels.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindUsedGenesLevels'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

model.genes = {'g1'; 'g2'; 'g3'};

%% values of the genes present in the data

exprData.gene = {'g1'; 'g3'};
exprData.value = [5; 7];
[geneId, geneExpr, geneSig] = findUsedGenesLevels(model, exprData);
assert(isequal(geneId, model.genes));
% g2 has no data
assert(isequaln(geneExpr, [5 NaN 7]));
assert(isempty(geneSig));

%% significance values

exprData.gene = {'g1'; 'g3'};
exprData.value = [5; 7];
exprData.sig = [0.01; 0.2];
[~, geneExpr, geneSig] = findUsedGenesLevels(model, exprData);
assert(isequaln(geneExpr, [5 NaN 7]));
% g2 has no significance entry, so the vector stops at g3's position
assert(geneSig(1) == 0.01 && geneSig(3) == 0.2);

%% genes with several entries use the mean, and a message at print level 1

dup.gene = {'g1'; 'g1'; 'g2'};
dup.value = [2; 4; 9];
dup.sig = [0.1; 0.3; 0.5];
text = evalc('[~, geneExpr, geneSig] = findUsedGenesLevels(model, dup, 1);');
assert(isequaln(geneExpr, [3 9 NaN]));
assert(abs(geneSig(1) - 0.2) < 1e-12 && geneSig(2) == 0.5);
assert(contains(text, 'Double for g1'));
% no message without print level
text = evalc('findUsedGenesLevels(model, dup);');
assert(isempty(text));

% change the directory
cd(currentDir)
