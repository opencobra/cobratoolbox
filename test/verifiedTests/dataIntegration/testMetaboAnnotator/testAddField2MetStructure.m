% The COBRAToolbox: testAddField2MetStructure.m
%
% Purpose:
%     - addField2MetStructure adds every allowed field of the metabolite structure (and its _source
%     field) that a metabolite lacks, filled with NaN, for all or for the named metabolites.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/dataIntegration/metaboAnnotator/buildMetStruct/addField2MetStructure.m
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
%     - Generated for feature tier1-test-batch3, 2026-10-12.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAddField2MetStructure'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

original.m1 = struct('name', 'x');
original.m2 = struct('name', 'y', 'charge', 1);

% the list of allowed fields (variable field2Add) is defined by the toolbox script
metaboliteStructureFieldNames;

%% all metabolites

result = addField2MetStructure(original);
% every allowed field exists in both metabolites
for k = 1:numel(field2Add)
    assert(isfield(result.m1, field2Add{k}) && isfield(result.m2, field2Add{k}));
end
% existing values are kept
assert(strcmp(result.m1.name, 'x') && strcmp(result.m2.name, 'y'));
assert(result.m2.charge == 1);
% added fields are NaN, each with a _source field
assert(isnan(result.m1.charge) && isnan(result.m1.charge_source));
assert(isnan(result.m2.VMHId) && isnan(result.m2.VMHId_source));

%% only a named metabolite

result = addField2MetStructure(original, 'm2');
assert(isfield(result.m2, 'VMHId'));
% the other metabolite is not completed
assert(isequal(fieldnames(result.m1), {'name'}));

%% a list of names

result = addField2MetStructure(original, {'m1'});
assert(isfield(result.m1, 'VMHId') && isnan(result.m1.VMHId));
assert(isequal(fieldnames(result.m2), {'name'; 'charge'}));

% change the directory
cd(currentDir)
