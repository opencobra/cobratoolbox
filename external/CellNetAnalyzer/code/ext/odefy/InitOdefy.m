% INITODEFY
%
%   Odefy initialization script. Run this command prior to using the Odefy
%   toolbox.

% Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
% Free for non-commerical use, for more information: see LICENSE.txt
% http://cmb.helmholtz-muenchen.de/odefy

% generate odefy codepath
odefypath = fileparts(which('InitOdefy.m'));

if (strcmp(odefypath, '.'))
	odefypath = pwd;
end

codepath = fullfile(odefypath, 'code');

% add to path
addpath(genpath(codepath));
addpath(odefypath);
%savepath;

if IsMatlab
    javapath = fullfile(odefypath, 'JavaGUI', 'bin');
    javaaddpath(javapath,'-end');
end

fprintf('\nOdefy initialized\n');
% display help information
scriptpath = fileparts(which('OdefyHelp.m'));
helpfile = fullfile(scriptpath,'doc/index.html');
fprintf('For detailed usage instructions type ''OdefyHelp''\n');
fprintf('or open %s in your webbrowser.\n\n',helpfile);

