function [matchingIDs, positions, similarities] = findMatchingFieldEntries(field, searchString, isAnnotation, minSim)
% Find elements of the field that are similar to the provided identifier
%
% USAGE:
%    [matchingIDs, positons, similarities] = findMatchingFieldEntries(field, searchString, isAnnotation, minSim)
%
% INPUTS:
%    field:             A Cell Array of strings
%    searchString:      The item to search for
%    isAnnotation:      Whether the strings in the field are annotation
%                       strings (multiple identifiers are concatenated with ; and will be
%                       separated)
%    minSim:            minimum "similarity" between element and search
%                       item.
%
% OUTPUTS:
%    matchingIDs:       All IDs which are matching to the search string.
%    positions:         The positions of these IDs in the supplied field.
%    similarities:      Similarities of the matchingIDs with the search
%                       String
%
% .. Author: - Thomas Pfau, June 2018

if isAnnotation
    % annotations are separated by ;. So we should split them.
    splittedFields = cellfun(@(x) strsplit(x,';'),field,'Uniform',0); %Should give a Cell Array of Cell Arrays.
    % calc distances for all cell arrays of cell array.
    distances = cellfun(@(x) cellfun(@(y) calcDist(searchString,y),x),splittedFields,'Uniform',0);
    distAndPos = cell2mat(cellfun(@(x) [min(x),find(x == min(x),1)],distances,'Uniform',0));
    bestAnnot = arrayfun(@(x,y) splittedFields{x}{y},(1:size(distAndPos,1))',distAndPos(:,2),'Uniform',0);
    if length(searchString) < 4
        relVals = ~cellfun(@(x) isempty(strfind(lower(x),lower(searchString))),betAnnot);
    else
        relVals = distAndPos(:,1) <= (1-minSim) * length(searchString);
    end
    field  = bestAnnot;
    distances = distAndPos(:,1);
else    
    distances = cellfun(@(x) calcDist(searchString,x),field);
    if length(searchString) < 4 % only look for perfect matches - case independent.
        relVals = ~cellfun(@(x) isempty(strfind(lower(x),lower(searchString))),field);
    else
        % if its a longer query, we only use those with a distance smaller
        % than a similarity threshold
        relVals = distances <= (1-minSim) * length(searchString);
    end
end
matchingIDs = field(relVals);
distances = distances(relVals);
[similarities,order] = sort(distances/length(searchString));
similarities = 1-similarities;
matchingIDs = matchingIDs(order);
positions = find(relVals);
positions = positions(order);
end