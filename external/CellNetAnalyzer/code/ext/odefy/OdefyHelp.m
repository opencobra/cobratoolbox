% ODEFYHELP  Display Odefy help file in webbrowser or, if no webbrowser is 
% available, show the path to the main HTML help file.

% Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
% Free for non-commerical use, for more information: see LICENSE.txt
% http://cmb.helmholtz-muenchen.de/odefy

function OdefyHelp

% find help file
scriptpath = fileparts(which('OdefyHelp.m'));
helpfile = fullfile(scriptpath,'doc/index.html');

if exist(helpfile)
    if IsMatlab && exist('web')
        web(helpfile);
    else
        fprintf('\nOpen the Odefy help in your webbrowser:\n%s\n\n',helpfile);
    end
else
    error('Could not find help file in %s',helpfile);
end

