% The COBRAToolbox: testgetMetanetxID.m
%
% Purpose:
%     - This test examines the results of getMetanetxID function
%
% Authors:
% .. Author: - Farid Zare, 7/12/2024
%

% save the current path and initialize the test
currentDir = cd(fileparts(which(mfilename)));

% determine the test path for references
testPath = pwd;

%Load reference data
load([testPath filesep 'refData_getMetanetxID.mat']);
metIDs = table2cell(refData_getMetanetxID(:, 1));
refMetanetxID = table2cell(refData_getMetanetxID(:, 2));

fprintf(' -- Running testData_getMetanetxID.mat:... ');

nlt = numel(metIDs);
metanetxID = cell(nlt,1);

for i = 1:nlt
    name = metIDs{i};
    metanetxID{i} = getMetanetxID(name);
end

% Assert the output and refrence data
assert(isequaln(metanetxID, refMetanetxID));

% output a success message
fprintf('Done.\n');

% change the directory
cd(currentDir)