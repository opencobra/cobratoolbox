% The COBRAToolbox: testPreprocessing.m
%
% Purpose:
%     - tests the preprocessing transcriptomic data
%
% Authors:
%     - Original file: Thomas Pfau - Sept 2017
%
% Note:
%     - The solver libraries must be included separately

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPreprocessing.m'));
cd(fileDir);

% load the model
model = createToyModelForPreProcessing();

% load the gene Information.
load ExpressionData

%The initial expression data has a max for G2 of 6 ; G3 of 5 and G6/G7 of
%5, so the resulting vector would be 6 5 5 -1 -1
[expressionRxns, parsedGpR] = mapExpressionToReactions(model,expression1);
assert(isequal(expressionRxns,[6; 5; 5; -1; -1]));

%The second expression vector leads to A gene expression of 
%R1: min((10+10+6)/3,(10+5)/2)
%R2: min(8, max(10,5));
%R3: max(5,9)
% And -1 for the exchangers.
[expressionRxns, parsedGpR] = mapExpressionToReactions(model,expression2);
assert(isequal(expressionRxns,[min(26/3,15/2); min(8, max(10,5)); max(5,9); -1; -1]));

fprintf('Done...\n')

%Switch back to original folder
cd(currentDir)