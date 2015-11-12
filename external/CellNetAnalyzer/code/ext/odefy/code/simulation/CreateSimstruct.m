% CREATESIMSTRUCT  Create simulation structure.
%
%   SIMSTRUCT=CREATESIMSTRUCT(INPUT)  Creates a simulation structure from
%   INPUT. INPUT can be an Odefy model, a simulation structure itsself (not
%   causing any changes) or a yEd graph file.
% 
%   Default values for the simulation structure:
%
%     field 'timeto':  10
%     field 'type':    hillcube
%     initial values:  all 0
%     parameter tau:   1
%     parameter n:     3
%     parameter k:     0.5

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%
function simstruct = CreateSimstruct(input)
    if (ischar(input))
        simstruct = [];
        simstruct.model = yEdToOdefy(input);
    elseif (IsOdefyModel(input))
        simstruct = [];
        simstruct.model = input;
    elseif (IsSimulationStructure(input))
        simstruct = input;
    else
        error('input must be an Odefy model or the path to a yEd GraphML file');
    end

    % default values
    defTau = 1;
    defN = 3;
    defK = 0.5;
    defTime = 10;

    % check for timeto
    if (~isfield(simstruct, 'timeto'))
        simstruct.timeto = defTime;
    end
    % check for hillmatrix
    if (~isfield(simstruct, 'params'))
        simstruct.params = DefaultParameters(simstruct.model,defTau,defN,defK);
    end
    % check for initial
    if (~isfield(simstruct, 'initial'))
        simstruct.initial = zeros(numel(simstruct.model.species),1);
    end
  
    % check for modelname
    if (~isfield(simstruct, 'modelname'))
        simstruct.modelname = simstruct.model.name;
    end
    % check for type
    if (~isfield(simstruct, 'type'))
        simstruct.type = 'hillcube';
    end
    
end