function getReactionMetabolitePresence(modelFolder,propertiesFolder,reconVersion)
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

mkdir([propertiesFolder filesep 'ReactionMetabolitePresence'])

dInfo = dir(modelFolder);
modelList={dInfo.name};
modelList=modelList';
modelList(~contains(modelList(:,1),'.mat'),:)=[];
modelList(:,1)=strrep(modelList(:,1),'.mat','');

% check if output file already exists
if isfile(['ReactionPresence_' reconVersion '.txt'])
    reactionPresence = readtable(['ReactionPresence_' reconVersion '.txt'], 'ReadVariableNames', false);
    ReactionPresence = table2cell(reactionPresence);
    allRxns=ReactionPresence(1,2:end)';
    metabolitePresence = readtable(['MetabolitePresence_' reconVersion '.txt'], 'ReadVariableNames', false);
    MetabolitePresence = table2cell(metabolitePresence);
    allMets=MetabolitePresence(1,2:end)';
else
    % restart from existing data if possible
    % find the correct file with the reaction and metabolite list
    if ~any(contains(propertiesFolder,{[filesep 'Draft'],[filesep 'Refined']}))
        reactionDB = [propertiesFolder filesep 'Reactions_' reconVersion '_refined.txt'];
        metDB = [propertiesFolder filesep 'Metabolites_' reconVersion '_refined.txt'];
    else
        reactionDB = [propertiesFolder filesep 'Reactions_' reconVersion '.txt'];
        metDB = [propertiesFolder filesep 'Metabolites_' reconVersion '.txt'];
    end
    if isfile(reactionDB)
        reactions = readtable(reactionDB, 'ReadVariableNames', false);
        reactions = table2cell(reactions);
        allRxns=reactions(:,1);
        metabolites = readtable(metDB, 'ReadVariableNames', false);
        metabolites = table2cell(metabolites);
        allMets=metabolites(:,1);
    else
        allRxns={};
        allMets={};
        for i=1:length(modelList)
            i
            model=readCbModel([modelFolder filesep modelList{i} '.mat']);
            allRxns=unique(vertcat(allRxns,model.rxns));
            allMets=unique(vertcat(allMets,model.mets));
        end
    end
    MetabolitePresence(1,2:length(allMets)+1)=allMets';
    ReactionPresence(1,2:length(allRxns)+1)=allRxns';
end

% remove models that were already retrieved
modelsRenamed=strrep(modelList(:,1),'.mat','');
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
            rxnsTmp{j}=model.rxns;
            metsTmp{j}=model.mets;
        end
        
        for j=i:i+endPnt
            plusonerow=size(ReactionPresence,1)+1;
            ReactionPresence{plusonerow,1}=strrep(modelList{j},'.mat','');
            MetabolitePresence{plusonerow,1}=strrep(modelList{j},'.mat','');
            for k=1:length(allRxns)
                if ~isempty(find(ismember(rxnsTmp{j},allRxns{k})))
                    ReactionPresence{plusonerow,k+1}=1;
                else
                    ReactionPresence{plusonerow,k+1}=0;
                end
            end
            for k=1:length(allMets)
                if any(find(ismember(metsTmp{j},{[allMets{k} '[c]'],[allMets{k} '[p]'],[allMets{k} '[e]']})))
                    MetabolitePresence{plusonerow,k+1}=1;
                else
                    MetabolitePresence{plusonerow,k+1}=0;
                end
            end
        end
        % export the results as a table
        writetable(cell2table(ReactionPresence),['ReactionPresence_' reconVersion],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
        writetable(cell2table(MetabolitePresence),['MetabolitePresence_' reconVersion],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
    end
end

writetable(cell2table(ReactionPresence),[propertiesFolder filesep 'ReactionMetabolitePresence' filesep 'ReactionPresence_' reconVersion],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
writetable(cell2table(MetabolitePresence),[propertiesFolder filesep 'ReactionMetabolitePresence' filesep 'MetabolitePresence_' reconVersion],'FileType','text','WriteVariableNames',false,'Delimiter','tab');

end