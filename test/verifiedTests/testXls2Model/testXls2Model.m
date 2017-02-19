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

% define the path to The COBRAToolbox
pth = which('initCobraToolbox.m');
CBTDIR = pth(1:end-(length('initCobraToolbox.m') + 1));

% remove the generated file
cd([CBTDIR, filesep, 'test', filesep, 'verifiedTests', filesep, 'testXls2Model']);

% convert the model
model = xls2model('cobra_import_toy_model.xlsx');

% test the number of reactions
assert(length(model.rxns) == 8)

% test the number of metabolites
assert(length(model.mets) == 5)

% test the number of fields in the model structure
assert(length(fields(model)) == 27)

% change the directory
cd(CBTDIR)
