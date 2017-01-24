% The COBRAToolbox: testPrintMatrix.m
%
% Purpose:
%     - Tests the printMatrix function
% Author:
%     - Original file: Laurent Heirendt
%     - CI integration: Laurent Heirendt

% define the matrix A
A = rand(10, 10);

% print the matrix on screen with default format
assert(printMatrix(A) == 1);

% print the matrix on screen with short format
assert(printMatrix(A, '%3.2f\t') == 1);

% print the matrix to a file with short format
assert(printMatrix(A, '%3.2f\t', 'testPrintMatrix.txt') == 1);

% remove the generated file
cd([CBTDIR '/test/verifiedTests/testTools']);
system('rm testPrintMatrix.txt');

% test for a cell matrix
A = {0, 1, 2;
     2, 3, 4;
     4, 5, 6;
     7, 8, 9};

% print the matrix on screen with default format
assert(printMatrix(A) == 1);
