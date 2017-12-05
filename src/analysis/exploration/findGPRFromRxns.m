function gprs = findGPRFromRxns(model,rxnIDs)
% Get the Textual representations of the GPR rules for the indicated
% reactions. 
% USAGE:
%
%    gprs = findGPRFromRxns(model,rxnIDs)
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

gprs = printGPRForRxns(model,rxnIDs, 0);




