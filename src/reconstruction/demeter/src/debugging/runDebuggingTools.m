function [reactionsToGapfill,reactionsToDelete,revisedModel]=runDebuggingTools(model,microbeID,biomassReaction,testResultsFolder,reconVersion)
% This function runs a suite of debugging functions on a refine
% reconstruction produced by the DEMETER pipeline. Tests
% are performed whether or not the models can produce biomass aerobically
% and anaerobically, and whether or not unrealistically high ATP is
% produced on the Western diet.

% load all test result files
dInfo = dir([testResultsFolder filesep reconVersion '_refined']);
fileList={dInfo.name};
fileList=fileList';
fileList(~(contains(fileList(:,1),{'.txt'})),:)=[];


% find reactions that are causing futile cycles
futileCycleReactions=identifyFutileCycles(model);

% find reactions that are preventing the model from growing
[blockedPrecursors,enablingMets]=findBlockedPrecursorsInRxn(model,biomassReaction,'max');

% identify blocked biomass precursors on defined medium for the organism
[growsOnDefinedMedium,constrainedModel,~] = testGrowthOnDefinedMedia(model, microbeID, biomassReaction);

if growsOnDefinedMedium == 0
[blockedPrecursors,enablingMets]=findBlockedPrecursorsInRxn(constrainedModel,biomassReaction,'max');
end

% load all test result files for experimental data
dInfo = dir([testResultsFolder filesep reconVersion '_refined']);
fileList={dInfo.name};
fileList=fileList';
fileList(~(contains(fileList(:,1),{'.txt'})),:)=[];
fileList(~(contains(fileList(:,1),{'FalseNegatives'})),:)=[];

% if there are any false negative predictions
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
                metExch=['EX_' metaboliteDatabase{find(strcmp(metaboliteDatabase(:,2),FNs{j})),1} '(e)'];
                % find what reactions should be added to enable agreement with experimental
                % data
                [blockedPrecursors,enablingMets]=findBlockedPrecursorsInRxn(model,metExch,osenseStr);
            end
        end
    end
end

end