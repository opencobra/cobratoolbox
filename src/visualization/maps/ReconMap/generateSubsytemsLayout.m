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

    content = 'name\treactionIdentifier\tlineWidth\tcolor\n';

    for i = 1:length(cobra_model.rxns)

        if isReactionInSubSystem(cobra_model, cobra_model.rxns(i), subsystem)
            % Assuming that reactions not existing in the map won't be a
            % problem
            mapReactionId = cobra_model.rxns{i};
            % if not ReconMap 2.01 use new reaction notation   
            if ~strcmp(minerva.map, 'ReconMap-2.01')
                mapReactionId = strcat('r_', mapReactionId);
            end
            line = strcat('\t', mapReactionId, '\t', '5', '\t', color, '\n');
            content = strcat(content, line);
        end

    end

    %   get all the parameters
    login = minerva.login;
    password = minerva.password;
    model = minerva.map;
    %     have to turn it into string
    content = sprintf(content);
    response = postMINERVArequest(login, password, model, subsystem, content);
end
