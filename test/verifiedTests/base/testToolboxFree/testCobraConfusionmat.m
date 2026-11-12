% The COBRAToolbox: testCobraConfusionmat.m
%
% Purpose:
%     - cobraConfusionmat is the plain-MATLAB replacement for confusionmat (Statistics and
%       Machine Learning Toolbox). This test checks the MathWorks documentation example (with
%       NaN, default order and 'Order', [4 3 2 1]), the numeric call of
%       modelPredictiveCapacity ('ORDER', [1 0 -1]), the text call of plotThermoKernelStats
%       ('order', labels, '' as missing) against scikit-learn, logical, string and categorical
%       input, first-appearance order for text, the errors for unsupported options and invalid
%       input, and (only where the toolbox is installed) parity with confusionmat.
%
% Function under test:
%     src/base/utilities/toolboxFree/cobraConfusionmat.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261111-152503-toolbox-free-remaining, 2026-11-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCobraConfusionmat'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% counts are integers, so every comparison below is exact

%% MathWorks documentation example (NaN is missing)

g1 = [3 2 2 3 1 1]';
g2 = [4 2 3 NaN 1 1]';
[C, order] = cobraConfusionmat(g1, g2);
assert(isequal(C, [2 0 0 0; 0 1 1 0; 0 0 0 1; 0 0 0 0]) && isequal(order, (1:4)') && isa(C, 'double'));
[C, order] = cobraConfusionmat(g1, g2, 'Order', [4 3 2 1]);
assert(isequal(C, [0 0 0 0; 1 0 0 0; 0 1 1 0; 0 0 0 2]) && isequal(order, [4; 3; 2; 1]));

%% modelPredictiveCapacity: numeric targets and predictions, 'ORDER', [1, 0, -1]

% references/g1_stats.py (section confusionmat), scikit-learn 1.9.1 confusion_matrix after
% dropping missing pairs: [2 0 1; 0 2 0; 1 0 1]
target = [1 0 -1 1 1 0 -1 NaN 0]';
prediction = [1 0 1 -1 1 NaN -1 1 0]';
C = cobraConfusionmat(target, prediction, 'ORDER', [1, 0, -1]);
assert(isequal(C, [2 0 1; 0 2 0; 1 0 1]));
% an order value that never occurs gives a zero row and column (quanQualAcc lists 2)
C = cobraConfusionmat(target, prediction, 'ORDER', [2, 1, 0, -1]);
assert(isequal(C, [0 0 0 0; 0 2 0 1; 0 0 2 0; 0 1 0 1]));

%% plotThermoKernelStats: cell arrays of text, 'order', labels, '' is missing

% scikit-learn 1.9.1: [2 0; 2 1]
P = {'Active'; 'Inactive'; 'Active'; 'Active'; 'Inactive'; 'Inactive'};
T = {'Active'; 'Active'; ''; 'Active'; 'Inactive'; 'Active'};
labels = {'Active'; 'Inactive'};
[C, order] = cobraConfusionmat(P, T, 'order', labels);
assert(isequal(C, [2 0; 2 1]) && isequal(order, labels));
% default order for text is first appearance in [group; grouphat]
[C, order] = cobraConfusionmat({'b'; 'a'; 'b'}, {'b'; 'c'; 'a'});
% pairs (b, b), (a, c), (b, a) in the order b, a, c
assert(isequal(order, {'b'; 'a'; 'c'}) && isequal(C, [1 1 0; 0 0 1; 0 0 0]));
% string arrays with <missing>, and an 'Order' given as strings
[C, order] = cobraConfusionmat(["x"; "y"; missing; "x"], ["x"; "x"; "y"; "y"], 'Order', ["y"; "x"]);
assert(isequal(C, [0 1; 1 1]) && isequal(order, {'y'; 'x'}));

%% logical and categorical input

[C, order] = cobraConfusionmat(logical([1 0 1 1]), logical([1 1 0 1]));
assert(isequal(C, [0 1; 1 2]) && isequal(order, [false; true]) && islogical(order));
cats = categorical({'lo'; 'hi'; 'hi'; 'lo'}, {'lo', 'mid', 'hi'});
catsHat = categorical({'lo'; 'lo'; 'hi'; '<undefined>'}, {'lo', 'mid', 'hi'});
[C, order] = cobraConfusionmat(cats, catsHat);
% category order (lo, hi; the unused mid is left out), the undefined prediction is missing
assert(isequal(C, [1 0; 1 1]) && isequal(order, categorical({'lo'; 'hi'}, {'lo', 'mid', 'hi'})));

%% errors: unsupported option, incomplete 'Order', mismatched inputs, wrong 'Order' type

assert(verifyCobraFunctionError('cobraConfusionmat', 'inputs', {g1, g2, 'Labels', [1 2 3 4]}, ...
    'testMessage', 'cobraConfusionmat: unsupported option ''Labels'' (only ''Order'' is supported).'));
assert(verifyCobraFunctionError('cobraConfusionmat', 'inputs', {g1, g2, 3, [1 2 3 4]}, ...
    'testMessage', 'cobraConfusionmat: unsupported option ''double'' (only ''Order'' is supported).'));
assert(verifyCobraFunctionError('cobraConfusionmat', 'inputs', {g1, g2, 'Order', [1 2 3]}, ...
    'testMessage', 'cobraConfusionmat: ''Order'' does not list the group ''4''.'));
assert(verifyCobraFunctionError('cobraConfusionmat', 'inputs', {P, T, 'order', {'Active'}}, ...
    'testMessage', 'cobraConfusionmat: ''Order'' does not list the group ''Inactive''.'));
assert(verifyCobraFunctionError('cobraConfusionmat', 'inputs', {g1, g2(1:5)}, ...
    'testMessage', 'cobraConfusionmat: group and grouphat must have the same type and length.'));
assert(verifyCobraFunctionError('cobraConfusionmat', 'inputs', {P, string(T)}, ...
    'testMessage', 'cobraConfusionmat: group and grouphat must have the same type and length.'));
assert(verifyCobraFunctionError('cobraConfusionmat', 'inputs', {g1, g2, 'Order', {'1'; '2'; '3'; '4'}}, ...
    'testMessage', 'cobraConfusionmat: ''Order'' must have the same type as group.'));

%% parity with confusionmat (only where the Statistics and Machine Learning Toolbox is installed)

if exist('confusionmat', 'file') == 2 && license('test', 'Statistics_Toolbox')
    [C, order] = cobraConfusionmat(g1, g2);
    [CToolbox, orderToolbox] = confusionmat(g1, g2);
    assert(isequal(C, CToolbox) && isequal(order, orderToolbox));
    assert(isequal(cobraConfusionmat(target, prediction, 'ORDER', [1, 0, -1]), confusionmat(target, prediction, 'ORDER', [1, 0, -1])));
    assert(isequal(cobraConfusionmat(P, T, 'order', labels), confusionmat(P, T, 'order', labels)));
    fprintf('parity with confusionmat: passed\n');
else
    fprintf('skipped: Statistics and Machine Learning Toolbox not installed\n');
end

% change the directory
cd(currentDir)
