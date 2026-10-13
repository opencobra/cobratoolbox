% The COBRAToolbox: testGetBioQualifiers.m
%
% Purpose:
%     - getBioQualifiers returns the list of biological qualifier names of the SBML standard and the
%     table that maps each standard qualifier to its alternative name.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/base/io/utilities/SBML/getBioQualifiers.m
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
fileDir = fileparts(which('testGetBioQualifiers'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

[bioQualifiers, standardQualifiers] = getBioQualifiers();

%% qualifier list

assert(iscell(bioQualifiers) && numel(bioQualifiers) == 34);
assert(numel(unique(bioQualifiers)) == numel(bioQualifiers));
% some members
assert(all(ismember({'is', 'isDescribedBy', 'hasPart', 'taxon', 'identity', 'class'}, bioQualifiers)));

%% table of standard qualifiers

assert(isequal(size(standardQualifiers), [16 2]));
assert(isequal(standardQualifiers(1, :), {'is', 'identity'}));
assert(isequal(standardQualifiers(end, :), {'hasTaxon', 'taxon'}));
% both names of every pair are qualifiers
assert(all(ismember(standardQualifiers(:), bioQualifiers)));

% change the directory
cd(currentDir)
