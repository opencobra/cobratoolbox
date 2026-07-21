function [metabolite_structure, IDsAdded] = parseChemIDPlusWebpage(metabolite_structure, startSearch, endSearch)
% Retrieve identifiers from the ChemIDPlus website for each metabolite. UNII ids
% are looked up from the metabolite InChIKey and added to the structure.
%
% USAGE:
%
%    [metabolite_structure, IDsAdded] = parseChemIDPlusWebpage(metabolite_structure, startSearch, endSearch)
%
% INPUT:
%    metabolite_structure:    metabolite structure whose fields are VMH
%                             metabolite IDs, each holding a `inchiKey` field
%
% OPTIONAL INPUTS:
%    startSearch:             numeric index of where the search should start in
%                             the metabolite structure (default: 1)
%    endSearch:               numeric index of where the search should end in
%                             the metabolite structure (default: last metabolite)
%
% OUTPUTS:
%    metabolite_structure:    metabolite structure updated with the retrieved
%                             identifiers
%    IDsAdded:                cell array logging the added identifiers, with the
%                             metabolite field name, the identifier type, and
%                             the assigned identifier per row
%
% .. Author: - Ines Thiele

annotationSource = 'ChemIDPlus website';
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

mapping ={
    'unii'  'https://fdasis.nlm.nih.gov/srs/unii'
    'actor' 'https://actor.epa.gov/actor/chemical'
    'clinicaltrials'    'https://clinicaltrials.gov/search/intervention'
    'wikipedia' 'http://en.wikipedia.org/'
    'echa_id' 'https://echa.europa.eu/substance-information'
    'ctd' 'http://ctdbase.org/detail'
    };

% can use unii ID but I do not have a lot of them, so I will retrieve them
% based on inchiKey
if 1
    for i = startSearch : endSearch
        if ~isempty(metabolite_structure.(Mets{i}).VMHId) && length(find(isnan(metabolite_structure.(Mets{i}).VMHId),1))==0
            if(~isempty(metabolite_structure.(Mets{i}).inchiKey) && length(find(isnan(metabolite_structure.(Mets{i}).inchiKey),1)))==0
                
                try
                    url = strcat('https://chem.nlm.nih.gov/chemidplus/inchikey/',metabolite_structure.(Mets{i}).inchiKey);
                    [syst,success] = urlread(url);
                    [metabolite_structure,idNew] = getData(metabolite_structure,syst,Mets{i}, {'unii'  'https://fdasis.nlm.nih.gov/srs/unii'},IDsAdded);
                    if ~isempty(idNew) && isempty(find(isnan(idNew),1))
                        if isempty(metabolite_structure.(Mets{i}).unii) || ~isempty(find(isnan(metabolite_structure.(Mets{i}).unii),1))
                            metabolite_structure.(Mets{i}).unii = (idNew);
                            metabolite_structure.(Mets{i}).unii_source = [annotationSource,':',annotationType,':',datestr(now)];
                            IDsAdded{a,1} = Mets{i};
                            IDsAdded{a,2} = 'unii';
                            IDsAdded{a,3} = char(idNew);
                            a = a+1;
                        end
                    end
                    
                end
            end
        end
    end
end

%
if 1
    for i = startSearch : endSearch
        if ~isempty(metabolite_structure.(Mets{i}).VMHId) && isempty(find(isnan(metabolite_structure.(Mets{i}).VMHId),1))
            
            if(~isempty(metabolite_structure.(Mets{i}).unii) && length(find(isnan(metabolite_structure.(Mets{i}).unii),1)))==0
                try
                    url = strcat('https://chem.nlm.nih.gov/chemidplus/unii/',metabolite_structure.(Mets{i}).unii);
                    syst = urlread(url);
                    for k = 1 : size(mapping,1)
                        [metabolite_structure,idNew] = getData(metabolite_structure,syst,Mets{i}, mapping(k,:),IDsAdded);
                        if ~isempty(idNew) && isempty(find(isnan(idNew),1))
                            if isempty(metabolite_structure.(Mets{i}).(mapping{k,1})) || ~isempty(find(isnan(metabolite_structure.(Mets{i}).(mapping{k,1})),1))
                                metabolite_structure.(Mets{i}).(mapping{k,1}) = (idNew);
                                metabolite_structure.(Mets{i}).(strcat(mapping{k,1},'_source')) = [annotationSource,':',annotationType,':',datestr(now)];
                                IDsAdded{a,1} = Mets{i};
                                IDsAdded{a,2} = mapping{k,1};
                                IDsAdded{a,3} = char(idNew);
                                a = a+1;
                            end
                        end
                    end
                catch
                    continue;
                end
            end
        end
    end
end

function [metabolite_structure,idNew] = getData(metabolite_structure,syst,met, map,IDsAdded)
a = size(IDsAdded,1)+1;
idNew = '';
try
    startvalue=strfind(syst,map{1,2});
    string = syst(startvalue(1):startvalue(1)+200);
    if contains(map{1,1},'actor') || contains(map{1,1},'clinicaltrials')
        [tok,rem] = strtok(string,' ');
        [tok2,rem2] = strtok(tok,'=');
        idNew = regexprep(rem2,'\W$','');
        idNew = regexprep(idNew,'^\W','');
    elseif contains(map{1,1},'wikipedia')
        [tok,rem] = strtok(string,' ');
        idNew = regexprep(tok,'http://en.wikipedia.org/wiki/','');
        idNew = regexprep(idNew,'\W$','');
    elseif contains(map{1,1},'echa_id')
        [tok,rem] = strtok(string,' ');
        idNew = regexprep(tok,'https://echa.europa.eu/substance-information/-/substanceinfo/','');
        idNew = regexprep(idNew,'\W$','');
    elseif contains(map{1,1},'ctd')
        [tok,rem] = strtok(string,' ');
        [tok2,rem2] = strtok(tok,'=');
        [tok3,rem3] = strtok(rem2,'=');
        idNew = regexprep(rem3,'^=','');
        idNew = regexprep(idNew,'\W$','');
    else
        [tok,rem] = strtok(string,'>');
        [tok2,rem2] = strtok(rem,'<');
        idNew = regexprep(tok2,'>','');
    end
    
end