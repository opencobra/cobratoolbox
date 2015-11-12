% SETINITIALVALUE  Set initial value in simulation structure or parameter
% matrix.
%
%  CHANGED=SETINITIALVALUE(SIMSTRUCT,SPECIES,VALUE) edits the simulation 
%  structure SIMSTRUCT by setting the initial value of SPECIES to VALUE.
%
%  CHANGED=SETINITIALVALUE(INIT,MODEL,SPECIES,VALUE) operates directly on a
%  vector of initial values INIT. MODEL has to be specified in order to map
%  the species names correctly.

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%
function r = SetInitialValue( varargin )

if nargin==3
    simstruct=varargin{1};
    species=varargin{2};
    val=varargin{3};
    if (~IsSimulationStructure(simstruct))
        error('First parameter must be a simulation structure');
    end
    model=simstruct.model;
    initial=simstruct.initial;
elseif nargin==4
    initial=varargin{1};
    model=varargin{2};
    species=varargin{3};
    val=varargin{4};
    if (~IsOdefyModel(model))
        error('Second parameter must be an Odefy model');
    end
else
    error('Functions takes 3 or 4 input arguments');
end

% Check if species is in the model
if (~ismember(species, model.species))
    error('Species %s is not part of the model', species);
end

if (~isscalar(val))
    error('val must be a number');
end

% Get index of species
species_index = GetSpeciesIndexFromName(species, model.species);

initial(species_index) = val;

if nargin==3
    % simstruct out
    r=simstruct;
    r.initial=initial;
else
    % matrix out
    r=initial;
end

end
