% The COBRAToolbox: testCobraParseModelFormula.m
%
% Purpose:
%     - cobraParseModelFormula parses the Wilkinson-notation formulas of the fitglm and fitlm
%       call sites for cobraFitglm and cobraFitlm. This test checks main effects, interactions,
%       crossing with '*', removal with '-', the order of the terms (main effects first),
%       duplicates, whitespace, random intercepts (1|g), string input, and the errors for
%       unsupported terms and unknown variables.
%
% Function under test:
%     src/base/utilities/toolboxFree/cobraParseModelFormula.m
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
fileDir = fileparts(which('testCobraParseModelFormula'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

names = {'y', 'Flux', 'Sex', 'Age', 'Weight', 'ID'};

%% main effects in formula order (the form performRegressions builds)

parsed = cobraParseModelFormula('y~Flux+Sex+Age', names);
assert(strcmp(parsed.response, 'y') && isequal(parsed.terms, {{'Flux'}, {'Sex'}, {'Age'}}));
assert(isempty(parsed.randomGroups) && isequal(parsed.predictors, {'Flux', 'Sex', 'Age'}));

%% crossing, removal, interactions after main effects, whitespace and string input

parsed = cobraParseModelFormula("y ~ Age*Weight*Sex - Age:Weight:Sex", names);
assert(isequal(parsed.terms, {{'Age'}, {'Weight'}, {'Sex'}, {'Age', 'Weight'}, {'Age', 'Sex'}, {'Weight', 'Sex'}}));
parsed = cobraParseModelFormula('y ~ Flux:Sex + Flux + Flux', names);
% the duplicate main effect is kept once, and the interaction follows the main effect
assert(isequal(parsed.terms, {{'Flux'}, {'Flux', 'Sex'}}));
parsed = cobraParseModelFormula('y ~ Flux + Sex:Flux - Flux:Sex', names);
% removal matches an interaction whatever the order of its factors
assert(isequal(parsed.terms, {{'Flux'}}));

%% random intercepts are returned separately

parsed = cobraParseModelFormula('y ~ Flux + Sex + (1|ID)', names);
assert(isequal(parsed.terms, {{'Flux'}, {'Sex'}}) && isequal(parsed.randomGroups, {'ID'}));

%% errors: unsupported terms, unknown variables, malformed formulas

assert(verifyCobraFunctionError('cobraParseModelFormula', 'inputs', {'y ~ Flux + (Flux|ID)', names}, ...
    'testMessage', 'cobraParseModelFormula: unsupported term in ''Flux+(Flux|ID)'' (only random intercepts (1|g) are supported).'));
assert(verifyCobraFunctionError('cobraParseModelFormula', 'inputs', {'y ~ Flux - 1', names}, ...
    'testMessage', 'cobraParseModelFormula: unsupported term ''-1'' (models without intercept are not supported).'));
assert(verifyCobraFunctionError('cobraParseModelFormula', 'inputs', {'y ~ 0 + Flux', names}, ...
    'testMessage', 'cobraParseModelFormula: unsupported term ''0''.'));
% an explicit intercept is accepted, so the Formula text of a fitted model can be used again
parsed = cobraParseModelFormula('y ~ 1 + Flux + Sex', names);
assert(isequal(parsed.terms, {{'Flux'}, {'Sex'}}));
assert(verifyCobraFunctionError('cobraParseModelFormula', 'inputs', {'y ~ Flux^2', names}, ...
    'testMessage', 'cobraParseModelFormula: unsupported term ''Flux^2''.'));
assert(verifyCobraFunctionError('cobraParseModelFormula', 'inputs', {'y ~ Mass', names}, ...
    'testMessage', 'cobraParseModelFormula: unknown variable ''Mass'' in the formula.'));
assert(verifyCobraFunctionError('cobraParseModelFormula', 'inputs', {'z ~ Flux', names}, ...
    'testMessage', 'cobraParseModelFormula: unknown variable ''z'' in the formula.'));
assert(verifyCobraFunctionError('cobraParseModelFormula', 'inputs', {'y ~ Flux + (1|Group)', names}, ...
    'testMessage', 'cobraParseModelFormula: unknown variable ''Group'' in the formula.'));
assert(verifyCobraFunctionError('cobraParseModelFormula', 'inputs', {'y Flux', names}, ...
    'testMessage', 'cobraParseModelFormula: formula must have the form ''response ~ terms''.'));
assert(verifyCobraFunctionError('cobraParseModelFormula', 'inputs', {{'y ~ Flux'}, names}, ...
    'testMessage', 'cobraParseModelFormula: formula must be a character vector or string scalar.'));

% change the directory
cd(currentDir)
