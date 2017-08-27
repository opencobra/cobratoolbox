% The COBRAToolbox: testGetDatabaseMappings.m
%
% Purpose:
%     - test the getDatabaseMappings function
%
% Authors:
%     - Jacek Wachowiak

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetDatabaseMappings'));
cd(fileDir);

% test variables
field = 'mets';
qualifiers = {};
refData_returnedmappings = cell(0, 5);

% function outputs
returnedmappings = getDatabaseMappings(field, qualifiers);

% test
assert(isequal(refData_returnedmappings, returnedmappings));

% change to old directory
cd(currentDir);
