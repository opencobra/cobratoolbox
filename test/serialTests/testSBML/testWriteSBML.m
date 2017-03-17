% The COBRAToolbox: testWriteSBML.m
%
% Purpose:
%     - read in a model from a .xml file, write it as a .sbml file,
%       read it back in and assess any differences
%
% Authors:
%     - Partial original file: Joseph Kang 04/07/09
%     - CI integration: Laurent Heirendt

% save the current path
currentDir = pwd;

% initialize the test
initTest(fileparts(which(mfilename)));

testModelXML = readCbModel('Ec_iJR904.xml');

% write the model as a .sbml file
writeCbModel(testModelXML, 'sbml', 'testModelSBML.sbml');

% read the model from the newly written .sbml file
testModelSBML = readCbModel('testModelSBML.sbml');

% check whether both models are the same
[isSame numDiff fieldNames] = isSameCobraModel(testModelXML, testModelSBML);

% assess any potential differences
assert(~any(numDiff))

% remove the written file to clean up
cd(fileparts(which(mfilename)))
system('rm testModelSBML.sbml.xml')

% change the directory
cd(currentDir)
