function [serverResponse] = buildFluxDistLayout( minerva, model, solution, identifier, hexColour, thickness)
% Builds a layout for MINERVA from a flux distribution. If a dictionary
% of identifiers is not provided it is assumed that the map and the COBRA
% model's nomenclature is coherent. Sends the layout to the remote MINERVA
% instance
%
% USAGE:
%
%    [serverResponse] = buildFluxDistLayout( minerva, model, solution, identifier, rxnList)
%
% INPUTS:
%    minerva:           Struct with the information of minerva instance:
%                       address, login, password and model (map)
%    model:             COBRA model structure
%    solution.v:        optimizeCb solution structure with a flux vector
%    identifier:        Name for the layout in MINERVA
%
% OPTIONAL INPUT:
%    hexColour          colour of overlay (hex color format)
%                       e.g. '#009933' corresponds to http://www.color-hex.com/color/009933
%    thickness:         maximum thickness
%
% OUTPUT:
%    serverResponse:          Response of the MINERVA
%
% .. Author: - Alberto Noronha Jan/2016

if exist('thickness', 'var') || nargin < 7
    thickness = 10;
end

if exist('hexColour','var')
    defaultColor = hexColour;
else
    defaultColor = '#57c657';
end

%nRxn=length(solution.v);
%normalizedFluxes = min(ones(nRxn,1),normalizeFluxes(abs(solution.v))-8);
normalizedFluxes = normalizeFluxes(abs(solution.v), thickness);
content = 'name%09reactionIdentifier%09lineWidth%09color%0D';
for i=1:length(solution.v)
    mapReactionId = model.rxns{i};

    % if not ReconMap 2.01 use new reaction notation   
    if ~strcmp(minerva.map, 'ReconMap-2.01')
        mapReactionId = strcat('r_', mapReactionId);
    end
    

    if solution.v(i) ~= 0
        line = strcat('%09', mapReactionId, '%09', num2str(normalizedFluxes(i)), '%09', defaultColor, '%0D');
        content = strcat(content, line);
    end
end

%   get all the parameters
login = minerva.login;
password = minerva.password;
googleLicenseContent = minerva.googleLicenseConsent;
map = minerva.map;
%     have to turn it into string
%     disp(content);
% content = sprintf(content);
serverResponse = postMINERVArequest(login, password, map, googleLicenseContent, identifier, content);
end

%% Normalize a flux into a range of 1 to 10
function [ normalized_value ] = normalizeFluxes(fluxDistribution, thickness)

    if exist('thickness','var') || nargin < 2
        thickness = 8;
    end

    m = min(fluxDistribution);
    range = max(fluxDistribution) - m;
    fluxDistribution = (fluxDistribution - m) / range;
    range2 = - thickness;
    normalized_value = (fluxDistribution*range2) + thickness;

end
