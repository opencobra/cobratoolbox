function [matchingIDs, positions] = findMatchingFieldEntries(field, identifier, isAnnotation, minSim)
% Find elements of the field that are similar to the provided identifier
% USAGE:
%    [matchingIDs, positons] = findMatchingFieldEntries(field, identifier, isAnnotation, minSim)
%
% INPUTS:
%    field:             A Cell Array of strings
%    identifier:        The item to search for
%    isAnnotation:      Whether the strings in the field are annotation
%                       strings (multiple identifiers are concatenated with ; and will be
%                       separated)
%    minSim:            minimum "similarity" between element and search
%                       item.
%
% OUTPUTS:
%    matchingIDs:       All IDs which are matching to the search string.
%    positions:         The positions of these IDs in the supplied field.

if isAnnotation
    %Annotations are separated by ;. So we should split them.
    splittedFields = cellfun(@(x) strsplit(x,';'),field,'Uniform',0); %Should give a Cell Array of Cell Arrays.
    %calc distances for all cell arrays of cell array.
    distances = cellfun(@(x) cellfun(@(y) calcSim(identifier,y),x),splittedFields,'Uniform',0);
    distAndPos = cellfun(@(x) [min(x),find(x == min(x),1)],distances);
    bestAnnot = arrayfun(@(x,y) splittedFields{y}{x},1:size(distAndPos,1),distAndPos(:,2),'Uniform',0);
    if length(identifier) < 4
        relVals = ~cellfun(@(x) isempty(strfind(lower(x),lower(identifier))),betAnnot);
    else
        relVals = bestAnnot(distAndPos(:,1) < (1-minSim) * length(identifier));
    end
    field  = bestAnnot;
    distances = distAndPos(:,1);
else
    distances = cellfun(@(x) calcSim(identifier,x),field);
    if length(identifier) < 4 %Only look for perfect matches - case independent.
        relVals = ~cellfun(@(x) isempty(strfind(lower(x),lower(identifier))),field);
    else
        %if its a longer query, we only use those with a distance < 1
        relVals = distances < (1-minSim) * length(identifier);
    end
end
matchingIDs = field(relVals);
distances = distances(relVals);
[~,order] = sort(distances);
matchingIDs = matchingIDs(order);
positions = find(relVals);
positions = positions(order);
end