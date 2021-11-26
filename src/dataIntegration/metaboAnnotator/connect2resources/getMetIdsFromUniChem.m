function [metabolite_structure,IDsAdded] = getMetIdsFromUniChem(metabolite_structure,startSearch,endSearch,vmhIdCheck,cheBIIdCheck,drugBankCheck, pubChemIdCheck,keggIdCheck,hmdbCheck, inchiKeyCheck, inchiStringCheck,inchiKeyAltCheck )

% This function connects to UniChem and grebs available ID's for
% metabolites that have Inchi Strings.

% I.T., Aug 2020
% POSSIBLE query terms for UniChem

if ~exist('cheBIIdCheck', 'var')
    cheBIIdCheck = 0;
end
if ~exist('vmhIdCheck', 'var')
    vmhIdCheck = 0;
end
if ~exist('drugBankCheck', 'var')
    drugBankCheck = 0;
end
if ~exist('cheBIIdCheck', 'var')
    cheBIIdCheck = 0;
end
if ~exist('hmdbCheck', 'var')
    hmdbCheck = 0;
end
if ~exist('keggIdCheck', 'var')
    keggIdCheck = 0;
end
if ~exist('pubChemIdCheck', 'var')
    cheBIIdCheck = 0;
end

% checks based on InchiKey/InchiString
if ~exist('inchiKeyCheck', 'var')
    inchiKeyCheck = 0;
end
if ~exist('inchiStringCheck', 'var')
    inchiStringCheck = 0;
end
if ~exist('inchiKeyAltCheck', 'var')
    inchiKeyAltCheck = 0;
end
if ~exist('pubChemIdCheck', 'var')
    pubChemIdCheck = 0;
end

annotationSource = 'UniChem website';
annotationType = 'automatic';

% specify the metabolites to be searching IDs for. If not defined, then
% assign all metabolites in metabolite_structure to be searched for.
    Mets = fieldnames(metabolite_structure);
if ~exist('startSearch','var')
    startSearch = 1;
end
if ~exist('endSearch','var')
    endSearch = length(Mets);
end



a = 1;
% add new fields to metabolite_structure that will be collected in this
% function but may not be present in the structure yet
fields = fieldnames(metabolite_structure.(Mets{1}));
IDsAdded = '';
% how to find and parse the different IDs in the webpage
ids = {'cheBIId'    'http://www.ebi.ac.uk/chebi/searchId.do?chebiId'
    'pubChemId' 'http://pubchem.ncbi.nlm.nih.gov/compound'
    'metabolights'  'http://www.ebi.ac.uk/metabolights/'
    'rhea'  'http://www.rhea-db.org/searchresults'
    'swisslipids'  'http://www.swisslipids.org/#/entity/'
    'bindingdb' 'http://www.bindingdb.org/bind/chemsearch/marvin'
    'drugbank'  'http://www.drugbank.ca/drugs/'
    'keggId'    'http://www.genome.jp/dbget-bin'
    'hmdb'  'http://www.hmdb.ca/metabolites'
    'epa_id'    'https://comptox.epa.gov/dashboard/'
    'lipidmaps'  'http://www.lipidmaps.org/data/LMSDRecord'
    };

for i = startSearch : endSearch
    %check if Recon ID exists - if so, no other checks will be carried out
    %as redundant
    if vmhIdCheck
        VMHId = metabolite_structure.(Mets{i}).VMHId;
        if ~isnan(VMHId)
            url=strcat('https://www.ebi.ac.uk/unichem/frontpage/results?queryText=',VMHId,'%0D%0A&kind=src_compound_id&sources=27&incl=exclude');
            syst = urlread(url);
            hit=strfind(syst,'was not found in UniChem');
            if isempty(hit)%hit was found
                for j = 1 : length(ids)
                    [metabolite_structure,IDsAdded] = addDataCollected(metabolite_structure,syst, IDsAdded,Mets,i,ids,j,annotationSource,annotationType);
                end
            end
        end
    end
    if inchiKeyCheck
        inchiKey = metabolite_structure.(Mets{i}).inchiKey;
        if ~isnan(inchiKey)
            url=strcat('https://www.ebi.ac.uk/unichem/frontpage/results?queryText=',inchiKey,'&kind=InChIKey&sources=&incl=exclude');
            try
                syst = urlread(url);
                for j = 1 : length(ids)
                    [metabolite_structure,IDsAdded] = addDataCollected(metabolite_structure,syst, IDsAdded,Mets,i,ids,j,annotationSource,annotationType);
                end
            catch
                continue;
            end
        end
    end
    
    if inchiStringCheck
        % repeat the same using the inchi string
        inchiString = metabolite_structure.(Mets{i}).inchiString;
        if ~isnan(inchiString)
            inchiString = strrep(inchiString,'=','%3D');
            inchiString = strrep(inchiString,'/','%2F');
            inchiString = strrep(inchiString,'(','%28');
            inchiString = strrep(inchiString,'\)','%29');
            inchiString = strrep(inchiString,'?','%3F');
            inchiString = strrep(inchiString,',','%2C');
            url=strcat('https://www.ebi.ac.uk/unichem/frontpage/results?queryText=',inchiString,'&kind=InChI&sources=&incl=exclude');
            try
                syst = urlread(url);
                for j = 1 : length(ids)
                    [metabolite_structure,IDsAdded] = addDataCollected(metabolite_structure,syst, IDsAdded,Mets,i,ids,j,annotationSource,annotationType);
                end
            catch
                continue;
            end
        end
    end
    if inchiKeyAltCheck
        %check for the neutral form
        inchiKey = metabolite_structure.(Mets{i}).inchiKey;
        
        if ~isnan(inchiKey)
            [tok,rem] = split(inchiKey,'-');
            inchiKey = strcat(tok{1},'-',tok{2},'-N');
            url=strcat('https://www.ebi.ac.uk/unichem/frontpage/results?queryText=',inchiKey,'&kind=InChIKey&sources=&incl=exclude');
            try
                syst = urlread(url);
                
                for j = 1 : length(ids)
                    [metabolite_structure,IDsAdded] = addDataCollected(metabolite_structure,syst, IDsAdded,Mets,i,ids,j,annotationSource,annotationType);
                end
            catch
                continue;
            end
        end
    end
    if cheBIIdCheck
        % retrieve ID
        cheBIId = metabolite_structure.(Mets{i}).cheBIId;
        
        if ~isnan(cheBIId)
            url=strcat('https://www.ebi.ac.uk/unichem/frontpage/results?queryText=',num2str(cheBIId),'%0D%0A&kind=src_compound_id&sources=7&incl=exclude');
            try
                syst = urlread(url);
                for j = 1 : length(ids)
                    % Parse and add new IDs to metabolite_structure
                    [metabolite_structure,IDsAdded] = addDataCollected(metabolite_structure,syst, IDsAdded,Mets,i,ids,j,annotationSource,annotationType);
                end
            catch
                continue;
            end
        end
    end
    if drugBankCheck % retrieve ID
        drugbank = metabolite_structure.(Mets{i}).drugbank;
        
        if ~isnan(drugbank)
            drugbank = regexprep(drugbank,'\s','');
            url=strcat('https://www.ebi.ac.uk/unichem/frontpage/results?queryText=',drugbank,'%0D%0A&kind=src_compound_id&sources=2&incl=exclude');
            try
                syst = urlread(url);
                for j = 1 : length(ids)
                    % Parse and add new IDs to metabolite_structure
                    [metabolite_structure,IDsAdded] = addDataCollected(metabolite_structure,syst, IDsAdded,Mets,i,ids,j,annotationSource,annotationType);
                end
            catch
                continue;
            end
        end
    end
    if pubChemIdCheck % retrieve ID
        pubChemId = metabolite_structure.(Mets{i}).pubChemId;
        
        if ~isnan(pubChemId)
            url=strcat('https://www.ebi.ac.uk/unichem/frontpage/results?queryText=',num2str(pubChemId),'%0D%0A&kind=src_compound_id&sources=22&incl=exclude');
            try
                syst = urlread(url);
                url
                for j = 1 : length(ids)
                    % Parse and add new IDs to metabolite_structure
                    [metabolite_structure,IDsAdded] = addDataCollected(metabolite_structure,syst, IDsAdded,Mets,i,ids,j,annotationSource,annotationType);
                end
            catch
                continue;
            end
        end
    end
    if keggIdCheck % retrieve ID
        keggId = metabolite_structure.(Mets{i}).keggId;
        
        if ~isnan(keggId)
            url=strcat('https://www.ebi.ac.uk/unichem/frontpage/results?queryText=',keggId,'%0D%0A&kind=src_compound_id&sources=6&incl=exclude');
            try
                syst = urlread(url);
                
                for j = 1 : length(ids)
                    % Parse and add new IDs to metabolite_structure
                    [metabolite_structure,IDsAdded] = addDataCollected(metabolite_structure,syst, IDsAdded,Mets,i,ids,j,annotationSource,annotationType);
                end
            catch
                continue;
            end
        end
    end
    if hmdbCheck % retrieve ID
        hmdb = metabolite_structure.(Mets{i}).hmdb;
        
        if ~isnan(hmdb)
            url=strcat('https://www.ebi.ac.uk/unichem/frontpage/results?queryText=',hmdb,'%0D%0A&kind=src_compound_id&sources=18&incl=exclude');
            try
                syst = urlread(url);
                
                for j = 1 : length(ids)
                    % Parse and add new IDs to metabolite_structure
                    [metabolite_structure,IDsAdded] = addDataCollected(metabolite_structure,syst, IDsAdded,Mets,i,ids,j,annotationSource,annotationType);
                end
            catch
                continue;
            end
        end
    end
    
end

function [metabolite_structure,IDsAdded] = addDataCollected(metabolite_structure,syst, IDsAdded,Mets,i,ids,j,annotationSource,annotationType)

if ~isempty(find(isnan(metabolite_structure.(Mets{i}).(ids{j,1})))) || isempty(metabolite_structure.(Mets{i}).(ids{j,1}))
    startvalue=strfind(syst,ids(j,2));
    if ~isempty(startvalue)
        a = size(IDsAdded,1)+1;
        string = syst(startvalue(1):startvalue(1)+100);
        [tok,rem] = strtok(string,'>');
        idNew = regexprep(rem,'</a></td>','');
        idNew = regexprep(idNew,'>','');
        idNew = regexprep(idNew,'</a</t','');
        idNew = cellstr(idNew);
        metabolite_structure.(Mets{i}).(ids{j,1}) = char(idNew);
        metabolite_structure.(Mets{i}).([ids{j,1} '_source']) = [annotationSource,':',annotationType,':',datestr(now)];
        clear startvalue;
        IDsAdded{a,1} = Mets{i};
        IDsAdded{a,2} = ids{j,1};
        IDsAdded{a,3} = char(idNew);
    end
end
