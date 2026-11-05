% The COBRA Toolbox: testconc2Rate
%
% Purpose:
%     - test conc2Rate function
%
% Function under test:
%     src/dataIntegration/metabotools/conc2Rate.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Loic Marx, November 2018
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.


% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testConc2Rate'));
cd(fileDir);

% this test needs no solver, toolbox or particular operating system
prepareTest();

%define inputs
% less than 4 inputs ,  CellWeight = 500 * 1e-12 g
metConc = 1;
cellConc = 2;
t = 3;
cellWeight = 500 * 1e-12;

% calculate reference value
v_ref = 1/3 * 1e6;

% compare to the reference value
calculate_conc2Rate = conc2Rate(1,2,3,500*1e-12);
tol = 1e-4;
assert(norm(calculate_conc2Rate - v_ref) < tol);

% less than 3 inputs, CellWeight = 500 * 1e-12 g and the doubling time T = 24
metConc = 1;
cellConc = 2;
cellWeight = 500 * 1e-12;
t = 24;

% calcule the reference value
v_ref_2 = 4.166666666666666e+04;

% compare to the reference value
calculate_conc2Rate_2 = conc2Rate(1,2,24,500 * 1e-12);
assert(norm(calculate_conc2Rate_2 - v_ref_2) < tol);

%% the cell weight defaults to 500 pg
assert(norm(conc2Rate(1, 2, 3) - v_ref) < tol);

%% the time defaults to the doubling time of 24 hours
assert(norm(conc2Rate(1, 2) - v_ref_2) < tol);

%% the flux scales with the concentration change and inversely with the cell concentration
assert(norm(conc2Rate(4, 2, 24) - 4 * v_ref_2) < 4 * tol);
assert(norm(conc2Rate(1, 4, 24) - v_ref_2 / 2) < tol);

% change the directory
cd(currentDir)
