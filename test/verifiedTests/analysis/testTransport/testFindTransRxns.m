% The COBRAToolbox: testFindTransRxns.m
%
% Purpose:
%     - findTransRxns finds the transport reactions of a model: reactions whose metabolites are in
%     more than one compartment and, optionally, exchange reactions.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/transport/findTransRxns.m
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
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindTransRxns'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% a[c] <-> a[e] (transport), an exchange of a[e], and a conversion a[c] -> b[c]
model.mets = {'a[c]'; 'a[e]'; 'b[c]'; 'b[e]'};
model.rxns = {'EX_a'; 'T_a'; 'R'};
model.S = [ 0 -1 -1; ...
           -1  1  0; ...
            0  0  1; ...
            0  0  0];
model.lb = [-10; -10; 0];
model.ub = [10; 10; 10];
model.c = zeros(3, 1);
model.b = zeros(4, 1);

%% transport reactions between compartments

[transRxns, nonTransRxns, transRxnsBool] = findTransRxns(model);
assert(isequal(transRxns, {'T_a'}));
assert(isequal(nonTransRxns, {'EX_a'; 'R'}));
assert(isequal(transRxnsBool, [false; true; false]));

%% exchange reactions can be included

[transRxns, nonTransRxns, transRxnsBool] = findTransRxns(model, true);
assert(isequal(transRxns, {'EX_a'; 'T_a'}));
assert(isequal(nonTransRxns, {'R'}));
assert(isequal(transRxnsBool, [true; true; false]));

%% only a subset of the reactions is examined

[transRxns, nonTransRxns, transRxnsBool] = findTransRxns(model, false, [2 3]);
assert(isequal(transRxns, {'T_a'}) && isequal(nonTransRxns, {'R'}));
assert(isequal(transRxnsBool, [true; false]));

% change the directory
cd(currentDir)
