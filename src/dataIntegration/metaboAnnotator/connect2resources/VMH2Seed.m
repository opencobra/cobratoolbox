function [metabolite_structure] = VMH2Seed(metabolite_structure)
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


fileName = 'MetaboliteTranslationTable.xlsx';

[NUM,TXT,RAW]=xlsread(fileName);
annotationSource = fileName;
annotationType = 'manual';
annotationVerification = 'verified';
vmh_col = find(contains(lower(RAW(1,:)),'vmh'));
seed_col = find(contains(lower(RAW(1,:)),'seed'));


[VMH2IDmappingAll,VMH2IDmappingPresent,VMH2IDmappingMissing]=getIDfromMetStructure(metabolite_structure,'VMHId');
for i = 2 : size(RAW,1)
    if ~isempty(RAW{i,vmh_col}) && length(find(isnan(RAW{i,vmh_col}))) == 0
        tmp = find(ismember(VMH2IDmappingAll(:,2),RAW{i,vmh_col}));
        if ~isempty(tmp)
            vmhId =  cellstr(VMH2IDmappingAll{tmp,1});
            
            % assign metabolon ID - I allow overwriting
            if ~isempty(RAW{i,seed_col})
                metabolite_structure.(vmhId{1}).seed = RAW{i,seed_col};
                metabolite_structure.(vmhId{1}).seed_source = [annotationSource,':',annotationType,':',datestr(now)];
            end
        end
    end
end