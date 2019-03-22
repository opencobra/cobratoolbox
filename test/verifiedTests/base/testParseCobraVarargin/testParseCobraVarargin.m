% The COBRAToolbox: testParseCobraVarargin.m
%
% Purpose:
%     - testParseCobraVarargin tests the ability of parseCobraVarargin to
%     return the correct function, cobra and solver parameters given
%     different supported input formats
%
% Authors:
%     - Original file: Joshua Chan 03/22/19
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFVA'));
cd(fileDir);



% change the directory
cd(currentDir)