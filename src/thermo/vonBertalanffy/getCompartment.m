function [compartments,uniqueCompartments]=getCompartment(mets)
% Gets the compartment for each metabolite, and the unique compartments
% 
% [compartments,uniqueCompartments]=getCompartment(mets)
%
%INPUTS
% mets      m x 1 cell array of metabolite abbreviations with compartment
%           concatentated on the right hand side (i.e. metAbbr[*]).
% 
% OUTPUTS
% compartments          m x 1 cell array of compartment identifiers
% uniqueCompartments    cell array of unique compartment identifiers
% 
% Ronan M.T. Fleming
% Hulda SH, Nov. 2012   Switched from for loop to regular expression

pat = '(?<abbr>[^\[]+)\[(?<compartment>[^\]]+)\]';
metStruct = regexp(mets,pat,'names'); % m x 1 cell array with fields abbr and compartment in each cell
metStruct = [metStruct{:}]'; % Convert from cell array to double
compartments = {metStruct.compartment}; % Concatenate compartment fields
compartments = reshape(compartments,length(compartments),1);
uniqueCompartments = unique(compartments);
