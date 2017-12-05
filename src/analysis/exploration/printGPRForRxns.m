function gprs = printGPRForRxns(model,rxnIDs, printLevel)
% Print the GPRs (in textual format) for the given RxnIDs
% USAGE:
%
%    gprs = printGPRForRxns(mode,rxnID)
%
% INPUTS:
%    model:             The model to add the Metabolite batch to.
%    rxnIDs:            The IDs of the reactions that shall be added.
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

rxnPos = findRxnIDs(model,rxnIDs);

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





