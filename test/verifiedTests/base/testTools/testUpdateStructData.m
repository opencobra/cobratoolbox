% The COBRAToolbox: testUpdateStructData.m
%
% Purpose:
%     - updateStructData updates a structure with the fields of another structure: existing fields
%     are overwritten, new fields are added, and nested structures are merged field by field.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/base/utilities/updateStructData.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A structure update is ignored when the original field is not a structure
%       SEVERITY: limitation
%       TRIGGER: a field that is a structure in the update but not a structure in the original
%       OBSERVED: the original value is kept and the update is dropped without a message
%       EXPECTED: the field replaced by the update (or an error)
%       LINES: 25-31
%
% Authors:
%     - Generated for feature tier1-test-batch3, 2026-10-12.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testUpdateStructData'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

original = struct('a', 1, 'n', struct('x', 1, 'y', 2));
update = struct('a', 5, 'b', 7, 'n', struct('y', 9, 'z', 3));

%% fields are overwritten or added, nested structures are merged

updated = updateStructData(original, update);
assert(updated.a == 5);                         % overwritten
assert(updated.b == 7);                         % added
assert(isequal(updated.n, struct('x', 1, 'y', 9, 'z', 3)));   % merged: x kept, y overwritten, z added

%% the original is not changed (MATLAB copies on assignment)

assert(original.a == 1 && ~isfield(original, 'b') && ~isfield(original.n, 'z'));

%% an empty update changes nothing

assert(isequal(updateStructData(original, struct()), original));

% change the directory
cd(currentDir)
