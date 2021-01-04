function computeStochiometricFluxConsistency(translDraftsFolder,refinedFolder,propertiesFolder,reconVersion, numWorkers)

% This computes the stochiometric and flux consistency for all draft and
% refined reconstructions in the reconstruction resource.
%
% USAGE
%   computeStochiometricFluxConsistency(translDraftsFolder,refinedFolder,propertiesFolder,reconVersion, numWorkers)
%
% INPUTS
% translDraftsFolder    Folder with translated draft reconstructions that were refined
% refinedFolder         Folder with refined reconstructions to be analyzed
% OPTIONAL INPUTS
% propertiesFolder      Folder where the computed stochiometric and flux
%                       consistencies will be stored (default: current folder)
% reconVersion          Name assigned to the reconstruction resource
%
%   - AUTHOR
%   Almut Heinken, 07/2020

versions={
    'Draft_'    translDraftsFolder
    'Refined_'  refinedFolder
    };

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

for t=1:size(versions,1)
    % Get all models from the input folder
    dInfo = dir(versions{t,2});
    models={dInfo.name};
    models=models';
    models(~contains(models(:,1),'.mat'),:)=[];
    
    dataSConsist = [];
    dataFConsist = [];
    modelsAlreadyAnalyzed = {};
        
    % load existing file if present to not lose progress
    if isfile([propertiesFolder filesep 'modelsAlreadyAnalyzed_' versions{t,1} reconVersion '.mat'])
        load([propertiesFolder filesep 'StochiometricConsistency_' versions{t,1} reconVersion '.mat']);
        load([propertiesFolder filesep 'FluxConsistency_' versions{t,1} reconVersion '.mat']);
        load([propertiesFolder filesep 'modelsAlreadyAnalyzed_' versions{t,1} reconVersion '.mat']);
    end
    
    % remove models that were already analyzed
    if ~isempty(modelsAlreadyAnalyzed)
        [C,IA]=intersect(models(:,1),modelsAlreadyAnalyzed(:,1));
        models(IA,:)=[];
    end
    
    % define the intervals in which the computations will be performed
    if length(models)>5000
        steps=500;
    elseif length(models)>500
        steps=200;
    else
        steps=25;
    end
    
    for i=1:steps:length(models)
        if length(models)>steps-1 && (length(models)-1)>=steps-1
            endPnt=steps-1;
        else
            endPnt=length(models)-i;
        end
        
        % get models to load
        modelToLoad = {};
        for j=i:i+endPnt
            if j <= length(models)
                modelToLoad{j} = [versions{t,2} filesep models{j}];
            end
        end
        
        dataSConsistTmp=[];
        dataFConsistTmp=[];
        parfor j=i:i+endPnt
            if j <= length(models)
                restoreEnvironment(environment);
                changeCobraSolver(solver, 'LP', 0, -1);
                if strcmp(solver,'ibm_cplex')
                    % prevent creation of log files
                    changeCobraSolverParams('LP', 'logFile', 0);
                end
                model=readCbModel(modelToLoad{j});
                
                [fluxConsistentMetBool, fluxConsistentRxnBool, fluxInConsistentMetBool, fluxInConsistentRxnBool] = findFluxConsistentSubset(model);
                % exclude exchange and demand reactions
                exRxns=vertcat(find(strncmp(model.rxns,'EX_',3)),find(strcmp(model.rxns,'rxn00062')));
                fluxConsistentRxnBool(exRxns,:)=[];
                fluxInConsistentRxnBool(exRxns,:)=[];
                dataFConsistTmp(j,1)=sum(fluxConsistentRxnBool)/(sum(fluxConsistentRxnBool) + sum(fluxInConsistentRxnBool));
                [SConsistentMetBool,SConsistentRxnBool,SInConsistentMetBool,SInConsistentRxnBool,unknownSConsistencyMetBool,unknownSConsistencyRxnBool]=...
                    findStoichConsistentSubset(model);
                % exclude exchange and demand reactions
                SConsistentRxnBool(exRxns,:)=[];
                SInConsistentRxnBool(exRxns,:)=[];
                dataSConsistTmp(j,1)=sum(SConsistentRxnBool)/(sum(SConsistentRxnBool) + sum(SInConsistentRxnBool));
            end
        end
        % add to already existing data
        for j=i:i+endPnt
            dataSConsist(size(dataSConsist,1)+1,1)=dataSConsistTmp(j,1);
            dataFConsist(size(dataFConsist,1)+1,1)=dataFConsistTmp(j,1);
            modelsAlreadyAnalyzed{size(modelsAlreadyAnalyzed,1)+1,1}=models{j};
        end
        save([propertiesFolder filesep 'modelsAlreadyAnalyzed_' versions{t,1} reconVersion '.mat'],'modelsAlreadyAnalyzed');
        save([propertiesFolder filesep 'StochiometricConsistency_' versions{t,1} reconVersion '.mat'],'dataSConsist');
        save([propertiesFolder filesep 'FluxConsistency_' versions{t,1} reconVersion '.mat'],'dataFConsist');
    end
end

% create figure

for t=1:size(versions,1)
    load([propertiesFolder filesep 'StochiometricConsistency_' versions{t,1} reconVersion '.mat']);
    load([propertiesFolder filesep 'FluxConsistency_' versions{t,1} reconVersion '.mat']);
    dataSConsistPlotted(:,t)=dataSConsist(:,1);
    dataFConsistPlotted(:,t)=dataFConsist(:,1);
end

figure;
subplot(2,1,1)
hold on
violinplot(dataSConsistPlotted, {'Draft models','Curated models'});
set(gca, 'FontSize', 16)
box on
title('Stochiometric consistency');
subplot(2,1,2)
hold on
violinplot(dataFConsistPlotted, {'Draft models','Curated models'});
set(gca, 'FontSize', 16)
box on
title('Flux consistency');
print([propertiesFolder filesep 'Consistency_' reconVersion],'-dpng','-r300')

close all

end

