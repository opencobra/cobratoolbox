function [model,summary]=doubleCheckGapfilledReactions(model,summary,biomassReaction,microbeID,database,definedMediumGrowthOK,inputDataFolder)
% Part of the DEMETER pipeline. Deletes reactions gapfilled by DEMETER that are no longer needed after the reconstruction was
% are no longer needed after finishing all steps of the pipeline.
%
% USAGE
%       [model,summary]=doubleCheckGapfilledReactions(model,summary,biomassReaction,microbeID,database,definedMediumGrowthOK,inputDataFolder)
%
% INPUT
% model:                    COBRA model structure
% summary:                  Structure with information of refinement 
%                           performed on the model
% biomassReaction:          Biomass reaction abbreviation
% microbeID:                ID of the reconstructed microbe that serves as the
%                           reconstruction name and to identify it in input tables
% database                  rBioNet reaction database containing min. 3 columns:
%                           Column 1: reaction abbreviation, Column 2: reaction
%                           name, Column 3: reaction formula.
% definedMediumGrowthOK:    If 1, defined medium is available for the
%                           organism and the model can grow on it
% inputDataFolder:          Folder with experimental data and database files
%                           to load
%
% OUTPUT
% model:                    COBRA model structure
% summary:                  Structure with information of refinement 
%                           performed on the model
%
% .. Author:
%           Almut Heinken, 03/2020

tol=0.0000001;

% load Western diet
WesternDiet = readtable('WesternDietAGORA2.txt', 'Delimiter', '\t');
WesternDiet=table2cell(WesternDiet);
WesternDiet=cellstr(string(WesternDiet));

cnt=1;
remRxnsWD={};
modelWD=useDiet(model,WesternDiet);
gapfilledRxns=model.rxns(find(strcmp(model.grRules,'demeterGapfill')));
if ~isempty(gapfilledRxns)
    modelTest=modelWD;
    [grRatio, grRateKO, grRateWT, hasEffect, delRxn, fluxSolution] = singleRxnDeletion(modelTest,'FBA',gapfilledRxns);
    remRxns=gapfilledRxns(grRatio>0);
    % test which reactions can be removed
    for i=1:length(remRxns)
        modelChanged=changeRxnBounds(modelTest,remRxns{i},0,'b');
        FBA=optimizeCbModel(modelChanged,'max');
        if FBA.f > tol
            modelTest=modelChanged;
            remRxnsWD{cnt}=remRxns{i};
            cnt=cnt+1;
        end
    end
end

remRxnsDM={};
if isnumeric(definedMediumGrowthOK)==1
    cnt=1;
    [growsOnDefinedMedium,constrainedModel] = testGrowthOnDefinedMedia(model, microbeID, biomassReaction, inputDataFolder);
    gapfilledRxns=model.rxns(find(strcmp(model.grRules,'demeterGapfill')));
    if ~isempty(gapfilledRxns)
        modelTest=constrainedModel;
        [grRatio, grRateKO, grRateWT, hasEffect, delRxn, fluxSolution] = singleRxnDeletion(modelTest,'FBA',gapfilledRxns);
        remRxns=gapfilledRxns(grRatio>0);
        % test which reactions can be removed
        for i=1:length(remRxns)
            modelChanged=changeRxnBounds(modelTest,remRxns{i},0,'b');
            FBA=optimizeCbModel(modelChanged,'max');
            if FBA.f > tol
                modelTest=modelChanged;
                remRxnsDM{cnt}=remRxns{i};
                cnt=cnt+1;
            end
        end
    end
    addedMismatchRxns=model.rxns(find(strcmp(model.grRules,'GrowthRequirementsGapfill')));
    if ~isempty(addedMismatchRxns)
        modelTest=constrainedModel;
        [grRatio, grRateKO, grRateWT, hasEffect, delRxn, fluxSolution] = singleRxnDeletion(modelTest,'FBA',addedMismatchRxns);
        remRxns=addedMismatchRxns(grRatio>0);
        % test which reactions can be removed
        for i=1:length(remRxns)
            modelChanged=changeRxnBounds(modelTest,remRxns{i},0,'b');
            FBA=optimizeCbModel(modelChanged,'max');
            if FBA.f > tol
                modelTest=modelChanged;
                remRxnsDM{cnt}=remRxns{i};
                cnt=cnt+1;
            end
        end
    end
end

% get all reactions that can be safely deleted
if ~isempty(remRxnsDM)
toRemove=intersect(remRxnsWD,remRxnsDM);
else
    toRemove=remRxnsWD;
end
model=removeRxns(model,toRemove);

summary.gapfilledRxns=setdiff(summary.gapfilledRxns,toRemove);
summary.balancedCycle_addedRxns=setdiff(summary.balancedCycle_addedRxns,toRemove);
summary.addedMismatchRxns=setdiff(summary.addedMismatchRxns,toRemove);
summary.addedReactionsBiomass=setdiff(summary.addedReactionsBiomass,toRemove);

% some models require another gapfill afterwards
if isnumeric(definedMediumGrowthOK)==1
    [growsOnDefinedMedium,constrainedModel,growthOnKnownCarbonSources] = testGrowthOnDefinedMedia(model, microbeID, biomassReaction, inputDataFolder);
    if growsOnDefinedMedium==0
        [model, addedMismatchRxns, deletedMismatchRxns] = curateGrowthRequirements(model, microbeID, database, inputDataFolder);
    end
summary.addedMismatchRxns=union(summary.addedMismatchRxns,addedMismatchRxns);
end

end