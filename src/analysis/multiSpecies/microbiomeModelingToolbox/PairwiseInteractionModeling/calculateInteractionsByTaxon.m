function [interactionsByTaxon] = calculateInteractionsByTaxon(pairwiseInteractions, taxonInformation)
% Part of the Microbiome Modeling Toolbox. This script analyzes computed pairwise
% interactions on different taxonomical levels to yield the interactions
% that each taxon (genus, family, order, class, phylum) displayed in total.
% The computed pairwise interactions and the taxnomical information for each
% analyzed strain are required as inputs.
%
% USAGE:
%
%   [interactionsByTaxon]=calculateinteractionsByTaxon(pairwiseInteractions,taxonInfo)
%
% INPUTS:
%   pairwiseInteractions:    a table with pairwise interactions computed
%                            for a number of analyzed microbe models (output of the function
%                            simulatePairwiseInteractions)
%   taxonInformation:        a table with taxonomical information on the
%                            analyzed microbes. Needs to contain at least six columns:
%                            1. The names of the analyzed model structures
%                            in the first column
%                            2-6. A column with the appropriate information
%                            and the header
%                            'Genus','Family','Order','Class','Phylum'
%                            respectively.
% OUTPUT:
%   interactionsByTaxon:     a structure with the outcomes predicted for
%                            all taxa on each taxonomical level.
%
% .. Author:
%       - Almut Heinken, 02/2018

microbes = unique(pairwiseInteractions(2:end, 2:3));  % if taxon information is missing for at least one microbe in the pairwise interactions input file
[present, position] = ismember(microbes, taxonInformation(:, 1));
if any(~present)
    error('Taxon information for analyzed microbes is missing!')
end

% first reduce the taxon information to only the taxa contained in the
% analyzed subset of microbes.
subArray(1, 1) = 1;
cnt = 2;
for i = 1:length(taxonInformation)
    if any(strcmp(microbes, taxonInformation(i, 1)))
        subArray(cnt, 1) = i;
        cnt = cnt + 1;
    end
end
taxonSubset = taxonInformation(subArray, :);

% define the nine possible outcomes for one microbe
outcomes = {
    'Competition'
    'Parasitism_Taker'
    'Parasitism_Giver'
    'Amensalism_Affected'
    'Amensalism_Unaffected'
    'Neutralism'
    'Commensalism_Taker'
    'Commensalism_Giver'
    'Mutualism'
};

% define the taxonomical levels on which the computed interactions will be
% analyzed
TaxonomyLevels = {
    'Phylum'
    'Class'
    'Order'
    'Family'
    'Genus'
};

for t = 1:length(TaxonomyLevels)
    for i = 1:length(outcomes)
        interactionsByTaxon.(TaxonomyLevels{t}){1, i + 1} = outcomes{i};
    end
end

for t = 1:length(TaxonomyLevels)
    interactions = {};
    % find the correct column in the taxon subset file
    taxonCol = find(strcmp(taxonSubset(1, :), TaxonomyLevels{t}));
    % find the taxa contained in the list of microbes analyzed
    taxaInMicrobeList = unique(taxonSubset(2:end, taxonCol));
    % excluded unclassified species/strains
    taxaInMicrobeList(strncmp('unclassified', taxaInMicrobeList, 1)) = [];
    for k = 1:length(outcomes)
        interactions{1, k + 1} = outcomes{k};
    end
    for i = 1:length(taxaInMicrobeList)
        interactions{i + 1, 1} = taxaInMicrobeList{i};
        % for each taxon, count the number of cases predicted for each
        % interaction type
        caseCnt = zeros(length(outcomes), 1);
        % first count interactions for Microbe 1
        for j = 2:size(pairwiseInteractions, 1)
            if strcmp(taxaInMicrobeList{i}, taxonSubset{find(strcmp(pairwiseInteractions{j, 2}, taxonSubset(:, 1))), taxonCol})
                currCase = pairwiseInteractions{j, 8};
                caseCnt(find(strcmp(currCase, outcomes(:, 1)))) = caseCnt(find(strcmp(currCase, outcomes(:, 1)))) + 1;
            end
        end
        % then count interactions for Microbe 2
        for j = 2:size(pairwiseInteractions, 1)
            if strcmp(taxaInMicrobeList{i}, taxonSubset{find(strcmp(pairwiseInteractions{j, 3}, taxonSubset(:, 1))), taxonCol})
                currCase = pairwiseInteractions{j, 9};
                caseCnt(find(strcmp(currCase, outcomes(:, 1)))) = caseCnt(find(strcmp(currCase, outcomes(:, 1)))) + 1;
            end
        end
        % fill in the table with the calculated number of interactions per
        % taxon
        for k = 1:length(outcomes)
            interactions{i + 1, k + 1} = caseCnt(k);
        end
    end
    % save the table in the output structure
    interactionsByTaxon.(TaxonomyLevels{t}) = interactions;
end
