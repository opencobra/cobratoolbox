function [IDs,IDcount,Table] = getStatsMetStruct(metabolite_structure)
%
% INPUT
% metabolite_structure  Metabolite structure
%
% OUTPUT
% IDs                   List of ID names
% IDcount               Count per ID
% Table                 Table listing IDs per reaction
%
% Ines Thiele, 09/2021

Mets = fieldnames(metabolite_structure);
IDs = fieldnames(metabolite_structure.(Mets{1}));
IDcount = zeros(length(IDs),1);
for i = 1 : length(Mets)
    Table{i+1,1} = Mets{i,1};
    i
    for j = 1 : length(IDs)
        Table{1,j+1} = IDs{j,1};
        if ~isempty(metabolite_structure.(Mets{i,1}).(IDs{j}))
            
            Table{i+1,j+1} = metabolite_structure.(Mets{i,1}).(IDs{j});
        else
            Table{i+1,j+1} = NaN;
        end
        
        
        if ~isempty(metabolite_structure.(Mets{i,1}).(IDs{j}))
            if length(find(isnan(metabolite_structure.(Mets{i,1}).(IDs{j}))))==0
                IDcount(j,1) =   IDcount(j,1)+1;
                
            end
            
        end
    end
end