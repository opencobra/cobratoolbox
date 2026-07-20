function configCMatrix()
% Add the CMatrix helper folders (parent config and include) to the path
%
% USAGE:
%
%    configCMatrix()
%

path = fileparts(mfilename('fullpath'));
addpath(fullfile(path, '..'));
config;

addpath(fullfile(path, 'include'));