function [metabolite_structure,IDsAdded] = parseCHOmineWebpage(metabolite_structure,startSearch,endSearch)
% try to guess chomine abbreviation based on VMH ID

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