function [ response ] = generateSubsytemsLayout(minerva, cobra_model, subsystem, color)
%GENERATESUBSYTEMSLAYOUT Summary of this function goes here
%   Detailed explanation goes here

    if nargin < 4
        color = '#009933';
    end
    
    content = 'name\treactionIdentifier\tlineWidth\tcolor\n';
    
    for i = 1:length(cobra_model.rxns)
        
        if strcmp(cobra_model.subSystems(i), subsystem)
%             Assuming that reactions not existing in the map won't be a
%             problem
            mapReactionId = cobra_model.rxns{i};
%             disp(mapReactionId)
            line = strcat('\t', mapReactionId, '\t', '5', '\t', color, '\n');
            content = strcat(content, line);
        end
        
    end
    
    %   get all the parameters
    minerva_servlet = minerva.minervaURL;
    login = minerva.login;
    password = minerva.password;
    model = minerva.map;
    %     have to turn it into string
    content = sprintf(content);
    response = postMINERVArequest(minerva_servlet, login, password, model, subsystem, content);
    
end

