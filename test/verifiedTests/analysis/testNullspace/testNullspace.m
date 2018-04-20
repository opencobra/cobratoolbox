% The COBRAToolbox: testNullspace.m
%
% Purpose:
%     - %tests the computation of the nullspace of a matrix using the LU
%        solver termed LUSOL developed by Michael A. Saunders
%
% Authors:
%     - Michael Saunders 2008
%     - Ronan Fleming 2017
%
% Note:
%     - LUSOL must have been installed, ususally this is done by initCobraToolbox.

% save the current path
currentDir = pwd;

%For windows systems, the LU implementation in sparseNull unfortunately does not provide the same accuracy as LU. We therefore skip the test on Windows.
prepareTest('needsUnix',true);

% initialize the test
fileDir = fileparts(which('testNullspace'));
cd(fileDir);


if ~exist('modelLargeA.mat', 'file')
    error('testNullspace could not complete because modelLargeA.mat could not be found');
else
    load('modelLargeA.mat');
end


[Z, rankS] = getNullSpace(A, 0);

% Check if A*Z = 0.
AZ    = A * Z;
normAZ= norm(AZ, inf);

tol = 1e-9;

% give an explicit error message
if normAZ < tol
    fprintf('%s%8.1e%s%8.1e\n','testNullspace passed: norm(S*Z,inf) =', normAZ, ', while tolerance is = ', tol);
else
    fprintf('%s%8.1e%s%8.1e\n','testNullspace failed: norm(S*Z,inf) =', normAZ, ', while tolerance is = ', tol);
end

assert(normAZ < tol)


% change the directory
cd(currentDir)

