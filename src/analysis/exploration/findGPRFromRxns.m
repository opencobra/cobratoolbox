function gprs = findGPRFromRxns(model,rxnIDs)
% Print the GPRs (in textual format) for the given RxnIDs
% USAGE:
%
%    gprs = findGPRFromRxns(mode,rxnID)
%
% INPUTS:
%    model:             The model to add the Metabolite batch to.
%    rxnIDs:            The IDs of the reactions that shall be added.
%
% OUTPUTS:
%
%    gprs:              The textual GPR Rules
%
% Authors:
%
%    Thomas Pfau Dec 2017

gprs = printGPRForRxns(model,rxnIDs);




