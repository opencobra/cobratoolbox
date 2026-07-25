function loadModular(name)
% Add a sibling module folder to the path and run its `config<name>` script
%
% USAGE:
%
%    loadModular(name)
%
% INPUTS:
%    name:       char, name of the module to load (its folder is a sibling of this file)
%

path = fileparts(mfilename('fullpath'));
addpath(fullfile(path, '..', name));
f = str2func(['config' name]);
f();