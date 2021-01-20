function [model,summary] = performDataDrivenRefinement(model, microbeID, database, inputDataFolder,summary)

%% Fermentation pathways
% Based on the fermentation pathway data for the microbe (table prepared above),
% add and remove reactions as defined in the following script.
%%
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

end