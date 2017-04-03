function [AddedRxns] = submitFastGapFill(modelFile,dbFile,dictionaryFile,prepareFGFResults,weightsPerRxnFile,forceRerun,epsilon,blackList,listCompartments)
%% function [AddedRxns] = submitFastGapFill(modelFile,dbFile,dictionaryFile,prepareFGFResults,weightsPerRxnFile,forceRerun,epsilon,blackList,listCompartments)
%
% A test function for both prepareFastGapFill and
% fastGapFill, allowing all files to be optionally specified and not 
% requiring prepareFastGapFill to be rerun (if relevant variables are saved
% in a specified workspace file) if it has already been run.
%
% This function performs three runs of fastGapFill on the same prepared 
% model, with weights as specified in the 'Define Runs' section of the 
% code.  The 'runs' variable can be appended to or changed to enable the 
% running of fastGapFill for different combinations of weights (and 
% different weightsPerRxnFile files).
%
% This function draws inspiration heavily from the example already 
% available for fastGapFill, i.e. runGapFill_example.m
%
% N.B. The defaults are set for testing all of the functionality of the
% algorithm, including setting a (toy) weight file, which is not necessary 
% in running fastGapFill so should be specified as empty if running without
% a weight file.
%
% INPUT (ALL optional, defaults to E. coli model iAF1260 and example files)
% modelFileIn         File containing model, either .mat or .xml
%                        (default: 'examples/iAF1260.mat')
% dbFileIn            File containing universal database
%                        (default: 'AuxillaryFiles/reaction.lst')
% dictionaryFileIn    File containing db metabolite IDs and model
%                        counterparts, either .xls or .tsv
%                        (default: 'AuxillaryFiles/KEGG_dictionary.xls')
% workspaceFileIn     File for storing prepareFastGapFill results 
%                        (default: 'examples/defaultWorkspace.mat')
% weightsPerRxnFile   File containing individual weights for reactions 
%                        (default: 'examples/sampleWeights.tsv')
% forceRerun          Boolean specifying whether to rerun 
%                     prepareFastGapFill even if it has already been 
%                     run. N.B. If this is set to 'true' it will overwrite
%                     the precalculated default results files, unless 
%                     prepareFGFResults is specified outside the examples
%                     directory
%                        (default: false)
% epsilon             Float, a fastCore parameter 
%                        (default: 1e-4)
% blackList           List of excluded universal DB reactions 
%                        (default: none)
% listCompartments    List of compartments in the model to be gapFilled N.B.
%                     the default is set within prepareGapFill
%                        (default: all compartments specified in the model)
%
% OUTPUT
% AddedRxns           Reactions that have been added from UX matrix to S
%
% Jan 2016
% Will Bryant


%% Preparation - load data

% Suppress load warnings and deal with in the function
warning('off','MATLAB:load:variableNotFound')

% Get folder for finding default files relative to submitGapFill
runFile = which('submitFastGapFill');
runDirCell = regexp(runFile,'(.+/)[^/]+$','tokens');
runDir = runDirCell{1}{1};

% Get input files where specified
if ~exist('modelFile','var') || isempty(modelFile)
    modelFile = strcat(runDir,'examples/iAF1260.mat');
end
if ~exist('dbFile','var') || isempty(dbFile)
    dbFile = strcat(runDir,'AuxillaryFiles/reaction.lst');
end
if ~exist('dictionaryFile','var') || isempty(dictionaryFile)
    dictionaryFile = strcat(runDir,'AuxillaryFiles/KEGG_dictionary.xls');
end
if ~exist('prepareFGFResults','var') || isempty(prepareFGFResults)
    prepareFGFResults = strcat(runDir,'examples/prepareFGFResultsDefault.mat');
end
if ~exist('weightsPerRxnFile','var') || isempty(weightsPerRxnFile)
    weightsPerRxnFile = strcat(runDir,'examples/sampleWeights.tsv');
end
% fastGapFill results files will be created in the same directory as prepareFGFResults
resultsDirCell = regexp(prepareFGFResults,'(.+/)[^/]+$','tokens');
resultsDir = resultsDirCell{1}{1};
if ~exist(resultsDir, 'dir')
  mkdir(resultsDir);
end

if ~exist('forceRerun','var') || isempty(forceRerun)
    forceRerun=false;
end
if ~exist('epsilon','var') || isempty(epsilon)
    epsilon=1e-4;
end
if ~exist('blackList','var') || isempty(blackList)
    blackList=[];
end
if ~exist('listCompartments','var') || isempty(listCompartments)
    listCompartments=[];
end


%% prepareFastGapFill
% If workspaceFile is present, check for all variables; if consistModel, 
% consistMatricesSUX and BlockedRxns are present, do not rerun 
% prepareFastGapFill, otherwise run and save workspace; check for but do
% not require prepStats
try
    a = load(prepareFGFResults,'consistModel','consistMatricesSUX','BlockedRxns','model');
catch
    fprintf('Workspace file not found, proceeding with prepareGapFill ...\n')
    a = struct();
end
length_a = length(fieldnames(a));
clear a;
if (length_a == 4) && ~forceRerun
    fprintf('prepareGapFill already run, and forceRerun set to "false", prepareGapFill will not be rerun\n');
else
    
    % load model using relevant load function
    if regexp(modelFile,'.mat$')
        model = readMlModel(modelFile);
    elseif regexp(modelFile,'.xml$')
        model = readCbModel(modelFile);
        % If subSystems is empty, create a dummy subSystems for mergeTwoModels
        if ~exist('model.subSystems') || length(model.subSystems) ~= length(model.rxnNames)
            model.subSystems = repmat({''},length(model.rxnNames));
        end
        if ~exist('model.genes')
            model.genes = repmat({'no_gene'},1);
        end
        if ~exist('model.rxnGeneMat')
            model.rxnGeneMat = zeros(length(model.rxnNames),1);
        end
        if ~exist('model.grRules')
            model.grRules = repmat({''},length(model.rxnNames));
        end
    end
    
    % remove constraints from exchange reactions
    EX = strncmp('EX_',model.rxns,3);
    model.lb(EX)=-100;
    model.ub(EX)=100;
    clear EX

%     % Switch all model IDs to lower-case
%     model.mets = cellfun(@lower,model.mets,'UniformOutput',false);    
    
    tic;
    [consistModel,consistMatricesSUX,BlockedRxns] = prepareFastGapFill(model, listCompartments, epsilon, dbFile, dictionaryFile, blackList);
    tpre=toc;
    
    % Prepare the output table with statistics
    cnt = 1;
    prepStats{cnt,1} = 'Model name';cnt = cnt+1;
    prepStats{cnt,1} = 'Size S (original model)';cnt = cnt+1;
    prepStats{cnt,1} = 'Number of compartments';cnt = cnt+1;
    prepStats{cnt,1} = 'List of compartments';cnt = cnt+1;
    prepStats{cnt,1} = 'Number of blocked reactions';cnt = cnt+1;
    prepStats{cnt,1} = 'Number of solvable blocked reactions';cnt = cnt+1;
    prepStats{cnt,1} = 'Size S (flux consistent)';cnt = cnt+1;
    prepStats{cnt,1} = 'Size SUX (including solvable blocked reactions)';cnt = cnt+1;
    prepStats{cnt,1} = 'Time preprocessing [min]';

    % get stats
    cnt = 1;
    prepStats{cnt,2} = modelFile;cnt = cnt+1;
    [a,b] = size(model.S);
    prepStats{cnt,2} = strcat(num2str(a),'x',num2str(b));cnt = cnt+1;
    [~,rem] = strtok(model.mets,'\[');
    rem = unique(rem);
    prepStats{cnt,2} = num2str(length(rem));cnt = cnt+1;
    Rem = rem{1};
    for j = 2:length(rem)
        Rem = strcat(Rem,',',rem{j});
    end
    prepStats{cnt,2} = Rem;cnt = cnt+1;
    clear Rem rem;
    prepStats{cnt,2} = num2str(length(BlockedRxns.allRxns));cnt = cnt+1;
    prepStats{cnt,2} = num2str(length(BlockedRxns.solvableRxns));cnt = cnt+1;
    [a,b] = size(consistModel.S);
    prepStats{cnt,2} = strcat(num2str(a),'x',num2str(b));cnt = cnt+1;
    [a,b] = size(consistMatricesSUX.S);
    prepStats{cnt,2} = strcat(num2str(a),'x',num2str(b));cnt = cnt+1;
    prepStats{cnt,2} = num2str(tpre/60);cnt = cnt+1;
    
    % Save data
    save(prepareFGFResults,'consistModel','consistMatricesSUX','BlockedRxns','prepStats','model');
    fprintf('prepareGapFill finished\n')
end

% prompt='Proceed with fastGapFill? [y]/n: ';
% str = input(prompt,'s');
% if ~isempty(str) && (str == 'n')
%     return
% end

fprintf('Running fastGapFill ...\n')

%% Define Runs
% define weights for reactions to be added - the lower the weight the
% higher the priority
% WARNING: weights should not be 1, as this impacts on the algorithm
% performance

runs = {};

% RUN 1 
run.weightsPerReactionFile = weightsPerRxnFile;
run.weights.MetabolicRxns = 0.1; % Kegg metabolic reactions
run.weights.ExchangeRxns = 0.5; % Exchange reactions
run.weights.TransportRxns = 10; % Transport reactions
run.name = 'initial';
runs = [runs; run];

% RUN 2
run.weightsPerReactionFile = weightsPerRxnFile;
run.weights.MetabolicRxns = 0.1; % Kegg metabolic reactions
run.weights.ExchangeRxns = 0.9; % Exchange reactions
run.weights.TransportRxns = 40; % Transport reactions
run.name = 'hw';
runs = [runs; run];

% RUN 3
run.weightsPerReactionFile = '';
run.weights.MetabolicRxns = 0.01; % Kegg metabolic reactions
run.weights.ExchangeRxns = 2.1; % Exchange reactions
run.weights.TransportRxns = 20; % Transport reactions
run.name = 'vhw';
runs = [runs; run];


clear run

%% fastGapFill

cnt = 1;
clear Stats;
Stats{cnt,1} = 'Run name';cnt = cnt+1;
Stats{cnt,1} = 'Number of added reactions (all)';cnt = cnt+1;
Stats{cnt,1} = 'Number of added metabolic reactions ';cnt = cnt+1;
Stats{cnt,1} = 'Number of added transport reactions ';cnt = cnt+1;
Stats{cnt,1} = 'Number of added exchange reactions ';cnt = cnt+1;
Stats{cnt,1} = 'Time fastGapFill';cnt = cnt+1;
Stats{cnt,1} = 'SFilename';cnt = cnt+1;

try
    a = load(prepareFGFResults,'consistModel','consistMatricesSUX','BlockedRxns','model');
    assert(length(fieldnames(a)) == 4);
    clear a;
    load(prepareFGFResults,'consistModel','consistMatricesSUX','BlockedRxns','model');
    fprintf('Variables loaded from .mat file\n');
    try
        b = load(prepareFGFResults,'prepStats');
        assert(~isempty(b))
        load(prepareFGFResults,'prepStats');
        clear b;
    catch
        fprintf('Warning: no stats for prepareFastGapfill\n');
    end
catch
    fprintf('Using preloaded variables for fastGapFill\n')
end

for i = 1:length(runs) 
    run_idx = i+1;
    fprintf('\nRun %i (%s)\n',i,runs{i}.name);
    weights = runs{i}.weights;
    weightsPerReactionFile = runs{i}.weightsPerReactionFile;
    resultsFile = strcat(resultsDir,'results_',runs{i}.name,'.mat');

    % If specified, import weights from weights file (tsv)
    if ~isempty(weightsPerReactionFile)
        file_handle = fopen(weightsPerReactionFile);
        try
            u = textscan(file_handle,'%s\t%s');
        catch
            fprintf('File "%s" could not be found, exiting\n',weightsPerReactionFile)
            return
        end
        weightsPerReaction.rxns = {};
        weightsPerReaction.weights = {};
        for k = 1:length(u{1})
            weightsPerReaction.rxns{k} = u{1}{k};
            weightsPerReaction.weights{k} = str2double(u{2}{k});
        end
        fclose(file_handle); 
    else
        weightsPerReaction = [];
    end
    
    cnt = 1;
    Stats{cnt,run_idx} = runs{i}.name;cnt = cnt+1;
    
    % fastGapFill
    tic; 
    [AddedRxns] = fastGapFill(consistMatricesSUX,epsilon,weights,weightsPerReaction);
    tgap=toc;
    Stats{cnt,run_idx} = num2str(length(AddedRxns.rxns));cnt = cnt+1;
    save(resultsFile);

    % Postprocessing
    [AddedRxnsExtended] = postProcessGapFillSolutions(AddedRxns,model,BlockedRxns,0);
    
    try
        Stats{cnt,run_idx} = num2str(AddedRxnsExtended.Stats.metabolicSol);cnt = cnt+1;
        Stats{cnt,run_idx} = num2str(AddedRxnsExtended.Stats.transportSol);cnt = cnt+1;
        Stats{cnt,run_idx} = num2str(AddedRxnsExtended.Stats.exchangeSol);cnt = cnt+1;
    catch
        Stats{cnt,run_idx} = num2str(0);cnt = cnt+1;
        Stats{cnt,run_idx} = num2str(0);cnt = cnt+1;
        Stats{cnt,run_idx} = num2str(0);cnt = cnt+1;
    end
    Stats{cnt,run_idx} = num2str(tgap);cnt = cnt+1;
    Stats{cnt,run_idx} = resultsFile;cnt = cnt+1;
    clear a b

    % Reaction List
    col = 1;
    RxnList={};
    try
        RxnList{1,col}=resultsFile;RxnList(2:length(AddedRxnsExtended.rxns)+1,col) = AddedRxnsExtended.rxns; col = col + 1;
        RxnList{1,col}=resultsFile;RxnList(2:length(AddedRxnsExtended.rxns)+1,col) = AddedRxnsExtended.rxnFormula; col = col + 1;
        RxnList{1,col}=resultsFile;RxnList(2:length(AddedRxnsExtended.rxns)+1,col) = AddedRxnsExtended.subSystem; col = col + 1;
    catch
        RxnList{1,col}=resultsFile; col = col + 1;
        RxnList{1,col}=resultsFile; col = col + 1;
        RxnList{1,col}=resultsFile; col = col + 1;
    end

    save(resultsFile);
end
