% CNAINSTALL  Install Odefy as CellNetAnalyzer plugin 
%
%   CNAINSTALL(VAR) inserts Odefy into the CellNetAnalyszer menu of a
%   given, currently open project. VAR is the string name of a
%   CellNetAnalyzer network (char) or the network structure itself.

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%
function CNAInstall(var)

if ~IsMatlab
    error('No CNA support in Octave');
end

if nargin == 0
    error('Please specify a CNA network or its name as an argument');
end

if (isa(var, 'char'))
    model = evalin('base', var);
    varname = var;
else
    model = var;
    varname = model.net_var_name;
end

CNAaddMenuEntry(model, 'Odefy: Export', sprintf('CNACallback(''%s'', 0)',varname));
CNAaddMenuEntry(model, 'Odefy: Simulate', sprintf('CNACallback(''%s'', 1)',varname));
CNAaddMenuEntry(model, 'Odefy: Save model to workspace', sprintf('CNACallback(''%s'', 2)',varname));