function [metabolite_structure] = parseVMH4IDs(metabolite_structure,startSearch,endSearch)
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
% metabolite_structure  Updated metabolite structure
%
%
% Ines Thiele, 09/2021

F = fieldnames(metabolite_structure);
if ~exist('startSearch','var')
    startSearch = 1;
end
if ~exist('endSearch','var')
    endSearch = length(F);
end

annotationSource = 'VMH API';
annotationType = 'automatic';

transl={
    % VMH term  structure term
    'metFormula'   'chargedFormula'
    'charge'    'charge'
    'biggId'    'biggId'
    'lmId'  'lipidmaps'
    'hepatonetId'   'hepatonetId'
    'keggId'  'keggId'
    'pubChemId' 'pubChemId'
    'cheBlId'   'cheBIId'
    'chembl'    'chembl'
    'inchiString'   'inchiString'
    'inchiKey'  'inchiKey'
    'smile'  'smile'
    'hmdb'  'hmdb'
    'metanetx'  'metanetx'
    'seed'  'seed'
    'pdmapName' 'pdmapName'
    'reconMap'  'reconMap'
    'reconMap3' 'reconMap3'
    'food_db'   'food_db'
    'chemspider'    'chemspider'
    'biocyc'    'biocyc'
    'wikipedia' 'wikipedia'
    'drugbank'  'drugbank'
    'knapsack'  'knapsack'
    'phenolExplorer' 'phenolExplorer'
    'metlin' 'metlin'
    'casRegistry' 'casRegistry'
    'epa_id'    'epa_id'
    'echa_id'   'echa_id'
    'iuphar_id'	'iuphar_id'
    'fda_id'    'fda_id'
    'mesh_id'	'mesh_id'
    'chodb_id'  'chodb_id'
    };

for i = startSearch : endSearch
    if length(find(isnan(metabolite_structure.(F{i}).VMHId))) == 0 % VMH Id exists
        VMHId = metabolite_structure.(F{i}).VMHId;
        % connect to api
        url = ['https://www.vmh.life/_api/metabolites/?abbreviation=' VMHId];
        syst = urlread(url);
        % only look through hits
        if length(strfind(syst,'&quot;results&quot;: []'))==0
            for k = 1 : size(transl,1)
                % only fill empty fields with this information
                if isempty(metabolite_structure.(F{i}).(transl{k,2})) || length(find(isnan(metabolite_structure.(F{i}).(transl{k,2}))))>0
                    [tok,rem] = split(syst,transl(k,1));
                    if length(tok)>=2
                        [tok2,rem] = split(tok{2},',');
                        x = regexprep(tok2{1},'&quot;: &quot;','');
                        x = regexprep(tok2{1},'&quot;: &quot;','');
                        y = regexprep(x,'&quot;','');
                        y = regexprep(y,':','');
                        y = regexprep(y,'"','');
                        if ~strcmp(y,'null') && ~isempty(y) && ~contains(y,'null')
                            metabolite_structure.(F{i}).(transl{k,2}) = y;
                            metabolite_structure.(F{i}).([transl{k,2} '_source']) = [annotationSource,':',annotationType,':',datestr(now)];
                        end
                    end
                end
            end
        end
    end
end


