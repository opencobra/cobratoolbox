function configPolytopeSimplifier()
path = fileparts(mfilename('fullpath'));
addpath(fullfile(path, '..'));
config;

loadModular('CMatrix');