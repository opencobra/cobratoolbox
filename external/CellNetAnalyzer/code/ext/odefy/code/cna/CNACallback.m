% CNACALLBACK  Function called by the CellNetAnalyzer when the user clicks an Odefy menu
% item. 
%
%   CNACALLBACK(VARNAME,SIMULATE). VARNAME is the name of the
%   CellNetAnalyzer variable, SIMULATE is set to 1 for simulation and to 0
%   for exporting.

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%
function CNACallback(varname, simulate)

if ~IsMatlab
    error('No CNA support in Octave');
end

% get actual model from workspace and convert to Odefy
cnastruct = evalin('base', varname);
model = CNAToOdefy(cnastruct);

if (simulate == 1)

 
% show dialog
Simulate(model, cnastruct);

elseif (simulate == 2)
    % save to workspace
    varname = inputdlg('Please enter a name for the new workspace variable:');
    if (numel(varname) > 0)
        % store it
        assignin('base', varname{1}, model);
        msgbox('Successfully stored model in workspace.');
    end
else
    % export
    Export(model);
end