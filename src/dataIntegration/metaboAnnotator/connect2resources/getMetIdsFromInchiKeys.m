function [metabolite_structure, IDsAdded] = getMetIdsFromInchiKeys(metabolite_structure, inchiKeyCheck, inchiStringCheck, inchiKeyAltCheck, metList)
% Connect to UniChem and grab available identifiers (ChEBI, PubChem,
% MetaboLights, Rhea, SwissLipids, BindingDB, DrugBank, KEGG, HMDB, EPA and
% LipidMaps) for metabolites that have InChIKeys or InChIStrings.
%
% USAGE:
%
%    [metabolite_structure, IDsAdded] = getMetIdsFromInchiKeys(metabolite_structure, inchiKeyCheck, inchiStringCheck, inchiKeyAltCheck, metList)
%
% INPUTS:
%    metabolite_structure:    metabolite structure whose fields are VMH
%                             metabolite IDs, each holding InChIKey/InChIString
%                             fields
%    inchiKeyCheck:           if true, query UniChem using the InChIKey
%    inchiStringCheck:        if true, query UniChem using the InChIString
%    inchiKeyAltCheck:        if true, query UniChem using the neutral form of
%                             the InChIKey
%
% OPTIONAL INPUT:
%    metList:                 list of metabolite field names to process
%                             (default: all fields of metabolite_structure)
%
% OUTPUTS:
%    metabolite_structure:    metabolite structure updated with the retrieved
%                             identifiers
%    IDsAdded:                cell array logging the added identifiers, with the
%                             metabolite field name, the identifier type, and
%                             the assigned identifier per row
%
% .. Author: - I.T., Aug 2020

if exist('metList', 'var')
    Mets = metList;
else
    Mets = fieldnames(metabolite_structure);
end
a = 1;
% add new fields to metabolite_structure that will be collected in this
% function but may not be present in the structure yet
fields = fieldnames(metabolite_structure.(Mets{301}));
IDsAdded = '';
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
[missingfields,map] = setdiff(ids(:,1),fields);
for i = 1 : length(Mets)
    for j = 1 : length(missingfields)
        metabolite_structure.(Mets{i}).(missingfields{j}) = NaN;
    end
end

for i = 3001 : 4000%length(Mets)
    i
    % add missing fields to each metabolite in the metabolite structure
    for j = 1 : length(missingfields)
        metabolite_structure.(Mets{i}).(missingfields{j}) = NaN;
    end
    
    for j = 1 : length(ids)
        if inchiKeyCheck
            inchiKey = metabolite_structure.(Mets{i}).inchiKey;
            if ~isnan(inchiKey)
                url=strcat('https://www.ebi.ac.uk/unichem/frontpage/results?queryText=',inchiKey,'&kind=InChIKey&sources=&incl=exclude');
                syst = urlread(url);
                
                
                if ~isempty(find(isnan(metabolite_structure.(Mets{i}).(ids{j,1})))) || isempty(metabolite_structure.(Mets{i}).(ids{j,1}))
                    startvalue=strfind(syst,ids(j,2));
                    if ~isempty(startvalue)
                        string = syst(startvalue(1):startvalue(1)+100);
                        [tok,rem] = strtok(string,'>');
                        idNew = regexprep(rem,'</a></td>','');
                        idNew = regexprep(idNew,'>','');
                        idNew = regexprep(idNew,'</a</t','');
                        idNew = cellstr(idNew);
                        metabolite_structure.(Mets{i}).(ids{j,1}) = char(idNew);
                        clear startvalue;
                        IDsAdded{a,1} = Mets{i};
                        IDsAdded{a,2} = ids{j,1};
                        IDsAdded{a,3} = char(idNew);
                        a=a+1;
                    end
                end
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
            syst = urlread(url);
            
            
            if ~isempty(find(isnan(metabolite_structure.(Mets{i}).(ids{j,1})))) || isempty(metabolite_structure.(Mets{i}).(ids{j,1}))
                startvalue=strfind(syst,ids(j,2));
                if ~isempty(startvalue)
                    string = syst(startvalue(1):startvalue(1)+100);
                    [tok,rem] = strtok(string,'>');
                    idNew = regexprep(rem,'</a></td>','');
                    idNew = regexprep(idNew,'>','');
                    idNew = regexprep(idNew,'</a</t','');
                    idNew = cellstr(idNew);
                    metabolite_structure.(Mets{i}).(ids{j,1}) = char(idNew);
                    clear startvalue;
                    IDsAdded{a,1} = Mets{i};
                    IDsAdded{a,2} = ids{j,1};
                    IDsAdded{a,3} = char(idNew);
                    a=a+1;
                end
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
            syst = urlread(url);
            
            
            if ~isempty(find(isnan(metabolite_structure.(Mets{i}).(ids{j,1})))) || isempty(metabolite_structure.(Mets{i}).(ids{j,1}))
                startvalue=strfind(syst,ids(j,2));
                if ~isempty(startvalue)
                    string = syst(startvalue(1):startvalue(1)+100);
                    [tok,rem] = strtok(string,'>');
                    idNew = regexprep(rem,'</a></td>','');
                    idNew = regexprep(idNew,'>','');
                    idNew = cellstr(idNew);
                    metabolite_structure.(Mets{i}).(ids{j,1}) = char(idNew);
                    clear startvalue;
                    IDsAdded{a,1} = Mets{i};
                    IDsAdded{a,2} = ids{j,1};
                    IDsAdded{a,3} = char(idNew);
                    a = a + 1;
                end
            end
        end
    end
end