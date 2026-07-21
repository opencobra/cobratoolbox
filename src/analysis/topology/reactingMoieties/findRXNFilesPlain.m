function [metRXNBool, rxnRXNBool, internalRxnBool] = findRXNFilesPlain(model, rxnfileDir)
%findRXNFilesPlain Find RXN files and internal reactions using base MATLAB.
%
% This mirrors the COBRA findRXNFiles behavior used by checkABRXNFiles, but
% always assigns internalRxnBool, including when every model reaction has an
% RXN file.

rxnfileDir = [regexprep(rxnfileDir, '(/|\\)$', ''), filesep];

d = dir(rxnfileDir);
d = d(~[d.isdir]);
aRxns = {d.name}';
aRxns = aRxns(~cellfun('isempty', regexp(aRxns, '(\.rxn)$', 'once')));
aRxns = regexprep(aRxns, '(\.rxn)$', '');

assert(~isempty(aRxns), 'Rxnfile directory is empty or nonexistent.');

fprintf('RXN files available for %d reactions.\n', length(aRxns));

rxnRXNBool = ismember(model.rxns, aRxns);
assert(any(rxnRXNBool), ...
    'No RXN files found for model reactions.\nCheck that rxnfile names match reaction identifiers in rxns.');

internalRxnBool = getInternalReactionBool(model);

if any(~rxnRXNBool)
    if any(~rxnRXNBool & internalRxnBool)
        fprintf('RXN files found for %d internal reactions.\n', sum(rxnRXNBool & internalRxnBool));
        fprintf('RXN files not found for %d internal reactions:\n', sum(~rxnRXNBool & internalRxnBool));
        if nnz(~rxnRXNBool & internalRxnBool) < 100
            disp(model.rxns(~rxnRXNBool & internalRxnBool))
        end
    else
        fprintf('RXN files found for all %d internal reactions.\n', sum(rxnRXNBool & internalRxnBool));
    end
end

metRXNBool = any(model.S(:, rxnRXNBool), 2);
end

function internalRxnBool = getInternalReactionBool(model)
if isfield(model, 'SConsistentRxnBool')
    internalRxnBool = model.SConsistentRxnBool;
elseif isfield(model, 'SIntRxnBool')
    internalRxnBool = model.SIntRxnBool;
else
    model = findSExRxnInd(model, [], 0);
    internalRxnBool = model.SIntRxnBool;
end

internalRxnBool = logical(internalRxnBool(:));
end
