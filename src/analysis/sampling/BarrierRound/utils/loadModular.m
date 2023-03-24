function loadModular(name)
path = fileparts(mfilename('fullpath'));
addpath(fullfile(path, '..', name));
f = str2func(['config' name]);
f();