% The COBRA Toolbox: testcalculateLODs
%
% Purpose:
%     - tests the calculateLODs function
%
% Authors:
%     Loic Marx, November 2018
%     
%
   

% Save the current path
currentDir = pwd;

% Initialize the test
fileDir = fileparts(which('testcalculateLODs'));

cd(fileDir);

% Defining the inputs
lod_ngmL = 1;

theo_mass = [1, 2];

% Calculate the reference value

v_ref = 1e-3 * [1; 0.5];

% Calculate the actual value by using the function

calculateLOD = calculateLODs(theo_mass,lod_ngmL);

% Comparison between calculate value and ref value

assert(isequal(calculateLOD, v_ref))

% Throwing an error if the dimensions of both inputs are not equal
lod_ngmL_unequal = [1, 2, 3];

assert(verifyCobraFunctionError('calculateLODs', 'inputs', {theo_mass,lod_ngmL_unequal'}, 'testMessage', 'The number of elements in the input vectors do not match. They have to be either the same size, or lod_ngmL has to be a single value which is used for all elements'));

% If both inputs are two vectors of the same size
lod_ngmL_vector = [1, 2];

v_ref_vector = 1e-3 * [1; 1];

% Comparison between the values calculated when the inputs have the same size and the reference value
calculateLOD_vector = calculateLODs(theo_mass,lod_ngmL_vector);

assert(isequal(calculateLOD_vector, v_ref_vector));

% Change the directory
cd(currentDir)
