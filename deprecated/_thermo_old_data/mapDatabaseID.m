function model=mapDatabaseID(model,rxnAbbrDatabaseID)
%Map a set of reaction Database ID's to the model
%
%INPUT
% model.S             m x n Stoichiometric matrix
% model.rxns          n x 1 reaction abbreviation
% rxnAbbrDatabaseID   n x 2 cell array of reaction abbreviation and database ID
%
%OUTPUT
% model.rxnDatabaseID
%
% Ronan M.T. Fleming

[nMet,nRxn]=size(model.S);

nRxnID=size(rxnAbbrDatabaseID,1);

if 1
    %replace any dashes in Database metabolite names with underscores
    for q=1:nRxnID
        rxnAbbr=rxnAbbrDatabaseID{q,1};
        x = strfind(rxnAbbr,'-');
        if x~=0
            rxnAbbr(x)='_';
        end
        rxnAbbrDatabaseID{q,1}=rxnAbbr;
    end
end

%add Database ID to each reaction
rxnDatabaseID=zeros(nRxn,1);
for n=1:nRxn
    got=0;
    if strncmpi('Biomass',model.rxns{n},7)
        for q=1:nRxnID
            if strcmp(model.rxns{n},rxnAbbrDatabaseID{q,1})
                a=rxnAbbrDatabaseID{q,2};
                rxnDatabaseID(n,1)=a;
                got=1;
                break;
            end
        end
    else
        for q=1:nRxnID
            if strcmp(model.rxns{n},rxnAbbrDatabaseID{q,1})
                a=rxnAbbrDatabaseID{q,2};
                rxnDatabaseID(n,1)=a;
                got=1;
                break;
            end
        end
    end
%     %print out reactions that don't match a Database ID
%     if got==0
%         fprintf('%s\n',['No DatabaseID for ' model.rxns{n}])
%     end
end

% %double check that all ID's are unique
% if length(rxnDatabaseID)~=length(unique(rxnDatabaseID))
%     error('Database reaction ID must be unique')
% end

model.rxnDatabaseID=rxnDatabaseID;