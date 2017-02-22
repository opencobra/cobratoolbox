function [ response ] = buildFluxDistLayout( minerva, model, fd, identifier, dic)

% Builds a layout for MINERVA from a flux distribution. If a dictionary
% of identifiers is not provided it is assumed that the map and the COBRA
% model's nomenclature is coherent. Sends the layout to the remote MINERVA
% instance
% 
%
% INPUT
%
% minerva           Struct with the information of minerva instance:
%                   address, login, password and model (map)
% model             COBRA model structure   
% fd                Flux distribution from a COBRA simulation
% identifier        Name for the layout in MINERVA
% dic(optional)     The dictionary of ids
%
% OUTPUT
% 
% 
% Alberto Noronha Jan/2016

    dicFlag = 1;
    if nargin < 5
        dicFlag = 0;
    end
    
    defaultColor = '#009933';
    normalizedFluxes = normalizeFluxes(abs(fd.x));
    content = 'name\treactionIdentifier\tlineWidth\tcolor\n';
    for i=1:length(fd.x)
        
        %get reaction
        if dicFlag == 1
            index = strcmp(model.rxns{i}, dic(:,1));
            mapReactionId = dic(index,2);
        else
            mapReactionId = model.rxns{i};
        end
        
        if fd.x(i) ~= 0
            line = strcat('\t', mapReactionId, '\t', num2str(normalizedFluxes(i)), '\t', defaultColor, '\n');
            content = strcat(content, line);
        end
    end
    
    %   get all the parameters
    minerva_servlet = minerva.minervaURL;
    login = minerva.login;
    password = minerva.password;
    map = minerva.map;
    %     have to turn it into string
%     disp(content);
    content = sprintf(content);
    response = postMINERVArequest(minerva_servlet, login, password, map, identifier, content);
end

%% Normalize a flux into a range of 1 to 10
function [ normalized_value ] = normalizeFluxes(fluxDistribution)
    
    m = min(fluxDistribution);
    range = max(fluxDistribution) - m;
    fluxDistribution = (fluxDistribution - m) / range;
    range2 = 1 - 10;
    normalized_value = (fluxDistribution*range2) + 10;
    
end