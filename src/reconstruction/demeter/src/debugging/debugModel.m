function [reactionsToGapfill,reactionsToReplace,revisedModel]=debugModel(model,testResultsFolder,reconVersion,microbeID,biomassReaction,numWorkers)
% This function runs a suite of debugging functions on a refined
% reconstruction produced by the DEMETER pipeline. Tests
% are performed whether or not the models can produce biomass aerobically
% and anaerobically, and whether or not unrealistically high ATP is
% produced on the Western diet.

reactionsToGapfill = {};
cntGF=1;
reactionsToReplace = {};

tol=0.0000001;

% implement Western diet
WesternDiet = readtable('WesternDietAGORA2.txt', 'Delimiter', 'tab');
WesternDiet=table2cell(WesternDiet);
WesternDiet=cellstr(string(WesternDiet));

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

[AerobicGrowth, AnaerobicGrowth] = testGrowth(model, biomassReaction);
if AnaerobicGrowth(1,1) < tol
    % find reactions that are preventing the model from growing
    % anaerobically
    [model,gapfilledRxns] = runGapfillingTools(model,biomassReaction,'max',database);
    if ~isempty(gapfilledRxns)
        reactionsToGapfill{cntGF,1}=microbeID;
        reactionsToGapfill{cntGF,2}='Gapfilled';
        reactionsToGapfill{cntGF,3}=biomassReaction;
        reactionsToGapfill(cntGF,4:length(gapfilledRxns)+3)=gapfilledRxns;
        cntGF=cntGF+1;
    end
end

[AerobicGrowth, AnaerobicGrowth] = testGrowth(model, biomassReaction);
if AerobicGrowth(1,2) < tol
    % identify blocked reactions on Western diet
    model=useDiet(model,WesternDiet);
    [model,gapfilledRxns] = runGapfillingTools(model,biomassReaction,'max',database);
    if ~isempty(gapfilledRxns)
        reactionsToGapfill{cntGF,1}=microbeID;
        reactionsToGapfill{cntGF,2}='Gapfilled';
        reactionsToGapfill{cntGF,3}=biomassReaction;
        reactionsToGapfill(cntGF,4:length(gapfilledRxns)+3)=gapfilledRxns;
        cntGF=cntGF+1;
    end
end

% identify blocked biomass precursors on defined medium for the organism
[growsOnDefinedMedium,constrainedModel,~] = testGrowthOnDefinedMedia(model, microbeID, biomassReaction);
if growsOnDefinedMedium == 0
    % find reactions that are preventing the model from growing
    [model,untGF] = untargetedGapFilling(model,biomassReaction,'max',database,numWorkers);
    if ~isempty(untGF)
        reactionsToGapfill{cntGF,1}=microbeID;
        reactionsToGapfill{cntGF,2}=biomassReaction;
        reactionsToGapfill(cntGF,3:length(untGF)+2)=untGF;
        cntGF=cntGF+1;
    end
end

[atpFluxAerobic, atpFluxAnaerobic] = testATP(model);
if atpFluxAerobic > 150 || atpFluxAnaerobic > 100
    % find reactions that are causing futile cycles
    futileCycleReactions=identifyFutileCycles(model);
    % find irreversible versions of the same reactions
    
    if ~isempty(futileCycleReactions)
        reactionsToReplace{1,1}=microbeID;
        reactionsToReplace{1,2}='To replace';
        reactionsToReplace(1,3:length(untDel)+2)=futileCycleReactions;
        % let us try if running removeFutileCycles again will work
        [model, deletedRxns, addedRxns] = removeFutileCycles(model, biomassReaction, database);
    end
end

% load all test result files for experimental data
dInfo = dir([testResultsFolder filesep reconVersion '_refined']);
fileList={dInfo.name};
fileList=fileList';
fileList(~(contains(fileList(:,1),{'.txt'})),:)=[];
fileList(~(contains(fileList(:,1),{'FalseNegatives'})),:)=[];

% if there are any false negative predictions
% find what reactions should be added to enable agreement with experimental
% data
if size(fileList,1)>0
    for i=1:size(fileList,1)
        % define if objective should be maximized or minimized
        if any(contains(fileList{i,1},{'Carbon_sources','Metabolite_uptake'}))
            osenseStr = 'min';
        elseif any(contains(fileList{i,1},{'Fermentation_products','Secretion_products'}))
            osenseStr = 'max';
        end
        FNlist = readtable([[testResultsFolder filesep reconVersion '_refined'] filesep fileList{i,1}], 'ReadVariableNames', false, 'Delimiter', 'tab');
        FNlist = table2cell(FNlist);
        FNs = FNlist(find(strcmp(FNlist(:,1),microbeID)),2:end);
        FNs = FNs(~cellfun(@isempty, FNs));
        if ~isempty(FNs)
            for j=1:length(FNs)
                metExch=['EX_' database.metabolites{find(strcmp(database.metabolites(:,2),FNs{j})),1} '(e)'];
                % find reactions that could be gap-filled to enable flux
                [model,gapfilledRxns] = runGapfillingTools(model,metExch,osenseStr,database);
                if ~isempty(gapfilledRxns)
                    reactionsToGapfill{cntGF,1}=microbeID;
                    reactionsToGapfill{cntGF,2}='Gapfilled';
                    reactionsToGapfill{cntGF,3}=FNs{j};
                    reactionsToGapfill(cntGF,4:length(gapfilledRxns)+3)=gapfilledRxns;
                    cntGF=cntGF+1;
                end
            end
        end
    end
end

% rebuild and export the model
revisedModel = rebuildModel(model,database);

end