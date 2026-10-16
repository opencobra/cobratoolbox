% The COBRAToolbox: testTmodelFields.m
%
% Purpose:
%     - TmodelFields returns the lists of model field names used by modelBorgifier: reaction text
%     fields, reaction number fields, metabolite text fields, metabolite number fields and the
%     ordered list of all fields.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/reconstruction/comparison/modelBorgifier/TmodelFields.m
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
fileDir = fileparts(which('testTmodelFields'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

fields = TmodelFields();

%% five groups of fields

assert(iscell(fields) && isequal(size(fields), [5 1]));

%% group contents

assert(isequal(fields{2}, {'lb'; 'ub'; 'c'}));
assert(isequal(fields{4}, {'metCharge'}));
assert(all(ismember({'rxns', 'rxnNames', 'grRules'}, fields{1})));
assert(all(ismember({'mets', 'metFormulas', 'metInChIString'}, fields{3})));
assert(isequal(size(fields{1}), [11 1]) && isequal(size(fields{3}), [9 1]));

%% the full list contains every other group and the matrix

allFields = fields{5};
assert(all(ismember([fields{1}; fields{2}; fields{3}; fields{4}], allFields)));
assert(all(ismember({'S', 'genes', 'description'}, allFields)));
assert(numel(unique(allFields)) == numel(allFields));

% change the directory
cd(currentDir)
