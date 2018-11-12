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
 
% Nargin <2
% if nargin <2: 
%      error('Not enough input arguments');
% end

