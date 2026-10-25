% The COBRAToolbox: testCheckIDsForTypeExist.m
%
% Purpose:
%     - checkIDsForTypeExist checks whether any of the given identifiers exists among the
%     identifiers of a model field (reactions and enzyme variables, or metabolites and constraints)
%     and optionally returns the ones that exist.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/reconstruction/refinement/checkIDsForTypeExist.m
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
fileDir = fileparts(which('testCheckIDsForTypeExist'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

model.rxns = {'r1'; 'r2'};
model.mets = {'a'; 'b'};

%% reaction identifiers

[present, existing] = checkIDsForTypeExist(model, {'r2', 'zz'}, 'rxns');
assert(present && isequal(existing, {'r2'}));
[present, existing] = checkIDsForTypeExist(model, {'zz'}, 'rxns');
assert(~present && isempty(existing));

%% metabolite identifiers

present = checkIDsForTypeExist(model, {'a'}, 'mets');
assert(present);

%% enzyme variables count as reaction identifiers and constraints as metabolite identifiers

model.evars = {'e1'};
model.ctrs = {'c1'; 'c2'};
[present, existing] = checkIDsForTypeExist(model, {'e1', 'r1'}, 'rxns');
assert(present && isequal(existing, {'e1'; 'r1'}));
[present, existing] = checkIDsForTypeExist(model, {'c2', 'a'}, 'mets');
assert(present && isequal(existing, {'a'; 'c2'}));
% the same through the other field names
assert(checkIDsForTypeExist(model, {'e1'}, 'evars'));
assert(checkIDsForTypeExist(model, {'c1'}, 'ctrs'));

%% a field the model does not have

assert(~checkIDsForTypeExist(model, {'x'}, 'genes'));

%% other fields use their own identifiers

model.genes = {'g1'};
[present, existing] = checkIDsForTypeExist(model, {'g1', 'g2'}, 'genes');
assert(present && isequal(existing, {'g1'}));

% change the directory
cd(currentDir)
