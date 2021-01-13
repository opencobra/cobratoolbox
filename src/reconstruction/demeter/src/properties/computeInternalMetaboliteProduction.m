function computeInternalMetaboliteProduction(modelFolder,propertiesFolder,reconVersion,metList,numWorkers)
% This function extracts all metabolites that could be produced internally
% by at least one refined reconstruction in the tested reconstruction
% resource. Disregards whether the metabolite can be transported.
%
% USAGE
%   computeInternalMetaboliteProduction(modelFolder,propertiesFolder,reconVersion,numWorkers)
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
%   Almut Heinken, 11/2020

dInfo = dir(modelFolder);
modelList={dInfo.name};
modelList=modelList';
modelList(~(contains(modelList(:,1),{'.mat','.sbml','.xml'})),:)=[];

currentDir=pwd;
mkdir([propertiesFolder filesep 'ComputedFluxes'])
cd([propertiesFolder filesep 'ComputedFluxes'])

% start from existing progress if possible
if isfile([propertiesFolder filesep 'ComputedFluxes' filesep 'InternalProduction_' reconVersion  '.txt'])
    InternalProduction = readtable([propertiesFolder filesep 'ComputedFluxes' filesep 'InternalProduction_' reconVersion  '.txt'], 'ReadVariableNames', false);
    InternalProduction = table2cell(InternalProduction);
    
    % use all metabolites in reconstruction resource unless specified
    % otherwise
    if isempty(metList)
        allMets=InternalProduction(1,2:end)';
    else
        allMets=metList;
    end
else
    if isempty(metList)
        % find the correct file with the metabolite list
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
    InternalProduction={};
    InternalProduction(1,2:length(allMets)+1)=allMets;
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
if isfile([propertiesFolder filesep 'ComputedFluxes' filesep 'InternalProduction_' reconVersion  '.txt'])
    modelsRenamed=strrep(modelList(:,1),'.mat','');
    modelsRenamed=strrep(modelsRenamed,'.sbml','');
    modelsRenamed=strrep(modelsRenamed,'.xml','');
    [C,IA]=intersect(modelsRenamed,InternalProduction(2:end,1));
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
            exRxns=model.rxns(find(strncmp(model.rxns,'EX_',3)));
            % open all exchanges
            model = changeRxnBounds(model, exRxns, -1000, 'l');
            model = changeRxnBounds(model, exRxns, 1000, 'u');
            
            % get all internal metabolites
            mets=strrep(model.mets,'[c]','');
            mets=strrep(mets,'[e]','');
            mets=unique(mets);
            % only get the ones that should be analyzed
            mets=intersect(mets,allMets);
            
            % add sink reactions for each metabolite and optimize it
            for k=1:length(mets)
                if ~isempty(find(strcmp(model.mets,[mets{k} '[c]'])))
                    if ~contains(model.rxns,['DM_' mets{k} '[c]'])
                        model=addDemandReaction(model,[mets{k} '[c]']);
                    end
                    model=changeObjective(model,['DM_' mets{k} '[c]']);
                    % do not count uptake of the metabolite
                    model=changeRxnBounds(model,['EX_' mets{k} '(e)'],0,'l');

                    FBA=optimizeCbModel(model,'max');
                    metFluxes{j}(k)=FBA.f;
                else
                    metFluxes{j}(k)=0;
                end
            end
        end
        
        for j=i:i+endPnt
            model=readCbModel(modelsToLoad{j});
            plusonerow=size(InternalProduction,1)+1;
            modelID=strrep(modelList{j},'.mat','');
            modelID=strrep(modelID,'.sbml','');
            modelID=strrep(modelID,'.xml','');
            InternalProduction{plusonerow,1}=modelID;
            InternalProduction(plusonerow,2:end)={'0'};
            
            % get all internal metabolites
            mets=strrep(model.mets,'[c]','');
            mets=strrep(mets,'[e]','');
            mets=unique(mets);
            % only get the ones that should be analyzed
            mets=intersect(mets,allMets);
            
            for k=1:length(mets)
                findInd=find(strcmp(InternalProduction(1,:),mets{k}));
                InternalProduction{plusonerow,findInd}=metFluxes{j}(k);
            end
        end
        writetable(cell2table(InternalProduction),[propertiesFolder filesep 'ComputedFluxes' filesep 'InternalProduction_' reconVersion],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
    end
end

% convert to qualitative data
tol=0.0000001;

data = readtable([propertiesFolder filesep 'ComputedFluxes' filesep 'InternalProduction_' reconVersion  '.txt'], 'ReadVariableNames', false);
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
writetable(cell2table(data),[propertiesFolder filesep 'ComputedFluxes' filesep 'InternalProduction_' reconVersion '_qualitative'],'FileType','text','WriteVariableNames',false,'Delimiter','tab');

cd(currentDir)

end
