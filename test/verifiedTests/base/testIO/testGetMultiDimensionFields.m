% The COBRAToolbox: testGetMultiDimensionFields.m
%
% Purpose:
%     - getMultiDimensionFields selects, from a table of model field definitions, the fields that
%     have a text entry for both dimensions and returns their names and dimensions.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/base/io/utilities/getMultiDimensionFields.m
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
fileDir = fileparts(which('testGetMultiDimensionFields'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% definitions: name, first dimension, second dimension (a non-text entry means one dimension only)
definitions = {'S',  'mets', 'rxns'; ...
               'lb', 'rxns', [];     ...
               'C',  'ctrs', 'rxns'; ...
               'c',  [],     'rxns'};

%% fields with both dimensions as text

[fieldNames, firstDim, secondDim] = getMultiDimensionFields(definitions);
assert(isequal(fieldNames, {'S'; 'C'}));
assert(isequal(firstDim, {'mets'; 'ctrs'}));
assert(isequal(secondDim, {'rxns'; 'rxns'}));

%% no field qualifies

[fieldNames, firstDim, secondDim] = getMultiDimensionFields(definitions(2, :));
assert(isempty(fieldNames) && isempty(firstDim) && isempty(secondDim));

% change the directory
cd(currentDir)
