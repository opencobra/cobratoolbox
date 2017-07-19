% The COBRAToolbox: testLrsInputHalfSpace.m
%
% Purpose:
%     - testLrsInputHalfSpace tests the functionality of lsrInputHalfspace.
%
% Authors:
%     - Sylvain Arreckx March 2017
%
% Test problem from
%     Extreme Pathway Lengths and Reaction Participation in Genome-Scale Metabolic Networks
%     Jason A. Papin, Nathan D. Price and Bernhard Ø. Palsson

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testLrsInputHalfSpace'));
cd(fileDir);

S = [-1,  0,  0,  0,  0,  0, 1,  0,  0;
      1, -2, -2,  0,  0,  0, 0,  0,  0;
      0,  1,  0,  0, -1, -1, 0,  0,  0;
      0,  0,  1, -1,  1,  0, 0,  0,  0;
      0,  0,  0,  1,  0,  1, 0, -1,  0;
      0,  1,  1,  0,  0,  0, 0,  0, -1;
      0,  0, -1,  1, -1,  0, 0,  0,  0];

% no linear objective
f = [];
positivity = 1;
inequality = 1;
filename = 'test';
shellScript = 0;
lrsInputHalfspace([], [], filename);
runLrs(filename, positivity, inequality, shellScript);

lrsInputHalfspace(S, [], filename);
runLrs(filename, positivity, inequality, shellScript);

lrsInputHalfspace(S, S, filename);
runLrs(filename, positivity, inequality, shellScript);

lrsInputHalfspace([], S, filename);
runLrs(filename, positivity, inequality, shellScript);

lrsInputHalfspace(S, [], filename, positivity, inequality, zeros(size(S, 1), 1), zeros(size(S, 2), 1), zeros(size(S, 2), 1));
runLrs(filename, positivity, inequality, shellScript);

positivity = 0;
lrsInputHalfspace([], [], filename, positivity);
runLrs(filename, positivity, inequality, shellScript);

lrsInputHalfspace(S, [], filename, positivity);
runLrs(filename, positivity, inequality, shellScript);

inequality = 0;
lrsInputHalfspace(S, [], filename, positivity, inequality);
runLrs(filename, positivity, inequality, shellScript);

lrsInputHalfspace([], [], filename, positivity, inequality);
runLrs(filename, positivity, inequality, shellScript);

lrsInputHalfspace(S, [], filename, positivity, inequality);
runLrs(filename, positivity, inequality, shellScript);

lrsInputHalfspace(S, S, filename, positivity, inequality);
runLrs(filename, positivity, inequality, shellScript);

lrsInputHalfspace([], S, filename, 1, inequality);
runLrs(filename, positivity, inequality, shellScript);

lrsInputHalfspace(S, S, filename, 1, inequality);
runLrs(filename, positivity, inequality, shellScript);

lrsInputHalfspace([], S, filename, positivity, inequality);
runLrs(filename, positivity, inequality, shellScript);

lrsInputHalfspace(S, [], filename, positivity, inequality, zeros(size(S, 1), 1), zeros(size(S, 2), 1), zeros(size(S, 2), 1));
runLrs(filename, positivity, inequality, shellScript);

try
    lrsInputHalfspace(S, [], filename, positivity, inequality, [], [], [], 0);
catch ME
    assert(length(ME.message) > 0)
end

% produce a bash script and run it
shellScript = 1;
lrsInputHalfspace(S, [], filename, positivity, inequality, zeros(size(S, 1), 1), [], [], shellScript);
runLrs(filename, positivity, inequality, shellScript);

% delete generated files
delete('*.ine');
delete('*.ext');
delete('*.sh');
delete('*.time');

% change the directory
cd(currentDir)
