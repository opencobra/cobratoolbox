function [metAtomMappedBool,rxnAtomMappedBool] = findAtomMappedSubset(model,rxnfileDir)
%
% USAGE:
%   [metAtomMappedBool,rxnAtomMappedBool] = findAtomMappedSubset(model,rxnfileDir)
%
% INPUTS:
%  model.rxns:     
%  model.SConsistentRxnBool:
%  model.S:           
%  rxnfileDir:               path to directory containing atom mapped reactions
%                            One .RXN file per reaction with each filename matching to model.rxns{i}   
%
% OUTPUTS:
% metAtomMappedBool:  `m x 1` boolean vector indicating atom mapped metabolites
% rxnAtomMappedBool:  `n x 1` boolean vector indicating atom mapped reactions
%
% EXAMPLE:
%
% NOTE:
%
% Author(s):

rxnfileDir = [regexprep(rxnfileDir,'(/|\\)$',''), filesep]; % Make sure input path ends with directory separator

% Get list of atom mapped reactions
d = dir(rxnfileDir);
d = d(~[d.isdir]);
aRxns = {d.name}';
if length(aRxns)~= length(unique(aRxns))
    warning('duplicate atom mappings')
end
aRxns = aRxns(~cellfun('isempty',regexp(aRxns,'(\.rxn)$')));
aRxns = regexprep(aRxns,'(\.rxn)$',''); % Identifiers for atom mapped reactions
assert(~isempty(aRxns), 'Rxnfile directory is empty or nonexistent.');

fprintf('Atom mappings available for %d reactions.\n', length(aRxns));
 
if any(strcmp(aRxns,'3AIBtm (Case Conflict)'))
    aRxns{strcmp(aRxns,'3AIBtm (Case Conflict)')} = '3AIBTm'; % Debug: Ubuntu file manager "Files" renames file '3AIBTm.rxn' if the file '3AIBtm.rxn' is located in the same directory (issue for Recon 2)
end

% Extract atom mapped reactions
rxnAtomMappedBool = (ismember(model.rxns,aRxns)); % True for atom mapped reactions

assert(any(rxnAtomMappedBool), 'No atom mappings found for model reactions.\nCheck that rxnfile names match reaction identifiers in rxns.');

if any(~rxnAtomMappedBool)
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
 
    if any(~rxnAtomMappedBool & internalRxnBool)
        
        fprintf('Atom mappings found for %d internal reactions.\n', sum(rxnAtomMappedBool & internalRxnBool));
        fprintf('Atom mappings not found for %d internal reactions:\n', sum(~rxnAtomMappedBool & internalRxnBool));
        if nnz(~rxnAtomMappedBool & internalRxnBool)<100
            disp(model.rxns(~rxnAtomMappedBool & internalRxnBool))
        end
    else
        fprintf('\nAtom mappings found for all %d internal reactions.\n', sum(rxnAtomMappedBool & internalRxnBool));
    end

end

metAtomMappedBool = any(model.S(:,rxnAtomMappedBool),2); % True for metabolites in atom mapped reactions

end

