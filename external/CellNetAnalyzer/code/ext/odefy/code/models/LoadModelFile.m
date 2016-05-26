% LOADMODELFILE  Load Odefy model or simulation structure from given file
%
%   OUT=LOADMODELFILE(FILE) loads an Odefy model or simulation structure
%   (only for .mat files) from a given FILE. Odefy will automatically
%   determine whether the file is
%
%   1. A MATLAB .mat file saved by the SaveModelMAT function
%   2. A text file containing Boolean equations 
%   3. An Odefy-compatible yEd graphml file
%   4. A GINsim GINML file
%
%   See also: LoadModelMAT, ExpressionsToOdefy, yEdToOdefy

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%
function out=LoadModelFile(file)

if ~exist(file)
    error('File does not exist');
end

% an XML file => yEd or GINsim
if IsXML(file)
    if IsGINML(file)
        out = GINsimToOdefy(file);
    else
        out = yEdToOdefy(file);
    end
    return;
end

% try loading as mat
try
    out=LoadModelMAT(file);
    return;
catch
end

% now try as boolean equations
try
    out=ExpressionsToOdefy(file);
    return;
catch
end

% if we got up to here Odefy could not load the model
error('There does not seem to be an Odefy model in this file');
