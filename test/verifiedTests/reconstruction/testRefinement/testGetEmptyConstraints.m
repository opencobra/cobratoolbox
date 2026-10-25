% The COBRAToolbox: testGetEmptyConstraints.m
%
% Purpose:
%     - getEmptyConstraints returns the identifiers of the coupling constraints that have no non-
%     zero coefficient in the flux coupling matrix (and in the enzyme coupling matrix when enzyme
%     variables exist).
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/reconstruction/refinement/getEmptyConstraints.m
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
fileDir = fileparts(which('testGetEmptyConstraints'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

model.C = [1 0; 0 0; 0 2];
model.ctrs = {'c1'; 'c2'; 'c3'};

%% no coupling constraints

assert(isempty(getEmptyConstraints(struct())));

%% constraints with an empty row

assert(isequal(getEmptyConstraints(model), {'c2'}));

%% a row that is empty in C but used by enzyme variables is not empty

model.evars = {'e1'};
model.D = [0; 1; 0];
assert(isempty(getEmptyConstraints(model)));
model.D = [0; 0; 0];
assert(isequal(getEmptyConstraints(model), {'c2'}));

%% all constraints used

model2.C = [1 0; 0 1];
model2.ctrs = {'c1'; 'c2'};
assert(isempty(getEmptyConstraints(model2)));

% change the directory
cd(currentDir)
