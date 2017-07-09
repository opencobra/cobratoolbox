% The COBRAToolbox: testGenerateSystemConfigReport.m
%
% Purpose:
%     - tests the generateSystemConfigReport functionality
%

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGenerateSystemConfigReport'));
cd(fileDir);

generateSystemConfigReport;

delete([CBTDIR filesep 'COBRAconfigReport.log']);

% change the directory
cd(currentDir)
