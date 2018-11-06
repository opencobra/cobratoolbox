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
theo_mass = [1, 2];
v_ref = 1e-3 * [1; 0.5];

%calculate inputs
lod_ngmL = 1;

calculateLOD = calculateLODs(theo_mass,lod_ngmL);
% Comparison to ref value

assert(isequal(calculateLOD, v_ref))
% throwing an error if the dimensions are not equal
lod_ngmL_unequal = [1, 2, 3];

assert(verifyCobraFunctionError('calculateLODs', 'inputs', {theo_mass,lod_ngmL_unequal'}, 'testMessage', 'both inputs do not have the same size'));
% Testing the case where lod_ngmL is a vector of the same size as theo_mass

lod_ngmL_vector = [1, 2];
v_ref_vector = 1e-3 * [1; 1];
% Comparison to the ref value
calculateLOD_vector = calculateLODs(theo_mass,lod_ngmL_vector);
assert(isequal(calculateLOD_vector, v_ref_vector));
% change the directory
cd(currentDir)
