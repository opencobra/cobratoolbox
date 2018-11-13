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
model = load('ecoli_core_model.mat');
set = model.model.rxns; 
fileName = 'Reactions.txt';

exportSetToGAMS(model.model.rxns, 'Reactions.txt');
exportSetToGAMS(model.model.rxns, 'Reactions.m')


% TextFolder = dlmread('Reactions.txt');  
% save('Reactions.mat','TextFolder');

v_ref = model.model.rxns
 assert(isequal(value - v_ref))
 
 % If nargin >2 
 
assert(verifyCobraFunctionError('testexportSetToGAMS', 'inputs', {model.model.rxns,fileName'}, 'testMessage', 'The number of elements in the input vectors do not match. They have to be either the same size, or lod_ngmL has to be a single value which is used for all elements'));

% Nargin <2
% if nargin <2: 
%      error('Not enough input arguments');
% end

