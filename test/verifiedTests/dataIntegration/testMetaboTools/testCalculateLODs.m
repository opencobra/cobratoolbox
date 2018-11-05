% The COBRA Toolbox: testcalculateLODs
%
% Purpose:
%     - tests the calculateLODs function
%
% Authors:
%     Loic Marx, November 2018
%     
%
   

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testcalculateLODs'));
cd(fileDir);

% calculate reference value
theo_mass = (10: - 1:1);
lod_gL = 1;

v_ref = lod_gL ./theo_mass*1000;

%calculate inputs 
theo_mass = (10: - 1:1);
lod_ngmL = 1;

calculateLOD = calculateLODs(theo_mass,lod_ngmL)
% Comparison to ref value
 assert(isequal(calculateLOD, v_ref))


% change the directory
cd(currentDir)
