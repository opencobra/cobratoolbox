function [] = generateSubsystemLayouts( minerva, cobra_model, color )
% Generates subsystem layouts
%
% USAGE:
%
%    generateSubsystemLayouts( minerva, cobra_model, color )
%
% INPUTS:
%    minerva:           Struct with the information of minerva instance:
%                       address, login, password and model (map)
%    cobra_model:       COBRA model structure
%    color:             Color

    subsystems = unique(cobra_model.subSystems);
    subsystems = subsystems(~cellfun('isempty',subsystems));

    for i= 1:length(subsystems)

        if nargin < 3
            response = generateSubsytemsLayout(cobra_model, subsystems(i));
        else
            response = generateSubsytemsLayout(cobra_model, subsystems(i), color);
        end

        if ~isempty(regexp(response, '"status":"OK"'))
            result = [subsystems(i), ' successfully sent to MINERVA instace.'];
            disp(result)
        else
            result = [subsystems(i), ' failed.'];
            disp(result)
        end

    end
end
