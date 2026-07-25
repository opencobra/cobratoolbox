function configPolytopeSimplifier()
% Configure the MATLAB path for the PolytopeSimplifier and load its CMatrix modules
%
% USAGE:
%
%    configPolytopeSimplifier()
%

path = fileparts(mfilename('fullpath'));
addpath(fullfile(path, '..'));
config;

loadModular('CMatrix');