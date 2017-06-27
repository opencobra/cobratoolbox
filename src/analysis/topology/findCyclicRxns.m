function [cyclicRxnBool, rankS] = findCyclicRxns(model, printLevel)
% Computes the reactions that are part of one or more stoichiometrically
% balanced cycles in the network
%
% USAGE:
%
%    [cyclicRxnBool, rankS] = findCyclicRxns(model, printLevel)
%
% INPUT:
%    model:            model structure
%    printLevel:       verbose level
%
% OUTPUTS:
%    cyclicRxnBool:    boolean value
%    rankS:            scalar giving rank of `S`

[Z,rankS]=getNullSpace(model.S,printLevel);
%computing the nullspace of the stoichiometric matrix

%check the support of the nullspace basis vectors
cyclicRxnBool=Z'*ones(size(Z,1),1);
