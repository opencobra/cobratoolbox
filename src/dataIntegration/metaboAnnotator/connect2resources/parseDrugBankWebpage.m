function [metabolite_structure,IDsAdded] = parseDrugBankWebpage(metabolite_structure,startSearch,endSearch)

Mets = fieldnames(metabolite_structure);
fields = fieldnames(metabolite_structure.(Mets{1}));
if ~exist('startSearch','var')
    startSearch = 1;
end
if ~exist('endSearch','var')
    endSearch = length(Mets);
end
annotationSource = 'Drugbank website';
annotationType = 'automatic';

mapping={
    'chemspider'        'http://www.chemspider.com'
    'food_db'   'http://foodb.ca/compounds'
    'wikipedia' 'http://en.wikipedia.org/wiki'
    'metlin'    'http://metlin.scripps.edu'
    'pubChemId'   'http://pubchem.ncbi.nlm.nih.gov/'
    'cheBIId'   'ChEBI ID'
    'keggId'  'http://www.genome.jp/dbget-bin'
    'inchiKey'   'InChI Key'
    'inchiString' 'InChI=1S'
 %   'smile'   'SMILES'
    'avgmolweight' 'Average Molecular Weight'
    'monoisotopicweight' 'Monoisotopic Molecular Weight'
    'iupac'    'IUPAC Name'
    'description'  'met-desc'
    'biocyc'   'http://biocyc.org/META/'
    'phenolExplorer'    'http://www.phenol-explorer.eu'
    'casRegistry'   'CAS Registry Number'
    'knapsack'     'http://kanaya.naist.jp/knapsack_core'
    'rxnav' 'https://mor.nlm.nih.gov/RxNav/'
    'zinc' 'https://zinc.docking.org/substances/'
    'pharmgkb'  'http://www.pharmgkb.org/drug'
    'pdbeLigand'   'http://www.ebi.ac.uk/pdbe-srv/pdbechem/chemicalCompound/'
    'drugs_com'    'http://www.drugs.com/'
    };
IDsAdded = ''; a=1;
IDsMismatch = '';b=1;



for i = startSearch : endSearch
    if ~isempty(metabolite_structure.(Mets{i}).drugbank) && isempty(find(isnan(metabolite_structure.(Mets{i}).drugbank),1))
        % check that smile or inchiKey does not exist
        % go to chebi and parse website for smile
        try
            if contains(metabolite_structure.(Mets{i}).drugbank,'MET')
                
                url=strcat('https://go.drugbank.com/metabolites/',(metabolite_structure.(Mets{i}).drugbank));
            else
                url=strcat('https://go.drugbank.com/drugs/',(metabolite_structure.(Mets{i}).drugbank));
            end
            syst = urlread(url);
            for k = 1 : size(mapping,1)
                [metabolite_structure,idNew] = getData(metabolite_structure,syst,Mets{i}, mapping(k,:),IDsAdded);
                if ~isempty(idNew) && isempty(find(isnan(idNew),1)) && ~contains(idNew,'NotAvailable')
                    if isempty(metabolite_structure.(Mets{i}).(mapping{k,1})) || ~isempty(find(isnan(metabolite_structure.(Mets{i}).(mapping{k,1})),1))
                        metabolite_structure.(Mets{i}).(mapping{k,1}) = (idNew);
                        metabolite_structure.(Mets{i}).([mapping{k,1},'_source']) = [annotationSource,':',annotationType,':',datestr(now)];
                        IDsAdded{a,1} = Mets{i};
                        IDsAdded{a,2} = mapping{k,1};
                        IDsAdded{a,3} = char(idNew);
                        a = a+1;
                    else
                        % compare with existing entries
                        % record it if it is not the same otw nothing happens
                        if(~strcmp(metabolite_structure.(Mets{i}).(mapping{k,1}),idNew))
                            if isnumeric(metabolite_structure.(Mets{i}).(mapping{k,1})) && (strcmp(num2str(metabolite_structure.(Mets{i}).(mapping{k,1})),idNew))
                            else
                                IDsMismatch{b,1} = Mets{i};
                                IDsMismatch{b,2} = metabolite_structure.(Mets{i}).(mapping{k,1});
                                IDsMismatch{b,3} = metabolite_structure.(Mets{i}).drugbank;
                                IDsMismatch{b,4} = mapping{k,1};
                                IDsMismatch{b,5} = char(idNew);
                                error = idNew;
                                b=b+1;
                            end
                        end
                    end
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
    if strcmp(map{1,1},'inchiKey')
        [tok,rem] = strtok(string,'>');
        [tok2,rem2] = strtok(rem,'>');
        rem2 = regexprep(rem2,'>','');
        [tok2,rem2] = strtok(rem2,'<');
        idNew = tok2;
    elseif (strcmp(map{1,1},'inchiString'))
        [tok,rem] = strtok(string,'<');
        idNew = tok;
    elseif (strcmp(map{1,1},'smile'))
        if ~contains(string,'word-break-all') % generally SMILES appears twice in the file and we want the second entry
            string = syst(startvalue(2):startvalue(2)+200);
        end
        string = regexprep(string,'SMILES</th><td><div class="word-break-all">','');
        [tok,rem] = strtok(string,'<');
        idNew = tok;
    elseif (strcmp(map{1,1},'avgmolweight')) ||(strcmp(map{1,1},'monoisotopicweight')) ...
            || strcmp(map{1,1},'iupac') || strcmp(map{1,1},'casRegistry')
        string = regexprep(string,strcat(map{1,2},'</th><td>'),'');
        [tok,rem] = strtok(string,'<');
        idNew = tok;
    elseif (strcmp(map{1,1},'cheBIId'))
        string = regexprep(string,strcat(map{1,2},'</th><td>'),'');
        [tok,rem] = strtok(string,'<');
        [tok2,rem2] = strtok(tok,'>');
        [rem2] = regexprep(rem2,'>','');
        [rem2] = regexprep(rem2,' ','');
        idNew = rem2;
        
    elseif (strcmp(map{1,1},'drugs_com'))
        [tok,rem] = strtok(string,'>');
        [tok] = regexprep(tok,'http://www.drugs.com/cdi/','');
        idNew = regexprep(tok,'.html\W$','');
        
    else
        [tok,rem] = strtok(string,'>');
        [tok2,rem2] = strtok(rem,'<');
        idNew = regexprep(tok2,'>','');
        if ~strcmp(map{1,1},'description')% do not remove spaces from description
            idNew = regexprep(idNew,' ','');
        end
    end
    if contains(idNew,'Not Available')
        idNew = NaN;
    end
end