% The COBRAToolbox: testRank.m
%
% Purpose:
%     - tests the computation of the rank of a matrix using the LU solver termed
%
% Authors:
%     - LUSOL developed by Michael A. Saunders
%     - original test file: Ronan Fleming
%     - CI integration: Laurent Heirendt

global CBTDIR

prepareTest('needsUnix',true);

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRank'));
cd(fileDir);

% load the model
iAF1260 = getDistributedModel('iAF1260.mat');
A = iAF1260.S;
printLevel = 1;

% calculate the rank with minimum i/o arguments
rankA = getRankLUSOL(A);

% test the rank
assert(rankA == 1630);

for printLevel = 0:1
    % calculate the rank using LUSOL
    [rankA, p, q] = getRankLUSOL(A, printLevel);
    
    % test the rank
    assert(rankA == 1630);
    
    % compare the norms of the permutations vectors
    assert(abs(norm(p) - 3.934854424244942e+04) < 1e-6);
    assert(abs(norm(q) - 6.714114249102409e+04) < 1e-6);
end


% change the directory
cd(currentDir)
