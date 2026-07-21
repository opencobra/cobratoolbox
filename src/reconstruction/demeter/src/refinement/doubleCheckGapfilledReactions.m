function [model, summary] = doubleCheckGapfilledReactions(model, summary, biomassReaction, microbeID, database, definedMediumGrowthOK, inputDataFolder)
% Part of the DEMETER pipeline. Deletes reactions gapfilled by DEMETER that
% are no longer needed after finishing all steps of the pipeline.
%
% USAGE:
%
%    [model, summary] = doubleCheckGapfilledReactions(model, summary, biomassReaction, microbeID, database, definedMediumGrowthOK, inputDataFolder)
%
% INPUTS:
%    model:    COBRA model structure with fields:
%
%                * .grRules - Gene-protein-reaction rules, used to identify reactions gap-filled by DEMETER (grRule `demeterGapfill`)
%                * .rxns - Reaction identifiers
%    summary:    Structure with information on refinement performed on the
%                model, with fields:
%
%                  * .conditionSpecificGapfill - Reactions added during condition-specific gapfilling
%                  * .targetedGapfill - Reactions added during targeted gapfilling
%                  * .relaxFBAGapfill - Reactions added by relaxFBA
%                  * .futileCycles_addedRxns - Reactions added to remove futile cycles
%                  * .addedMismatchRxns - Reactions added to conform to growth requirements
%                  * .addedReactionsBiomass - Reactions added to enable synthesis of biomass components according to the gram status of the organism
%    biomassReaction:    Biomass reaction abbreviation
%    microbeID:    ID of the reconstructed microbe that serves as the
%                  reconstruction name and to identify it in input tables
%    database:    rBioNet reaction database containing min. 3 columns:
%                 Column 1: reaction abbreviation, Column 2: reaction
%                 name, Column 3: reaction formula.
%    definedMediumGrowthOK:    If 1, defined medium is available for the
%                              organism and the model can grow on it
%    inputDataFolder:    Folder with experimental data and database files
%                        to load
%
% OUTPUTS:
%    model:    COBRA model structure with unneeded gapfilled reactions removed
%    summary:    Structure with information on refinement performed on the
%                model, updated with the reactions removed during double-checking
%
% .. Author:
%           Almut Heinken, 03/2020

tol=0.0000001;

% load complex medium
constraints = readtable('ComplexMedium.txt', 'Delimiter', '\t');
constraints=table2cell(constraints);
constraints=cellstr(string(constraints));

cnt=1;
remRxnsCM={};
modelCM=useDiet(model,constraints);
gapfilledRxns=model.rxns(find(strcmp(model.grRules,'demeterGapfill')));
if ~isempty(gapfilledRxns)
    modelTest=modelCM;
    [grRatio, grRateKO, grRateWT, hasEffect, delRxn, fluxSolution] = singleRxnDeletion(modelTest,'FBA',gapfilledRxns);
    remRxns=gapfilledRxns(grRatio>0);
    % test which reactions can be removed
    for i=1:length(remRxns)
        modelChanged=changeRxnBounds(modelTest,remRxns{i},0,'b');
        FBA=optimizeCbModel(modelChanged,'max');
        if FBA.f > tol
            modelTest=modelChanged;
            remRxnsCM{cnt}=remRxns{i};
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
toRemove=intersect(remRxnsCM,remRxnsDM);
else
    toRemove=remRxnsCM;
end
model=removeRxns(model,toRemove);

summary.conditionSpecificGapfill=setdiff(summary.conditionSpecificGapfill,toRemove);
summary.targetedGapfill=setdiff(summary.targetedGapfill,toRemove);
summary.relaxFBAGapfill=setdiff(summary.relaxFBAGapfill,toRemove);
summary.futileCycles_addedRxns=setdiff(summary.futileCycles_addedRxns,toRemove);
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