function computeFluxConsistentReactionPresence(modelFolder,propertiesFolder,reconVersion)
% This function extracts the presence of flux consistent reactions for a 
% resource of reconstructions that were refined through the semi-automatic 
% refinement pipeline (1 = present in the flux consistent submodel, 0 = not
% present in the flux consistent submodel).
%
% USAGE
%   computeFluxConsistentReactionPresence(modelFolder,propertiesFolder,reconVersion)
%
% INPUTS
% modelFolder                                                                                                                                                                                           Folder with COBRA models to be analyzed
% propertiesFolder      Folder where the retrieved reaction presences will
%                       be stored (default: current folder)
% reconVersion          Name assigned to the reconstruction resource
%
%   - AUTHOR
%   Almut Heinken, 12/2020

mkdir([propertiesFolder filesep 'ReactionMetabolitePresence'])
currentDir=pwd;
cd([propertiesFolder filesep 'ReactionMetabolitePresence'])

dInfo = dir(modelFolder);
modelList={dInfo.name};
modelList=modelList';
modelList(~(contains(modelList(:,1),{'.mat','.sbml','.xml'})),:)=[];

% check if output file already exists
if isfile(['ReactionPresence_' reconVersion '.txt'])
    reactionPresence = readtable(['ReactionPresence_' reconVersion '.txt'], 'ReadVariableNames', false);
    ReactionPresence = table2cell(reactionPresence);
    allRxns=ReactionPresence(1,2:end)';
else
    % restart from existing data if possible
    if isfile([propertiesFolder filesep 'Reactions_' reconVersion '.txt'])
        reactions = readtable([propertiesFolder filesep 'Reactions_' reconVersion '.txt'], 'ReadVariableNames', false);
        reactions = table2cell(reactions);
        allRxns=reactions(:,1);
    else
        allRxns={};
        for i=1:length(modelList)
            i
            model=readCbModel([modelFolder filesep modelList{i} '.mat']);
            allRxns=unique(vertcat(allRxns,model.rxns));
        end
    end
end

% remove models that were already retrieved
modelsRenamed=strrep(modelList(:,1),'.mat','');
modelsRenamed=strrep(modelsRenamed,'.sbml','');
modelsRenamed=strrep(modelsRenamed,'.xml','');
[C,IA]=intersect(modelsRenamed,ReactionPresence(2:end,1));
modelList(IA,:)=[];

% define the intervals in which the computations will be performed
if length(modelList)>100000
    steps=50000;
elseif length(modelList)>20000
    steps=10000;
elseif length(modelList)>5000
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
                modelsToLoad{j}=[modelFolder filesep modelList{j} '.mat'];
            end
        end
        
        rxnsTmp={};
        parfor j=i:i+endPnt
            model=readCbModel(modelsToLoad{j});
            [~, ~, ~, ~, model] = findFluxConsistentSubset(model);
            rxnsTmp{j}=model.rxns;
        end
        
        for j=i:i+endPnt
            plusonerow=size(ReactionPresence,1)+1;
            
            ReactionPresence{plusonerow,1}=strrep(modelList{j},'.mat','');
            for k=1:length(allRxns)
                if ~isempty(find(ismember(rxnsTmp{j},allRxns{k})))
                    ReactionPresence{plusonerow,k+1}=1;
                else
                    ReactionPresence{plusonerow,k+1}=0;
                end
            end
        end
        % export the results as a table
        writetable(cell2table(ReactionPresence),['FluxConsistent_ReactionPresence_' reconVersion],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
    end
end

cd(currentDir)

end