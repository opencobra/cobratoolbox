function [metComps,metIDs] = extractCompartmentsFromMets(mets, varargin)
% function to extract the compartment IDs from a list of metabolite IDs
% (assuming the compartments are stored in '\[[^\]+]\]$' expressions, while
% giving a default expression to empty elements.
% USAGE: 
%    metComps = extractCompartmentsFromMets(mets, varargin)
% 
% INPUT:
%    mets:                  The list of metabolites to extract compartments
%                           from (cell array of strings)
%
% OPTIONAL INPUT:
%    varargin:              additional parameters as 'paramerName',value
%                           pairs or parameter struct with the following
%                           parameters:
%                            * `defaultCompartment` - The default compartment to use for mets which don't have an id. (Default: 'k' for unknown)
%                            * `compartmentRegExp` - Regular expression matching compartments. with needs to define a compID and a metID group and assume that those groups exist in ALL metabolites If they don't the regexp should not match. (default: '(?<metID>.*)\[(?<compID>[^\]]+)\]')
%
% OUTPUT:
%    metComps:              The compartment IDs extracted. (cell array of
%                           strings)
%    metID:                 The compartmentless metabolite ID.
%  
% AUTHOR:   Thomas Pfau Nov 2018
%
% NOTE:
%    The function should only be used when no `metComps` field is available,
%    or when it is required to obtain metabolite IDs without any
%    compartment information (e.g. when checking for unique metabolites).
%    If the actual compartment of a metabolite is requested, please always
%    refer to the metComps field!
%
% EXAMPLE:
%    % Extract unique metabolites from a model
%    [~,metIDs] = extractCompartmentsFromMets(model.mets)
%    uniqueMets = unique(metIDs)
%    % extract compartments form a model, which has BiGG style compartment
%    % IDs using the cytosol ('c') as default compartment id:
%    [metComps,metIDs] = extractCompartmentsFromMets(model.mets, 'defaultCompartment', 'c', 'compartmentRegExp', '^(?<metID>.*?)_(?<compID>[a-z][a-z0-9]?)(_([A-Z][A-Z0-9]?))?$)
%    
%

parser = inputParser();
parser.addParameter('defaultCompartment','k',@ischar);
parser.addParameter('compartmentRegExp','(?<metID>.*)\[(?<compID>[^\]]+)\]',@ischar);

parser.parse(varargin{:});

defaultCompartment = parser.Results.defaultCompartment;
compartmentRegExp = parser.Results.compartmentRegExp;

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
