% The COBRAToolbox: testConvRevSamples.m
%
% Purpose:
%     - convRevSamples renames the reactions whose identifier ends in _r (reactions that only run in
%     reverse), negates their stoichiometric column and, when a sample set is given, negates their
%     rows in the samples.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/sampling/ACHR/convRevSamples.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Bounds of a reverse-only reaction are not exchanged correctly
%       SEVERITY: wrong-result
%       TRIGGER: a reaction named with the suffix _r, for example with lb = -10 and ub = 0
%       OBSERVED: the new upper bound is computed from the lower bound that was just overwritten, so
%         it equals the old upper bound; lb = -10, ub = 0 becomes lb = 0, ub = 0
%       EXPECTED: the bounds are exchanged and negated: lb = -10, ub = 0 becomes lb = 0, ub = 10
%       LINES: 31-32
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testConvRevSamples'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% three reactions; the second runs only in reverse (suffix _r)
model.rxns = {'a'; 'b_r'; 'c'};
model.lb = [0; -10; -5];
model.ub = [10; 0; 5];
model.S = [1 2 3; 4 5 6];
samples = [1 2; 3 4; 5 6];

%% reverse-only reactions are renamed and their stoichiometric column is negated

[newModel, newSamples] = convRevSamples(model, samples); %#ok<ASGLU>
assert(isequal(newModel.rxns, {'a'; 'b'; 'c'}));
assert(isequal(newModel.S, [1 -2 3; 4 -5 6]));
% the lower bound of the converted reaction is minus its old upper bound (0);
% the upper bound is not asserted (see the known defect in the header)
assert(newModel.lb(2) == 0);
% other reactions keep their bounds
assert(isequal(newModel.lb([1 3]), [0; -5]) && isequal(newModel.ub([1 3]), [10; 5]));

%% samples of the converted reaction are negated

[~, newSamples] = convRevSamples(model, samples);
assert(isequal(newSamples, [1 2; -3 -4; 5 6]));

%% without samples the second output is empty

[newModel, newSamples] = convRevSamples(model);
assert(isempty(newSamples));
assert(isequal(newModel.S, [1 -2 3; 4 -5 6]));

%% a model without reverse-only reactions is unchanged

plain = model;
plain.rxns = {'a'; 'b'; 'c'};
[newModel, newSamples] = convRevSamples(plain, samples);
assert(isequal(newModel, plain) && isequal(newSamples, samples));

% change the directory
cd(currentDir)
