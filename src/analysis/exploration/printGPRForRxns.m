function gprs = printGPRForRxns(model,rxnIDs, printLevel)
% Print the GPRs (in textual format) for the given RxnIDs
% USAGE:
%
%    gprs = printGPRForRxns(model,rxnID)
%
% INPUTS:
%    model:             The model to retrieve the GPR rules from
%    rxnIDs:            The reaction IDs to obtain the GPR rules for
%
% OPTIONAL INPUTS:
%
%    printLevel:        Whether to print out the GPRs. If printLevel is 0,
%                       the function will only return the Strings in a cell
%                       array.
%
% OUTPUTS:
%
%    gprs:              The textual GPR Rules
%
% Authors:
%
%    Thomas Pfau Dec 2017

if ~isnumeric(rxnIDs)
    rxnPos = findRxnIDs(model,rxnIDs);
else
    %We got a list of positions
    rxnPos = rxnIDs;
    if any(rxnPos > numel(model.rxns))
        error('Some indices provided are larger than the number of reactions.');
    end
end

if any(rxnPos == 0) 
    error('The following reaction IDs are not part of this model:\n%s\n',strjoin(rxnIDs(rxnPos==0),'; '));
end

if ~exist('printLevel','var')
    printLevel = 1;
end

if isfield(model,'grRules')
    gprs = model.grRules(rxnPos);
else
    if isfield(model,'rules') && isfield(model,'genes')
        gprs = strrep(model.rules(rxnPos),'|','or');
        gprs = strrep(gprs,'&','and');
        gprs = regexprep(gprs,'x\(([0-9]+)\)','${model.genes{str2num($1)}}');
    else
        gprs = repmat({''},size(rxnPos));
    end
end
rxnNames = model.rxns(rxnPos);
maxRxnLength = num2str(max(cellfun(@length,rxnNames))+2);

if printLevel > 0
    for i = 1:numel(rxnPos)
        fprintf(['%-' maxRxnLength 's:\t%s\n'],rxnNames{i},gprs{i});
    end
end





