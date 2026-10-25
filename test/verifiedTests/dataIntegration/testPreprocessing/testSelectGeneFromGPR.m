% The COBRAToolbox: testSelectGeneFromGPR.m
%
% Purpose:
%     - selectGeneFromGPR derives a reaction expression from gene expression and parsed gene rules:
%     the minimum over the genes of each and-set and the maximum over the alternatives (or the sum
%     and minimum when minSum is set), recording the gene used and its significance.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/dataIntegration/transcriptomics/preprocessing/selectGeneFromGPR.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: With minSum the reported gene does not belong to the selected alternative
%       SEVERITY: wrong-result
%       TRIGGER: minSum set and a rule with an alternative that has more than one gene before the
%         selected alternative, for example (g1 and g2) or g3 with g3 selected
%       OBSERVED: the list of candidate genes has one entry per gene while the list of values has
%         one entry per alternative, so the position of the minimum points into the wrong list entry
%         (here g2 is reported instead of g3)
%       EXPECTED: the gene of the selected alternative
%       LINES: 44-49
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSelectGeneFromGPR'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

model.rxns = {'r1'; 'r2'; 'r3'};
% parsed rules: r1 = (g1 and g2) or g3; r2 = g2; r3 has no rule
parsedGPR = {{{'g1'; 'g2'}, {'g3'}}; {{'g2'}}; {{''}}};
geneNames = {'g1'; 'g2'; 'g3'};
geneExpr = [4; 2; 3];
geneSig = [0.1; 0.2; 0.3];

%% minimum within an and-set, maximum over the alternatives

[expressionCol, geneUsed, signifCol] = selectGeneFromGPR(model, geneNames, geneExpr, parsedGPR);
% r1: and-set (g1, g2) gives min(4, 2) = 2 by g2; the alternative g3 gives 3; the maximum is 3 by g3
assert(isequaln(expressionCol, [3; 2; NaN]));
assert(isequal(geneUsed{1}, {'g3'}) && isequal(geneUsed{2}, {'g2'}) && isempty(geneUsed{3}));
assert(isequal(signifCol, [0; 0; 0]));

%% significance of the selected gene

[~, ~, signifCol] = selectGeneFromGPR(model, geneNames, geneExpr, parsedGPR, false, geneSig);
assert(isequal(signifCol, [0.3; 0.2; 0]));

%% sum within the sets and minimum over the alternatives

[expressionCol, geneUsed, signifCol] = selectGeneFromGPR(model, geneNames, geneExpr, parsedGPR, true, geneSig);
% r1: and-set sum 4 + 2 = 6, alternative g3 gives 3; the minimum is 3
assert(isequaln(expressionCol, [3; 2; NaN]));
% the gene recorded for r1 is not asserted (see the known defect in the header)
assert(abs(signifCol(1) - 0.3) < 1e-12);

%% genes without data

[expressionCol, ~, ~] = selectGeneFromGPR(model, {'x'}, 1, parsedGPR);
assert(all(isnan(expressionCol)));

%% missing values are ignored

withNaN = [NaN; 2; 3];
[expressionCol, ~, ~] = selectGeneFromGPR(model, geneNames, withNaN, parsedGPR);
% r1: and-set (g1 = NaN, g2 = 2) gives 2; alternative g3 gives 3; maximum 3
assert(isequaln(expressionCol, [3; 2; NaN]));

% change the directory
cd(currentDir)
