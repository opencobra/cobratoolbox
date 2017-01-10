function [cyclicRxnBool,rankS]=findCyclicRxns(model,printLevel)
%compute the reactions that are part of one or more stoichiometrically 
%balanced cycles in the network
%
%INPUT
% model
% printLevel
%OUPUT
% cyclicRxnBool

%computing the nullspace of the stoichiometric matrix
[Z,rankS]=getNullSpace(model.S,printLevel);

%check the support of the nullspace basis vectors
cyclicRxnBool=Z'*ones(size(Z,1),1);