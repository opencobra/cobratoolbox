% ISODEFYMODEL  Determines whether a variable is a valid Odefy model.
%
%   R=ISODEFYMODEL(VAR) determines if VAR contains a valid Odefy model.

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%
function r=IsOdefyModel(value)
    if (isfield(value,'tables') && isfield(value, 'species') && ...
            isfield(value.tables,'truth') && isfield(value.tables,'inspecies'))
        r = 1;
    else
        r = 0;
    end
end