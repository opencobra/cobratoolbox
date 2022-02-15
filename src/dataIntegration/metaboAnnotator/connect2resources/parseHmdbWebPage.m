function [metabolite_structure,IDsAdded,IDsMismatch,InchiKeyList,InchiStringList ] = parseHmdbWebPage(metabolite_structure,startSearch,endSearch,printInchis)

if ~exist('printInchis','var')
    printInchis = 0; % default setting is not to print the InchiKeyList,InchiStringList 
end
Mets = fieldnames(metabolite_structure);
if ~exist('startSearch','var')
    startSearch = 1;
end
if ~exist('endSearch','var')
    endSearch = length(Mets);
end

annotationSource = 'HMDB website';
annotationType = 'automatic';

mapping={
    'chemspider'        'http://www.chemspider.com' 'external'
    'food_db'   'http://foodb.ca/compounds' 'external'
    'wikipedia' 'http://en.wikipedia.org/wiki' 'external'
    'metlin'    'http://metlin.scripps.edu' 'external'
    'pubChemId'   'http://pubchem.ncbi.nlm.nih.gov/' 'external'
    'cheBIId'   'ChEBI ID' 'external'
    'keggId'  'http://www.genome.jp/dbget-bin' 'external'
    'inchiKey'   'InChI Key' 'internal'
    'inchiString' 'InChI=1S'    'internal'
 %   'smile'   'SMILES'  'internal'
    'avgmolweight' 'Average Molecular Weight'   'internal'
    'monoisotopicweight' 'Monoisotopic Molecular Weight'    'internal'
    'iupac'    'IUPAC Name' 'internal'
    'description'  'met-desc'   'internal'
    'biocyc'   'http://biocyc.org/META/' 'external'
    'phenolExplorer'    'http://www.phenol-explorer.eu' 'external'
    'casRegistry'   'CAS Registry Number' 'external'
    'knapsack'     'http://kanaya.naist.jp/knapsack_core' 'external'
    'drugbank'  'http://www.drugbank.ca/drugs/' 'external'
    'rxnav' 'https://mor.nlm.nih.gov/RxNav/' 'external'
    'zinc' 'https://zinc.docking.org/substances/' 'external'
    'pharmgkb'  'http://www.pharmgkb.org/drug' 'external'
    'pdbeLigand'   'http://www.ebi.ac.uk/pdbe-srv/pdbechem/chemicalCompound/' 'external'
    'drugs_com'    'http://www.drugs.com/' 'external'
    };
IDsAdded = ''; a=1;
IDsMismatch = '';b=1;
InchiStringList = ''; c=1;
InchiKeyList = '';d=1;
fields = fieldnames(metabolite_structure.(Mets{1}));

for i = startSearch : endSearch
    if ~isempty(metabolite_structure.(Mets{i}).hmdb) && isempty(find(isnan(metabolite_structure.(Mets{i}).hmdb),1))
        % check that smile or inchiKey does not exist
        % go to chebi and parse website for smile
        try
            clear list
            metabolite_structure.(Mets{i}).hmdb = regexprep(metabolite_structure.(Mets{i}).hmdb,',',';');
            if contains(metabolite_structure.(Mets{i}).hmdb,';')
                list = split(metabolite_structure.(Mets{i}).hmdb,';');
            else
                list{1} = metabolite_structure.(Mets{i}).hmdb;
            end
            list = regexprep(list,' ','');
            for t = 1 : length(list)
           
                url=strcat('https://hmdb.ca/metabolites/',list{t});
                syst = urlread(url);
           
                x = split(syst,'External Links');
                systExt = x{2};
                for k = 1 : size(mapping,1)
                    if strcmp(mapping(k,3),'external')
                        % only search through external links
                        [metabolite_structure,idNew] = getData(metabolite_structure,systExt,Mets{i}, mapping(k,1:2),IDsAdded);
                    else
                        [metabolite_structure,idNew] = getData(metabolite_structure,syst,Mets{i}, mapping(k,1:2),IDsAdded);
                    end
                    if ~isempty(idNew) && length(find(isnan(idNew),1))==0 && ~contains(idNew,'NotAvailable')
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
                                    IDsMismatch{b,2} = mapping{k,1};
                                    IDsMismatch{b,3} = metabolite_structure.(Mets{i}).(mapping{k,1});
                                    IDsMismatch{b,4} = metabolite_structure.(Mets{i}).([mapping{k,1},'_source']);
                                    IDsMismatch{b,5} = list{t};
                                    IDsMismatch{b,6} = char(idNew);
                                    error = idNew;
                                    b=b+1;
                                end
                            end
                        end
                        
                        if printInchis
                            % inchiKeys and inchiStrings separately printed out
                            
                            if strcmp(mapping{k,1},'inchiKey')
                                InchiKeyList{c,1} = Mets{i};
                                InchiKeyList{c,2} = list{t};
                                InchiKeyList{c,3} = idNew;
                                InchiKeyList{c,4} = [annotationSource,':',annotationType,':',datestr(now)];
                                c = c + 1;
                            elseif strcmp(mapping{k,1},'inchiString')
                                InchiStringList{d,1} = Mets{i};
                                InchiStringList{d,2} = list{t};
                                InchiStringList{d,3} = idNew;
                                InchiStringList{d,4} = [annotationSource,':',annotationType,':',datestr(now)];
                                d = d + 1;
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
        [tok,rem] = strtok(string,'&gt');
        idNew = tok;
    elseif (strcmp(map{1,1},'smile'))
        if ~contains(string,'word-break-all') % generally SMILES appears twice in the file and we want the second entry
            string = syst(startvalue(2):startvalue(2)+200);
        end
        if contains(string,'SMILES</th><td><div class="word-break-all">')
            string = regexprep(string,'SMILES</th><td><div class="word-break-all">','');
            [tok,rem] = strtok(string,'<');
        else
            string = split(string,'&gt;');
            tok = strtrim(string{2});
        end
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
    elseif (strcmp(map{1,1},'wikipedia')) && (regexp(string,'http://en.wikipedia.org/wiki/\w+">'))
        [tok,rem] = strtok(string,'>');
        [tok] = regexprep(tok,'http://en.wikipedia.org/wiki/','');
        idNew = regexprep(tok,'\W$','');
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