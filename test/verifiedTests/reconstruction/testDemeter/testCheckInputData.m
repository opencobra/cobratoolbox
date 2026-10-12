% The COBRAToolbox: testCheckInputData.m
%
% Purpose:
%     - checkInputData cleans a table of strain data (as a cell array) against the strain information: removes unknown strains, keeps the best duplicate, adds missing strains with zeros and tidies the reference columns.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/reconstruction/demeter/src/integration/checkInputData.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     When the first-column header of the data differs from the header of the strain information (as in the test, which is the intended use), the header name is also listed in removedStrains; the test therefore only checks that the unknown strain is in that list. When both headers are equal, the unknown strain is listed but its row is not removed (the first removed index is skipped); that input is not tested.
%
% Authors:
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCheckInputData'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

strainInformation = {'Strain'; 's1'; 's2'; 's3'};

%% unknown strain removed, duplicate strain reduced to its best row, missing strain added

inputData = {'Taxon', 'a', 'b'; 's1', '1', '0'; 's1', '5', '0'; 's4', '2', '2'; 's2', '3', '3'};
[checkedData, addedStrains, removedStrains, duplicateStrains] = checkInputData(inputData, strainInformation);

% s4 is not in the strain information and is removed
assert(ismember('s4', removedStrains));
% s1 occurs twice: the row with the larger total (5) is kept
assert(isequal(duplicateStrains, {'s1'}));
% s3 is in the strain information but not in the data: added with zeros
assert(isequal(addedStrains, {'s3'}));
assert(isequal(checkedData, {'Taxon', 'a', 'b'; 's1', '5', '0'; 's2', '3', '3'; 's3', '0', '0'}));

%% reference columns (names starting with Ref): empty, zero and NaN entries are dropped and the rest moved left

inputData = {'Taxon', 'a', 'Ref1', 'Ref2'; 's1', '1', 'p1', 'p2'; 's2', '2', '0', 'p3'; 's3', '3', '', ''; 's2x', '2', 'p1', 'p1'};
[checkedData, addedStrains, removedStrains] = checkInputData(inputData, strainInformation);
assert(isempty(addedStrains));
assert(ismember('s2x', removedStrains));
assert(isequal(checkedData, {'Taxon', 'a', 'Ref1', 'Ref2'; 's1', '1', 'p1', 'p2'; 's2', '2', 'p3', ''; 's3', '3', '', ''}));

% a NaN reference entry is treated as empty
inputData = {'Taxon', 'a', 'Ref1', 'Ref2'; 's1', '1', NaN, 'p2'};
checkedData = checkInputData(inputData, {'Strain'; 's1'});
assert(isequal(checkedData, {'Taxon', 'a', 'Ref1', 'Ref2'; 's1', '1', 'p2', ''}));

%% a strain that is in the strain information but not in the data is added with zeros

[checkedData, addedStrains] = checkInputData({'Taxon', 'a'; 's1', '1'}, {'Strain'; 's1'; 's2'});
assert(isequal(addedStrains, {'s2'}));
assert(isequal(checkedData, {'Taxon', 'a'; 's1', '1'; 's2', '0'}));

% change the directory
cd(currentDir)
