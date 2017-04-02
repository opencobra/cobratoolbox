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

% define the tolerance
tol = 1e-5;

A = [1, -1, 1;
     1,  2, 4];

[mu, Q] = matrixCoherence(A);

assert(abs(mu - 0.8575) < tol);

cd(currentDir)
