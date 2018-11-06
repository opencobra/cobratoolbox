% The COBRA Toolbox: testconc2Rate
%
% Purpose:
%     - test conc2Rate function
%
% Authors:
%     Loic Marx, November 2018
%     
%
   

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testconc2Rate'));
cd(fileDir);

%calculate inputs
metConc = [1 2]
cellConc = 2
t = 3
cellWeight = 8


% calculate reference value

v_ref = [2.0833e-05, 4.1667e-05];

% v_ref = [1.0e-04 * 0.2083 , 1.0e-04 * 0.4167];
% Comparison to ref value
calculate_conc2Rate = conc2Rate(metConc, cellConc, t, cellWeight)
assert(isequal(calculate_conc2Rate, v_ref))

% change the directory
cd(currentDir)