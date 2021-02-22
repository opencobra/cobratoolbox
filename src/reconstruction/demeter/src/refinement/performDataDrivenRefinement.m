function [refinedModel,summary] = performDataDrivenRefinement(model, microbeID, biomassReaction, database, inputDataFolder,summary)
% This function is part of the DEMETER pipeline and performs data-driven
% refinement of a genome-scale reconstruction based on available
% species-specific experimental data.
%
% USAGE
%      [model,summary] = performDataDrivenRefinement(model, microbeID, biomassReaction, database, inputDataFolder,summary)
%
% INPUTS
% model             COBRA model structure to refine
% microbeID         ID of the reconstructed microbe that serves as the 
%                   reconstruction name and to identify it in input tables
% inputDataFolder   Folder with input tables with experimental data and
%                   databases that inform the refinement process
% summary           Structure with information on performed refinement
%
% OUTPUT
% refinedModel      Refined COBRA model structure
% summary           Structure with information on performed refinement
%
% .. Authors:
%       - Almut Heinken and Stefania Magnusdottir, 2016-2021

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
[model,secretionRxnsAdded] = secretionProductGapfill(model,microbeID,database,inputDataFolder);
summary.('secretionRxnsAdded') = secretionRxnsAdded;
%% Known consumed metabolites
[model,uptakeRxnsAdded] = uptakeMetaboliteGapfill(model,microbeID,database, inputDataFolder);
summary.('uptakeRxnsAdded') = uptakeRxnsAdded;

%% test pathways to make sure they work
model=rebuildModel(model,database);
FNs = {};
% Carbon sources
[TruePositives, FalseNegatives] = testCarbonSources(model, microbeID, biomassReaction, inputDataFolder);
FNs=union(FNs,FalseNegatives);

% Metabolite uptake
[TruePositives, FalseNegatives] = testMetaboliteUptake(model, microbeID, biomassReaction, inputDataFolder);
FNs=union(FNs,FalseNegatives);

%% gapfill if there are any false negatives
osenseStr='min';

dataDrivenGapfill={};
if ~isempty(FNs)
    for j=1:length(FNs)
        metExch=['EX_' database.metabolites{find(strcmp(database.metabolites(:,2),FNs{j})),1} '(e)'];
        % find reactions that could be gap-filled to enable flux
        [model,gapfilledRxns] = runGapfillingFunctions(model,metExch,biomassReaction,osenseStr,database);
        dataDrivenGapfill=union(dataDrivenGapfill,gapfilledRxns);
    end
    if ~isempty(dataDrivenGapfill)
        summary.('DataDrivenGapfill')=dataDrivenGapfill;
    end
end

% Fermentation products
[TruePositives, FalseNegatives] = testFermentationProducts(model, microbeID, biomassReaction, inputDataFolder);
FNs=union(FNs,FalseNegatives);

% Putrefaction pathways
[TruePositives, FalseNegatives] = testPutrefactionPathways(model, microbeID, biomassReaction);
FNs=union(FNs,FalseNegatives);

% Secretion products
[TruePositives, FalseNegatives] = testSecretionProducts(model, microbeID, biomassReaction, inputDataFolder);
FNs=union(FNs,FalseNegatives);

% gapfill if there are any false negatives
osenseStr='max';

if ~isempty(FNs)
    for j=1:length(FNs)
        metExch=['EX_' database.metabolites{find(strcmp(database.metabolites(:,2),FNs{j})),1} '(e)'];
        % find reactions that could be gap-filled to enable flux
        [model,condGF,targetGF,relaxGF] = runGapfillingFunctions(model,metExch,biomassReaction,osenseStr,database);
        summary.('condGF') = union(summary.('condGF'),condGF);
        summary.('targetGF') = union(summary.('targetGF'),targetGF);
        summary.('relaxGF') = union(summary.('relaxGF'),relaxGF);
    end
end

%% change back to biomass reaction
refinedModel=changeObjective(model,biomassReaction);

end
