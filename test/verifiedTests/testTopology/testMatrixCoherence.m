% The COBRAToolbox: testMatrixCoherence.m
%
% Purpose:
%     - testMatriceCoherence tests the functionality of matrixCoherence.
%
% Authors:
%     - Sylvain Arreckx March 2017
%
% Exemple comes from http://stemblab.github.io/mutual-coherence/

% save the current path
currentDir = pwd;

% initialize the test
initTest(fileparts(which(mfilename)));

A = [1, -1, 1;
     1,  2, 4];

[mu, Q] = matrixCoherence(A);

assert(abs(mu - 0.8575) < 1e-5);

cd(currentDir)
