function batchTestAllReconstructionFunctions(modelFolder,testResultsFolder,inputDataFolder,reconVersion, numWorkers)
% Part of the DEMETER pipeline. This function performs all quality
% control/quality assurance tests on a batch of reconstructions and saves
% the results for each reconstruction in the input folder.
%
% USAGE:
%
%   batchTestAllReconstructionFunctions(modelFolder,testResultsFolder,inputDataFolder,reconVersion, numWorkers)
%
% INPUTS
% modelFolder           Folder with COBRA models (draft or refined
%                       reconstructions) to analyze
% testResultsFolder     Folder where the test results should be saved
% inputDataFolder       Folder with experimental data and database files
%                       to load
% reconVersion          Name of the refined reconstruction resource
% numWorkers            Number of workers in parallel pool
%
% .. Author:
%   - Almut Heinken, 09/2020

% set a solver if not done yet
global CBT_LP_SOLVER
solver = CBT_LP_SOLVER;
if isempty(solver)
    initCobraToolbox(false); %Don't update the toolbox automatically
end

% initialize parallel pool
if numWorkers>0 && ~isempty(ver('parallel'))
    % with parallelization
    poolobj = gcp('nocreate');
    if isempty(poolobj)
        parpool(numWorkers)
    end
end
environment = getEnvironment();

% Runs through all tests
dInfo = dir(modelFolder);
modelList={dInfo.name};
modelList=modelList';
modelList(~contains(modelList(:,1),'.mat'),:)=[];

fields = {
    'Mass_imbalanced'
    'Charge_imbalanced'
    'Mets_without_formulas'
    'Leaking_metabolites'
    'ATP_from_O2'
    'Blocked_reactions'
    'RefinedReactionsCarryingFlux'
    'BlockedRefinedReactions'
    'Incorrect_Gene_Rules'
    'Incorrect_Compartments'
    'Carbon_sources_TruePositives'
    'Carbon_sources_FalseNegatives'
    'Fermentation_products_TruePositives'
    'Fermentation_products_FalseNegatives'
    'growsOnDefinedMedium'
    'growthOnKnownCarbonSources'
    'Biomass_precursor_biosynthesis_TruePositives'
    'Biomass_precursor_biosynthesis_FalseNegatives'
    'Metabolite_uptake_TruePositives'
    'Metabolite_uptake_FalseNegatives'
    'Secretion_products_TruePositives'
    'Secretion_products_FalseNegatives'
    'Bile_acid_biosynthesis_TruePositives'
    'Bile_acid_biosynthesis_FalseNegatives'
    'Drug_metabolism_TruePositives'
    'Drug_metabolism_FalseNegatives'
    'PutrefactionPathways_TruePositives'
    'PutrefactionPathways_FalseNegatives'
    };

%% load the results from existing test suite run and restart from there
Results=struct;

alreadyAnalyzedStrains={};

for i=1:length(fields)
    if isfile([testResultsFolder filesep fields{i} '_' reconVersion '.txt'])
        savedResults = readtable([testResultsFolder filesep fields{i} '_' reconVersion '.txt'], 'Delimiter', 'tab', 'ReadVariableNames', false);
        Results.(fields{i}) = table2cell(savedResults);
        alreadyAnalyzedStrains = Results.(fields{i})(:,1);
    else
        Results.(fields{i})={};
    end
end

% propagate strains to empty fields
for i=1:length(fields)
    if isempty(Results.(fields{i}))
        Results.(fields{i})=alreadyAnalyzedStrains;
    end
end

% remove already analyzed reconstructions
if size(Results.(fields{1}),1)>0
    [C,IA]=intersect(strrep(modelList(:,1),'.mat',''),Results.(fields{1})(:,1));
    modelList(IA,:)=[];
end

% define the intervals in which the testing and regular saving will be
% performed
if length(modelList)>5000
    steps=1000;
elseif length(modelList)>1000
    steps=500;
elseif length(modelList)>200
    steps=200;
else
    steps=25;
end

%% Start the test suite
for i = 1:steps:length(modelList)
    tmpData={};
    if length(modelList)>steps-1 && (length(modelList)-1)>=steps-1
        endPnt=steps-1;
    else
        endPnt=length(modelList)-i;
    end
    
    modelsToLoad={};
    for j=i:i+endPnt
        modelsToLoad{j}={};
        if j <= length(modelList)
            modelsToLoad{j}=[modelFolder filesep modelList{j}];
        end
    end
    parfor j=i:i+endPnt
        if j <= length(modelList)
            restoreEnvironment(environment);
            changeCobraSolver(solver, 'LP');
            % prevent creation of log files
            changeCobraSolverParams('LP', 'logFile', 0);
            
            try
                model=readCbModel(modelsToLoad{j});
            catch
                modelsToLoad{j}
                model=load(modelsToLoad{j});
                fieldnames(model)
                model=model.model;
            end
            
            microbeID=strrep(modelList{j},'.mat','');
            testResults = runTestsOnModel(model, microbeID, inputDataFolder);
            tmpData{j}=testResults;
        end
    end
    for k=1:length(fields)
        for j=i:i+endPnt
            if j <= length(modelList)
                res=tmpData{j};
                
                if strcmp(fields{k},'Blocked_reactions') && length(modelList) + length(alreadyAnalyzedStrains) > 10000
                    % do not save for very large-scale resources-file would be
                    % enormous
                    Results.(fields{k}){size(Results.(fields{k}),1)+1,1} = res.(fields{k}){1,1};
                    Results.(fields{k}){size(Results.(fields{k}),1),2} = size(res.(fields{k}),2)-1;
                else
                    Results.(fields{k})(size(Results.(fields{k}),1)+1,1:size(res.(fields{k}),2)) = res.(fields{k})(1,1:end);
                end
            end
        end
    end
    
    %% print the results regularly to avoid having to repeat simulations
    % only if there were any findings that need to be reported
    for j=1:length(fields)
        if size(Results.(fields{j}),2)>1
            table2print=cell2table(Results.(fields{j}));
            writetable(table2print,[testResultsFolder filesep fields{j} '_' reconVersion],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
        end
    end
end

end
