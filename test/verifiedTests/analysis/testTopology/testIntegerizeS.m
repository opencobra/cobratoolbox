% The COBRAToolbox: testIntegerizeS.m
%
% Purpose:
%     - integerizeS multiplies each reaction of a model by the least common multiple of the
%     denominators of its stoichiometric coefficients so that the stoichiometric matrix is integer,
%     and returns the scale factors.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Defect(s) fixed by feature 20261102-140321-tier1-safe-defect-fixes: A reaction with a single
%       non-integer coefficient stops the function with an error.
%
% Function under test:
%     src/analysis/topology/integerizeS.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Lines 73-88, the disabled branch (if 0) that scales by powers of ten: it can never run.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.
%     - Updated for feature 20261102-140321-tier1-safe-defect-fixes, 2026-11-02.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testIntegerizeS'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% two reactions with halves: r1: 0.5 a -> 0.5 b ; r2: 1.5 b -> a + 0.5 c  (written as net stoichiometry)
model.S = [-0.5  1; ...
            0.5 -1.5; ...
            0    0.5];
model.rxns = {'r1'; 'r2'};
model.mets = {'a[c]'; 'b[c]'; 'c[c]'};
% the same model with integer coefficients
intModel = model;
intModel.S = [-1 2; 1 -3; 0 1];

%% all reactions integerised

[modelOut, g] = integerizeS(model, 0, 0);
% r1 has denominators 2, 2 and r2 has 1, 2, 2: both are scaled by 2
assert(isequal(g, [2; 2]));
assert(isequal(modelOut.S, [-1 2; 1 -3; 0 1]));

%% only the reactions flagged as consistent are integerised

withFlag = model;
withFlag.SConsistentRxnBool = [true; false];
[modelOut, g] = integerizeS(withFlag, 0);
assert(isequal(g, [2; 1]));
assert(isequal(modelOut.S(:, 1), [-1; 1; 0]) && isequal(modelOut.S(:, 2), [1; -1.5; 0.5]) || ...
       isequal(fix(modelOut.S(:, 2)), [1; -1; 0]));

%% internal reactions are found from the metabolite identifiers

[modelOut, g] = integerizeS(model, 0);
assert(isequal(g, [2; 2]));
assert(isfield(modelOut, 'SIntRxnBool'));

%% a model without metabolite identifiers treats every reaction as internal

noMets = rmfield(model, 'mets');
[~, g] = integerizeS(noMets, 0);
assert(isequal(g, [2; 2]));

%% integer coefficients are left unchanged

[modelOut, g] = integerizeS(intModel, 0, 0);
assert(isequal(g, [1; 1]) && isequal(modelOut.S, intModel.S));

%% a reaction with a single non-integer coefficient

% exchange reaction r1: 0.5 a ->, integerised with all reactions (internalRxnsOnly = 0): the factor
% is the denominator of its only coefficient (2); r2 (b -> a) is integer and keeps factor 1
exchangeModel.S = [-0.5  1; ...
                    0   -1];
exchangeModel.rxns = {'r1'; 'r2'};
exchangeModel.mets = {'a[c]'; 'b[c]'};
[modelOut, g] = integerizeS(exchangeModel, 0, 0);
assert(isequal(g, [2; 1]));
assert(isequal(modelOut.S, [-1 1; 0 -1]));
% a third of a metabolite gives the factor 3
exchangeModel.S = [-1/3; 0];
exchangeModel.rxns = {'r1'};
[modelOut, g] = integerizeS(exchangeModel, 0, 0);
assert(g == 3 && isequal(modelOut.S, [-1; 0]));

%% printing of the integerised reactions

% the default print level is 1
text = evalc('integerizeS(model);');
assert(contains(text, 'Reactions integerised:'));

% print level 1: after the integerisation
text = evalc('integerizeS(model, 1, 0);');
assert(contains(text, 'Reactions integerised:'));
assert(~contains(text, 'Before reactions integerised'));
% print level 2: before and after
text = evalc('integerizeS(model, 2, 0);');
assert(contains(text, 'Before reactions integerised:') && contains(text, 'Reactions integerised:'));
% nothing to print when no reaction changes
text = evalc('integerizeS(intModel, 2, 0);');
assert(isempty(text));

% change the directory
cd(currentDir)
