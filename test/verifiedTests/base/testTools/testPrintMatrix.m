% The COBRAToolbox: testPrintMatrix.m
%
% Purpose:
%     - Tests the printMatrix function
% Author:
%     - Original file: Laurent Heirendt
%     - CI integration: Laurent Heirendt

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPrintMatrix'));
cd(fileDir);

fileName = 'testPrintMatrix.txt';
nbFormat = '%3.2f\t';

% test for a cell matrix
A = {0, 1, 2;
     2, 3, 4;
     4, 5, 6;
     7, 8, 9};

% print the matrix on screen with default format
assert(printMatrix(A) == 1);

% define the matrix A
A = rand(10, 10);

% print the matrix on screen with default format
assert(printMatrix(A) == 1);

% print the matrix on screen with short format
assert(printMatrix(A, nbFormat) == 1);

% print the matrix to a file with short format
assert(printMatrix(A, nbFormat, fileName) == 1);

% remove the generated file
fullFileNamePath = [fileparts(which(mfilename)), filesep, fileName];
if exist(fullFileNamePath, 'file') == 2
    delete(fullFileNamePath);
end

% test to print to a file and read the data from that same file
A = ones(6) * 6;
A = A + (A / 10) + (A / 100);
nbFormat = '%6.2f\t';

retStatus = printMatrix(A, nbFormat, fileName);
assert(retStatus == 1);

% read in the data from the newly generated file and test against reference data
[~, data1, ~] = readMixedData(fileName, 0, 0)
[~, data2, ~] = readMixedData('refData_printMatrix.txt', 0, 0)
assert(isequal(data1, data2))

% remove the generated file
fullFileNamePath = [fileparts(which(mfilename)), filesep, fileName];
if exist(fullFileNamePath, 'file') == 2
    delete(fullFileNamePath);
end

% change the directory
cd(currentDir)
