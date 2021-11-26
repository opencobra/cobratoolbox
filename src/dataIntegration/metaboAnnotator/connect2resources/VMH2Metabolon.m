function [metabolite_structure] = VMH2Metabolon(metabolite_structure)
% read in Metabolon to VMH mapping which has been done in parts manually
% and cross checked from two sides independently. Currently, we have 400
% metabolites mapped.
% information missing in the current rBioNet flat files will be substituted
% with this information.
% I will also read in the Metabolon ID. (CHEM_ID in this input file).
%
% INPUT
% metabolite_structure  metabolite structure
%
% OUTPUT
% metabolite_structure  Updated metabolite structure
%
%
% Ines Thiele, 09/2021

fileName = 'metabolon_crossmatch_IT_withUpdatedInchiKey.xlsx';

[NUM,TXT,RAW]=xlsread(fileName);
annotationSource = fileName;
annotationType = 'manual';
annotationVerification = 'verified';

vmh_col = find(contains(lower(RAW(1,:)),'vmh'));
hmdb_col = find(contains(lower(RAW(1,:)),'hmdb'));
metabolon_col = find(contains(lower(RAW(1,:)),'chem_id'));
inchiK_col = find(contains(lower(RAW(1,:)),'inchikey'));
inchiS_col = find(contains(lower(RAW(1,:)),'inchistring'));
cas_col = find(contains(lower(RAW(1,:)),'cas'));
chemS_col = find(contains(lower(RAW(1,:)),'chemspider'));
kegg_col = find(contains(lower(RAW(1,:)),'kegg'));
pubC_col = find(contains(lower(RAW(1,:)),'pubchem'));

[VMH2IDmappingAll,VMH2IDmappingPresent,VMH2IDmappingMissing]=getIDfromMetStructure(metabolite_structure,'VMHId');
for i = 2 : size(RAW,1)
    if ~isempty(RAW{i,vmh_col}) && length(find(isnan(RAW{i,vmh_col}))) == 0 && ...
            length( strfind(RAW{i,vmh_col},'/')) == 0 % do not consider unspecified matches
        % some entries have multiple matches, which are separated by ','
        if strfind(RAW{i,vmh_col},',')
            tmp = split(RAW{i,vmh_col},',');
            for j = 1 : length(tmp)
                vmhId{j} =  (VMH2IDmappingAll{find(ismember(VMH2IDmappingAll(:,2),tmp{j})),1});
            end
        else
            % there seems to be 1 metabolite
            % (https://www.vmh.life/#metabolite/N1aspmd) from the online
            % rBioNet version
            tmp = find(ismember(VMH2IDmappingAll(:,2),RAW{i,vmh_col}));
            if ~isempty(tmp)
            vmhId =  cellstr(VMH2IDmappingAll{tmp,1});
            end
        end
        for j = 1 : length(vmhId)
            
            % assign metabolon ID - I allow overwriting
            if ~isempty(RAW{i,metabolon_col})
                metabolite_structure.(vmhId{j}).metabolon = RAW{i,metabolon_col};
                metabolite_structure.(vmhId{j}).metabolon_source = [annotationSource,':',annotationType,':',datestr(now)];
            end
            % assign inchikey- I allow overwriting
            if ~isempty(RAW{i,inchiK_col})
                metabolite_structure.(vmhId{j}).inchiKey = RAW{i,inchiK_col};
                metabolite_structure.(vmhId{j}).inchiKey_source = [annotationSource,':',annotationType,':',datestr(now)];
            end
            % assign hmdb ID - I allow overwriting
            if ~isempty(RAW{i,hmdb_col})
                metabolite_structure.(vmhId{j}).hmdb = RAW{i,hmdb_col};
                metabolite_structure.(vmhId{j}).hmdb_source = [annotationSource,':',annotationType,':',datestr(now)];
            end
            % assign inchistring - I allow overwriting
            if ~isempty(RAW{i,inchiS_col})
                metabolite_structure.(vmhId{j}).inchiString = RAW{i,inchiS_col};
                metabolite_structure.(vmhId{j}).inchiString_source = [annotationSource,':',annotationType,':',datestr(now)];
            end
            % assign casRegistry ID - I allow overwriting
            if ~isempty(RAW{i,cas_col})
                metabolite_structure.(vmhId{j}).casRegistry = RAW{i,cas_col};
                metabolite_structure.(vmhId{j}).casRegistry_source = [annotationSource,':',annotationType,':',datestr(now)];
            end
            % assign kegg ID - I allow overwriting
            if ~isempty(RAW{i,kegg_col})
                metabolite_structure.(vmhId{j}).keggId = RAW{i,kegg_col};
                metabolite_structure.(vmhId{j}).keggId_source = [annotationSource,':',annotationType,':',datestr(now)];
            end
            % assign chemspider ID - I allow overwriting
            if ~isempty(RAW{i,chemS_col})
                metabolite_structure.(vmhId{j}).chemspider = RAW{i,chemS_col};
                metabolite_structure.(vmhId{j}).chemspider_source = [annotationSource,':',annotationType,':',datestr(now)];
            end
            % assign pubchem ID - I allow overwriting
            if ~isempty(RAW{i,pubC_col})
                metabolite_structure.(vmhId{j}).pubChemId = RAW{i,pubC_col};
                metabolite_structure.(vmhId{j}).pubChemId_source = [annotationSource,':',annotationType,':',datestr(now)];
            end
        end
    end
end