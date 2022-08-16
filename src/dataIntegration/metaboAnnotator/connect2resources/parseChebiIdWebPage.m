function [metabolite_structure,IDsAdded,InchiKeyList,InchiStringList ] = parseChebiIdWebPage(metabolite_structure,startSearch,endSearch,printInchis)


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

% get inchiKey and smiles from chebiid

warning off;
annotationSource = 'ChEBI website';
annotationType = 'automatic';

IDsAdded = ''; a=1;
InchiStringList = ''; c=1;
InchiKeyList = '';d=1;

fields = fieldnames(metabolite_structure.(Mets{1}));
for i = startSearch : endSearch
    % check that chebiid exists
    if ~isempty(metabolite_structure.(Mets{i}).cheBIId) && isempty(find(isnan(metabolite_structure.(Mets{i}).cheBIId),1))
        % check that smile or inchiKey does not exist
        % go to chebi and parse website for smile
        if isnumeric(metabolite_structure.(Mets{i}).cheBIId)
metabolite_structure.(Mets{i}).cheBIId = num2str(isnumeric(metabolite_structure.(Mets{i}).cheBIId));
        end

        metabolite_structure.(Mets{i}).cheBIId = regexprep(metabolite_structure.(Mets{i}).cheBIId,',',';');
        if contains(metabolite_structure.(Mets{i}).cheBIId,';')
            list = split(metabolite_structure.(Mets{i}).cheBIId,';');
        else
            list{1} = metabolite_structure.(Mets{i}).cheBIId;
        end
        list = regexprep(list,' ','');
        for t = 1 : length(list)
            url=strcat('https://www.ebi.ac.uk/chebi/searchId.do?chebiId=CHEBI:',num2str(list{t}));
            syst = urlread(url);
            if isempty(metabolite_structure.(Mets{i}).smile) || ~isempty(find(isnan(metabolite_structure.(Mets{i}).smile),1))
                startvalue=strfind(syst,'>SMILES</td>');
                % smile is in the next line
                try
                    string = syst(startvalue(1):startvalue(1)+100);
                    [tok,rem] = strtok(string,'>');
                    rem = regexprep(rem,'<td>','');
                    [tok2,rem2] = strtok(rem,'<');
                    tok2 = regexprep(tok2,'>','');
                    idNew = regexprep(tok2,'\s','');
                    idNew = cellstr(idNew);
                    metabolite_structure.(Mets{i}).smile = char(idNew);
                    metabolite_structure.(Mets{i}).smile_source =[annotationSource,':',annotationType,':',datestr(now)];
                    clear startvalue;
                    IDsAdded{a,1} = Mets{i};
                    IDsAdded{a,2} = 'smile';
                    IDsAdded{a,3} = char(idNew);
                    a=a+1;
                end
            end
            if isempty(metabolite_structure.(Mets{i}).inchiKey) || ~isempty(find(isnan(metabolite_structure.(Mets{i}).inchiKey),1))
                startvalue=strfind(syst,'>InChIKey</td>');
                % smile is in the next line
                try
                    string = syst(startvalue(1):startvalue(1)+100);
                    [tok,rem] = strtok(string,'>');
                    
                    rem = regexprep(rem,'<td>','');
                    [tok2,rem2] = strtok(rem,'<');
                    tok2 = regexprep(tok2,'>','');
                    idNew = regexprep(tok2,'\s','');
                    metabolite_structure.(Mets{i}).inchiKey = idNew;
                    metabolite_structure.(Mets{i}).inchiKey_source =[annotationSource,':',annotationType,':',datestr(now)];
                    clear startvalue;
                    IDsAdded{a,1} = Mets{i};
                    IDsAdded{a,2} = 'inchiKey';
                    IDsAdded{a,3} = char(idNew);
                    a=a+1;
                end
            end
            if isempty(metabolite_structure.(Mets{i}).inchiString) || ~isempty(find(isnan(metabolite_structure.(Mets{i}).inchiString),1))
                startvalue=strfind(syst,'td>InChI=');
                % smile is in the next line
                try
                    string = syst(startvalue(1):startvalue(1)+1000);
                    [tok,rem] = strtok(string,'>');
                    [tok2,rem2] = strtok(rem,'<');
                    idNew = regexprep(tok2,'>','');
                    metabolite_structure.(Mets{i}).inchiString = idNew;
                    metabolite_structure.(Mets{i}).inchiString_source =[annotationSource,':',annotationType,':',datestr(now)];
                    clear startvalue;
                    IDsAdded{a,1} = Mets{i};
                    IDsAdded{a,2} = 'inchiString';
                    IDsAdded{a,3} = char(idNew);
                    a=a+1;
                end
            end
            
            
            if isempty(metabolite_structure.(Mets{i}).wikipedia) || ~isempty(find(isnan(metabolite_structure.(Mets{i}).wikipedia),1))
                startvalue=strfind(syst,'Read full article at Wikipedia');
                % smile is in the next line
                try
                    string = syst(startvalue(1)-100:startvalue(1));
                    [tok,rem] = strtok(string,'wiki');
                    
                    rem = regexprep(rem,'wikipedia.org/wiki/','');
                    rem = regexprep(rem,'target="_blank">R','');
                    idNew = regexprep(rem,'" ','');
                    metabolite_structure.(Mets{i}).wikipedia = idNew;
                    metabolite_structure.(Mets{i}).wikipedia_source =[annotationSource,':',annotationType,':',datestr(now)];
                    
                    clear startvalue;
                    IDsAdded{a,1} = Mets{i};
                    IDsAdded{a,2} = 'wikipedia';
                    IDsAdded{a,3} = char(idNew);
                    a=a+1;
                end
            end
            if isempty(metabolite_structure.(Mets{i}).knapsack) || ~isempty(find(isnan(metabolite_structure.(Mets{i}).knapsack),1))
                startvalue=strfind(syst,'http://www.knapsackfamily.com/knapsack');
                % smile is in the next line
                try
                    string = syst(startvalue(1):startvalue(1)+200);
                    [tok,rem] = strtok(string,'>');
                    [tok2,rem2] = strtok(rem,'<');
                    idNew = regexprep(tok2,'>','');
                    metabolite_structure.(Mets{i}).knapsack = idNew;
                    metabolite_structure.(Mets{i}).knapsack_source =[annotationSource,':',annotationType,':',datestr(now)];
                    clear startvalue;
                    IDsAdded{a,1} = Mets{i};
                    IDsAdded{a,2} = 'knapsack';
                    IDsAdded{a,3} = char(idNew);
                    a=a+1;
                end
            end
            if isempty(metabolite_structure.(Mets{i}).keggId) || ~isempty(find(isnan(metabolite_structure.(Mets{i}).keggId),1))
                startvalue=strfind(syst,'http://www.genome.ad.jp');
                % smile is in the next line
                try
                    string = syst(startvalue(1):startvalue(1)+200);
                    [tok,rem] = strtok(string,'>');
                    [tok2,rem2] = strtok(rem,'<');
                    idNew = regexprep(tok2,'>','');
                    metabolite_structure.(Mets{i}).keggId = idNew;
                    metabolite_structure.(Mets{i}).keggId_source =[annotationSource,':',annotationType,':',datestr(now)];
                    clear startvalue;
                    IDsAdded{a,1} = Mets{i};
                    IDsAdded{a,2} = 'keggId';
                    IDsAdded{a,3} = char(idNew);
                    a=a+1;
                end
            end
            if isempty(metabolite_structure.(Mets{i}).biocyc) || ~isempty(find(isnan(metabolite_structure.(Mets{i}).biocyc),1))
                startvalue=strfind(syst,'http://biocyc.org/');
                % smile is in the next line
                try
                    string = syst(startvalue(1):startvalue(1)+200);
                    [tok,rem] = strtok(string,'>');
                    [tok2,rem2] = strtok(rem,'<');
                    idNew = regexprep(tok2,'>','');
                    metabolite_structure.(Mets{i}).biocyc = idNew;
                    metabolite_structure.(Mets{i}).biocyc_source =[annotationSource,':',annotationType,':',datestr(now)];
                    clear startvalue;
                    IDsAdded{a,1} = Mets{i};
                    IDsAdded{a,2} = 'biocyc';
                    IDsAdded{a,3} = char(idNew);
                    a=a+1;
                end
            end
            if isempty(metabolite_structure.(Mets{i}).hmdb) || ~isempty(find(isnan(metabolite_structure.(Mets{i}).hmdb),1))
                startvalue=strfind(syst,'http://www.hmdb.ca');
                try
                    % smile is in the next line
                    string = syst(startvalue(1):startvalue(1)+200);
                    [tok,rem] = strtok(string,'>');
                    [tok2,rem2] = strtok(rem,'<');
                    idNew = regexprep(tok2,'>','');
                    metabolite_structure.(Mets{i}).hmdb = idNew;
                    metabolite_structure.(Mets{i}).hmdb_source =[annotationSource,':',annotationType,':',datestr(now)];
                    clear startvalue;
                    IDsAdded{a,1} = Mets{i};
                    IDsAdded{a,2} = 'hmdb';
                    IDsAdded{a,3} = char(idNew);
                    a=a+1;
                end
            end
            if isempty(metabolite_structure.(Mets{i}).casRegistry) || ~isempty(find(isnan(metabolite_structure.(Mets{i}).casRegistry),1))
                startvalue=strfind(syst,'https://chem.nlm.nih.gov/chemidplus/');
                % smile is in the next line
                try
                    string = syst(startvalue(1):startvalue(1)+200);
                    [tok,rem] = strtok(string,'>');
                    [tok2,rem2] = strtok(rem,'<');
                    idNew = regexprep(tok2,'>','');
                    metabolite_structure.(Mets{i}).casRegistry = idNew;
                    metabolite_structure.(Mets{i}).casRegistry_source =[annotationSource,':',annotationType,':',datestr(now)];
                    clear startvalue;
                    IDsAdded{a,1} = Mets{i};
                    IDsAdded{a,2} = 'casRegistry';
                    IDsAdded{a,3} = char(idNew);
                    a=a+1;
                end
            end
            if isempty(metabolite_structure.(Mets{i}).lipidmaps) || ~isempty(find(isnan(metabolite_structure.(Mets{i}).lipidmaps),1))
                startvalue=strfind(syst,'http://www.lipidmaps.org');
                % smile is in the next line
                try
                    string = syst(startvalue(1):startvalue(1)+200);
                    [tok,rem] = strtok(string,'>');
                    [tok2,rem2] = strtok(rem,'<');
                    idNew = regexprep(tok2,'>','');
                    metabolite_structure.(Mets{i}).lipidmaps = idNew;
                    metabolite_structure.(Mets{i}).lipidmaps_source =[annotationSource,':',annotationType,':',datestr(now)];
                    clear startvalue;
                    IDsAdded{a,1} = Mets{i};
                    IDsAdded{a,2} = 'lipidmaps';
                    IDsAdded{a,3} = char(idNew);
                    a=a+1;
                end
            end
            if printInchis
                % inchiKeys and inchiStrings separately printed out
                startvalue=strfind(syst,'>InChIKey</td>');
                try
                    string = syst(startvalue(1):startvalue(1)+100);
                    [tok,rem] = strtok(string,'>');
                    
                    rem = regexprep(rem,'<td>','');
                    [tok2,rem2] = strtok(rem,'<');
                    tok2 = regexprep(tok2,'>','');
                    idNew = regexprep(tok2,'\s','');
                    metabolite_structure.(Mets{i}).inchiKey = idNew;
                    metabolite_structure.(Mets{i}).inchiKey_source =[annotationSource,':',annotationType,':',datestr(now)];
                    clear startvalue;
                    InchiKeyList{c,1} = Mets{i};
                    InchiKeyList{c,2} = list{t};
                    InchiKeyList{c,3} = idNew;
                    InchiKeyList{c,4} = [annotationSource,':',annotationType,':',datestr(now)];
                    c = c + 1;
                end
                % get Inchistring (again)
                startvalue=strfind(syst,'td>InChI=');
                
                try
                    string = syst(startvalue(1):startvalue(1)+1000);
                    [tok,rem] = strtok(string,'>');
                    [tok2,rem2] = strtok(rem,'<');
                    idNew = regexprep(tok2,'>','');
                    metabolite_structure.(Mets{i}).inchiString = idNew;
                    metabolite_structure.(Mets{i}).inchiString_source =[annotationSource,':',annotationType,':',datestr(now)];
                    clear startvalue;
                    InchiStringList{d,1} = Mets{i};
                    InchiStringList{d,2} = list{t};
                    InchiStringList{d,3} = idNew;
                    InchiStringList{d,4} = [annotationSource,':',annotationType,':',datestr(now)];
                    d=d+1;
                end
                
            end
        end
    end
end