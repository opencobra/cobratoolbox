% The COBRAToolbox: testReadMixedData.m
%
% Purpose:
%     - tests the functionality of readMixedData
%
% Author:
%     - Original file: Lemmer El Assal
%     - CI integration: Laurent Heirendt

% save the current path
currentDir = pwd;

% initialize the test
cd(fileparts(which(mfilename)));

file = 'testData_readMixedData.txt';
n_header = 1;
n_labels = 3;
delimiter = ',';

% read in the file
for verbose = 0:1
    [id, data, header] = readMixedData(file, n_header, n_labels, delimiter, verbose);
end

% load reference data
load('refData_readMixedData.mat');
assert(isequal(ref_data, data))
assert(isequal(ref_header, header))
assert(isequal(ref_id, id))

% return to original directory
cd(currentDir);
