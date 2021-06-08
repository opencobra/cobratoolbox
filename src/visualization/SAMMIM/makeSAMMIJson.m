function jsonstr = makeSAMMIJson(model)
    if isrow(model.mets); model.mets = model.mets'; end
    if isrow(model.rxns); model.rxns = model.rxns'; end
    %Get fields
    fds = fieldnames(model);
    fds = fds(~ismember(fds,{'rxns' 'mets'}));
    rxnfds = {};
    metfds = {};
    for i = 1:length(fds)
        if isrow(model.(fds{i})); model.(fds{i}) = model.(fds{i})'; end
        if size(model.(fds{i})) == size(model.mets)
            metfds = cat(1,metfds,fds{i});
        end
        if size(model.(fds{i})) == size(model.rxns)
            rxnfds = cat(1,rxnfds,fds{i});
        end
        if iscell(model.(fds{i})) && ischar(model.(fds{i}){1})
            model.(fds{i}) = strrep(model.(fds{i}),char(10),' ');
            model.(fds{i}) = strrep(model.(fds{i}),'"','');
        end
    end

    %Print Metabolites
    fd = strcat('{"id":"',model.mets,'",');
    for i = 1:length(metfds)
        added = false;
        if iscell(model.(metfds{i})) || ischar(model.(metfds{i}))
            fd = strcat(fd,'"',metfds{i},'":"',model.(metfds{i}),'"');
            added = true;
        elseif isnumeric(model.(metfds{i}))
            fd = strcat(fd,'"',metfds{i},'":',sprintfc('%g',model.(metfds{i})));
            added = true;
        end
        if i ~= length(metfds) && added
            fd = strcat(fd,',');
        end
        if i == length(metfds)
            fd = strcat(fd,'}');
        end
    end
    fd = strjoin(fd,',');
    jsonstr = strcat('{"metabolites":[',fd,'],"reactions":[');
    
    %Print reaction fields
    fd = strcat('{"id":"',model.rxns,'",');
    for i = 1:length(rxnfds)
        added = false;
        if iscell(model.(rxnfds{i})) || ischar(model.(rxnfds{i}))
            fd = strcat(fd,'"',rxnfds{i},'":"',model.(rxnfds{i}),'"');
            added = true;
        elseif isnumeric(model.(rxnfds{i})) || islogical(model.(rxnfds{i}))
            fd = strcat(fd,'"',rxnfds{i},'":',sprintfc('%g',model.(rxnfds{i})));
            added = true;
        end
        if added
            fd = strcat(fd,',');
        end
    end
    %Print metabolites
    fun = @(a) joinmets(a,model.mets);
    metarr = arrayfun(fun,num2cell(model.S,1),'UniformOutput',false);
    fd = strcat(fd,'"metabolites":{',metarr','}}');
    %Join all
    fd = strjoin(fd,',');
    jsonstr = strcat(jsonstr,fd,']}');
end

function otp = joinmets(s,mets)
    ind = find(s{1});
    otp = strjoin(strcat('"',mets(ind),'":',num2str(s{1}(ind))),',');
end



