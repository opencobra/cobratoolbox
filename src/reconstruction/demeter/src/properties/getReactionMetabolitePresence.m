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
if isfile([propertiesFolder filesep 'ReactionMetabolitePresence' filesep 'ReactionPresence_' reconVersion '.txt'])
    reactionPresence = readtable([propertiesFolder filesep 'ReactionMetabolitePresence' filesep 'ReactionPresence_' reconVersion '.txt'], 'ReadVariableNames', false);
    ReactionPresence = table2cell(reactionPresence);
    allRxns=ReactionPresence(1,2:end)';
    metabolitePresence = readtable([propertiesFolder filesep 'ReactionMetabolitePresence' filesep 'MetabolitePresence_' reconVersion '.txt'], 'ReadVariableNames', false);
    MetabolitePresence = table2cell(metabolitePresence);
    allMets=MetabolitePresence(1,2:end)';
else
    % restart from existing data if possible
    if isfile([propertiesFolder filesep 'Reactions_' reconVersion '.txt'])
        reactions = readtable([propertiesFolder filesep 'Reactions_' reconVersion '.txt'], 'ReadVariableNames', false);
        reactions = table2cell(reactions);
        allRxns=reactions(:,1);
        metabolites = readtable([propertiesFolder filesep 'Metabolites_' reconVersion '.txt'], 'ReadVariableNames', false);
        metabolites = table2cell(metabolites);
        allMets=metabolites(:,1);
    else
        allRxns={};
        allMets={};
        for i=1:length(modelList)
            model=readCbModel([modelFolder filesep modelList{i}]);
            allRxns=unique(vertcat(allRxns,model.rxns));
            allMets=unique(vertcat(allMets,model.mets));
        end
    end
    MetabolitePresence(1,2:length(allMets)+1)=allMets';
    ReactionPresence(1,2:length(allRxns)+1)=allRxns';
end

% remove models that were already retrieved
modelsRenamed=strrep(modelList(:,1),'.mat','');
modelsRenamed=strrep(modelsRenamed,'.sbml','');
modelsRenamed=strrep(modelsRenamed,'.xml','');
[C,IA]=intersect(modelsRenamed,ReactionPresence(2:end,1));
modelList(IA,:)=[];

% define the intervals in which the computations will be performed
if length(modelList)>5000
    steps=2000;
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
            model=readCbModel(modelsToLoad{j});
            rxnsTmp{j}=model.rxns;
            metsTmp{j}=model.mets;
        end
        
        for j=i:i+endPnt
            plusonerow=size(ReactionPresence,1)+1;
            modelID=strrep(modelList{j},'.mat','');
            modelID=strrep(modelID,'.sbml','');
            modelID=strrep(modelID,'.xml','');
            ReactionPresence{plusonerow,1}=modelID;
            MetabolitePresence{plusonerow,1}=modelID;
            for k=1:length(allRxns)
                if ~isempty(find(ismember(rxnsTmp{j},allRxns{k})))
                    ReactionPresence{plusonerow,k+1}=1;
                else
                    ReactionPresence{plusonerow,k+1}=0;
                end
            end
            for k=1:length(allMets)
                if any(find(ismember(metsTmp{j},{[allMets{k} '[c]'],[allMets{k} '[p]'],[allMets{k} '[e]'],[allMets{k} '[c0]'],[allMets{k} '[e0]']})))
                    MetabolitePresence{plusonerow,k+1}=1;
                else
                    MetabolitePresence{plusonerow,k+1}=0;
                end
            end
        end
        % export the results as a table
        writetable(cell2table(ReactionPresence),[propertiesFolder filesep 'ReactionMetabolitePresence' filesep 'ReactionPresence_' reconVersion],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
        writetable(cell2table(MetabolitePresence),[propertiesFolder filesep 'ReactionMetabolitePresence' filesep 'MetabolitePresence_' reconVersion],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
    end
end

writetable(cell2table(ReactionPresence),[propertiesFolder filesep 'ReactionMetabolitePresence' filesep 'ReactionPresence_' reconVersion],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
writetable(cell2table(MetabolitePresence),[propertiesFolder filesep 'ReactionMetabolitePresence' filesep 'MetabolitePresence_' reconVersion],'FileType','text','WriteVariableNames',false,'Delimiter','tab');

end