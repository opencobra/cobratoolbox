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


% Generate 2 matrix of the same size
 P= [12 62; 93 3]
 Q= [1 23; 43 1]
 
 % Reference data 
 KLDis_1 = KLDis(P,Q)
  %save('refData_KLDis_1.mat', 'KLDis_1');
 % Test  if a function throws an error or warning message
assert(verifyCobraFunctionError('KLDis','inputs', {P, Q'},'testMessage', 'Input2 has the wrong dimension'));

% run the function 
KLD=KLDis(P,Q);

% compare the scaled matrix against the reference data
assert(isequal(KLD, KLDis_1))

% change the directory
cd(currentDir)
