function [model,summary] = performDataDrivenRefinement(model, microbeID, biomassReaction, database, inputDataFolder,summary)

%% Fermentation pathways
% Based on the fermentation pathway data for the microbe (table prepared above),
% add and remove reactions as defined in the following script.
% Perform fermentation pathway gap fill:
[model, addedRxns, removedRxns] = fermentationPathwayGapfill(model, microbeID, database, inputDataFolder);
summary.('addedRxns_fermentation') = addedRxns;
summary.('removedRxns_fermentation') = removedRxns;
%% Carbon sources
% Based on the carbon source data for the microbe (table prepared above), add
% and remove reactions as defined in the following script.
% Perform carbon source pathway gap fill:
[model, addedRxns, removedRxns] = carbonSourceGapfill(model, microbeID, database, inputDataFolder);
summary.('addedRxns_carbonSources') = addedRxns;
summary.('removedRxns_carbonSources') = removedRxns;
%% Putrefaction pathways
[model,putrefactionRxnsAdded]=putrefactionPathwaysGapfilling(model,microbeID,database);
summary.('putrefactionRxnsAdded') = putrefactionRxnsAdded;
%% Known secretion products
[model,secretionRxnsAdded] = addSecretionProductRxns(model,microbeID,database,inputDataFolder);
summary.('secretionRxnsAdded') = secretionRxnsAdded;
%% Known consumed metabolites
[model,uptakeRxnsAdded] = addUptakeRxns(model,microbeID,database, inputDataFolder);
summary.('uptakeRxnsAdded') = uptakeRxnsAdded;

%% test pathways to make sure they work
model=rebuildModel(model,database);
FNs = {};
% Carbon sources
[TruePositives, FalseNegatives] = testCarbonSources(model, microbeID, biomassReaction);
FNs=union(FNs,FalseNegatives);

% Metabolite uptake
[TruePositives, FalseNegatives] = testMetaboliteUptake(model, microbeID, biomassReaction);
FNs=union(FNs,FalseNegatives);

% gapfill if there are any false negatives
osenseStr='min';

dataDrivenGapfill={};
if ~isempty(FNs)
    for j=1:length(FNs)
        metExch=['EX_' database.metabolites{find(strcmp(database.metabolites(:,2),FNs{j})),1} '(e)'];
        % find reactions that could be gap-filled to enable flux
        [model,gapfilledRxns] = runGapfillingTools(model,metExch,biomassReaction,osenseStr,database);
        dataDrivenGapfill=union(dataDrivenGapfill,gapfilledRxns);
    end
    if ~isempty(dataDrivenGapfill)
        summary.('DataDrivenGapfill')=dataDrivenGapfill;
    end
end

% Fermentation products
[TruePositives, FalseNegatives] = testFermentationProducts(model, microbeID, biomassReaction);
FNs=union(FNs,FalseNegatives);

% Putrefaction pathways
[TruePositives, FalseNegatives] = testPutrefactionPathways(model, microbeID, biomassReaction);
FNs=union(FNs,FalseNegatives);

% Secretion products
[TruePositives, FalseNegatives] = testSecretionProducts(model, microbeID, biomassReaction);
FNs=union(FNs,FalseNegatives);

% gapfill if there are any false negatives
osenseStr='max';

dataDrivenGapfill={};
if ~isempty(FNs)
    for j=1:length(FNs)
        metExch=['EX_' database.metabolites{find(strcmp(database.metabolites(:,2),FNs{j})),1} '(e)'];
        % find reactions that could be gap-filled to enable flux
        [model,gapfilledRxns] = runGapfillingTools(model,metExch,biomassReaction,osenseStr,database);
        dataDrivenGapfill=union(dataDrivenGapfill,gapfilledRxns);
    end
    if ~isempty(dataDrivenGapfill)
        summary.('DataDrivenGapfill')=dataDrivenGapfill;
    end
end

end
