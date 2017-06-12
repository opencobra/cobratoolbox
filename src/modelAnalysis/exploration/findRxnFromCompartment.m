function [compartmentReactions] = findRxnFromCompartment(model,compartment)
% findRxnFromCompartment finds all the reactions and their identifiers in a
% compartment of interest.
%
% USAGE:
%
%    [compartmentReactions] = findRxnFromCompartment(model,Compartment)
%
% INPUTS:
%    model         COBRA model strcture
%    compartment   compartment of interest (e.g.: '[m]', '[n]', '[e]', etc.)
%
% OUTPUT:
%    compartmentMetabolites  List of reactions in the compartment of interest
%
% .. Authors:
%       - written by Diana El Assal 01/06/16

%Form a matrix with the metabolites and its identifiers
[reactions]=[model.rxns, printRxnFormula(model, model.rxns)];

%Find the reactions in the compartment of interest (e.g. '[m], '[n]')
compartmentRxns=strfind(reactions(:,2), compartment);
index=find(~cellfun(@isempty, compartmentRxns));
compartmentRxns=unique(reactions(index,1));

%Find all reaction identifiers
for i=1:size(compartmentRxns,1);
    num=find(ismember(reactions(:,1),compartmentRxns{i,1}));
    if ~isempty(num);
        compartmentReactions(i,:)=reactions(num,:);
    end
end
