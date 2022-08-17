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

%Compare with a second equivalent model, that does not have the cytosol
%localisation. 
model2 = xls2model('cobra_import_toy_model_2.xlsx');

assert(isequal(printRxnFormula(model2,model2.rxns),printRxnFormula(model,model2.rxns)));

% change the directory
cd(currentDir)
