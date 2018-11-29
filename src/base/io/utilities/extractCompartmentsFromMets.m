function [metComps,metIDs] = extractCompartmentsFromMets(mets, defaultCompartment,compartmentRegexp)
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
%    compartmentRegExp:     Regular expression matching compartments. with
%                           needs to define a compID and a metID group. 
%                           (default: '(?<metID>.*)\[(?<compID>[^\]]+)\]')
%
% OUTPUT:
%    metComps:              The compartment IDs extracted. (cell array of
%                           strings)
%    metID:                 The compartmentless metabolite ID.
%  

if ~exist('defaultCompartment', 'var')
    defaultCompartment = {'k'};
end
if ~exist('compartmentRegExp','var')
    compartmentRegExp = '(?<metID>.*)\[(?<compID>[^\]]+)\]';
end

if ischar(defaultCompartment)
    defaultCompartment = {defaultCompartment};
end

metMatches = regexp(mets,compartmentRegExp,'names');
if isempty(metMatches) 
    if ischar(mets)
        metIDs = mets;
        metComps = 'k';       
    else
        metIDs = mets;
        metComps = {'k'};       
    end
else       
    if ischar(mets)
        metIDs = metMatches.metID;
        metComps = metMatches.compID;
    else
        metComps = cell(numel(mets),1);
        metIDs = cell(numel(mets),1);
        emptyComps = cellfun(@isempty, metMatches);
        metComps(~emptyComps) = cellfun(@(x) x.compID,metMatches(~emptyComps),'Uniform',0);
        metComps(emptyComps) = {defaultCompartment};
        metIDs(~emptyComps) = cellfun(@(x) x.metID,metMatches(~emptyComps),'Uniform',0);
        metIDs(emptyComps) = mets(emptyComps);
    end
end
