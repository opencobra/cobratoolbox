function gprs = findGPRFromRxns(model,rxnIDs)
% Get the Textual representations of the GPR rules for the indicated
% reactions. 
% USAGE:
%
%    gprs = findGPRFromRxns(model,rxnIDs)
%
% INPUTS:
%    model:             The model to retrieve the GPR rules from
%    rxnIDs:            The reaction IDs to obtain the GPR rules for
%
% OUTPUTS:
%
%    gprs:              The textual GPR Rules
%
% Authors:
%
%    Thomas Pfau Dec 2017

gprs = printGPRForRxns(model,rxnIDs, 0);




