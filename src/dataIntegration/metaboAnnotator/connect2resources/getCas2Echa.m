function [metabolite_structure, IDsAdded] = getCas2Echa(metabolite_structure)
% Add ECHA (European Chemicals Agency) identifiers to the metabolite structure
% by matching on the CAS registry number. The input file was downloaded from
% https://echa.europa.eu/documents/10162/13629/ec_inventory_en.xlsx (first
% column: echa_id, 4th column: cas registry).
%
% USAGE:
%
%    [metabolite_structure, IDsAdded] = getCas2Echa(metabolite_structure)
%
% INPUT:
%    metabolite_structure:    metabolite structure whose fields are VMH
%                             metabolite IDs, each holding a `casRegistry` field
%
% OUTPUTS:
%    metabolite_structure:    metabolite structure updated with the matched
%                             ECHA identifiers
%    IDsAdded:                cell array logging the added identifiers, with the
%                             metabolite field name, the annotation type
%                             (`echa_id`), and the assigned identifier per row
%
% .. Author: - Ines Thiele, 2020-2021

% first column contains echa_id,4th col is cas registry
[NUM,TXT,RAW]=xlsread('ec_inventory_en.xlsx');

annotationSource = 'Echa_id mapping from CasRegistry';
annotationType = 'automatic';

Mets = fieldnames(metabolite_structure);
for i = 1 : length(Mets)
    Cas{i,1} = Mets{i};
    Cas{i,2} = num2str(metabolite_structure.(Mets{i}).casRegistry);
end

for i = 4 : size(RAW,1)
    casRAW{i-3,1} = RAW{i,4};
    casRAWList{i-3,1} = RAW{i,1};
end
a = 1;
IDsAdded = '';

for i = 1 : size(Cas,1)
    % no keggId exists
    if ~isempty(metabolite_structure.(Cas{i,1}).casRegistry) && isempty(find(isnan(metabolite_structure.(Cas{i,1}).casRegistry),1))
        if isempty(metabolite_structure.(Cas{i,1}).echa_id) || ~isempty(find(isnan(metabolite_structure.(Cas{i,1}).echa_id),1))
            match = strmatch(Cas{i,2},casRAW,'exact');
            if ~isempty(match)
                metabolite_structure.(Cas{i,1}).echa_id = casRAWList{match};
                metabolite_structure.(Cas{i,1}).echa_id_source =  [annotationSource,':',annotationType,':',datestr(now)];
                IDsAdded{a,1} = Cas{i,1};
                IDsAdded{a,2} = 'echa_id';
                IDsAdded{a,3} =  metabolite_structure.(Cas{i}).echa_id;
                a = a + 1;
            end
        end
    end
end
[metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure);
