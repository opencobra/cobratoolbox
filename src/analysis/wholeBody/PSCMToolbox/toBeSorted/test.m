
for a = 1 : length(modelOrganAll.mets)
    [organ,metAbb] = strtok(modelOrganAll.mets{a},'_')
    if length(strfind(metAbb,'_'))>0
        Met = metAbb(2:end);
        [xa,b]=strtok(Met,'[');
        if length(b)> 3 % (extracellular compartment)
            Met = strcat(xa,'[e]');
        end
    else
        Met = organ; % if no '_'
        [xa,b]=strtok(Met,'[');
        if length(b)> 3 % (extracellular compartment)
            Met = strcat(xa,'[e]');
            organ = strcat( 'Biofluid, ',b);
        end
    end
    %  replace any fancy compartments with [e]
    M3ID = strmatch(Met,modelConsistent.mets);
    if ~isempty(M3ID)
        modelOrganAll.metCharge(a) = modelConsistent.metCharge(M3ID);
        modelOrganAll.metFormulas{a} = modelConsistent.metFormulas{M3ID};
    end
    
end

