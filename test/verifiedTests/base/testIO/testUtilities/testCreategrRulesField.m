% The COBRAToolbox: testCreategrRulesField.m
%
% Purpose:
%     - creategrRulesField rebuilds the readable grRules of a model from its rules (x(i)
%       indices, & and |) and its gene identifiers, for all reactions or for the positions
%       given as a logical mask, as indices or as reaction names. This test checks the
%       translation on hand-written rules with and, or, parentheses, an empty rule and a
%       two-digit gene index, the three forms of positions against an existing grRules field,
%       that positions are ignored when the model has no grRules yet, and that a list of only
%       unknown reaction names is refused. The expected strings are written by hand.
%
% Function under test:
%     src/base/io/utilities/creategrRulesField.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation without a solver, hand-built models.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: unknown reaction names in positions are not reported as intended
%       SEVERITY: cosmetic
%       TRIGGER: creategrRulesField(model, {'R1', 'notInModel'}) and
%                creategrRulesField(model, {'notInModel'}) on a model with a grRules field
%       OBSERVED: MATLAB R2025a: the mixed list raises no error and silently updates R1 only,
%                 because the test of line 45 reads (~sum(pos)) == numel(unique(positions)),
%                 which is true only when no name matches and exactly one name is given; the
%                 all-unknown list then stops in the error call of line 46 with "Unrecognized
%                 function or variable 'postions'" (misspelt variable) instead of the intended
%                 message. The test below only checks that the all-unknown list raises an error.
%       EXPECTED: the error "The following reactions are not part of this model: notInModel"
%                 for both lists
%       LINES: 45-46
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCreategrRulesField'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% hand-built model: three reactions, three genes, rules with and, or, parentheses and an
% empty rule
model = struct();
model.rxns = {'R1'; 'R2'; 'R3'};
model.genes = {'g1'; 'g2'; 'g3'};
model.rules = {'x(1) & x(2)'; '(x(1) | x(3)) & x(2)'; ''};
expectedAll = {'g1 and g2'; '(g1 or g3) and g2'; ''};

%% no positions and no grRules: every reaction gets grRules built from rules and genes

out = creategrRulesField(model);
% exact strings: & becomes and, | becomes or, x(i) becomes genes{i}; the field is nRxns x 1
assert(isequal(out.grRules, expectedAll));
assert(isequal(size(out.grRules), [3 1]));
% the fields the function reads are returned unchanged
assert(isequal(out.rules, model.rules) && isequal(out.genes, model.genes));

%% positions given but no grRules field yet: all reactions are built (positions are ignored)

out = creategrRulesField(model, 2);
assert(isequal(out.grRules, expectedAll));

%% logical positions replace only the selected entries of an existing grRules field

modelOld = model;
modelOld.grRules = {'old1'; 'old2'; 'old3'};
out = creategrRulesField(modelOld, logical([1; 0; 0]));
assert(isequal(out.grRules, {'g1 and g2'; 'old2'; 'old3'}));

%% numeric positions

out = creategrRulesField(modelOld, [2 3]);
assert(isequal(out.grRules, {'old1'; '(g1 or g3) and g2'; ''}));

%% reaction names, in any order

out = creategrRulesField(modelOld, {'R3'});
assert(isequal(out.grRules, {'old1'; 'old2'; ''}));
out = creategrRulesField(modelOld, {'R2'; 'R1'});
assert(isequal(out.grRules, {'g1 and g2'; '(g1 or g3) and g2'; 'old3'}));

%% a two-digit gene index names the tenth gene, not the first followed by a zero

model10 = struct('rxns', {{'R1'}}, 'rules', {{'x(10) | x(1)'}}, ...
    'genes', {arrayfun(@(i) sprintf('g%d', i), 1:10, 'UniformOutput', false)'});
out = creategrRulesField(model10);
assert(isequal(out.grRules, {'g10 or g1'}));

%% a list of only unknown reaction names is refused (an error is the intended behaviour; its
%% message is wrong, see the defect in the header, so the message is not checked)

assert(verifyCobraFunctionError('creategrRulesField', 'inputs', {modelOld, {'notInModel'}}));

% change the directory
cd(currentDir)
