function [compartments,uniqueCompartments]=getCompartment(mets,numChar)
% Get the compartment for each metabolite, and the unique compartments
%
%INPUT
% mets      m x 1 cell array of metabolite abbreviations with compartment
%           concatentated on the right hand side 
%           i.e. metAbbr[*]
%
% OPTIONAL INPUT
% numChar   number of characters in compartment identifier (default = 1)
% 
% OUTPUT
% compartments          m x 1 cell array of compartment identifiers
% uniqueCompartments    cell array of unique compartment identifiers
% 
%Ronan M.T. Fleming

if ~exist('numChar','var')
    numChar=1;
end

nMet=length(mets);
compartments=cell(nMet,1);
for m=1:nMet
    compartments{m} = mets{m}(end-numChar:end-1);
end
uniqueCompartments=unique(compartments);
