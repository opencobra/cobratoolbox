function [metRXNBool,rxnRXNBool,internalRxnBool] = findRXNFiles(model,rxnfileDir)
%
% USAGE:
%   [metRXNBool,rxnRXNBool] = findRXNFiles(model,rxnfileDir)
%
% INPUTS:
%  model.rxns:     
%  model.SConsistentRxnBool:
%  model.S:           
%  rxnfileDir:               path to directory containing atom mapped reactions
%                            One .RXN file per reaction with each filename matching to model.rxns{i}   
%
% OUTPUTS:
% metRXNBool:  `m x 1` boolean vector true for metabolites in atom mapped reactions
% rxnRXNBool:  `n x 1` boolean vector true for atom mapped reactions
% internalRxnBool: :  `n x 1` boolean vector true for reactions considered internal
%
% EXAMPLE:
%
% NOTE:
%
% Author(s): Ronan M.T. Fleming, 2022

rxnfileDir = [regexprep(rxnfileDir,'(/|\\)$',''), filesep]; % Make sure input path ends with directory separator

% Get list of atom mapped reactions
d = dir(rxnfileDir);
d = d(~[d.isdir]);
aRxns = {d.name}';
if length(aRxns)~= length(unique(aRxns))
    warning('duplicate RXN files')
end
aRxns = aRxns(~cellfun('isempty',regexp(aRxns,'(\.rxn)$')));
aRxns = regexprep(aRxns,'(\.rxn)$',''); % Identifiers for atom mapped reactions
assert(~isempty(aRxns), 'Rxnfile directory is empty or nonexistent.');

fprintf('RXN files available for %d reactions.\n', length(aRxns));

% Extract atom mapped reactions
rxnRXNBool = (ismember(model.rxns,aRxns)); % True for atom mapped reactions

assert(any(rxnRXNBool), 'No RXN files found for model reactions.\nCheck that rxnfile names match reaction identifiers in rxns.');

if any(~rxnRXNBool)
    if isfield(model,'SConsistentRxnBool')
        internalRxnBool = model.SConsistentRxnBool;
    else
        if ~isfield(model,'SIntRxnBool')
            if isfield(model,'mets')
                %attempts to finds the reactions in the model which export/import from the model
                %boundary i.e. mass unbalanced reactions
                %e.g. Exchange reactions
                %     Demand reactions
                %     Sink reactions
                model = findSExRxnInd(model,[],0);
            end
        end
        internalRxnBool = model.SIntRxnBool;
    end
 
    if any(~rxnRXNBool & internalRxnBool)
        
        fprintf('RXN files found for %d internal reactions.\n', sum(rxnRXNBool & internalRxnBool));
        fprintf('RXN files not found for %d internal reactions:\n', sum(~rxnRXNBool & internalRxnBool));
        if nnz(~rxnRXNBool & internalRxnBool)<100
            disp(model.rxns(~rxnRXNBool & internalRxnBool))
        end
    else
        fprintf('RXN files found for all %d internal reactions.\n', sum(rxnRXNBool & internalRxnBool));
    end

end

metRXNBool = any(model.S(:,rxnRXNBool),2); % True for metabolites in atom mapped reactions

end

