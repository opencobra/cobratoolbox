function [compartmentReactions] = findRxnFromCompartment(model, compartment)
% Finds all the reactions and their identifiers in a compartment of interest.
%
% USAGE:
%
%    [compartmentReactions] = findRxnFromCompartment(model,Compartment)
%
% INPUTS:
%    model:                     COBRA model strcture
%    compartment:               compartment of interest (e.g.: '[m]', '[n]', '[e]', etc.)
%
% OUTPUT:
%    compartmentMetabolites:    List of reactions in the compartment of interest
%
% .. Authors:
%       - written by Diana El Assal 01/06/16
%       - rewritten by Uri David Akavia 6-Jul-2018

if (length(compartment) == 1)
    compartment = ['[' compartment ']'];
end
% Find mets in this compartment
compartmentMets = ~cellfun(@isempty, strfind(model.mets, compartment));
% Find reactions that involve the above mets
compartmentRxns = model.rxns(any(model.S(compartmentMets, :)));
compartmentReactions = [compartmentRxns, printRxnFormula(model, 'rxnAbbrList', compartmentRxns, 'printFlag', false)];