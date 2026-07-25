function [IDs, IDcount, Table] = getStatsMetStruct(metabolite_structure)
% Computes statistics on the identifiers stored in a metabolite structure
%
% Collects the identifier field names present in the metabolite structure,
% counts how many metabolites carry each identifier, and assembles a table of
% the identifiers per metabolite.
%
% USAGE:
%
%    [IDs, IDcount, Table] = getStatsMetStruct(metabolite_structure)
%
% INPUT:
%    metabolite_structure:    metabolite structure
%
% OUTPUTS:
%    IDs:                     list of identifier (field) names
%    IDcount:                 count of metabolites carrying each identifier
%    Table:                   table listing the identifiers per metabolite
%
% .. Author: - Ines Thiele, 09/2021

Mets = fieldnames(metabolite_structure);
IDs = fieldnames(metabolite_structure.(Mets{1}));
IDcount = zeros(length(IDs),1);
Table{1,1} = 'MetStrctID';
for i = 1 : length(Mets)
    Table{i+1,1} = Mets{i,1};
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