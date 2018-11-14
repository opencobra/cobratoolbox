% The COBRA Toolbox: testexportSetToGAMS
%
% Purpose:
%     - test exportSetToGAMS function
%
% Authors:
%     - Loic Marx, November 2018
%
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testexportSetToGAMS'));
cd(fileDir);

% If nargin = 2 : 
model = getDistributedModel('ecoli_core_model.mat');
fileName = 'refData_reactions.txt';

% read in the file
rxnsRef = textread(fileName, '%s', 'delimiter', '\n');

% test if the first and end cells are equal to /
assert(isequal(rxnsRef{1}, '/'))
assert(isequal(rxnsRef{end}, '/'))

% test if all the other cells correspond to the reaction names
for k=2:length(model.rxns)-1
    assert(isequal(cellstr(rxnsRef{k}(2:end-1)), model.rxns(k-1)));
end

 
 % If nargin >2 
 
%assert(verifyCobraFunctionError('testexportSetToGAMS', 'inputs', {model.rxns, fileName}, 'testMessage', 'The number of elements in the input vectors do not match. They have to be either the same size, or lod_ngmL has to be a single value which is used for all elements'));



