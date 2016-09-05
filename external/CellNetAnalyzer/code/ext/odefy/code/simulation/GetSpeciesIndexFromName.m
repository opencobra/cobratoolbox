% GETSPECIESINDEXFROMNAME  Find index of species in list.
%
%    r=GETSPECIESINDEXFROMNAME(NAME,SPECIES)
%
%    Odefy-internal function
%

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%
function r=GetSpeciesIndexFromName(name, species)
    if (~ischar(name) && ~iscellstr(name))
        error('name must be a string or a cell array of strings');
    end
    if ~iscell(name)
        name = {name};
    end
    r = zeros(numel(name),1);
    for j=1:numel(name)
        ind = find(strcmp(species,name{j}));
        if numel(ind)
            r(j)=ind;
        else
            r(j)=0;
        end
    end
end