function rxnCSBnew = rxnDatabaseInsert(rxnCSB,data)
%inserts each reaction in data into the database if that reaction
%abbreviation does not yet appear in the database
%data is in the format saved by rBioNet 
N=size(rxnCSB,1);
M=size(data,1);

for m=1:M
    if ~any(strcmp(data{m,2},rxnCSB(:,1)))
        %abbr
        rxnCSB{N+1,1}=data{m,2};
        %name
        rxnCSB{N+1,2}=data{m,3};
        %formula
        rxnCSB{N+1,3}=data{m,4};
        %reversibility
        rxnCSB{N+1,4}=data{m,5};
        %confidence
        rxnCSB{N+1,5}=data{m,9};
        %note
        rxnCSB{N+1,6}=data{m,12};
        %ref
        rxnCSB{N+1,7}=data{m,11};
        %EC
        rxnCSB{N+1,8}=data{m,13};
        %KEGG
        rxnCSB{N+1,9}=data{m,14};
        %date
        rxnCSB{N+1,10}=date;
        N=N+1;
    end
end

%sort the new database
rxnCSBnew=sortrows(rxnCSB,1);