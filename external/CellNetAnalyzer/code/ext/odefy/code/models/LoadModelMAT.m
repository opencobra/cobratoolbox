% LOADMODELMAT  Load Odefy model or simulation structure from .mat file
%
%   OUT=LOADMODELMAT(FILE) loads a Odefy model or simulation structure
%   (automatically determined) from the variable 'odefystruct' in FILE

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%
function out=LoadModelMAT(file)

load(file);

if ~exist('odefystruct')
    error('MAT file does not contain variable odefystruct');
end

if ~IsSimulationStructure(odefystruct) && ~IsOdefyModel(odefystruct)
    error('Variable ''odefystruct'' from MAT file does not contain valid Odefy model or simulation structure');
end

out=odefystruct;