function [cyclicRxnBool,rankS]=findCyclicRxns(model,printLevel)
% Computes the reactions that are part of one or more stoichiometrically
% balanced cycles in the network
%
% INPUT:
%    model:
%    printLevel: verbose level
%
% OUPUTS:
%    cyclicRxnBool:
%    rankS: scalar giving rank of S

[Z,rankS]=getNullSpace(model.S,printLevel);
%computing the nullspace of the stoichiometric matrix

%check the support of the nullspace basis vectors
cyclicRxnBool=Z'*ones(size(Z,1),1);
