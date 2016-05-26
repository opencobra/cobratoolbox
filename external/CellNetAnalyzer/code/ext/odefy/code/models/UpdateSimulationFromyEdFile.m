% UPDATESIMULATIONFROMYEDFILE 
%
%   NEW_SIMSTRUCT UPDATESIMULATIONFROMYEDFILE(OLD_SIMSTRUCT,FILENAME)
%   Creates an Odefy model from the yEd graphml file in FILENAME and
%   generates a a new simulation structure NEW_SIMSTRUCT while preserving 
%   the old parameter values from OLD_SIMSTRUCT

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%
function new_simstruct = UpdateSimulationFromyEdFile(old_simstruct, filename)
    % Create new model and simstruct for file
    new_model = yEdToOdefy(filename);
    new_simstruct = CreateSimstruct(new_model);
    
    new_simstruct = UpdateSimstruct(old_simstruct, new_simstruct);
end