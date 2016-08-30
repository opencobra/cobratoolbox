% PARASBIGTOSMALL
%
%   Odefy-internal function

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%
function smallparas = ParasBigToSmall(bigmodel, smallmodel, bigparas)

% iterate over species
for i=1:numel(bigmodel.species)
    % copy tau
    smallparas(i,1) = bigparas(i,1);
	numin = numel(smallmodel.tables(i).inspecies);
    
    if (numin > 0)
        % iterate over input species of smaller model
        for j=1:numin
            in = smallmodel.tables(i).inspecies(j);
            index = find(bigmodel.tables(i).inspecies == in);
            smallparas(i,j*2) = bigparas(i,index*2);
            smallparas(i,j*2+1) = bigparas(i,index*2+1);
        end
    else
        % no input species, copy the 2 parameters
        smallparas(i,2) = bigparas(i,2);
        smallparas(i,3) = bigparas(i,3);
    end
 %   'next'

end