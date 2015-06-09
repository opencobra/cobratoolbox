% SAVEMODELMAT  Saves a model or simulation structure as a MATLAB MAT file
%
%   SAVEMODELMAT(TOSAVE,FILE) savs the Odefy model or simulation structure
%   TOSAVE into FILE. A variable 'odefystruct' will be used for storing
%   the model.

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%
function SaveModelMAT(tosave, file)

if ~IsSimulationStructure(tosave) && ~IsOdefyModel(tosave)
    error('Input argument is neither an Odefy model nor a valid simulation structure');
end

odefystruct = tosave;
save(file,'odefystruct');