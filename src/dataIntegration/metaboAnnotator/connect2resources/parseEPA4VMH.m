function [metabolite_structure,IDsAdded] = parseEPA4VMH(metabolite_structure,startSearch,endSearch)
% search EPA  - comptox
% using casRegistry
% or using inchiKey
annotationSource = 'EPA website';
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
    syst = '';
    if isempty(metabolite_structure.(Mets{i}).epa_id) || ~isempty(find(isnan(metabolite_structure.(Mets{i}).epa_id),1))

        if ~isempty(metabolite_structure.(Mets{i}).casRegistry) && isempty(find(isnan(metabolite_structure.(Mets{i}).casRegistry),1))
            % based on
            % 'casRegistry'
            
            url = strcat('https://comptox.epa.gov/dashboard/dsstoxdb/results?search=',metabolite_structure.(Mets{i}).casRegistry);
            syst = urlread(url);
            method = [annotationSource ' (casRegistry)'];
        elseif ~isempty(metabolite_structure.(Mets{i}).inchiKey) && isempty(find(isnan(metabolite_structure.(Mets{i}).inchiKey),1))
            
            url = strcat('https://comptox.epa.gov/dashboard/dsstoxdb/results?search=',metabolite_structure.(Mets{i}).inchiKey);
            syst = urlread(url);
            method = [annotationSource ' (inchiKey)'];
        end
        if contains(syst,'https://comptox.epa.gov/dashboard')
            startvalue=strfind(syst,'https://comptox.epa.gov/dashboard');
            string = syst(startvalue(1):startvalue(1)+200);
            [tok,rem] = strtok(string,' ');
            idNew = regexprep(tok, 'https://comptox.epa.gov/dashboard/','');
            metabolite_structure.(Mets{i}).epa_id = idNew;
            s = ' ';
            metabolite_structure.(Mets{i}).epa_id_source =  [method,':',annotationType,':',datestr(now)];
            IDsAdded{a,1} = Mets{i};
            IDsAdded{a,2} = 'epa_id';
            IDsAdded{a,3} = char(idNew);
            a = a+1;
        end
    end
end
