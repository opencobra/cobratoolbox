function [modelUpdated] = populateModelwithRxnIDs(model)
% Populates a COBRA model with reaction cross-reference identifiers looked
% up from a local VMH reaction list spreadsheet and, for `rxnSEEDID`, from a
% DEMETER seed-to-VMH translation table.
%
% USAGE:
%
%    [modelUpdated] = populateModelwithRxnIDs(model)
%
% INPUTS:
%    model:           COBRA model structure
%
% OUTPUT:
%    modelUpdated:    COBRA model structure with the following reaction ID
%                     fields populated (overwritten where already present):
%
%                       * .rxnECNumbers - EC number(s) for the reaction
%                       * .rxnKEGGID - KEGG reaction identifier
%                       * .rxnMetaNetXID - MetaNetX reaction identifier
%                       * .rxnSEEDID - ModelSEED reaction identifier
%                       * .rxnRheaID - Rhea reaction identifier
%                       * .rxnBRENDAID - BRENDA reaction identifier (same
%                         value as `.rxnECNumbers`)
%
% NOTE:
%
%    Allowed COBRA fields can be found here:
%
%       fileName = which('COBRA_structure_fields.tab');
%       [raw] = descFileRead(fileName);
%       raw.Model_Field
%
%    Reaction ID fields include: rxnGeneMat, rxnConfidenceScores, rxnNames,
%    rxnNotes, rxnECNumbers, rxnReferences, rxnKEGGID, rxnKEGGPathways,
%    rxnMetaNetXID, rxnBRENDAID, rxnBioCycID, rxnReactomeID, rxnSABIORKID,
%    rxnSEEDID, rxnRheaID, rxnBiGGID, rxnSBOTerms

[~,~,RAW] = xlsread('C:\Users\0123322S\Dropbox\Studies\VMH\VMH_reactionList.xlsx');
% this file was obtained from the VMH database dump (July 2020,dellby)


%  model field reactionList column header
translate={
    'rxnECNumbers' 'ecnumber'
    'rxnKEGGID' 'keggId'
    'rxnMetaNetXID' 'metanetx'
    'rxnSEEDID' 'seed'
    'rxnRheaID' 'rhea'
    'rxnBRENDAID' 'ecnumber' % brenda id is the same as the ec number
    };
modelUpdated = model;

for i = 1 : length(modelUpdated.rxns)
    row = find(ismember(RAW(:,2),modelUpdated.rxns{i}));
    for j = 1 : size(translate,1)
        if ~isempty(row) % reaction does  exist in VMH
            
            % I overwrite existing IDs
            col = find(ismember(RAW(1,:),translate{j,2}));

            if length(find(isnan(RAW{row,col})))==0 && ~strcmp(RAW{row,col}, '\N')
                if isnumeric(RAW{row,col})
                    modelUpdated.(translate{j,1}){i,1} = num2str(RAW{row,col});
                else
                    modelUpdated.(translate{j,1}){i,1} = (RAW{row,col});
                end
            else
                modelUpdated.(translate{j,1}){i,1} = '';
            end
        else
            modelUpdated.(translate{j,1}){i,1} = '';
        end
    end
end