function computeReconstructionFeatures(translDraftsFolder,refinedFolder,propertiesFolder,reconVersion,numWorkers)
% This function prints a comparison of basic reconstruction features of 
% the draft and refined reconstructions for the refined reconstruction 
% resource.
%
% USAGE
%   computeReconstructionFeatures(translDraftsFolder,refinedFolder,propertiesFolder,reconVersion,numWorkers)
%
% INPUTS
% translDraftsFolder    Folder with translated draft reconstructions
% refinedFolder         Folder with refined reconstructions to be analyzed
% propertiesFolder      Folder where the computed stochiometric and flux
%                       consistencies will be stored
% reconVersion          Name assigned to the reconstruction resource
% numWorkers            Number of workers in parallel pool
%
%   - AUTHOR
%   Almut Heinken, 07/2020

if ~isempty(translDraftsFolder)
toCompare={
    'Draft' translDraftsFolder
    'Refined' refinedFolder
    };
else
    toCompare={
    'Refined' refinedFolder
    };
end

global CBT_LP_SOLVER
if isempty(CBT_LP_SOLVER)
    initCobraToolbox
end
solver = CBT_LP_SOLVER;

if numWorkers>0 && ~isempty(ver('parallel'))
    % with parallelization
    poolobj = gcp('nocreate');
    if isempty(poolobj)
        parpool(numWorkers)
    end
end
environment = getEnvironment();

% define input parameters for findFluxConsistentSubset
param=struct;
feasTol = getCobraSolverParams('LP', 'feasTol');
param.('feasTol')= feasTol;
param.('epsilon')=feasTol*100;
param.('modeFlag')=0;
param.('method')='fastcc';

for j=1:size(toCompare,1)
    % get reconstruction statistics: stats, stats, production, number of
    % reactions, metabolites, and genes
    
    stats={};
    stats{1,1}='Model_ID';
    stats{1,2}='Growth_aerobic_unlimited_medium';
    stats{1,3}='Growth_anaerobic_unlimited_medium';
    stats{1,4}='Growth_aerobic_complex_medium';
    stats{1,5}='Growth_anaerobic_complex_medium';
    stats{1,6}='ATP_aerobic_complex_medium';
    stats{1,7}='ATP_anaerobic_complex_medium';
    stats{1,8}='Reactions';
    stats{1,9}='Metabolites';
    stats{1,10}='Genes';
    stats{1,11}='Gene_associated_reactions';
    stats{1,12}='Stoichiometrically_consistent_reactions';
    stats{1,13}='Flux_consistent_reactions';
    
    dInfo = dir(toCompare{j,2});
    models={dInfo.name};
    models=models';
    models(~(contains(models(:,1),{'.mat','.sbml','.xml'})),:)=[];
        
    % load the results from existing run and restart from there
    if isfile(['stats_' toCompare{j,1} '.mat'])
        load(['stats_' toCompare{j,1} '.mat']);
        
        % remove models that were already analyzed
        modelsRenamed=strrep(models(:,1),'.mat','');
        modelsRenamed=strrep(modelsRenamed,'.sbml','');
        [C,IA]=intersect(modelsRenamed(:,1),stats(2:end,1));
        models(IA,:)=[];
    end
    
    if length(models)>5000
        steps=1000;
    elseif length(models)>2000
        steps=200;
    else
        steps=25;
    end

    for l=1:steps:length(models)
        if length(models)-l>=steps-1
            endPnt=steps-1;
        else
            endPnt=length(models)-l;
        end
        
        modelsToLoad={};
        
        for i=l:l+endPnt
            modelsToLoad{i} = [toCompare{j,2} filesep models{i}];
        end
        statsTmp={};
        
        parfor i=l:l+endPnt
            statsTmp{i+1}=[];
            restoreEnvironment(environment);
            changeCobraSolver(solver, 'LP', 0, -1);
            if strcmp(solver,'ibm_cplex')
                % prevent creation of log files
                changeCobraSolverParams('LP', 'logFile', 0);
            end
            try
                model = readCbModel(modelsToLoad{i});
            catch
                    model = load(modelsToLoad{i});
                    model=model.model;
            end
            
            % start collecting features of each reconstruction
            biomassID=find(strncmp(model.rxns,'bio',3));
            [AerobicGrowth, AnaerobicGrowth] = testGrowth(model, model.rxns(biomassID));
            statsTmp{i+1}(2)=AerobicGrowth(1,1);
            statsTmp{i+1}(3)=AnaerobicGrowth(1,1);
            statsTmp{i+1}(4)=AerobicGrowth(1,2);
            statsTmp{i+1}(5)=AnaerobicGrowth(1,2);
            
            % stats
            [ATPFluxAerobic, ATPFluxAnaerobic] = testATP(model);
            statsTmp{i+1}(6)=ATPFluxAerobic(1,1);
            statsTmp{i+1}(7)=ATPFluxAnaerobic(1,1);

            % Number of reactions, metabolites, and genes
            statsTmp{i+1}(8)=length(model.rxns);
            statsTmp{i+1}(9)=length(model.mets);
            statsTmp{i+1}(10)=length(model.genes);

            % Stoichiometrically and flux consistent reactions
            % exclude exchange and demand reactions
            exRxns=vertcat(find(strncmp(model.rxns,'EX_',3)),find(strcmp(model.rxns,'rxn00062')));
            [SConsistentMetBool,SConsistentRxnBool,SInConsistentMetBool,SInConsistentRxnBool,unknownSConsistencyMetBool,unknownSConsistencyRxnBool]=...
                findStoichConsistentSubset(model);
            % exclude exchange and demand reactions
            SConsistentRxnBool(exRxns,:)=[];
            SInConsistentRxnBool(exRxns,:)=[];
            statsTmp{i+1}(12)=sum(SConsistentRxnBool)/(sum(SConsistentRxnBool) + sum(SInConsistentRxnBool));
            [fluxConsistentMetBool, fluxConsistentRxnBool, fluxInConsistentMetBool, fluxInConsistentRxnBool] = findFluxConsistentSubset(model,param);
            fluxConsistentRxnBool(exRxns,:)=[];
            fluxInConsistentRxnBool(exRxns,:)=[];
            statsTmp{i+1}(13)=sum(fluxConsistentRxnBool)/(sum(fluxConsistentRxnBool) + sum(fluxInConsistentRxnBool));
        end
        for i=l:l+endPnt
            % grab all statistics
            onerowmore=size(stats,1)+1;
            modelID=strrep(models{i},'.mat','');
            modelID=strrep(modelID,'.sbml','');
            stats{onerowmore,1}=modelID;
            for k=2:13
                stats{onerowmore,k}=statsTmp{i+1}(k);
            end
        end

        % save results
        save(['stats_' toCompare{j,1} '.mat'],'stats');
    end
    % print out a table with the features
    writetable(cell2table(stats),[propertiesFolder filesep 'Reconstruction_Features_' toCompare{j,1} '_' reconVersion],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
end

% print summary table

for i=1:size(toCompare,1)
    Averages{1,i+1} = toCompare{i,1};
    load(['stats_' toCompare{i,1} '.mat']);
    for j=2:size(stats,2)
        Averages{j,1} = stats{1,j};
        if any(strncmp(stats{1,j},'Biomass',7))
            if contains(version,'(R202') % for Matlab R2020a and newer
                Averages{j,i+1} = num2str(sum(cell2mat(stats(2:end,j))> 0.000001));
            else
                Averages{j,i+1} = num2str(sum(str2double(stats(2:end,j))> 0.000001));
            end
        else
            if contains(version,'(R202') % for Matlab R2020a and newer
                av = mean(cell2mat(stats(2:end,j)));
                s = std(cell2mat(stats(2:end,j)));
            else
                av = mean(str2double(stats(2:end,j)));
                s = std(str2double(stats(2:end,j)));
            end
            Averages{j,i+1} = [num2str(round(av,2)) ' +/- ' num2str(round(s,2))];
        end
    end
end
writetable(cell2table(Averages),[propertiesFolder filesep 'Reconstruction_Features_Summary_Table_' reconVersion],'FileType','text','WriteVariableNames',false,'Delimiter','tab');

% create figure
for t=1:size(toCompare,1)
    load(['stats_' toCompare{t,1} '.mat']);
    dataSConsistPlotted(:,t)=cell2mat(stats(2:end,12));
    dataFConsistPlotted(:,t)=cell2mat(stats(2:end,13));
end

if ~isempty(translDraftsFolder)
    figure;
    subplot(2,1,1)
    hold on
    violinplot(dataSConsistPlotted, {'Draft models','Curated models'});
    set(gca, 'FontSize', 16)
    title('Stochiometric consistency');
    subplot(2,1,2)
    hold on
    violinplot(dataFConsistPlotted, {'Draft models','Curated models'});
    set(gca, 'FontSize', 16)
    title('Flux consistency');
    print([propertiesFolder filesep 'Consistency_' reconVersion],'-dpng','-r300')
else
    figure;
    subplot(2,1,1)
    hold on
    violinplot(dataSConsistPlotted, 'Curated models');
    set(gca, 'FontSize', 16)
    title('Stochiometric consistency');
    subplot(2,1,2)
    hold on
    violinplot(dataFConsistPlotted, 'Curated models');
    set(gca, 'FontSize', 16)
    title('Flux consistency');
    print([propertiesFolder filesep 'Consistency_' reconVersion],'-dpng','-r300')
end

% delete unneeded files
for j=1:size(toCompare,1)
    delete(['stats_' toCompare{j,1} '.mat'])
end

end
