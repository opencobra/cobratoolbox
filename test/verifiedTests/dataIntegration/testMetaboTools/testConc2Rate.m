% The COBRA Toolbox: testconc2Rate
%
% Purpose:
%     - test conc2Rate function
%
% Authors:
%     - Loic Marx, November 2018
%
%


% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testconc2Rate'));
cd(fileDir);

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

% change the directory
cd(currentDir)
