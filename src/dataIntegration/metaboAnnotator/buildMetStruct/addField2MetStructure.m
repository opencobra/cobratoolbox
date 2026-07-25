function metabolite_structure = addField2MetStructure(metabolite_structure, metField)
% Adds the standard metabolite structure fields to each metabolite entry
%
% Adds fields to the metabolite structure as defined in
% `metaboliteStructureFieldNames`. Note that this function does not populate
% the fields with new data; missing fields are added and set to NaN.
%
% USAGE:
%
%    metabolite_structure = addField2MetStructure(metabolite_structure, metField)
%
% INPUT:
%    metabolite_structure:    metabolite structure
%
% OPTIONAL INPUT:
%    metField:                specify a single metabolite (field name) whose
%                             fields should be added (default: all metabolites)
%
% OUTPUT:
%    metabolite_structure:    updated metabolite structure
%
% .. Author: - Ines Thiele, 2020/2021

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