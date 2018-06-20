function [ response ] = generateSubsytemsLayout(minerva, cobra_model, subsystem, color)
  % Generates subsystem layouts
  %
  % USAGE:
  %
  %    generateSubsytemsLayout(minerva, cobra_model, subsystem, color)
  %
  % INPUTS:
  %    minerva:           Struct with the information of minerva instance:
  %                       address, login, password and model (map)
  %    cobra_model:       COBRA model structure
  %    subsystem:         Subsystem
  %    color:             Color

    if nargin < 4
        color = '#009933';
    end

    content = 'name%09reactionIdentifier%09lineWidth%09color%0D';

    for i = 1:length(cobra_model.rxns)

        if isReactionInSubSystem(cobra_model, cobra_model.rxns(i), subsystem)
            % Assuming that reactions not existing in the map won't be a
            % problem
            mapReactionId = cobra_model.rxns{i};
            % if not ReconMap 2.01 use new reaction notation   
            if ~strcmp(minerva.map, 'ReconMap-2.01')
                mapReactionId = strcat('r_', mapReactionId);
            end
            line = strcat('%09', mapReactionId, '%09', '5', '%09', color, '%0D');
            content = strcat(content, line);
        end

    end

    %   get all the parameters
    login = minerva.login;
    password = minerva.password;
    map = minerva.map;
    googleLicenseContent = minerva.googleLicenseConsent;
    %     have to turn it into string
    content = sprintf(content);
    response = postMINERVArequest(login, password, map, googleLicenseContent, subsystem, content);
end
