% The COBRAToolbox: testCobraGrp2idx.m
%
% Purpose:
%     - cobraGrp2idx is the plain-MATLAB replacement for grp2idx (Statistics and Machine
%       Learning Toolbox). This test checks every syntax used by the call sites in src/
%       (g = grp2idx(categorical(...)) - 1 to code a binary response as 0/1), the rules of
%       mathworks-semantics.md section 7 (sorted order for numeric and logical input,
%       categories order for categorical input, first appearance for char, cellstr and string
%       input; missing values give NaN in g and no group; g is a column; gN is a cellstr; gL
%       has the type of the input, cellstr for string input), the errors for unsupported
%       input, and parity with grp2idx when the toolbox is installed.
%     - Reference values: hand computation of the documented rules in
%       specs/20261103-120403-toolbox-free-replacements/references/tables.py (Python 3,
%       SciPy 1.16.0 environment; no SciPy equivalent exists) and the documentation example
%       https://www.mathworks.com/help/stats/grp2idx.html (gN(g) and gL(g) reproduce s).
%       Indices, names and orders are compared exactly.
%
% Function under test:
%     src/base/utilities/toolboxFree/cobraGrp2idx.m
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
%     - Generated for feature 20261103-120403-toolbox-free-replacements, 2026-11-03.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCobraGrp2idx'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% call sites performRegressions and runNonparametricTests: a binary response coded 0/1

response = categorical({'healthy'; 'disease'; 'healthy'; 'disease'; 'disease'});
coded = cobraGrp2idx(response) - 1;
% categories are sorted alphabetically by categorical(), so disease = 0 and healthy = 1
assert(isequal(coded, [1; 0; 1; 0; 0]));

%% categorical: the order of categories(s), every category is a group, <undefined> is NaN

s = categorical({'30s', '40s', '30s', '', '40s'}, {'40s', '30s', '20s'});
[g, gN, gL] = cobraGrp2idx(s);
assert(iscolumn(g) && isequaln(g, [2; 1; 2; NaN; 1]));
assert(isequal(gN, {'40s'; '30s'; '20s'}));
assert(iscategorical(gL) && iscolumn(gL) && isequal(cellstr(gL), gN));
assert(isequal(categories(gL), categories(s)));
% as in the documentation example, gN(g) and gL(g) reproduce s where s is defined
defined = ~isnan(g);
assert(isequal(gN(g(defined)), cellstr(s(defined))'));
assert(all(gL(g(defined)) == s(defined)'));
% an ordinal categorical keeps its ordinal levels
[~, ~, gLOrdinal] = cobraGrp2idx(categorical({'low', 'high'}, {'low', 'high'}, 'Ordinal', true));
assert(isordinal(gLOrdinal));

%% numeric: sorted levels, NaN is missing, names from num2str

[g, gN, gL] = cobraGrp2idx([3 1 NaN 3 2]);
% tables.py: g = [3 1 NaN 3 2], levels [1 2 3]
assert(iscolumn(g) && isequaln(g, [3; 1; NaN; 3; 2]));
assert(isequal(gN, {'1'; '2'; '3'}) && isequal(gL, [1; 2; 3]));
% non-integer levels and the class of the input are kept in gL
[g, gN, gL] = cobraGrp2idx(single([0.5 -2 0.5]));
assert(isequal(g, [2; 1; 2]) && isequal(gN, {'-2'; '0.5'}) && isa(gL, 'single'));
% names are num2str of the whole column of levels, trimmed (R14 rule): one format for all
% levels, whose number of significant digits grows with the largest magnitude
[~, gN] = cobraGrp2idx([2.5 -1 0 10 0.123456]);
assert(isequal(gN, {'-1'; '0'; '0.123456'; '2.5'; '10'}));
[~, gN] = cobraGrp2idx([0.123456 -2]);
assert(isequal(gN, {'-2'; '0.12346'}));
[~, gN] = cobraGrp2idx(int8([10 1 -7]));
assert(isequal(gN, {'-7'; '1'; '10'}));

%% logical: sorted (false first), names '0' and '1', gL logical

[g, gN, gL] = cobraGrp2idx([true false true]);
assert(isequal(g, [2; 1; 2]) && isequal(gN, {'0'; '1'}));
assert(islogical(gL) && isequal(gL, [false; true]));

%% cell array of character vectors: first appearance, '' is missing

[g, gN, gL] = cobraGrp2idx({'b', 'a', '', 'b', 'c'});
% tables.py: g = [1 2 NaN 1 3], levels ['b', 'a', 'c']
assert(isequaln(g, [1; 2; NaN; 1; 3]));
assert(isequal(gN, {'b'; 'a'; 'c'}) && isequal(gL, gN));
% the text 'NaN' is an ordinary group name
assert(isequal(cobraGrp2idx({'NaN', 'x'}), [1; 2]));

%% string array: first appearance, <missing> and "" are missing, gL is a cellstr

[g, gN, gL] = cobraGrp2idx(["b"; missing; "a"; ""; "b"]);
assert(isequaln(g, [1; NaN; 2; NaN; 1]));
assert(isequal(gN, {'b'; 'a'}) && iscellstr(gL) && isequal(gL, gN));

%% char matrix: one group per row, a blank row is missing, gL is a char matrix

[g, gN, gL] = cobraGrp2idx(['b '; 'a '; '  '; 'b ']);
assert(isequaln(g, [1; 2; NaN; 1]));
assert(isequal(gN, {'b'; 'a'}) && ischar(gL) && isequal(gL, ['b'; 'a']));
% gL(g, :) reproduces the non-missing rows
assert(isequal(gL(g([1 2 4]), :), ['b'; 'a'; 'b']));

%% empty input gives empty outputs

[g, gN, gL] = cobraGrp2idx([]);
assert(isempty(g) && isempty(gN) && iscell(gN) && isempty(gL));

%% unsupported input raises an error

assert(verifyCobraFunctionError('cobraGrp2idx', 'inputs', {datetime(2026, 11, 3)}, ...
    'testMessage', 'cobraGrp2idx: grouping variables of class datetime are not supported.'));
assert(verifyCobraFunctionError('cobraGrp2idx', 'inputs', {[1 2; 3 4]}, ...
    'testMessage', 'cobraGrp2idx: the grouping variable must be a vector.'));

%% parity with grp2idx when the Statistics and Machine Learning Toolbox is installed

if exist('grp2idx', 'file') && license('test', 'Statistics_Toolbox')
    inputs = {[3 1 NaN 3 2], [true false true], {'b', 'a', '', 'b', 'c'}, ...
        ["b"; missing; "a"; ""; "b"], categorical({'x', 'y', 'x'})};
    for i = 1:numel(inputs)
        [g, gN] = cobraGrp2idx(inputs{i});
        [expectedG, expectedGN] = grp2idx(inputs{i});
        assert(isequaln(g, expectedG(:)) && isequal(gN, expectedGN));
    end
else
    fprintf('skipped: Statistics and Machine Learning Toolbox not installed\n');
end

% change the directory
cd(currentDir)
