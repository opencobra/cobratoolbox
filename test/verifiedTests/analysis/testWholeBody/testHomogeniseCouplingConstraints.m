% The COBRAToolbox: testHomogeniseCouplingConstraints.m
%
% Purpose:
%     - homogeniseCouplingConstraints cleans the coupling constraints of a whole-body model: it
%     removes the trtr coupling of triple constraints, deletes empty and single-reaction rows, and
%     rewrites rows with two negative coefficients to positive ones with the inequality sense
%     reversed.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/wholeBody/io/homogeniseCouplingConstraints.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Lines 50-81, the disabled branch (if 0) that rewrites triple constraints with the trtr biomass
%     reaction: it can never run. Line 109, the error for remaining single rows: all single rows are
%     removed just before, so it cannot be reached.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testHomogeniseCouplingConstraints'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

model.C = sparse([1 1 0; 0 1 -1]);
model.d = [0; 0];
model.ctrs = {'c1'; 'c2'};
model.dsense = ['L'; 'G'];
model.rxns = {'a'; 'b'; 'c'};

%% constraints with two non-zero coefficients stay as they are

out = homogeniseCouplingConstraints(model);
assert(isequal(full(out.C), [1 1 0; 0 1 -1]));
assert(isequal(out.ctrs, {'c1'; 'c2'}) && isequal(out.dsense, ['L'; 'G']));

%% empty rows and single-reaction rows are removed

model2 = model;
model2.C = sparse([1 1 0; 0 0 0; 0 2 0; 0 1 -1]);
model2.d = [0; 0; 0; 0];
model2.ctrs = {'c1'; 'c2'; 'c3'; 'c4'};
model2.dsense = ['L'; 'L'; 'G'; 'G'];
out = homogeniseCouplingConstraints(model2);
assert(isequal(full(out.C), [1 1 0; 0 1 -1]));
assert(isequal(out.ctrs, {'c1'; 'c4'}) && isequal(out.dsense, ['L'; 'G']) && isequal(out.d, [0; 0]));

%% rows with two negative coefficients are switched to positive and the sense is reversed

model3 = model;
model3.C = sparse([-1 -1 0; 0 -1 -2; 1 -1 0]);
model3.d = [0; 0; 0];
model3.ctrs = {'c1'; 'c2'; 'c3'};
model3.dsense = ['L'; 'G'; 'L'];
text = evalc('out = homogeniseCouplingConstraints(model3);');
assert(isequal(full(out.C), [1 1 0; 0 1 2; 1 -1 0]));
% L became G, G became L, and the mixed-sign row is untouched
assert(isequal(out.dsense, ['G'; 'L'; 'L']));
assert(contains(text, '2') && contains(text, 'both negative signs switched to both positive'));

%% triple rows have the trtr biomass reaction removed from the coupling

model4 = model;
model4.rxns = {'sIEC_biomass_reactionIEC01b_trtr'; 'b'; 'c'};
model4.C = sparse([1 1 1; 0 1 -1]);
model4.d = [0; 0];
model4.ctrs = {'c1'; 'c2'};
model4.dsense = ['L'; 'G'];
out = homogeniseCouplingConstraints(model4);
assert(isequal(full(out.C), [0 1 1; 0 1 -1]));

%% triple rows that cannot be resolved are an error

model5 = model;
model5.C = sparse([1 1 1; 0 1 -1]);
model5.d = [0; 0];
model5.ctrs = {'c1'; 'c2'};
model5.dsense = ['L'; 'G'];
verifyCobraFunctionError('homogeniseCouplingConstraints', 'inputs', {model5}, ...
    'testMessage', 'triplets not completely replaced');

%% equality constraints are not allowed

model6 = model;
model6.dsense = ['E'; 'L'];
verifyCobraFunctionError('homogeniseCouplingConstraints', 'inputs', {model6}, ...
    'testMessage', 'equality dsense at 1 positions');

%% rows with more than two coefficients that are not triples are not a problem for the single check

model7 = model;
model7.C = sparse([1 1 1 1; 0 1 -1 0]);
model7.d = [0; 0];
model7.ctrs = {'c1'; 'c2'};
model7.dsense = ['L'; 'G'];
model7.rxns = {'a'; 'b'; 'c'; 'd'};
out = homogeniseCouplingConstraints(model7);
assert(isequal(full(out.C), [1 1 1 1; 0 1 -1 0]));

% change the directory
cd(currentDir)
