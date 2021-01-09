function printReconstructionFeatures(draftFolder,curatedFolder,propertiesFolder,reconVersion,numWorkers)

% This function prints a comparison of the draft and refined
% reconstructions for the refined reconstruction resource, as well as
% creates text files containing all reactions and metabolites in the 
% refined reconstruction resource.
%
% USAGE
%   printReconstructionFeatures(draftFolder,curatedFolder,propertiesFolder,reconVersion,numWorkers)
%
% INPUTS
% draftFolder           Folder with translated draft reconstructions
% curatedFolder         Folder with refined reconstructions to be analyzed
% propertiesFolder      Folder where the computed stochiometric and flux
%                       consistencies will be stored
% reconVersion          Name assigned to the reconstruction resource
% numWorkers            Number of workers in parallel pool
%
%   - AUTHOR
%   Almut Heinken, 07/2020


toCompare={
    'Draft' draftFolder
    'Refined' curatedFolder
    };

cd(propertiesFolder)
mkdir([propertiesFolder filesep 'Draft_Refined_Comparison'])
cd([propertiesFolder filesep 'Draft_Refined_Comparison'])
currentDir=pwd;

fileDir = fileparts(which('ReactionTranslationTable.txt'));
metaboliteDatabase = readtable([fileDir filesep 'MetaboliteDatabase.txt'], 'Delimiter', 'tab','TreatAsEmpty',['UND. -60001','UND. -2011','UND. -62011'], 'ReadVariableNames', false);
metaboliteDatabase=table2cell(metaboliteDatabase);
database.metabolites=metaboliteDatabase;
for i=1:size(database.metabolites,1)
    database.metabolites{i,5}=num2str(database.metabolites{i,5});
end
reactionDatabase = readtable([fileDir filesep 'ReactionDatabase.txt'], 'Delimiter', 'tab','TreatAsEmpty',['UND. -60001','UND. -2011','UND. -62011'], 'ReadVariableNames', false);
reactionDatabase=table2cell(reactionDatabase);
database.reactions=reactionDatabase;

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

for j=1:size(toCompare,1)
    % get reconstruction statistics: stats, stats, production, number of
    % reactions, metabolites, and genes
    
    stats={};
    stats{1,1}='Model_ID';
    stats{1,2}='Growth_aerobic_unlimited_medium';
    stats{1,3}='Growth_anaerobic_unlimited_medium';
    stats{1,4}='Growth_aerobic_Western_diet';
    stats{1,5}='Growth_anaerobic_Western_diet';
    stats{1,6}='ATP_aerobic_Western_diet';
    stats{1,7}='ATP_anaerobic_Western_diet';
    stats{1,8}='Reactions';
    stats{1,9}='Metabolites';
    stats{1,10}='Genes';
    stats{1,11}='Gene_associated_reactions';
    stats{1,12}='Reactions_supported_by_experimental_data';
    
    dInfo = dir(toCompare{j,2});
    models={dInfo.name};
    models=models';
    models(~contains(models(:,1),'.mat'),:)=[];
        
        % load existing file with resource content if present to not lose progress
        if isfile([propertiesFolder filesep 'uniqueRxns_' toCompare{j,1} '_' reconVersion '.mat'])
            load([propertiesFolder filesep 'uniqueMets_' toCompare{j,1} '_' reconVersion '.mat']);
            load([propertiesFolder filesep 'uniqueRxns_' toCompare{j,1} '_' reconVersion '.mat']);
        else
            uniqueRxns={};
            uniqueMets={};
        end
    
    % load the results from existing run and restart from there
    if isfile(['stats_' toCompare{j,1} '.mat'])
        load(['stats_' toCompare{j,1} '.mat']);

        % remove models that were already analyzed
        modelsRenamed=strrep(models(:,1),'.mat','');
        [C,IA]=intersect(modelsRenamed(:,1),stats(2:end,1));
        models(IA,:)=[];
    end
    
    if length(models)>1000
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
        
        % print resource content for refined reconstructions
            rxnsTmp={};
            metsTmp={};

        parfor i=l:l+endPnt
            statsTmp{i+1}=[];
            restoreEnvironment(environment);
            changeCobraSolver(solver, 'LP', 0, -1);
            if strcmp(solver,'ibm_cplex')
                % prevent creation of log files
                changeCobraSolverParams('LP', 'logFile', 0);
            end
            model = readCbModel(modelsToLoad{i});
            
            % collect unique metabolites and reactions resource content for refined reconstructions
            rxnsTmp{i}=model.rxns;
            mets=strrep(model.mets,'[c]','');
            mets=strrep(mets,'[e]','');
            mets=strrep(mets,'[p]','');
            metsTmp{i}=mets;
            
            % start collecting features of each reconstruction
            biomassID=find(strncmp(model.rxns,'bio',3));
            [AerobicGrowth, AnaerobicGrowth] = testGrowth(model, model.rxns(biomassID));
            statsTmp{i+1}(2)=AerobicGrowth(1,1);
            statsTmp{i+1}(3)=AnaerobicGrowth(1,1);
            statsTmp{i+1}(4)=AerobicGrowth(1,1);
            statsTmp{i+1}(5)=AnaerobicGrowth(1,1);
            % stats
            [ATPFluxAerobic, ATPFluxAnaerobic] = testATP(model);
            statsTmp{i+1}(6)=ATPFluxAerobic(1,1);
            statsTmp{i+1}(7)=ATPFluxAnaerobic(1,1);
            % Number of reactions, metabolites, and genes
            statsTmp{i+1}(8)=length(model.rxns);
            statsTmp{i+1}(9)=length(model.mets);
            statsTmp{i+1}(10)=length(model.genes);
            % fraction of gene-associated reactions and reactions supported by
            % experimental evidence
            model=removeRxns(model,model.rxns(find(strncmp(model.rxns,'EX_',3))));
            model=removeRxns(model,model.rxns(find(strncmp(model.rxns,'sink_',5))));
            model=removeRxns(model,model.rxns(strncmp(model.rxns,'DM_',3)));
            gpr_cnt=0;
            for k=1:length(model.rxns)
                if ~isempty(model.grRules{k}) && ~strcmp(model.grRules{k},'Unknown')
                    gpr_cnt=gpr_cnt+1;
                end
            end
            statsTmp{i+1}(11)=gpr_cnt/length(model.rxns);
            exp_cnt=0;
            if isfield(model,'comments')
                for k=1:length(model.comments)
                    if ~isempty(model.comments{k})
                        if contains(model.comments{k},'experimental')
                            exp_cnt=exp_cnt+1;
                        end
                    end
                end
            end
            statsTmp{i+1}(12)=exp_cnt/length(model.rxns);
        end
        for i=l:l+endPnt
            % grab all statistics
            onerowmore=size(stats,1)+1;
            stats{onerowmore,1}=strrep(models{i,1},'.mat','');
            for k=2:12
                stats{onerowmore,k}=statsTmp{i+1}(k);
            end
            
            % grab all unique reactions and metabolites
            uniqueRxns=unique(vertcat(uniqueRxns,rxnsTmp{i}));
            uniqueMets=unique(vertcat(uniqueMets,metsTmp{i}));
        end
        
        % save results
        save(['stats_' toCompare{j,1} '.mat'],'stats');
        
        save([propertiesFolder filesep 'uniqueRxns_' toCompare{j,1} '_' reconVersion '.mat'],'uniqueRxns');
        save([propertiesFolder filesep 'uniqueMets_' toCompare{j,1} '_' reconVersion '.mat'],'uniqueMets');
    end
    % print out a table with the features
    writetable(cell2table(stats),['ReconstructionFeatures_' toCompare{j,1} '_' reconVersion],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
    
    % print out the unique reactions and metabolites of the resource
    reconMetabolites=database.metabolites;
    [C,IA] = setdiff(reconMetabolites(:,1),uniqueMets);
    reconMetabolites(IA,:)=[];
    
    writetable(cell2table(reconMetabolites),[propertiesFolder filesep 'Metabolites_' reconVersion '_' lower(toCompare{j,1})],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
    
    reconReactions=database.reactions;
    [C,IA] = setdiff(reconReactions(:,1),uniqueRxns);
    reconReactions(IA,:)=[];
    writetable(cell2table(reconReactions),[propertiesFolder filesep 'Reactions_' reconVersion  '_' lower(toCompare{j,1})],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
end

% print summary table

for i=1:2
    Averages{1,i+1} = toCompare{i,1};
    stats = readtable(['ReconstructionFeatures_' toCompare{i,1} '_' reconVersion], 'ReadVariableNames', false);
    stats = table2cell(stats);
    for j=2:size(stats,2)
        Averages{j,1} = stats{1,j};
        if any(strncmp(stats{1,j},'Biomass',7))
            Averages{j,i+1} = num2str(sum(str2double(stats(2:end,j))> 0.000001));
        else
            av = mean(str2double(stats(2:end,j)));
            s = std(str2double(stats(2:end,j)));
            Averages{j,i+1} = [num2str(round(av,2)) ' +/- ' num2str(round(s,2))];
        end
    end
end
Averages=cell2table(Averages);
writetable(Averages,['ReconstructionFeatures_Overview_' reconVersion],'FileType','text','WriteVariableNames',false,'Delimiter','tab');

cd(currentDir)

end
