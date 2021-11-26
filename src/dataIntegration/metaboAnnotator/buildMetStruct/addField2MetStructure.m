function metabolite_structure= addField2MetStructure(metabolite_structure,metField)
% This function adds fields to the metabolite_structure as defined in
% metaboliteStructureFieldNames.m. Please note that this function does not
% populate the fields with new data.
%
% INPUT 
% metabolite_structure  Metabolite structure
% metField                   specify metabolite (optional)
%
% OUTPUT
% metabolite_structure  Updated metabolite structure
%
% Ines Thiele 2020/2021

metaboliteStructureFieldNames;
if ~exist('metField','var')
    Mets = fieldnames(metabolite_structure);
    fields = fieldnames(metabolite_structure.(Mets{1}));
else
    Mets = cellstr(metField);
    fields = fieldnames(metabolite_structure.(Mets{1}));
end

% add missing fields that I would like to have in the structure

for i = 1 : length(Mets)
    fields = fieldnames(metabolite_structure.(Mets{i}));
    [missingfields,map] = setdiff(field2Add,fields);
    for j = 1 : length(missingfields)
        metabolite_structure.(Mets{i}).(missingfields{j}) = NaN;
        metabolite_structure.(Mets{i}).([missingfields{j},'_source']) = NaN;
    end
end