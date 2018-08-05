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

    subsystems = getModelSubSystems(cobra_model);

    for i= 1:length(subsystems)

        if nargin < 3
            response = generateSubsytemsLayout(cobra_model, subsystems(i));
        else
            response = generateSubsytemsLayout(cobra_model, subsystems(i), color);
        end

        if ~isempty(regexp(response, strcat('"creator":"', minerva.login, '"')))
            result = [subsystems(i), ' successfully sent to ReconMap.'];
            disp(result)
        else
            result = [subsystems(i), ' failed.'];
            disp(result)
        end

    end
end
