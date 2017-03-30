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
initTest(fileparts(which(mfilename)));

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
lrsInputHalfspace([], [], filename);
runLrs(filename, positivity, inequality);

lrsInputHalfspace(S, [], filename);
runLrs(filename, positivity, inequality);

positivity = 0;
lrsInputHalfspace(S, [], filename, positivity);
runLrs(filename, positivity, inequality);

try
    lrsInputHalfspace(S, [], filename, positivity, inequality, [], [], [], sh);
catch ME
    assert(length(ME.message) > 0)
end

% produce a bash script and run it
sh = 1;
lrsInputHalfspace(S, [], filename, positivity, inequality, zeros(size(S, 1), 1), [], [], sh);
runLrsBash(filename, positivity, inequality);

% delete generated files
delete('*.ine');
delete('*.ext');
delete('*.sh');
delete('*.time');

% change the directory
cd(currentDir)
