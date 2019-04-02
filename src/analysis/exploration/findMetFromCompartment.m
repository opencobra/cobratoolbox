function [compartmentMetabolites] = findMetFromCompartment(model, compartment)
% Finds all the metabolites and their identifiers in
% a compartment of interest.
%
% USAGE:
%
%    [compartmentMetabolites] = findMetFromCompartment(model,compartment)
%
% INPUTS:
%    model:                     COBRA model strcture
%    compartment:               compartment of interest (e.g.: '[m]', '[n]', '[e]', etc.)
%
% OUTPUT:
%    compartmentMetabolites:    List of metabolites in the compartment of interest
%
% .. Authors:
%       - written by Diana El Assal 27/10/15
%       - updated to use metComps by Thomas Pfau, Nov 2018

%Find the metabolites in the compartment of interest (e.g. '[m], '[n]')
compartment = regexprep(compartment, '\[([^\]]+\])\]','$1'); % compartments is a cell array list of compartments to keep (e.g. {'[e]','[c]','[m]'})
compartmentMetabolites = model.mets(ismember(model.metComps,compartment));

