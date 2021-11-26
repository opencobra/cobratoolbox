function [metabolite_structure,IDsAdded] = parseWikipediaWebpage(metabolite_structure,startSearch,endSearch)
% This function searches wikipedia for identifiers. It will either use
% wikipedia ids provided by the metabolite structure or try to find perfect
% hits based on metabolite name search.
%
% INPUT
% metabolite_structure  metabolite structure
% startSearch           specify where the search should start in the
%                       metabolite structure. Must be numeric (optional, default: all metabolites
%                       in the structure will be search for)
% endSearch             specify where the search should end in the
%                       metabolite structure. Must be numeric (optional, default: all metabolites
%                       in the structure will be search for)
%
% OUTPUT
% metabolite_structure  updated metabolite structure
%
%
% Ines Thiele, 09/2021


annotationSource = 'Wikipedia website';
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
    'iuphar_id'   'http://www.guidetopharmacology.org/GRAC/'
    'chemspider'    'http://www.chemspider.com/Chemical-Structure'
    'echa_id'   'https://echa.europa.eu/substance-information/-/substanceinfo/'
    'chembl'    'https://www.ebi.ac.uk/chembldb'
    'casRegistry'   'http://www.commonchemistry.org/ChemicalDetail'
    'pubChemId' 'https://pubchem.ncbi.nlm.nih.gov/'
    'unii' 'https://fdasis.nlm.nih.gov/srs/'
    'epa_id'   'https://comptox.epa.gov/dashboard/'
    'keggId'    'https://www.kegg.jp/entry/'
    'drugbank'  'https://www.drugbank.ca/drugs/'
    };


for i = startSearch : endSearch
    if(~isempty(metabolite_structure.(Mets{i}).wikipedia) && isempty(find(isnan(metabolite_structure.(Mets{i}).wikipedia),1)))
        try
            url = strcat('https://en.wikipedia.org/wiki/',metabolite_structure.(Mets{i}).wikipedia);
            syst = urlread(url);
        catch
            try
                url = strcat('https://en.wikipedia.org/wiki/',metabolite_structure.(Mets{i}).metNames);
                syst = urlread(url);
            catch
                continue;
            end
            annotationSource = [annotationSource '-direct name search'];
        end
    else
        try
            url = strcat('https://en.wikipedia.org/wiki/',metabolite_structure.(Mets{i}).metNames);
            syst = urlread(url);
        catch
            continue;
        end
        annotationSource = [annotationSource '-direct name search'];
    end
    % try to find metabolite by name
    if ~contains(syst,'Wikipedia does not have an article with this exact name.')
        for k = 1 : size(mapping,1)
            [metabolite_structure,idNew] = getData(metabolite_structure,syst,Mets{i}, mapping(k,:),IDsAdded);
            if ~isempty(idNew) && isempty(find(isnan(idNew),1))
                if isempty(metabolite_structure.(Mets{i}).(mapping{k,1})) || length(find(isnan(metabolite_structure.(Mets{i}).(mapping{k,1})),1))>0
                    metabolite_structure.(Mets{i}).(mapping{k,1}) = (idNew);
                    metabolite_structure.(Mets{i}).(strcat(mapping{k,1},'_source')) = [annotationSource,':',annotationType,':',datestr(now)];
                    IDsAdded{a,1} = Mets{i};
                    IDsAdded{a,2} = mapping{k,1};
                    IDsAdded{a,3} = char(idNew);
                    a = a+1;
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
    
    if contains(map{1,1},'chemspider')
        string = regexprep(string,'http://www.chemspider.com/Chemical-Structure.','');
        [tok,rem] = strtok(string,'.');
        idNew = tok;
    else
        [tok,rem] = strtok(string,'>');
        [tok2,rem2] = strtok(rem,'<');
        idNew = regexprep(tok2,'>','');
    end
end