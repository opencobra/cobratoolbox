function [revisedModel,gapfilledReactions,replacedReactions]=debugModel(model,testResults, inputDataFolder,microbeID,biomassReaction)
% This function runs a suite of debugging functions on a refined
% reconstruction produced by the DEMETER pipeline. Tests
% are performed whether or not the models can produce biomass aerobically
% and anaerobically, and whether or not unrealistically high ATP is
% produced on a complex medium.
%
% USAGE:
%
%   [revisedModel,gapfilledReactions,replacedReactions]=debugModel(model,testResults, inputDataFolder,microbeID,biomassReaction)
%
% INPUTS
% model:                 COBRA model structure
% testResults:           Structure with results of test run
% inputDataFolder:       Folder with input tables with experimental data
%                        and databases that inform the refinement process
% microbeID:             ID of the reconstructed microbe that serves as
%                        the reconstruction name and to identify it in
%                        input tables
% biomassReaction:       Reaction ID of the biomass objective function
%
% OUTPUT
% revisedModel:          Gapfilled COBRA model structure
% gapfilledReactions:    Reactions gapfilled to enable flux
% replacedReactions:     Reactions replaced because they were causing
%                        futile cycles
%
% .. Author:
%       - Almut Heinken, 09/2020

gapfilledReactions = {};
cntGF=1;
replacedReactions = {};

tol=0.0000001;

model=changeObjective(model,biomassReaction);

% implement complex medium
constraints = readtable('ComplexMedium.txt', 'Delimiter', 'tab');
constraints=table2cell(constraints);
constraints=cellstr(string(constraints));

% Load reaction and metabolite database
metaboliteDatabase = readtable('MetaboliteDatabase.txt', 'Delimiter', 'tab','TreatAsEmpty',['UND. -60001','UND. -2011','UND. -62011'], 'ReadVariableNames', false);
metaboliteDatabase=table2cell(metaboliteDatabase);
database.metabolites=metaboliteDatabase;
for i=1:size(database.metabolites,1)
    database.metabolites{i,5}=num2str(database.metabolites{i,5});
    database.metabolites{i,7}=num2str(database.metabolites{i,7});
    database.metabolites{i,8}=num2str(database.metabolites{i,8});
end
reactionDatabase = readtable('ReactionDatabase.txt', 'Delimiter', 'tab','TreatAsEmpty',['UND. -60001','UND. -2011','UND. -62011'], 'ReadVariableNames', false);
reactionDatabase=table2cell(reactionDatabase);
database.reactions=reactionDatabase;

% create a temporary summary file of the performed refinement
summary=struct;
summary.condGF={};
summary.targetGF={};
summary.relaxGF={};

% rebuild model
model=rebuildModel(model,database);

[AerobicGrowth, AnaerobicGrowth] = testGrowth(model, biomassReaction);
if AnaerobicGrowth(1,1) < tol
    % find reactions that are preventing the model from growing
    % anaerobically
    [model,condGF,targetGF,relaxGF] = runGapfillingFunctions(model,biomassReaction,biomassReaction,'max',database);
    % export the gapfilled reactions
    if ~isempty(condGF)
        summary.condGF=union(summary.condGF,condGF);
        
        gapfilledReactions{cntGF,1}=microbeID;
        gapfilledReactions{cntGF,2}='Enabling anaerobic growth';
        gapfilledReactions{cntGF,3}='Condition-specific gapfilling';
        gapfilledReactions(cntGF,4:length(condGF)+3)=condGF;
        cntGF=cntGF+1;
    end
    if ~isempty(targetGF)
        summary.targetGF=union(summary.targetGF,targetGF);
        
        gapfilledReactions{cntGF,1}=microbeID;
        gapfilledReactions{cntGF,2}='Enabling anaerobic growth';
        gapfilledReactions{cntGF,3}='Targeted gapfilling';
        gapfilledReactions(cntGF,4:length(targetGF)+3)=targetGF;
        cntGF=cntGF+1;
    end
    if ~isempty(relaxGF)
        summary.relaxGF=union(summary.relaxGF,relaxGF);
        
        gapfilledReactions{cntGF,1}=microbeID;
        gapfilledReactions{cntGF,2}='Enabling anaerobic growth';
        gapfilledReactions{cntGF,3}='Gapfilling based on relaxFBA';
        gapfilledReactions(cntGF,4:length(relaxGF)+3)=relaxGF;
        cntGF=cntGF+1;
    end
end

[AerobicGrowth, AnaerobicGrowth] = testGrowth(model, biomassReaction);
if AerobicGrowth(1,2) < tol
    % identify blocked reactions on complex medium
    model=useDiet(model,constraints);
    [model,condGF,targetGF,relaxGF] = runGapfillingFunctions(model,biomassReaction,biomassReaction,'max',database);
    % export the gapfilled reactions
    if ~isempty(condGF)
        summary.condGF=union(summary.condGF,condGF);
        
        gapfilledReactions{cntGF,1}=microbeID;
        gapfilledReactions{cntGF,2}='Growth on complex medium';
        gapfilledReactions{cntGF,3}='Condition-specific gapfilling';
        gapfilledReactions(cntGF,4:length(condGF)+3)=condGF;
        cntGF=cntGF+1;
    end
    if ~isempty(targetGF)
        summary.targetGF=union(summary.targetGF,targetGF);
        
        gapfilledReactions{cntGF,1}=microbeID;
        gapfilledReactions{cntGF,2}='Growth on complex medium';
        gapfilledReactions{cntGF,3}='Targeted gapfilling';
        gapfilledReactions(cntGF,4:length(targetGF)+3)=targetGF;
        cntGF=cntGF+1;
    end
    if ~isempty(relaxGF)
        summary.relaxGF=union(summary.relaxGF,relaxGF);
        
        gapfilledReactions{cntGF,1}=microbeID;
        gapfilledReactions{cntGF,2}='Growth on complex medium';
        gapfilledReactions{cntGF,3}='Gapfilling based on relaxFBA';
        gapfilledReactions(cntGF,4:length(relaxGF)+3)=relaxGF;
        cntGF=cntGF+1;
    end
end

% identify blocked biomass precursors on defined medium for the organism
[growsOnDefinedMedium,constrainedModel,~] = testGrowthOnDefinedMedia(model, microbeID, biomassReaction, inputDataFolder);
if growsOnDefinedMedium == 0
    % find reactions that are preventing the model from growing
    [model,condGF,targetGF,relaxGF] = runGapfillingFunctions(constrainedModel,biomassReaction,biomassReaction,'max',database,1);
    % export the gapfilled reactions
    if ~isempty(condGF)
        summary.condGF=union(summary.condGF,condGF);
        
        gapfilledReactions{cntGF,1}=microbeID;
        gapfilledReactions{cntGF,2}='Growth on defined medium';
        gapfilledReactions{cntGF,3}='Condition-specific gapfilling';
        gapfilledReactions(cntGF,4:length(condGF)+3)=condGF;
        cntGF=cntGF+1;
    end
    if ~isempty(targetGF)
        summary.targetGF=union(summary.targetGF,targetGF);
        
        gapfilledReactions{cntGF,1}=microbeID;
        gapfilledReactions{cntGF,2}='Growth on defined medium';
        gapfilledReactions{cntGF,3}='Targeted gapfilling';
        gapfilledReactions(cntGF,4:length(targetGF)+3)=targetGF;
        cntGF=cntGF+1;
    end
    if ~isempty(relaxGF)
        summary.relaxGF=union(summary.relaxGF,relaxGF);
        
        gapfilledReactions{cntGF,1}=microbeID;
        gapfilledReactions{cntGF,2}='Growth on defined medium';
        gapfilledReactions{cntGF,3}='Gapfilling based on relaxFBA';
        gapfilledReactions(cntGF,4:length(relaxGF)+3)=relaxGF;
        cntGF=cntGF+1;
    end
end

% if there are any false negative predictions
% find what reactions should be added to enable agreement with experimental
% data

fields=fieldnames(testResults);

for i=1:length(fields)
    % define if objective should be maximized or minimized
    if any(contains(fields{i},{'Carbon_sources','Metabolite_uptake','Drug_metabolism'}))
        osenseStr = 'min';
    elseif any(contains(fields{i},{'Fermentation_products','Secretion_products','Bile_acid_biosynthesis'}))
        osenseStr = 'max';
    end
    FNlist = testResults.(fields{i});
    if size(FNlist,1)>1
        FNs = FNlist(find(strcmp(FNlist(:,1),microbeID)),2:end);
        FNs = FNs(~cellfun(@isempty, FNs));
        if ~isempty(FNs)
            for j=1:length(FNs)
                metExch=['EX_' database.metabolites{find(strcmp(database.metabolites(:,2),FNs{j})),1} '(e)'];
                % find reactions that could be gap-filled to enable flux
                [model,condGF,targetGF,relaxGF] = runGapfillingFunctions(model,metExch,biomassReaction,osenseStr,database);
                % export the gapfilled reactions
                if ~isempty(condGF)
                    summary.condGF=union(summary.condGF,condGF);
                    
                    gapfilledReactions{cntGF,1}=microbeID;
                    gapfilledReactions{cntGF,2}=FNs{j};
                    gapfilledReactions{cntGF,3}='Condition-specific gapfilling';
                    gapfilledReactions(cntGF,4:length(condGF)+3)=condGF;
                    cntGF=cntGF+1;
                end
                if ~isempty(targetGF)
                    summary.targetGF=union(summary.targetGF,targetGF);
                    
                    gapfilledReactions{cntGF,1}=microbeID;
                    gapfilledReactions{cntGF,2}=FNs{j};
                    gapfilledReactions{cntGF,3}='Targeted gapfilling';
                    gapfilledReactions(cntGF,4:length(targetGF)+3)=targetGF;
                    cntGF=cntGF+1;
                end
                if ~isempty(relaxGF)
                    summary.relaxGF=union(summary.relaxGF,relaxGF);
                    
                    gapfilledReactions{cntGF,1}=microbeID;
                    gapfilledReactions{cntGF,2}=FNs{j};
                    gapfilledReactions{cntGF,3}='Gapfilling based on relaxFBA';
                    gapfilledReactions(cntGF,4:length(relaxGF)+3)=relaxGF;
                    cntGF=cntGF+1;
                end
            end
        end
    end
end

% remove futile cycles if any exist
[atpFluxAerobic, atpFluxAnaerobic] = testATP(model);
if atpFluxAerobic > 200 || atpFluxAnaerobic > 150
    % let us try if running removeFutileCycles again will work
    [model, deletedRxns, addedRxns] = removeFutileCycles(model, biomassReaction, database);
    replacedReactions{1,1}=microbeID;
    replacedReactions{1,2}='Futile cycle correction';
    replacedReactions{1,3}='To replace';
    replacedReactions(1,4:length(deletedRxns)+3)=deletedRxns;
    
    % if any futile cycles remain
    [atpFluxAerobic, atpFluxAnaerobic] = testATP(model);
    if atpFluxAerobic > 200 || atpFluxAnaerobic > 150
        % let us try if running removeFutileCycles again will work
        [model, deletedRxns, addedRxns] = removeFutileCycles(model, biomassReaction, database);
        replacedReactions{1,1}=microbeID;
        replacedReactions{1,2}='Futile cycle correction';
        replacedReactions{1,3}='To replace';
        replacedReactions(1,4:length(deletedRxns)+3)=deletedRxns;
    end
end

% add the gap-filling to model.comments field
for i=1:length(model.rxns)
    if strcmp(model.grRules{i},'demeterGapfill')
        model.grRules{i}=strrep(model.grRules{i},'demeterGapfill','');
        if ~isempty(find(strcmp(summary.condGF,model.rxns{i})))
            model.comments{i}='Added by DEMETER to enable flux with VMH-consistent constraints.';
        elseif ~isempty(find(strcmp(summary.targetGF,model.rxns{i})))
            model.comments{i}='Added by DEMETER during targeted gapfilling to enable production of required metabolites.';
        elseif ~isempty(find(strcmp(summary.relaxGF,model.rxns{i})))
            model.comments{i}='Added by DEMETER based on relaxFBA. Low confidence level.';
        end
    end
end

% rebuild and export the model
revisedModel = rebuildModel(model,database);
revisedModel=changeObjective(revisedModel,biomassReaction);

end