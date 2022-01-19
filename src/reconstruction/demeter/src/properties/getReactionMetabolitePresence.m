function getReactionMetabolitePresence(modelFolder,propertiesFolder,reconVersion,numWorkers)
% This function extracts the presence of reactions and metabolites for a 
% resource of reconstructions that were refined through the semi-automatic 
% refinement pipeline (1 = present, 0 = not present).
%
% USAGE
%   getReactionMetabolitePresence(modelFolder,propertiesFolder,reconVersion)
%
% INPUTS
% modelFolder                                                                                                                                                                                           Folder with COBRA models to be analyzed
% propertiesFolder      Folder where the retrieved reaction presences will
%                       be stored (default: current folder)
% reconVersion          Name assigned to the reconstruction resource
%
%   - AUTHOR
%   Almut Heinken, 06/2020

if numWorkers>0 && ~isempty(ver('parallel'))
    % with parallelization
    poolobj = gcp('nocreate');
    if isempty(poolobj)
        parpool(numWorkers)
    end
end

mkdir([propertiesFolder filesep 'ReactionMetabolitePresence'])

dInfo = dir(modelFolder);
modelList={dInfo.name};
modelList=modelList';
modelList(~(contains(modelList(:,1),{'.mat','.sbml','.xml'})),:)=[];

% check if output file already exists
if isfile([propertiesFolder filesep 'ReactionMetabolitePresence' filesep 'reactionPresence_' reconVersion '.txt'])
    reactionPresence = readInputTableForPipeline([propertiesFolder filesep 'ReactionMetabolitePresence' filesep 'reactionPresence_' reconVersion '.txt']);
    allRxns=reactionPresence(1,2:end)';
    metabolitePresence = readInputTableForPipeline([propertiesFolder filesep 'ReactionMetabolitePresence' filesep 'metabolitePresence_' reconVersion '.txt']);
    allMets=metabolitePresence(1,2:end)';
else
    % restart from existing data if possible
    if isfile([propertiesFolder filesep 'Reactions_' reconVersion '.txt'])
        reactions = readInputTableForPipeline([propertiesFolder filesep 'Reactions_' reconVersion '.txt']);
        allRxns=reactions(:,1);
        metabolites = readInputTableForPipeline([propertiesFolder filesep 'Metabolites_' reconVersion '.txt']);
        allMets=metabolites(:,1);
    else
        allRxns={};
        allMets={};
        for i=1:length(modelList)
            try
                model=readCbModel([modelFolder filesep modelList{i}]);
            catch
                model=load([modelFolder filesep modelList{i}]);
                model = model.model;
            end
            allRxns=unique(vertcat(allRxns,model.rxns));
            allMets=unique(vertcat(allMets,model.mets));
        end
    end
    metabolitePresence(1,2:length(allMets)+1)=allMets';
    reactionPresence(1,2:length(allRxns)+1)=allRxns';
end

% remove models that were already retrieved
modelsRenamed=strrep(modelList(:,1),'.mat','');
modelsRenamed=strrep(modelsRenamed,'.sbml','');
modelsRenamed=strrep(modelsRenamed,'.xml','');
[C,IA]=intersect(modelsRenamed,reactionPresence(2:end,1));
modelList(IA,:)=[];

% define the intervals in which the computations will be performed
if length(modelList)>5000
    steps=1000;
elseif length(modelList)>200
    steps=200;
else
    steps=25;
end

% in case of reruns, skip if all models are already analyzed
if ~isempty(modelList)
    for i=1:steps:length(modelList)
        if length(modelList)-i>=steps-1
            endPnt=steps-1;
        else
            endPnt=length(modelList)-i;
        end
        
        modelsToLoad={};
        for j=i:i+endPnt
            if j <= length(modelList)
                modelsToLoad{j}=[modelFolder filesep modelList{j}];
            end
        end
        
        rxnsTmp={};
        parfor j=i:i+endPnt
            try
                model=readCbModel(modelsToLoad{j});
            
            catch
                model=  load(modelsToLoad{j});
                model = model.model;
            end
            
            rxnsTmp{j}=model.rxns;
            metsTmp{j}=model.mets;
        end
        
        for j=i:i+endPnt
            plusonerow=size(reactionPresence,1)+1;
            modelID=strrep(modelList{j},'.mat','');
            modelID=strrep(modelID,'.sbml','');
            modelID=strrep(modelID,'.xml','');
            reactionPresence{plusonerow,1}=modelID;
            reactionPresence(plusonerow,2:end)={'0'};
            metabolitePresence{plusonerow,1}=modelID;
            metabolitePresence(plusonerow,2:end)={'0'};
            for k=1:length(allRxns)
                if ~isempty(find(ismember(rxnsTmp{j},allRxns{k})))
                    reactionPresence{plusonerow,k+1}='1';
                else
                    reactionPresence{plusonerow,k+1}='0';
                end
            end
            for k=1:length(allMets)
                if any(find(ismember(metsTmp{j},{[allMets{k} '[c]'],[allMets{k} '[p]'],[allMets{k} '[e]'],[allMets{k} '[c0]'],[allMets{k} '[e0]']})))
                    metabolitePresence{plusonerow,k+1}='1';
                else
                    metabolitePresence{plusonerow,k+1}='0';
                end
            end
        end
        metabolitePresence{1,1}='Model_ID';
        reactionPresence{1,1}='Model_ID';
        % export the results as a table
        writetable(cell2table(reactionPresence),[propertiesFolder filesep 'ReactionMetabolitePresence' filesep 'reactionPresence_' reconVersion],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
        writetable(cell2table(metabolitePresence),[propertiesFolder filesep 'ReactionMetabolitePresence' filesep 'metabolitePresence_' reconVersion],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
    end
end

end