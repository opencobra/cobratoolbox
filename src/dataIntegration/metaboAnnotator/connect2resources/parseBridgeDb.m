function [metabolite_structure,IDsAdded,IdsMismatch] = parseBridgeDb(metabolite_structure,startSearch,endSearch)
%% function [metabolite_structure,IDsAdded,IdsMismatch] = parseBridgeDb(metabolite_structure)
% This function takes existing database-dependent identifiers and searches
% BridgeDB (https://bridgedb.github.io/) via their webservice for other
% database identifiers (see below) and adds them to the metabolite
% structure if the metabolite does not have the respective identifier. In
% the case that the metabolite has such identifier already but if there is
% a mismatch, this will be listed in 'IdsMismatch'
%
% INPUT
% metabolite_structure  metabolite structure
%
% OUTPUT
% metabolite_structure  updated metabolite structure
% IDsAdded              List of added IDs from BridgeDB
% IdsMismatch           List of mismatching IDs between VMH and BridgeDB
%
% Ines Thiele   October 2020

annotationSource = 'BridgeDb (online)';
annotationType = 'automatic';

Mets = fieldnames(metabolite_structure);

if ~exist('startSearch','var')
    startSearch = 1;
end
if ~exist('endSearch','var')
    endSearch = length(Mets);
end

for i = startSearch : endSearch
    VMHId{i,1} = Mets{i};
    if isfield(metabolite_structure.(Mets{i}),VMHId)
        VMHId{i,2} = metabolite_structure.(Mets{i}).VMHId;
    else
        VMHId{i,2} = Mets{i};
    end
end
a = 1;
b = 1;
IDsAdded = '';
IdsMismatch = '';

% get ID's from BridgeDB
% translation list:
% https://github.com/bridgedb/BridgeDb/blob/master/org.bridgedb.bio/resources/org/bridgedb/bio/datasources.tsv
mapping={
    'cheBIId'   'Ce'
    'biocyc'    'bc'
    'casRegistry'   'Ca'
    'cheBIId'   'Ce'
    'chemspider'    'Cs'
    'chembl'    'Cl'
    'drugbank'  'Dr'
    'hmdb'  'Ch'
    'iuphar_id'    'Gpl'%	Guide to Pharmacology Ligand ID (aka IUPHAR)
      'inchiKey'  'Ik'
    'keggId'    'Ck'%	KEGG Compound
    'keggId'    'Kd'    %Kd	KEGG Drug
    'keggId'    'Kl'    %Kl	KEGG Glycan
    'lipidmaps'  'Lm'
    'lipidbank' 'Lb'    %Lb	LipidBank
    'pharmgkb'  'Pgd'%	PharmGKB Drug
    'pubChemId' 'Cpc'
    %Cps	PubChem Substance
    'swisslipids'   'Sl'%	SwissLipids
    %Td	TTD Drug
    'wikidata' 'Wd' %Wd	Wikidata
    'wikipedia' 'Wi'%	Wikipedia
    'VMHId' 'VmhM'
    };


for i = startSearch : endSearch
    % use Kegg as query term
    % if ~isempty(metabolite_structure.(Mets{i}).keggId) && isempty(find(isnan(metabolite_structure.(Mets{i}).keggId),1))
    i
    for z = 1 : size(mapping,1)
        if isfield(metabolite_structure.(Mets{i}),(mapping{z,1})) && ~isempty(metabolite_structure.(Mets{i}).(mapping{z,1})) && isempty(find(isnan(metabolite_structure.(Mets{i}).(mapping{z,1})),1))
            %  search for exact term
            try
                % check if the field contains a list, if not go ahead with
                % the search, otw split the list
                metabolite_structure.(Mets{i}).(mapping{z,1}) = regexprep(metabolite_structure.(Mets{i}).(mapping{z,1}),',',';');
                if contains(metabolite_structure.(Mets{i}).(mapping{z,1}),';')
                    list = split(metabolite_structure.(Mets{i}).(mapping{z,1}),';');
                else
                    list = {metabolite_structure.(Mets{i}).(mapping{z,1});};
                end
                for t= 1: length(list)
                    
                    %curl -X POST "https://webservice.bridgedb.org/Human/xrefsBatch/Ck" -H "accept: */*" -H "Content-Type: text/html" -d "C00468";
                    url = strcat('curl -X POST "https://webservice.bridgedb.org/Human/xrefsBatch/',mapping{z,2},'" -H "accept: */*" -H "Content-Type: text/html" -d "',list{t},'"');
                    [w,syst] = system(url);
                    % parse output from syst
                    results = split(syst);
                    for j = 3:length(results) % find the entries with results
                        if contains(results(j),',')
                            hits = split(results{j},',');
                            for k = 1 : length(hits)
                                [tok, rem] = strtok(hits{k},':');
                                if contains(rem,'CHEBI')
                                    rem = regexprep(rem,':CHEBI:','');
                                end
                                
                                Id = regexprep(rem,':','');
                                match = strmatch(tok,mapping(:,2),'exact');
                                if ~isempty(match)
                                    if isempty(metabolite_structure.(Mets{i}).(mapping{match,1})) || ~isempty(find(isnan(metabolite_structure.(Mets{i}).(mapping{match,1})),1))
                                        metabolite_structure.(Mets{i}).(mapping{match,1})= Id;
                                        metabolite_structure.(Mets{i}).([mapping{match,1},'_source'])= [annotationSource,':',annotationType,':',datestr(now)];
                                        IDsAdded{a,1} = Mets{i};
                                        IDsAdded{a,2} = mapping{match,1};
                                        IDsAdded{a,3} = metabolite_structure.(Mets{i}).(mapping{match,1});
                                        a=a+1;
                                    else
                                        % compare BridgeDB and VMH entries
                                        if ~strcmp(metabolite_structure.(Mets{i}).(mapping{match,1}),Id) && ~strcmp(num2str(metabolite_structure.(Mets{i}).(mapping{match,1})),(Id))
                                            IdsMismatch{b,1} = Mets{i};
                                            IdsMismatch{b,2} = metabolite_structure.(Mets{i}).fullName;
                                            IdsMismatch{b,3} = mapping{match,1};
                                            IdsMismatch{b,4} = metabolite_structure.(Mets{i}).(mapping{match,1});
                                            IdsMismatch{b,5} = metabolite_structure.(Mets{i}).([mapping{match,1},'_source']);
                                            IdsMismatch{b,6} = Id;
                                            IdsMismatch{b,7} =  [annotationSource,':',annotationType,':',datestr(now)];
                                            b = b+1;
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

[metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure,startSearch,endSearch);