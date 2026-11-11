% The COBRAToolbox: testCobraBuildModelDesign.m
%
% Purpose:
%     - cobraBuildModelDesign builds the design matrix of cobraFitglm and cobraFitlm. This test
%       checks continuous and categorical predictors (cell, string, categorical, logical, char),
%       reference coding with the first level (first appearance for text, category order for
%       categorical), the coefficient names, interactions (continuous by categorical and
%       categorical by categorical), missing values in every type, a single-level factor,
%       coding new data with the levels of a fitted design (prediction), and the errors for
%       invalid input.
%
% Function under test:
%     src/base/utilities/toolboxFree/cobraBuildModelDesign.m
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
fileDir = fileparts(which('testCobraBuildModelDesign'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

buildDesign = @(tbl, formula) cobraBuildModelDesign(tbl, cobraParseModelFormula(formula, tbl.Properties.VariableNames));

%% continuous and text predictors: reference = first appearance

tbl = table([1; 2; 3; 4], {'m'; 'f'; 'm'; 'f'}, [2; 4; 6; 9], 'VariableNames', {'x', 'g', 'y'});
design = buildDesign(tbl, 'y ~ x + g');
assert(isequal(design.coefficientNames, {'(Intercept)', 'x', 'g_f'}));
assert(isequal(design.X, [1 1 0; 1 2 1; 1 3 0; 1 4 1]) && isequal(design.y, [2; 4; 6; 9]));
assert(~any(design.isMissing) && isequal(design.variableInfo(2).levels, {'m', 'f'}) && design.variableInfo(2).isCategorical);

%% categorical (category order), string, logical and char predictors

categoricalGroup = categorical({'b'; 'a'; 'b'; 'a'}, {'a', 'b'});
tbl = table(categoricalGroup, ["u"; "v"; "u"; "w"], logical([1; 0; 0; 1]), ['p'; 'q'; 'p'; 'q'], [1; 2; 3; 4], ...
    'VariableNames', {'c', 's', 'l', 'h', 'y'});
design = buildDesign(tbl, 'y ~ c + s + l + h');
assert(isequal(design.coefficientNames, {'(Intercept)', 'c_b', 's_v', 's_w', 'l_1', 'h_q'}));
assert(isequal(design.X(:, 2)', [1 0 1 0]) && isequal(design.X(:, 5)', [1 0 0 1]) && isequal(design.X(:, 6)', [0 1 0 1]));

%% unused categories of a categorical predictor give no column (no rank deficiency)

tbl = table(categorical({'lo'; 'hi'; 'lo'; 'hi'}, {'lo', 'mid', 'hi'}), [1; 3; 2; 5], 'VariableNames', {'c', 'y'});
design = buildDesign(tbl, 'y ~ c');
assert(isequal(design.coefficientNames, {'(Intercept)', 'c_hi'}) && isequal(design.variableInfo(1).levels, {'lo', 'hi'}));
lastwarn('');
cobraFitglm(tbl, 'y ~ c');
[warningMessage, ~] = lastwarn;
assert(isempty(warningMessage));

%% interactions: continuous by categorical, categorical by categorical (first factor fastest)

tbl = table([1; 2; 3; 4; 5; 6], {'a'; 'b'; 'c'; 'a'; 'b'; 'c'}, {'u'; 'u'; 'v'; 'v'; 'w'; 'w'}, (1:6)', ...
    'VariableNames', {'x', 'g', 'k', 'y'});
design = buildDesign(tbl, 'y ~ x:g + g:k');
assert(isequal(design.coefficientNames, {'(Intercept)', 'x:g_b', 'x:g_c', 'g_b:k_v', 'g_c:k_v', 'g_b:k_w', 'g_c:k_w'}));
assert(isequal(design.X(:, 2)', [0 2 0 0 5 0]) && isequal(design.X(:, 5)', [0 0 1 0 0 0]));

%% missing values exclude the row (NaN, '', <missing>, <undefined>, NaN response)

tbl = table([1; NaN; 3; 4; 5; 6], {'a'; 'b'; ''; 'a'; 'b'; 'a'}, ["u"; "v"; "u"; missing; "v"; "u"], ...
    categorical({'p'; 'q'; 'p'; 'q'; ''; 'p'}), [1; 2; 3; 4; 5; NaN], ...
    'VariableNames', {'x', 'g', 's', 'c', 'y'});
design = buildDesign(tbl, 'y ~ x + g + s + c');
assert(isequal(design.isMissing', [false true true true true true]));
assert(all(isnan(design.X(design.isMissing, :)), 'all'));
% a factor with a single level among the rows used contributes no column
tbl = table([1; 2; 3], {'a'; 'a'; 'a'}, [1; 2; 4], 'VariableNames', {'x', 'g', 'y'});
design = buildDesign(tbl, 'y ~ x + g');
assert(isequal(design.coefficientNames, {'(Intercept)', 'x'}));

%% coding new data with the levels of a fitted design (prediction); unknown level = missing

fitted = buildDesign(table([1; 2; 3], {'m'; 'f'; 'm'}, logical([0; 1; 1]), [1; 2; 3], 'VariableNames', {'x', 'g', 'l', 'y'}), 'y ~ x + g + l');
newData = table([5; 6; 7], {'f'; 'm'; 'z'}, logical([1; 0; 1]), 'VariableNames', {'x', 'g', 'l'});
design = cobraBuildModelDesign(newData, cobraParseModelFormula('y ~ x + g + l', {'x', 'g', 'l', 'y'}), fitted.variableInfo);
assert(isequal(design.X(1:2, :), [1 5 1 1; 1 6 0 0]) && isequal(design.isMissing', [false false true]) && all(isnan(design.y)));

%% errors: table, response type, non-vector variable

assert(verifyCobraFunctionError('cobraBuildModelDesign', 'inputs', {[1 2], struct('response', 'y', 'terms', {{}})}, ...
    'testMessage', 'cobraBuildModelDesign: tbl must be a table.'));
tbl = table({'a'; 'b'}, [1; 2], 'VariableNames', {'y', 'x'});
assert(verifyCobraFunctionError('cobraBuildModelDesign', 'inputs', {tbl, cobraParseModelFormula('y ~ x', {'y', 'x'})}, ...
    'testMessage', 'cobraBuildModelDesign: the response ''y'' must be a numeric or logical vector.'));
tbl = table([1; 2], [1 2; 3 4], 'VariableNames', {'y', 'x'});
assert(verifyCobraFunctionError('cobraBuildModelDesign', 'inputs', {tbl, cobraParseModelFormula('y ~ x', {'y', 'x'})}, ...
    'testMessage', 'cobraBuildModelDesign: variable ''x'' must be a vector.'));

% change the directory
cd(currentDir)
