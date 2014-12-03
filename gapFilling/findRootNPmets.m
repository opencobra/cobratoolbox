function gaps = findRootNPmets(model,findNCmets)
%findRootNPmets Find the root no production (and no consumption) 
%metabolites in a model, used by gapFind
%
% gaps = findRootNPmets(model,findNCmets)
%
%INPUT
% model         a COBRA model
%
%OPTIONAL INPUT
% findNCmets    find no consumption mets as well as no production (default
%               false)
%
%OUTPUT
% gaps          all root no production metabolites
%
% Jeff Orth 7/15/09

if nargin < 2
    findNCmets = false;
end

isRootNPmet = zeros(length(model.mets),1);

for i = 1:length(model.mets)
    row = find(model.S(i,:)); %which rxns this met participates in
    rowR = ismember(row,find(model.rev)); %reversible rxns
    if any(model.S(i,row) > 0) %if met is produced by any reaction
        %don't do anything
    elseif any(rowR) %if met is in any reverible rxns
        %don't do anything
    else
        isRootNPmet(i) = 1;
    end
end

if findNCmets
    
    isRootNCmet = zeros(length(model.mets),1);
    
    for i = 1:length(model.mets)
        row = find(model.S(i,:)); %which rxns this met participates in
        rowR = ismember(row,find(model.rev)); %reversible rxns
        if any(model.S(i,row) < 0) %if met is consumed by any reaction
            %don't do anything
        elseif any(rowR) %if met is in any reverible rxns
            %don't do anything
        else
            isRootNCmet(i) = 1;
        end
    end
end

if findNCmets
    gaps = model.mets((isRootNPmet+isRootNCmet)>=1);
else
    gaps = model.mets(isRootNPmet==1);
end




