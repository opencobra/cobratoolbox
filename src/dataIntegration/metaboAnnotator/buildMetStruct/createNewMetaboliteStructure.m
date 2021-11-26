function [metabolite_structure] =createNewMetaboliteStructure(input,source,metabolite_structure_rBioNet)
% This function creates a metabolite structure using the provided input. If
% no VMHId is provided in the header of the input, then VMHId are
% generated.
%
% INPUT
% Input                          Cell array containing the metabolites
%                                   The information provided must be as follows:
%                                   metList={
%                                   'VMH ID' 'metabolite_name' 'HMDB' 'inchistring' 'neutral_formula' 'charged_formula' 'charge'
%                                   'cot' 'Cotinine' 'HMDB0001046'  '' '' '' ''
%                                   'coto' 'Cotinine n-oxide' 'HMDB0001411'  '' '' '' ''
% source                            source of the information contained in metArray
%                                   (e.g., 'Manually assembled by IT')
% metabolite_structure_rBioNet      (optional and only necessary if the
%                                   input has no VMHId)
%
% OUTPUT
% metabolite_structure              metabolite structure
%
% Ines Thiele, 09/2021



RAW = input;

% load the designated field names associated with each metabolites
metaboliteStructureFieldNames;
% find VMH ID in the input file
vmh_col = find(contains(lower(RAW(1,:)),'vmh'));
% clean up some known issues:
name_col = find(contains(lower(RAW(1,:)),'name'));
RAW(1,name_col) = regexprep(RAW(1,name_col),RAW(1,name_col),'metNames');

if isempty(vmh_col) || vmh_col ==0
    if ~exist('metabolite_structure_rBioNet','var')
        load met_strc_rBioNet;
    end
end

% populate metabolite structure
for i = 2 : size(RAW,1)
    name = RAW(i,find(contains(lower(RAW(1,:)),'name'))) ;
    if ~isempty(vmh_col) && vmh_col ~=0 % VMH ID exists
        Ori = RAW{i,vmh_col};
        
        RAW{i,vmh_col} = regexprep(RAW{i,vmh_col},'-','_minus_');
        RAW{i,vmh_col} = regexprep(RAW{i,vmh_col},'(','_parentO_');
        RAW{i,vmh_col} = regexprep(RAW{i,vmh_col},')','_parentC_');
        VMHId = RAW{i,vmh_col};
    else
        [VMHId] = generateVMHMetAbbr(RAW{i,name_col},metabolite_structure_rBioNet,metab,rxnDB);
        Ori = VMHId;
        vmh_col = 0;
    end
    % adjust the abbreviations to the requirements of Matlab field
    % names
    % the original designated VMH ids listed in the field VMHId
    metabolite_structure.(strcat('VMH_',VMHId)) = struct();
    
    for j = 1:size(RAW,2)
        if j~=vmh_col
            % check whether a columnn header is part of the field2Add
            % definition
            colName1 =  regexprep(RAW(1,j),' ','_');
            colName2 =  regexprep(RAW(1,j),' ','');
            if ~isempty(find(contains(lower(field2Add),lower(colName1)))) || ~isempty(find(contains(lower(field2Add),lower(colName2))))
                clear F
                % assign correct field name
                if ~isempty(find(contains(lower(field2Add),lower(colName1))))
                    F=  field2Add(find(contains(lower(field2Add),lower(colName1))));
                elseif ~isempty(find(contains(lower(field2Add),lower(colName2))))
                    F=  field2Add(find(contains(lower(field2Add),lower(colName2))));
                end
                % make sure that the novel entry is not NaN or empty
                if isempty(find(isnan(RAW{i,j}))) && ~isempty(RAW{i,j}) && ~isempty(F)
                    metabolite_structure.(strcat('VMH_',VMHId)).(F{1}) = RAW{i,j};
                    metabolite_structure.(strcat('VMH_',VMHId)).([F{1},'_source']) = [source ': ' datestr(now)];
                else
                    metabolite_structure.(strcat('VMH_',VMHId)).(F{1}) = NaN;
                    metabolite_structure.(strcat('VMH_',VMHId)).([F{1},'_source']) = NaN;
                end
                metabolite_structure.(strcat('VMH_',VMHId)).VMHId = Ori;
            end
        end
    end
end
% add the remaining fields to the metabolite structure
metabolite_structure= addField2MetStructure(metabolite_structure);
% clean up known, potential issues with the input data
[metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure);
% check for known, potentially remaining issues with the metabolite IDs
% any errors will be removed.
removeErrors = 1;
[metabolite_structure,errorFlag] = sanityCheckMetIds(metabolite_structure,removeErrors);

