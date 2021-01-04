function getMetabolitePresence(modelFolder,propertiesFolder,reconVersion,numWorkers)
% This function extracts the presence of all metabolites that were in at
% least one reconstruction in the analyzed reconstruction resource in each
% individual reconstruction.
%
% USAGE
%   getMetabolitePresence(modelFolder,propertiesFolder,reconVersion,numWorkers)
%
% INPUTS
% modelFolder           Folder with reconstructions to be analyzed
% propertiesFolder      Folder where the retrieved data will be stored 
%                       (default: current folder)
% reconVersion          Name assigned to the reconstruction resource
%                       (default: "Reconstructions")
% numWorkers            Number of workers in parallel pool (default: 0)
%
%   - AUTHORS
%   Almut Heinken, 12/2020

dInfo = dir(modelFolder);
modelList={dInfo.name};
modelList=modelList';
modelList(~contains(modelList(:,1),'.mat'),:)=[];

currentDir=pwd;
mkdir([propertiesFolder filesep 'ComputedFluxes'])
cd([propertiesFolder filesep 'ComputedFluxes'])

% start from existing progress if possible
if isfile([propertiesFolder filesep 'ComputedFluxes' filesep 'MetabolitePresence_' reconVersion  '.txt'])
    MetabolitePresence = readtable([propertiesFolder filesep 'ComputedFluxes' filesep 'MetabolitePresence_' reconVersion  '.txt'], 'ReadVariableNames', false);
    MetabolitePresence = table2cell(MetabolitePresence);
    
    % use all metabolites in reconstruction resource unless specified
    % otherwise
    if isempty(metList)
        allMets=MetabolitePresence(1,2:end)';
    else
        allMets=metList;
    end
else
    if isempty(metList)
        if isfile([propertiesFolder filesep 'Metabolites_' reconVersion '.txt'])
            metabolites = readtable([propertiesFolder filesep 'Metabolites_' reconVersion '.txt'], 'ReadVariableNames', false);
            metabolites = table2cell(metabolites);
            allMets=metabolites(:,1);
        else
            % load all reconstructions and get the exchange reactions
            allMets={};
            for i=1:length(modelList)
                i
                model=readCbModel([modelFolder filesep modelList{i}]);
                mets=strrep(model.mets,'[c]','');
                mets=strrep(mets,'[e]','');
                allMets=unique(vertcat(allMets,mets));
            end
        end
    else
        allMets=metList;
    end
    MetabolitePresence={};
    MetabolitePresence(1,2:length(allMets)+1)=allMets;
end

global CBT_LP_SOLVER
if isempty(CBT_LP_SOLVER)
    initCobraToolbox
end
solver = CBT_LP_SOLVER;

if numWorkers > 0
    % with parallelization
    poolobj = gcp('nocreate');
    if isempty(poolobj)
        parpool(numWorkers)
    end
end
environment = getEnvironment();

% remove models that were already retrieved
if isfile([propertiesFolder filesep 'ComputedFluxes' filesep 'MetabolitePresence_' reconVersion  '.txt'])
modelsRenamed=strrep(modelList(:,1),'.mat','');
[C,IA]=intersect(modelsRenamed,MetabolitePresence(2:end,1));
modelList(IA,:)=[];
end

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
                modelsToLoad{j}=[modelFolder filesep modelList{j}];
            end
        end
        
        parfor j=i:i+endPnt
            j
            restoreEnvironment(environment);
            changeCobraSolver(solver, 'LP', 0, -1);
            if strcmp(solver,'ibm_cplex')
                % prevent creation of log files
                changeCobraSolverParams('LP', 'logFile', 0);
            end
            model=readCbModel(modelsToLoad{j});
            metsTmp{j}=model.mets;
        end
        
        for j=i:i+endPnt
            model=readCbModel(modelsToLoad{j});
            plusonerow=size(MetabolitePresence,1)+1;
            MetabolitePresence{plusonerow,1}=strrep(modelList{j},'.mat','');
            MetabolitePresence(plusonerow,2:end)={'0'};
            
            % get all internal metabolites
            mets=strrep(model.mets,'[c]','');
            mets=strrep(mets,'[e]','');
            mets=unique(mets);
            % only get the ones that should be analyzed
            mets=intersect(mets,allMets);
            
            for k=1:length(mets)
                findInd=find(strcmp(MetabolitePresence(1,:),mets{k}));
                MetabolitePresence{plusonerow,findInd}=metFluxes{j}(k);
            end
        end
        writetable(cell2table(MetabolitePresence),[propertiesFolder filesep 'ComputedFluxes' filesep 'MetabolitePresence_' reconVersion],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
    end
end

% convert to qualitative data
tol=0.0000001;

data = readtable([propertiesFolder filesep 'ComputedFluxes' filesep 'MetabolitePresence_' reconVersion  '.txt'], 'ReadVariableNames', false);
data = table2cell(data);
for j=2:size(data,1)
    for k=2:size(data,2)
        if str2double(data{j,k}) > tol
            data{j,k}=1;
        else
            data{j,k}=0;
        end
    end
end
writetable(cell2table(data),[propertiesFolder filesep 'ComputedFluxes' filesep 'MetabolitePresence_' reconVersion '_qualitative'],'FileType','text','WriteVariableNames',false,'Delimiter','tab');

cd(currentDir)

end
