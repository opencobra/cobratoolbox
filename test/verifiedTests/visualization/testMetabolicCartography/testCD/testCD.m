% The COBRAToolbox: testCD.m
%
% Purpose:
%     - testCD tests the functionality of transformXML2Map function.
%
% Authors:
%     - Original file: Ronan Fleming 03/11/2020
%     - Modified: Farid Zare         03/06/2025
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCD'));
cd(fileDir);

% Initialise the test
fprintf('   Testing transformXML2Map ... ')

%test to see if io of cell designer maps is lossless
[GlyXml, GlyMap] = transformXML2Map('glycolysisAndTCA.xml');

transformMap2XML(GlyXml,GlyMap,'glycolysisAndTCA_test.xml');

[GlyXml2, GlyMap2] = transformXML2Map('glycolysisAndTCA_test.xml');

%Compare xml structure
[resultXml, whyXml] = structeq(GlyXml, GlyXml2);

assert(resultXml==1)

%Compare map structure
[resultMap, whyMap] = structeq(GlyMap, GlyMap2);

assert(resultMap==1)

% output a success message
fprintf('Done.\n');

% change the directory
cd(currentDir)