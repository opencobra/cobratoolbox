function printReconstructionContent(modelFolder,propertiesFolder,reconVersion,numWorkers)
% This function creates text files containing all reactions and metabolites
% in the reconstruction resource.
%
% USAGE
%   printReconstructionContent(modelFolder,propertiesFolder,reconVersion,numWorkers)
%
% INPUTS
% modelFolder         Folder with reconstructions to be printed
% propertiesFolder    Folder where the computed stochiometric and flux
%                     consistencies will be stored
% reconVersion        Name assigned to the reconstruction resource
% numWorkers          Number of workers in parallel pool
%
%   - AUTHOR
%   Almut Heinken, 07/2020

metaboliteDatabase = readtable('MetaboliteDatabase.txt', 'Delimiter', 'tab','TreatAsEmpty',['UND. -60001','UND. -2011','UND. -62011'], 'ReadVariableNames', false);
metaboliteDatabase=table2cell(metaboliteDatabase);
database.metabolites=metaboliteDatabase;
for i=1:size(database.metabolites,1)
    database.metabolites{i,5}=num2str(database.metabolites{i,5});
end
reactionDatabase = readtable('ReactionDatabase.txt', 'Delimiter', 'tab','TreatAsEmpty',['UND. -60001','UND. -2011','UND. -62011'], 'ReadVariableNames', false);
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

dInfo = dir(modelFolder);
models={dInfo.name};
models=models';
models(~(contains(models(:,1),{'.mat','.sbml','.xml'})),:)=[];

modelsToLoad={};

for i=1:length(models)
    modelsToLoad{i} = [modelFolder filesep models{i}];
end

% print resource content
uniqueRxns = {};
uniqueMets = {};

rxnsTmp={};
metsTmp={};

parfor i=1:length(models)
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
    
end
for i=1:length(models)
    % grab all unique reactions and metabolites
    uniqueRxns=unique(vertcat(uniqueRxns,rxnsTmp{i}));
    uniqueMets=unique(vertcat(uniqueMets,metsTmp{i}));
end

% print out the unique reactions and metabolites of the resource-only if it
% used VMH nomenclature
reconMetabolites=database.metabolites;
[C,IA] = setdiff(reconMetabolites(:,1),uniqueMets);
reconMetabolites(IA,:)=[];
if size(reconMetabolites,1)>200
writetable(cell2table(reconMetabolites),[propertiesFolder filesep 'Metabolites_' reconVersion],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
end

reconReactions=database.reactions;
[C,IA] = setdiff(reconReactions(:,1),uniqueRxns);
reconReactions(IA,:)=[];
if size(reconMetabolites,1)>200
writetable(cell2table(reconReactions),[propertiesFolder filesep 'Reactions_' reconVersion],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
end

end
