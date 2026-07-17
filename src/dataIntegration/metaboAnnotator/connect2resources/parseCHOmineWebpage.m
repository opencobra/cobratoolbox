function [metabolite_structure, IDsAdded] = parseCHOmineWebpage(metabolite_structure, startSearch, endSearch)
% Guess the CHOmine abbreviation of each metabolite from its VMH id by testing
% the CHOmine website (https://chomine.boku.ac.at/) and add the `chodb_id` when
% a matching entry exists.
%
% USAGE:
%
%    [metabolite_structure, IDsAdded] = parseCHOmineWebpage(metabolite_structure, startSearch, endSearch)
%
% INPUT:
%    metabolite_structure:    metabolite structure whose fields are VMH
%                             metabolite IDs, each holding a `VMHId` field
%
% OPTIONAL INPUTS:
%    startSearch:             numeric index of where the search should start in
%                             the metabolite structure (default: 1)
%    endSearch:               numeric index of where the search should end in
%                             the metabolite structure (default: last metabolite)
%
% OUTPUTS:
%    metabolite_structure:    metabolite structure updated with the matched
%                             CHOmine identifier
%    IDsAdded:                cell array logging the added identifiers, with the
%                             metabolite field name, the annotation type
%                             (`chodb_id`), and the assigned identifier per row
%
% .. Author: - Ines Thiele

annotationSource = 'CHOmine website matching';
annotationType = 'automatic';

Mets = fieldnames(metabolite_structure);
if ~exist('startSearch','var')
    startSearch = 1;
end
if ~exist('endSearch','var')
    endSearch = length(Mets);
end



a = 1;
IDsAdded = '';


for i = startSearch : endSearch    
    if ~isempty(metabolite_structure.(Mets{i}).VMHId) && isempty(find(isnan(metabolite_structure.(Mets{i}).VMHId),1))
      
        if (isempty(metabolite_structure.(Mets{i}).chodb_id) || ~isempty(find(isnan(metabolite_structure.(Mets{i}).chodb_id),1)))
            try
                url = strcat('https://chomine.boku.ac.at/chomine/portal.do?externalid=',metabolite_structure.(Mets{i}).VMHId,'&class=Species');
                syst = urlread(url);
                if ~contains(syst,'No matches found')
                    metabolite_structure.(Mets{i}).chodb_id = Mets{i};
                    metabolite_structure.(Mets{i}).chodb_id_source =   [annotationSource,':',annotationType,':',datestr(now)];
                    IDsAdded{a,1} = Mets{i};
                    IDsAdded{a,2} = 'chodb_id';
                    IDsAdded{a,3} = char(idNew);
                    a = a + 1;
                end
            end
        end
    end
end