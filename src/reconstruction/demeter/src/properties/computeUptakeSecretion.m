function computeUptakeSecretion(modelFolder,propertiesFolder,reconVersion,metList,numWorkers)
% This function extracts all metabolites that could be consumed or secreted
% by at least one refined reconstruction in the tested reconstruction
% resource.
%
% USAGE
%   computeUptakeSecretion(modelFolder,propertiesFolder,reconVersion,numWorkers)
%
% INPUTS
% modelFolder           Folder with reconstructions to be analyzed
% propertiesFolder      Folder where the retrieved uptake and secretion
%                       potential will be stored (default: current folder)
% reconVersion          Name assigned to the reconstruction resource
%                       (default: "Reconstructions")
% metList               List of VMH IDs of metabolites to analyze (default:
%                       all metabolites in reconstruction resource)
% numWorkers            Number of workers in parallel pool (default: 0)
%
%   - AUTHORS
%   Almut Heinken, 06/2020

dInfo = dir(modelFolder);
modelList={dInfo.name};
modelList=modelList';
modelList(~(contains(modelList(:,1),{'.mat','.sbml','.xml'})),:)=[];

mkdir([propertiesFolder filesep 'ComputedFluxes'])

uptakeFluxes = {};
secretionFluxes = {};

if ~isempty(metList)
    allExch={};
    for i=1:length(metList)
        allExch{i}=['EX_'  metList{i} '(e)'];
    end
else
    % start from existing progress if possible
    if isfile([propertiesFolder filesep 'ComputedFluxes' filesep 'uptakeFluxes_' reconVersion  '.txt'])
        uptakeFluxes = readtable([propertiesFolder filesep 'ComputedFluxes' filesep 'uptakeFluxes_' reconVersion  '.txt'], 'ReadVariableNames', false);
        uptakeFluxes = table2cell(uptakeFluxes);
        allExch=uptakeFluxes(1,2:end)';
        secretionFluxes = readtable([propertiesFolder filesep 'ComputedFluxes' filesep 'secretionFluxes_' reconVersion  '.txt'], 'ReadVariableNames', false);
        secretionFluxes = table2cell(secretionFluxes);
        
        % remove models that were already retrieved
        modelsRenamed=strrep(modelList(:,1),'.mat','');
        modelsRenamed=strrep(modelsRenamed,'.sbml','');
        modelsRenamed=strrep(modelsRenamed,'.xml','');
        [C,IA]=intersect(modelsRenamed,uptakeFluxes(2:end,1));
        modelList(IA,:)=[];
    else
        % restart from existing data if possible
        if isfile([propertiesFolder filesep 'Reactions_' reconVersion '.txt'])
            reactions = readtable([propertiesFolder filesep 'Reactions_' reconVersion '.txt'], 'ReadVariableNames', false);
            reactions = table2cell(reactions);
            allExch=reactions(find(strncmp(reactions(:,1),'EX_',3)),1);
        else
            % load all reconstructions and get the exchange reactions
            allExch={};
            for i=1:length(modelList)
                i
                model=readCbModel([modelFolder filesep modelList{i}]);
                exRxns=model.rxns(find(strncmp(model.rxns,'EX_',3)));
                allExch=unique(vertcat(allExch,exRxns));
            end
        end
    end
end

uptakeFluxes(1,2:length(allExch)+1) = allExch;
secretionFluxes(1,2:length(allExch)+1) = allExch;

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
        
        minFluxes={};
        maxFluxes={};
        
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
            restoreEnvironment(environment);
            changeCobraSolver(solver, 'LP', 0, -1);
            if strcmp(solver,'ibm_cplex')
                % prevent creation of log files
                changeCobraSolverParams('LP', 'logFile', 0);
            end
            model=readCbModel(modelsToLoad{j});
            exRxns=model.rxns(find(strncmp(model.rxns,'EX_',3)));
            % open all exchanges
            model = changeRxnBounds(model, exRxns, -1000, 'l');
            model = changeRxnBounds(model, exRxns, 1000, 'u');

            % only use the ones that should be analyzed
            exRxns=intersect(exRxns,allExch);
            
            % compute the total uptake and secretion potential
            if ~isempty(exRxns)
                if ~isempty(ver('distcomp')) && any(strcmp(solver,{'ibm_cplex','tomlab_cplex','cplex_direct'}))
                    [minFlux, maxFlux, ~, ~] = fastFVA(model, 0, 'max', solver, exRxns, 'S');
                else
                    [minFlux, maxFlux] = fluxVariability(model, 0, 'max', exRxns);
                end
            else
                minFlux=zeros(length(allExch),1);
                maxFlux=zeros(length(allExch),1);
            end
            minFluxes{j}=minFlux;
            maxFluxes{j}=maxFlux;
        end
        
        for j=i:i+endPnt
            model=readCbModel(modelsToLoad{j});
            plusonerow=size(uptakeFluxes,1)+1;
            modelID=strrep(modelList{j},'.mat','');
            modelID=strrep(modelID,'.sbml','');
            modelID=strrep(modelID,'.xml','');
            uptakeFluxes{plusonerow,1}=modelID;
            secretionFluxes{plusonerow,1}=modelID;
            uptakeFluxes(plusonerow,2:end)={'0'};
            secretionFluxes(plusonerow,2:end)={'0'};
            exRxns=model.rxns(find(strncmp(model.rxns,'EX_',3)));
            
            % only use the ones that should be analyzed
            exRxns=intersect(exRxns,allExch);
            
            for k=1:length(exRxns)
                findInd=find(strcmp(allExch,exRxns{k}));
                uptakeFluxes{plusonerow,findInd}=minFluxes{j}(k);
                secretionFluxes{plusonerow,findInd}=maxFluxes{j}(k);
            end
        end
        writetable(cell2table(uptakeFluxes),[propertiesFolder filesep 'ComputedFluxes' filesep 'uptakeFluxes_' reconVersion],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
        writetable(cell2table(secretionFluxes),[propertiesFolder filesep 'ComputedFluxes' filesep 'secretionFluxes_' reconVersion],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
    end
    
    % save both combined in one file
    UptakeSecretion=secretionFluxes;
    UptakeSecretion(:,size(UptakeSecretion,2)+1:size(UptakeSecretion,2)+length(allExch))=uptakeFluxes(:,2:end);
    writetable(cell2table(UptakeSecretion),[propertiesFolder filesep 'ComputedFluxes' filesep 'UptakeSecretion_' reconVersion],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
end

% convert to qualitative data
tol=0.0000001;

files={['uptakeFluxes_' reconVersion],['secretionFluxes_' reconVersion],['UptakeSecretion_' reconVersion]};
for i=1:length(files)
    data = readtable([propertiesFolder filesep 'ComputedFluxes' filesep files{i}  '.txt'], 'ReadVariableNames', false);
    data = table2cell(data);
    for j=2:size(data,1)
        for k=2:size(data,2)
            if str2double(data{j,k}) < -tol
                data{j,k}=-1;
            elseif str2double(data{j,k}) > tol
                data{j,k}=1;
            else
                data{j,k}=0;
            end
        end
    end
    writetable(cell2table(data),[propertiesFolder filesep 'ComputedFluxes' filesep files{i} '_qualitative'],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
end

end
