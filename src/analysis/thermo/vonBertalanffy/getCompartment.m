function [metCompartments, uniqueCompartments] = getCompartment(mets)
% Gets the compartment for each metabolite, and the unique compartments
%
% USAGE:
%
%    [metCompartments, uniqueCompartments] = getCompartment(mets)
%
% INPUT:
%    mets:                  `m x 1` cell array of metabolite abbreviations with compartment
%                           concatentated on the right hand side (i.e. `metAbbr[*]`).
%
% OUTPUTS:
%    compartments:          `m x 1` cell array of compartment identifiers
%    uniqueCompartments:    cell array of unique compartment identifiers
%
% .. Author:
%       - Ronan M.T. Fleming
%       - Hulda SH, Nov. 2012   Switched from for loop to regular expression

metCompartments = extractCompartmentsFromMets(mets);
uniqueCompartments = unique(metCompartments);
