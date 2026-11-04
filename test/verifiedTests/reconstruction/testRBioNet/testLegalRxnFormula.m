% The COBRAToolbox: testLegalRxnFormula.m
%
% Purpose:
%     - testReactionEq tests the functionality of LegalRxnFormula in the
%     rBioNet extension
%
% Function under test:
%     src/reconstruction/rBioNet/LegalRxnFormula.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - no solver; ecoli_core_model loaded through getDistributedModel. A message box is
%     opened and closed by the test.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: An empty formula is accepted when more than one formula is checked
%       SEVERITY: wrong-result
%       TRIGGER: LegalRxnFormula({''; 'a[c] -> b[c]'}, {'R1'; 'R2'})
%       OBSERVED: the flags of the empty formulas are a square matrix of size n by n, and the
%         check only reports when all its elements are true, which needs n = 1, so the result is
%         true and no message is shown
%       EXPECTED: false, with a message that names R1
%       LINES: 46, 53
%     - DEFECT: The message has a spelling error
%       SEVERITY: cosmetic
%       TRIGGER: any illegal formula
%       OBSERVED: the message says illeagal
%       EXPECTED: illegal
%       LINES: 69
%
% Authors:
%     - Stefania Magnusdottir April 2017
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testReactionEq'));
cd(fileDir);

% this test needs no solver, MATLAB toolbox or particular operating system
prepareTest();

% load E. coli model
model = getDistributedModel('ecoli_core_model.mat');

% check validity of reaction formulas
formula = printRxnFormula(model, model.rxns(1));
result = LegalRxnFormula(formula, model.rxns(1));

% test output
assert(result)

%% without abbreviations the formulas are checked in the same way

assert(LegalRxnFormula(formula));

%% a formula with an arrow only is illegal, and the message names the reaction

assert(~LegalRxnFormula({' <=> '; 'a[c] -> b[c]'}, {'R1'; 'R2'}));
assert(contains(closeMessageBoxes(), 'R1 is/are'));

assert(~LegalRxnFormula({'a[c] -> b[c]'; ' -> '}, {'R1'; 'R2'}));
assert(contains(closeMessageBoxes(), 'R2 is/are'));

%% all illegal reactions are named

assert(~LegalRxnFormula({' <=> '; 'a[c] -> b[c]'; '<=>'}, {'R1'; 'R2'; 'R3'}));
assert(contains(closeMessageBoxes(), 'R1, R3 is/are'));

%% a single empty formula is illegal

assert(~LegalRxnFormula({''}, {'R1'}));
assert(contains(closeMessageBoxes(), 'R1 is/are'));

% change the directory
cd(currentDir)

function boxText = closeMessageBoxes()
% Returns the text of the open message boxes and closes them, so that no window stays open.
boxes = findall(0, 'Type', 'figure', '-regexp', 'Tag', '^Msgbox_');
boxText = '';
for iBox = 1:numel(boxes)
    boxLines = cellstr(get(findall(boxes(iBox), 'Type', 'text'), 'String'));
    boxText = [boxText, ' ', strjoin(strtrim(boxLines), ' ')];
end
delete(boxes);
end
