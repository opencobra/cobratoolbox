function [metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors)
% perform basic sanity checks

if ~exist('removeErrors', 'var')
    removeErrors = 0;
end

errorFlag = '';
Mets = fieldnames(metabolite_structure);
cnt = 1;
for i = 1 : length(Mets)
    % charge must be numeric
    if ~isnumeric(metabolite_structure.(Mets{i}).charge)
        errorFlag{cnt,1} = Mets{i};
        errorFlag{cnt,2} = metabolite_structure.(Mets{i}).charge;
        errorFlag{cnt,3} = 'charge is not numeric';
        cnt = 1 + cnt;
    end
    % avgmolweight must be numeric
    if  isfield(metabolite_structure.(Mets{i}),'avgmolweight')&& ~isnumeric(metabolite_structure.(Mets{i}).avgmolweight)
        errorFlag{cnt,1} = Mets{i};
        errorFlag{cnt,2} = metabolite_structure.(Mets{i}).avgmolweight;
        errorFlag{cnt,3} = 'avgmolweight is not numeric';
        cnt = 1 + cnt;
        
        if removeErrors
            % remove error
            metabolite_structure.(Mets{i}).avgmolweight = NaN;
            metabolite_structure.(Mets{i}).avgmolweight_source = [];
        end
    end
    % monoisotopicweight must be numeric
    if isfield(metabolite_structure.(Mets{i}),'monoisotopicweight')&& ~isnumeric(metabolite_structure.(Mets{i}).monoisotopicweight)
        errorFlag{cnt,1} = Mets{i};
        errorFlag{cnt,2} = metabolite_structure.(Mets{i}).monoisotopicweight;
        errorFlag{cnt,3} = 'monoisotopicweight is not numeric';
        cnt = 1 + cnt;
        if removeErrors
            % remove error
            metabolite_structure.(Mets{i}).monoisotopicweight = NaN;
            metabolite_structure.(Mets{i}).monoisotopicweight_source = [];
        end
    end
    % pubChemId must be numeric
    if isfield(metabolite_structure.(Mets{i}),'pubChemId')&&  ~isnumeric(metabolite_structure.(Mets{i}).pubChemId)
        errorFlag{cnt,1} = Mets{i};
        errorFlag{cnt,2} = metabolite_structure.(Mets{i}).pubChemId;
        errorFlag{cnt,3} = 'pubChemId is not numeric';
        cnt = 1 + cnt;
        
        if removeErrors
            % remove error
            metabolite_structure.(Mets{i}).pubChemId = NaN;
            metabolite_structure.(Mets{i}).pubChemId_source = [];
        end
    end
    % cheBIId must be numeric
    if isfield(metabolite_structure.(Mets{i}),'cheBIId')&&   ~isnumeric(metabolite_structure.(Mets{i}).cheBIId)
        errorFlag{cnt,1} = Mets{i};
        errorFlag{cnt,2} = metabolite_structure.(Mets{i}).cheBIId;
        errorFlag{cnt,3} = 'cheBIId is not numeric';
        cnt = 1 + cnt;
        
        if removeErrors
            % remove error
            metabolite_structure.(Mets{i}).cheBIId = NaN;
            metabolite_structure.(Mets{i}).cheBIId_source = [];
        end
    end
    % chemspider must be numeric
    if isfield(metabolite_structure.(Mets{i}),'chemspider')&& ~isnumeric(metabolite_structure.(Mets{i}).chemspider)
        errorFlag{cnt,1} = Mets{i};
        errorFlag{cnt,2} = metabolite_structure.(Mets{i}).chemspider;
        errorFlag{cnt,3} = 'chemspider is not numeric';
        cnt = 1 + cnt;
        
        if removeErrors
            % remove error
            metabolite_structure.(Mets{i}).chemspider = NaN;
            metabolite_structure.(Mets{i}).chemspider_source = [];
        end
    end
    % metlin must be numeric
    if isfield(metabolite_structure.(Mets{i}),'metlin')&& ~isnumeric(metabolite_structure.(Mets{i}).metlin)
        errorFlag{cnt,1} = Mets{i};
        errorFlag{cnt,2} = metabolite_structure.(Mets{i}).metlin;
        errorFlag{cnt,3} = 'metlin is not numeric';
        cnt = 1 + cnt;
        
        if removeErrors
            % remove error
            metabolite_structure.(Mets{i}).metlin = NaN;
            metabolite_structure.(Mets{i}).metlin_source = [];
        end
    end
    % keggId must start with C,D, or G
    if  isfield(metabolite_structure.(Mets{i}),'keggId') &&  isempty(find(isnan(metabolite_structure.(Mets{i}).keggId),1))
        if isnumeric(metabolite_structure.(Mets{i}).keggId) || isempty(regexp(metabolite_structure.(Mets{i}).keggId,'^C')) && isempty(regexp(metabolite_structure.(Mets{i}).keggId,'^D')) ...
                && isempty(regexp(metabolite_structure.(Mets{i}).keggId,'^G'))
            errorFlag{cnt,1} = Mets{i};
            errorFlag{cnt,2} = metabolite_structure.(Mets{i}).keggId;
            errorFlag{cnt,3} = 'keggId does not start with C,D, or G';
            cnt = 1 + cnt;
            
            if removeErrors
                % remove error
                metabolite_structure.(Mets{i}).keggId = NaN;
                metabolite_structure.(Mets{i}).keggId_source = [];
            end
        end
    end
    % hmdb must start with HMDB
    if  isfield(metabolite_structure.(Mets{i}),'hmdb')&&  isempty(find(isnan(metabolite_structure.(Mets{i}).hmdb),1))
        if isnumeric(metabolite_structure.(Mets{i}).hmdb) || isempty(regexp(metabolite_structure.(Mets{i}).hmdb,'^HMDB'))
            errorFlag{cnt,1} = Mets{i};
            errorFlag{cnt,2} = metabolite_structure.(Mets{i}).hmdb;
            errorFlag{cnt,3} = 'hmdb does not start with HMDB';
            cnt = 1 + cnt;
            
            if removeErrors
                % remove error
                metabolite_structure.(Mets{i}).hmdb = NaN;
                metabolite_structure.(Mets{i}).hmdb_source = [];
            end
        end
    end
    % reconMap3 must be equal to VMHId
    %     if isnumeric(metabolite_structure.(Mets{i}).reconMap3) || isempty(strmatch(metabolite_structure.(Mets{i}).VMHId,metabolite_structure.(Mets{i}).reconMap3,'exact')) && ...
    %             ~isempty(find(isnan(metabolite_structure.(Mets{i}).reconMap3)))
    %         errorFlag{cnt,1} = Mets{i};
    %         errorFlag{cnt,2} = metabolite_structure.(Mets{i}).reconMap3;
    %         errorFlag{cnt,3} = 'reconMap3 is not equal to VMHId';
    %         cnt = 1 + cnt;
    %     end
    
    % food_db must start with FDB
    if isfield(metabolite_structure.(Mets{i}),'food_db')&&   isempty(find(isnan(metabolite_structure.(Mets{i}).food_db),1))
        if isnumeric(metabolite_structure.(Mets{i}).food_db) ||isempty(regexp(metabolite_structure.(Mets{i}).food_db,'^FDB'))
            errorFlag{cnt,1} = Mets{i};
            errorFlag{cnt,2} = metabolite_structure.(Mets{i}).food_db;
            errorFlag{cnt,3} = 'food_db does not start with FDB';
            cnt = 1 + cnt;
            
            if removeErrors
                % remove error
                metabolite_structure.(Mets{i}).food_db = NaN;
                metabolite_structure.(Mets{i}).food_db_source = [];
            end
        end
    end
    % metanetx must start with MNXM
    if isfield(metabolite_structure.(Mets{i}),'metanetx')&&  isempty(find(isnan(metabolite_structure.(Mets{i}).metanetx),1))
        if isnumeric(metabolite_structure.(Mets{i}).metanetx) ||isempty(regexp(metabolite_structure.(Mets{i}).metanetx,'^MNXM'))
            errorFlag{cnt,1} = Mets{i};
            errorFlag{cnt,2} = metabolite_structure.(Mets{i}).metanetx;
            errorFlag{cnt,3} = 'metanetx does not start with MNXM';
            cnt = 1 + cnt;
            
            if removeErrors
                % remove error
                metabolite_structure.(Mets{i}).metanetx = NaN;
                metabolite_structure.(Mets{i}).metanetx_source = [];
            end
        end
    end
    % epa_id must start with DTX
    if  isfield(metabolite_structure.(Mets{i}),'epa_id')&&  isempty(find(isnan(metabolite_structure.(Mets{i}).epa_id),1))
        if isnumeric(metabolite_structure.(Mets{i}).epa_id) ||isempty(regexp(metabolite_structure.(Mets{i}).epa_id,'^DTX'))
            errorFlag{cnt,1} = Mets{i};
            errorFlag{cnt,2} = metabolite_structure.(Mets{i}).epa_id;
            errorFlag{cnt,3} = 'epa_id does not start with DTX';
            cnt = 1 + cnt;
            
            if removeErrors
                % remove error
                metabolite_structure.(Mets{i}).epa_id = NaN;
                metabolite_structure.(Mets{i}).epa_id_source = [];
            end
        end
    end
    % seed must start with cpd
    if  isfield(metabolite_structure.(Mets{i}),'seed')&&  isempty(find(isnan(metabolite_structure.(Mets{i}).seed),1))
        if isnumeric(metabolite_structure.(Mets{i}).seed) ||isempty(regexp(metabolite_structure.(Mets{i}).seed,'^cpd'))
            errorFlag{cnt,1} = Mets{i};
            errorFlag{cnt,2} = metabolite_structure.(Mets{i}).seed;
            errorFlag{cnt,3} = 'seed does not start with cpd';
            cnt = 1 + cnt;
            if removeErrors
                % remove error
                metabolite_structure.(Mets{i}).seed = NaN;
                metabolite_structure.(Mets{i}).seed_source = [];
            end
        end
    end
    % casRegistry must contain 2 -
    if isfield(metabolite_structure.(Mets{i}),'casRegistry')&& isempty(find(isnan(metabolite_structure.(Mets{i}).casRegistry),1))
        if isnumeric(metabolite_structure.(Mets{i}).casRegistry) ||isempty(regexp(metabolite_structure.(Mets{i}).casRegistry,'\d*-\d*-\d*'))
            errorFlag{cnt,1} = Mets{i};
            errorFlag{cnt,2} = metabolite_structure.(Mets{i}).casRegistry;
            errorFlag{cnt,3} = 'casRegistry does not follow \d*-\d*-\d*';
            cnt = 1 + cnt;
            if removeErrors
                % remove error
                metabolite_structure.(Mets{i}).casRegistry = NaN;
                metabolite_structure.(Mets{i}).casRegistry_source = [];
            end
        end
    end
    % inchiKey must contain 2 -
    if  isfield(metabolite_structure.(Mets{i}),'inchiKey')&&  isempty(find(isnan(metabolite_structure.(Mets{i}).inchiKey),1))
        if isnumeric(metabolite_structure.(Mets{i}).inchiKey) ||isempty(regexp(metabolite_structure.(Mets{i}).inchiKey,'[A-Z]+-[A-Z]+-[A-Z]'))
            errorFlag{cnt,1} = Mets{i};
            errorFlag{cnt,2} = metabolite_structure.(Mets{i}).inchiKey;
            errorFlag{cnt,3} = 'inchiKey does not follow [A-Z]+-[A-Z]+-[A-Z]+';
            cnt = 1 + cnt;
            if removeErrors
                % remove error
                metabolite_structure.(Mets{i}).inchiKey = NaN;
                metabolite_structure.(Mets{i}).inchiKey_source = [];
            end
        end
    end
    % inchiString must start with InChI=
    if isfield(metabolite_structure.(Mets{i}),'inchiString')&& isempty(find(isnan(metabolite_structure.(Mets{i}).inchiString),1))
        if isnumeric(metabolite_structure.(Mets{i}).inchiString) ||isempty(regexp(metabolite_structure.(Mets{i}).inchiString,'^InChI='))
            errorFlag{cnt,1} = Mets{i};
            errorFlag{cnt,2} = metabolite_structure.(Mets{i}).inchiString;
            errorFlag{cnt,3} = 'inchiString does not follow ^InChI=';
            cnt = 1 + cnt;
            if removeErrors
                % remove error
                metabolite_structure.(Mets{i}).inchiString = NaN;
                metabolite_structure.(Mets{i}).inchiString_source = NaN;
            end
        end
    end
end