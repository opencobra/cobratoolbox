function [serverResponse] = buildFluxDistLayout( minerva, model, solution, identifier, rxnList, hexColour, thickness)
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
%    rxnList:           cell array of reaction abbreviations to colour
%    hexColour          colour of overlay (hex color format)
%                       e.g. '#009933' corresponds to http://www.color-hex.com/color/009933
%    thickness:         maximum thickness
%
% OUTPUT:
%    serverResponse:          Response of the MINERVA
%
% .. Author: - Alberto Noronha Jan/2016

if exist('rxnList','var')
    if ~isempty(rxnList)
        dicFlag=1;
    else
        dicFlag = 0;
    end
else
    dicFlag = 0;
end

if exist('thickness', 'var') || nargin < 7
    thickness = 10;
end

if exist('hexColour','var')
    defaultColor = hexColour;
else
    defaultColor = '#009933';
end

%nRxn=length(solution.v);
%normalizedFluxes = min(ones(nRxn,1),normalizeFluxes(abs(solution.v))-8);
normalizedFluxes = normalizeFluxes(abs(solution.v), thickness);
content = 'name\treactionIdentifier\tlineWidth\tcolor\n';
for i=1:length(solution.v)

    %get reaction
    if dicFlag == 1
        index = strcmp(model.rxns{i}, rxnList(:,1));
        mapReactionId = rxnList(index,2);
    else
        mapReactionId = model.rxns{i};
    end

    if solution.v(i) ~= 0
        line = strcat('\t', mapReactionId, '\t', num2str(normalizedFluxes(i)), '\t', defaultColor, '\n');
        content = strcat(content, line);
    end
end

%   get all the parameters
login = minerva.login;
password = minerva.password;
map = minerva.map;
%     have to turn it into string
%     disp(content);
content = sprintf(content);
serverResponse = postMINERVArequest(minerva_servlet, login, password, map, identifier, content);
end

%% Normalize a flux into a range of 1 to 10
function [ normalized_value ] = normalizeFluxes(fluxDistribution, thickness)

    if exist('thickness','var') || nargin < 2
        thickness = 10;
    end

    m = min(fluxDistribution);
    range = max(fluxDistribution) - m;
    fluxDistribution = (fluxDistribution - m) / range;
    range2 = - thickness;
    normalized_value = (fluxDistribution*range2) + thickness;

end
