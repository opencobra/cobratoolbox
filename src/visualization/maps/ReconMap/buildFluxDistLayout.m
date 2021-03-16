function [serverResponse] = buildFluxDistLayout( minerva, model, solution, identifier, hexColour, thickness, content)
% Builds a layout for MINERVA from a flux distribution. If a dictionary
% of identifiers is not provided it is assumed that the map and the COBRA
% model's nomenclature is coherent. Sends the layout to the remote MINERVA
% instance
%
% USAGE:
%
%    [serverResponse] = buildFluxDistLayout( minerva, model, solution, identifier, hexColour, thickness, content)
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
%    normalizedFluxesOption:     if 'true' (default) then fluxes will be
%                       normalized, otw they will be displayed as is
%    content:           character array with the following format for each
%                       reaction to be displayed. Bypasses the use of solution.v to set the format. 
%                       'name%09reactionIdentifier%09lineWidth%09color%0D'
%
% OUTPUT:
%    serverResponse:          Response of the MINERVA
%
% .. Author: - Alberto Noronha Jan/2016
%            - Ines Thiele April/2020, fixed issue with using ReconMap-3 as target map.

if ~exist('thickness', 'var')
    thickness = 10;
end

if exist('hexColour','var')
    defaultColor = hexColour;
else
    defaultColor = '#57c657';
end

%nRxn=length(solution.v);
%normalizedFluxes = min(ones(nRxn,1),normalizeFluxes(abs(solution.v))-8);

% build input data for minerva
if ~exist('content','var')
    normalizedFluxes = normalizeFluxes(abs(solution.v), thickness);
    content = 'name%09reactionIdentifier%09lineWidth%09color%0D';
    for i=1:length(solution.v)
        mapReactionId = model.rxns{i};
        
        % if not ReconMap 2.01 use new reaction notation
        if ~strcmp(minerva.map, 'ReconMap-2.01')
            mapReactionId = strcat('R_', mapReactionId);
        end
        
        if solution.v(i) ~= 0
            line = strcat('%09', mapReactionId, '%09', num2str(normalizedFluxes(i)), '%09', defaultColor, '%0D');
            content = strcat(content, line);
        end
        
        if contains(mapReactionId,'%') || contains(mapReactionId,' ')
            error('ReactionID cannot contain delimiting characters, such as: %')
        end
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
if isempty(serverResponse)
    warning('Minerva server did not respond')
end

%end of function
end

%% Normalize a flux into a range of 1 to 10
function [ normalized_value ] = normalizeFluxes(fluxDistribution, thickness)

if ~exist('thickness','var') || nargin < 2
    thickness = 8;
end

m = min(fluxDistribution);
range = max(fluxDistribution) - m;
fluxDistribution = (fluxDistribution - m) / range;
range2 = - thickness;
normalized_value = (fluxDistribution*range2) + thickness;

end
