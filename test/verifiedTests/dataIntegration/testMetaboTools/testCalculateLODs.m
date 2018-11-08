% The COBRA Toolbox: testcalculateLODs
%
% Purpose:
%     - tests the calculateLODs function
%
% Author: - Loic Marx, November 2018
%    
  
% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testcalculateLODs'));
cd(fileDir);

% define the inputs
lod_ngmL = 1;
theo_mass = [1, 2];

% calculate the reference value
v_ref = 1e-3 * [1; 0.5];

% calculate the actual value by using the function
calculateLOD = calculateLODs(theo_mass,lod_ngmL);

% compare the calculated value and the reference value
assert(isequal(calculateLOD, v_ref))

% throw an error if the dimensions of both inputs are not equal
lod_ngmL_unequal = [1, 2, 3];
assert(verifyCobraFunctionError('calculateLODs', 'inputs', {theo_mass,lod_ngmL_unequal'}, 'testMessage', 'The number of elements in the input vectors do not match. They have to be either the same size, or lod_ngmL has to be a single value which is used for all elements'));

% lod_ngmL and theo_mass are two vectors of the same size
lod_ngmL_vector = [1, 2];
v_ref_vector = 1e-3 * [1; 1];

% compare the values calculated when the inputs have the same size and the reference value
calculateLOD_vector = calculateLODs(theo_mass,lod_ngmL_vector);
assert(isequal(calculateLOD_vector, v_ref_vector));

% change the directory
cd(currentDir)
