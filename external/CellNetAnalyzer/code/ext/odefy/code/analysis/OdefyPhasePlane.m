% ODEFYPHASEPLANE  Draw a 2D phase plane of a converted Odefy model
%
%   ODEFYPHASEPLANE(SIMSTRUCT,V1,V1RANGE,V2,V2RANGE,[param1, value1,...])
%   draws a two-dimensional phase plane of an ODE system with respect to
%   two given variables and initial value ranges. SIMSTRUCT defines the
%   simulation parameters, V1 is the index of the first species to be
%   varied and V1RANGE is the range over which th initial values of that
%   species are varied. V2 and V2RANGE have an analogous meaning.
%
%   For the remaining optional parameters please refer to the help of the
%   PhasePlane function.
%
%   See also: PhasePlane, CreateSimStruct

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%
function OdefyPhasePlane( simstruct, v1, v1range, v2, v2range, varargin )

if IsOdefyModel(simstruct)
    fprintf('Warning: You provided an Odefy model instead of a simulation structure, using default values.\nSee also: CreateSimstruct\n');
end
simstruct = CreateSimstruct(simstruct);

if ValidateType(simstruct.type)>3
    error('Cannot draw phase planes of Boolean simulations.');
end

% generate temporary file
tmpfull = [tempname() '.m'];
[tmppath, tmpname, tmpext, tmpversn] = fileparts(tmpfull);
% go to that temp directory
lwd = pwd;
eval(['cd ' tmppath]);


% create actual model
SaveMatlabODE(simstruct.model, tmpfull, simstruct.type);
rehash;

% parameters
simparams = ParameterVector(simstruct);

cmd = sprintf('fun = @(t,y)%s(t, y, simparams);', tmpname);
eval(cmd);

if (ischar(v1))
    % Get index of species
    v1 = GetSpeciesIndexFromName(v1, simstruct.model.species);
end
if (ischar(v2))
    % Get index of species
    v2 = GetSpeciesIndexFromName(v2, simstruct.model.species);
end

PhasePlane(fun, numel(simstruct.model.species), ...
    v1, v1range, v2, v2range, varargin{:});

xlabel(simstruct.model.species(v1));
ylabel(simstruct.model.species(v2));

eval(['cd ' lwd]);
end
