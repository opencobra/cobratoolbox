% The COBRAToolbox: testWriteSBML.m
%
% Purpose:
%     - read in a model from a .xml file, write it as a .sbml file,
%       read it back in and assess any differences
%
% Authors:
%     - Partial original file: Joseph Kang 04/07/09
%     - CI integration: Laurent Heirendt

% read in the .xml model first
testModelXML = readCbModel('Ec_iJR904.xml');

% write the model as a .sbml file
writeCbModel(testModelXML, 'sbml', 'testModelSBML.sbml');

% read the model from the newly written .sbml file
testModelSBML = readCbModel('testModelSBML.sbml');

% check whether both models are the same
[isSame numDiff fieldNames] = isSameCobraModel(testModelXML, testModelSBML);

% assess any potential differences
assert(any(numDiff))

% remove the written file to clean up
pth = which('initCobraToolbox.m');
cd(pth(1:end-(length('initCobraToolbox.m')+1)));
cd('./test/models')
system('rm testModelSBML.sbml')
