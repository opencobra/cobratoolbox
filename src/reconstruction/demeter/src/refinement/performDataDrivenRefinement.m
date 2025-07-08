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

model = rebuildModel(model,database,biomassReaction);

FNs = {};
% Carbon sources
[TruePositives, FalseNegatives] = testCarbonSources(model, microbeID, biomassReaction, database, inputDataFolder);
FNs=union(FNs,FalseNegatives);

% Metabolite uptake
[TruePositives, FalseNegatives] = testMetaboliteUptake(model, microbeID, biomassReaction, database, inputDataFolder);
FNs=union(FNs,FalseNegatives);

%% gapfill if there are any false negatives
osenseStr='min';

if ~isempty(FNs)
    for j=1:length(FNs)
        metExch=['EX_' database.metabolites{find(strcmp(database.metabolites(:,2),FNs{j})),1} '(e)'];
        % find reactions that could be gap-filled to enable flux
        % seems to try to fix exchanges that are not part of the model,
        % leading it to crash:
        %  Objective reactions not found in model!
        %
        % Error in runGapfillingFunctions (line 41)
        % model = changeObjective(model, objectiveFunction);
        %   add exchange reaction
        if isempty(find(strcmp(model.rxns,metExch)))
            met = [database.metabolites{find(strcmp(database.metabolites(:,2),FNs{j}))} '[e]'];
            model = addExchangeRxn(model,met,-1000,1000);
        end
        [model,condGF,targetGF,relaxGF] = runGapfillingFunctions(model,metExch,biomassReaction,osenseStr,database);
    end
    summary.('conditionSpecificGapfill') = union(summary.('conditionSpecificGapfill'),condGF);
    summary.('targetedGapfill') = union(summary.('targetedGapfill'),targetGF);
    summary.('relaxFBAGapfill') = union(summary.('relaxFBAGapfill'),relaxGF);
end

% Fermentation products
[TruePositives, FalseNegatives] = testFermentationProducts(model, microbeID, biomassReaction, database, inputDataFolder);
FNs=union(FNs,FalseNegatives);

% Putrefaction pathways
[TruePositives, FalseNegatives] = testPutrefactionPathways(model, microbeID, biomassReaction, database);
FNs=union(FNs,FalseNegatives);

% Secretion products
[TruePositives, FalseNegatives] = testSecretionProducts(model, microbeID, biomassReaction, database, inputDataFolder);
FNs=union(FNs,FalseNegatives);

% gapfill if there are any false negatives
osenseStr='max';

if ~isempty(FNs)
    for j=1:length(FNs)
        metInd=find(strcmp(database.metabolites(:,2),FNs{j}));
        if length(metInd)>1
            metInd=metInd(1);
        end
        metExch=['EX_' database.metabolites{metInd,1} '(e)'];
        if isempty(find(ismember(model.rxns,metExch)))
            % reaction ID itself provided
            metExch = FNs{j};
        end
        % find reactions that could be gap-filled to enable flux
        if isempty(find(strcmp(model.rxns,metExch)))
            met = [database.metabolites{find(strcmp(database.metabolites(:,2),FNs{j}))} '[e]'];
            model = addExchangeRxn(model,met,-1000,1000);
        end
        [model,condGF,targetGF,relaxGF] = runGapfillingFunctions(model,metExch,biomassReaction,osenseStr,database);
        summary.('conditionSpecificGapfill') = union(summary.('conditionSpecificGapfill'),condGF);
        summary.('targetedGapfill') = union(summary.('targetedGapfill'),targetGF);
        summary.('relaxFBAGapfill') = union(summary.('relaxFBAGapfill'),relaxGF);
    end
end

%% change back to biomass reaction
refinedModel=changeObjective(model,biomassReaction);

end
