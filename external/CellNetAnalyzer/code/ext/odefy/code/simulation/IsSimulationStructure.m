% ISSIMULATIONSTRUCTURE  Determines whether a variable is a valid
% simulation structure.
%
%  R=ISSIMULATIONSTRUCTURE(VALUE)  returns true if VALUE is a valid
%  simulation structure.

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%
function r=IsSimulationStructure(value)
    r = ( isfield(value,'model') );
end