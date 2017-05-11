function [] = generateSubsystemLayouts( minerva, cobra_model, color )
%GENERATESUBSYSTEMLAYOUTS Summary of this function goes here
%   Detailed explanation goes here
    
    subsystems = unique(cobra_model.subSystems);
    subsystems = subsystems(~cellfun('isempty',subsystems));
    
    for i= 1:length(subsystems)
        
        if nargin < 3
            response = generateSubsytemsLayout(minerva, cobra_model, subsystems(i));
        else
            response = generateSubsytemsLayout(minerva, cobra_model, subsystems(i), color);
        end
        
        if ~isempty(strfind(response, '<span id="default_form:status">OK</span>'))
            result = [subsystems(i), ' successfully sent to MINERVA instace.'];
            disp(result)
        else
            result = [subsystems(i), ' failed.'];
            disp(result)
        end
            
    end
end

