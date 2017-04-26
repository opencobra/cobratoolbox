function [model, rxn_name] = augmentBOF(model,targetRxn,epsilon)
% Adjusts the objective function to eliminate
% "non-unique" optknock solutions by favoring the lowest production rate at
% a given predicted max growth-rate.
%
% USAGE:
%
%    [model, rxn_name] = augmentBOF(model, targetRxn, epsilon)
%
% INPUTS:
%    model:             Structure containing all necessary variables to described a
%                       stoichiometric model
%    targetRxn:         objective of the optimization
%
% OPTIONAL INPUT:
%    epsilon:           degree of augmentation considering the biochemical objective
%
% OUTPUTS:
%    model:             Augmented model structure
%    rxn_name:          reaction that carries the augmented value
%
% .. Author: - Adam Feist 10/16/08
%
% This funtion uses the outermembrane transport reaction, therefore:
%
%   1. the model must have an extracellular compartment and a periplasm (e.g. `iAF1260`)
%   2. there should not be an extracellular reaction acting on the metabolite
%   besides the exchange reaction and the OM transport reaction

if (nargin < 3)
    % Biomass flux
    epsilon = .00001;
end

rxnID = findRxnIDs(model,targetRxn);
metID = find(model.S(:,rxnID));

% find the OM reaction
OMtransRxnID = find(model.S(metID,:));
% check to see if function is appropriate, if there are more than 2
% reactions that act on this metabolite in the extracellular space
[m,n]=size(OMtransRxnID);
if n >= 3
    fprintf 'augmentBOF will not work.'
    return
end
%remove the exchange reaction from the variable that held all the reaction
%IDs that are associated with the extracellular metabolite
OMtransRxnID(find(OMtransRxnID == rxnID))=[];
% The variable that holds the OM reaction
rxn_name = model.rxns(OMtransRxnID,1);
rxn_name = rxn_name{1};

%augment the objective
model.c(OMtransRxnID,1)= epsilon;
