% The COBRAToolbox: testXls2Model.m
%
% Purpose:
%     - tests the functionality of the xls2model function
%   	- check whether the toy model xlsx file can be loaded without error
%        if not: fail test
%
% Note:
%		    The addReaction function will produce output in one of its last lines.
%		    can not be helped since this is a useful functionality outside of testing
%
% Authors:
%     - CI integration: Laurent Heirendt

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testXls2Model'));
cd(fileDir);

% convert the model
model = xls2model('cobra_import_toy_model.xlsx');

% test the number of reactions
assert(length(model.rxns) == 8)

% test the number of metabolites
assert(length(model.mets) == 5)

% test the number of fields in the model structure
assert(length(fields(model)) == 27)

% change the directory
cd(currentDir)
