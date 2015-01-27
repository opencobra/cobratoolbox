% Model selection of the mid-hindbrain boundary
% Example code from the Odefy paper

% Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
% Free for non-commerical use, for more information: see LICENSE.txt
% http://cmb.helmholtz-muenchen.de/odefy

mhbsettings;
for i=1:numel(models)
    single = ExpressionsToOdefy(models{i});
    simstruct.model = MultiModel(single, [3 4], 6);
    simstruct.params = DefaultParameters(simstruct.model);
    simstruct.init = knownstate;
    [t,y] = OdefySimulation(simstruct, 0);
    if all(y(end,:)>0.5 == knownstate)
        fprintf('Valid: Model %d\n', i);
    end
end






