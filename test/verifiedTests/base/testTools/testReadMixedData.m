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
fileDir = fileparts(which('testReadMixedData'));
cd(fileDir);

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

% update of the test with n_labels=0
[id, data, header] = readMixedData(file, n_header, 0, delimiter, verbose);
assert(isequal(ref_header, header))
ref_id = [];
assert(isequal(ref_id, id))

% update of the tests with only one input argument and n_labels=1
[id, data, header] = readMixedData(file);
assert(isequal(ref_data, data))
ref_header = [];
ref_id = {'col1,col2,col3'; '1,2,3'; '4,5,6'; '7,8,9'};
assert(isequal(ref_header, header))
assert(isequal(ref_id, id))

% return to original directory
cd(currentDir);
