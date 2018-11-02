% The COBRAToolbox: testKLDis.m
%
% Purpose:
%     - test the functionality of KLDis
%
% Authors:
%     - Loic Marx
%

% save the current path
currentDir = pwd;

% initialize the test
cd(fileparts(which(mfilename)));

% set the tolerance
tol = 1e-6;

% Generate 2 matrix of the same size
P = [1 2; 2 1];
Q = [3 2; 2 3];

% run the function 
KLD = KLDis(P,Q);

% compare the scaled matrix against the reference data
assert(norm(KLD - 0.12723233459191 * [1; 1]) < tol)

Q2 = [inf inf]; 
P2 = [inf inf];

% Test if KLDis throws an error
assert(verifyCobraFunctionError('KLDis','inputs', {P, Q(:,1)}, 'testMessage', 'the number of columns in P and Q should be the same'));
assert(verifyCobraFunctionError('KLDis','inputs', {P2, Q2}, 'testMessage', 'the inputs contain non-finite values!'));

% change the directory
cd(currentDir)
