function [metComps,metIDs] = extractCompartmentsFromMets(mets, defaultCompartment)
% function to extract the compartment IDs from a list of metabolite IDs
% (assuming the compartments are stored in '\[[^\]+]\]$' expressions, while
% giving a default expression to empty elements.
% USAGE: 
%    metComps = extractCompartmentsFromMets(mets, defaultCompartment)
% 
% INPUT:
%    mets:                  The list of metabolites to extract compartments
%                           from (cell array of strings)
%
% OPTIONAL INPUT:
%    defaultCompartment:    The default compartment to use for mets which
%                           don't have an id. (Default: 'k' for unknown)
%
% OUTPUT:
%    metComps:              The compartment IDs extracted. (cell array of
%                           strings)

if ~exist('defaultCompartment', 'var')
    defaultCompartment = {'k'};
end

if ischar(defaultCompartment)
    defaultCompartment = {defaultCompartment};
end

metMatches = regexp(mets,'(?<metID>.*)\[(?<compID>[^\]]+)\]','names');
if isempty(metMatches) 
    if ischar(mets)
        metIDs = mets;
        metComps = 'k';       
    else
        metIDs = mets;
        metComps = {'k'};       
    end
else        
    metComps = cell(numel(mets),1);
    metIDs = cell(numel(mets),1);
    emptyComps = cellfun(@isempty, metMatches);    
    metComps(~emptyComps) = cellfun(@(x) x.compID,metMatches(~emptyComps),'Uniform',0);
    metComps(emptyComps) = {defaultCompartment};
    metIDs(~emptyComps) = cellfun(@(x) x.metID,metMatches(~emptyComps),'Uniform',0);
    metIDs(emptyComps) = mets(emptyComps);
end
