function [minFluxes,maxFluxes,fluxSpans] = predictMicrobeContributions(modPath, varargin)
% Predicts the minimal and maximal fluxes through internal exchange
% reactions in microbes in a list of microbiome community models for a list
% of metabolites. This allows for the prediction of the individual
% contribution of each microbe to total metabolite uptake and secretion by
% the community.
%
% [minFluxes,maxFluxes,fluxSpans] = predictMicrobeContributions(modPath, varargin)
%
% INPUTS:
%    modPath            char with path of directory where models are stored
%
% OPTIONAL INPUTS:
%    metList            List of VMH IDs for metabolites to analyze
%                       (default: all exchanged metabolites)
%    resultsFolder      Path where results will be saved
%    numWorkers         integer indicating the number of cores to use
%                       for parallelization
%
% OUTPUTS:
%    minFluxes:         Minimal fluxes through analyzed exchange reactions,
%                       corresponding to secretion fluxes for each microbe
%    maxFluxes:         Maximal fluxes through analyzed exchange reactions,
%                       corresponding to uptake fluxes for each microbe
%    fluxSpans:         Range between min and max fluxes for analyzed
%                       exchange reactions
%
% .. Author: Almut Heinken, 12/20
%
%
% Define default input parameters if not specified
parser = inputParser();
parser.addRequired('modPath', @ischar);
parser.addParameter('resultsFolder', [pwd filesep 'Contributions'], @ischar);
parser.addParameter('metList', {}, @iscell);
parser.addParameter('numWorkers', 4, @isnumeric);

parser.parse(modPath, varargin{:});

modPath = parser.Results.modPath;
resultsFolder = parser.Results.resultsFolder;
metList = parser.Results.metList;
numWorkers = parser.Results.numWorkers;

tol=0.0000001;

mkdir(resultsFolder)

if ~isempty(metList)
    for i=1:length(metList)
        metList{i}=['IEX_' metList{i} '[u]tr'];
    end
end

% initialize parallel pool
if numWorkers > 0
    % with parallelization
    poolobj = gcp('nocreate');
    if isempty(poolobj)
        parpool(numWorkers)
    end
end

global CBT_LP_SOLVER
if isempty(CBT_LP_SOLVER)
    initCobraToolbox
end
solver = CBT_LP_SOLVER;

cpxControl.PARALLELMODE = 1;
cpxControl.THREADS = 1;
cpxControl.AUXROOTTHREADS = 2;
environment = getEnvironment();

% Get all models from the input folder
dInfo = dir(modPath);
modelList={dInfo.name};
modelList=modelList';
% remove everything that is not a model
modelList(find(strcmp(modelList,'.')),:)=[];
modelList(find(strcmp(modelList,'..')),:)=[];
modelList(~any(contains(modelList(:,1),{'.mat','.sbml','.xml'})),:)=[];

if size(modelList,1) ==0
    error('There are no models to load in the model folder!')
end

% start from already computed results if function crashed
if isfile('minFluxes.mat')
    load('minFluxes.mat');
    load('maxFluxes.mat');
    startPnt=size(minFluxes,2)-1;
else
    minFluxes={};
    maxFluxes={};
    startPnt=1;
end

% define the intervals in which the testing and regular saving will be
% performed
if length(modelList)>200
    steps=100;
else
    steps=25;
end

for i = startPnt:steps:length(modelList)
    if length(modelList)>steps-1 && (length(modelList)-1)>=steps-1
        endPnt=steps-1;
    else
        endPnt=length(modelList)-i;
    end
    parfor j=i:i+endPnt
        if j <=length(modelList)
            restoreEnvironment(environment);
            changeCobraSolver(solver, 'LP', 0, -1);
            if strcmp(solver,'ibm_cplex')
                % prevent creation of log files
                changeCobraSolverParams('LP', 'logFile', 0);
            end
            
            % workaround for models that give an error in readCbModel
            try
                model=readCbModel([modPath filesep modelList{j,1}]);
            catch
                warning('Model could not be read through readCbModel. Consider running verifyModel.')
                modelStr=load([modPath filesep modelList{j,1}]);
                modelF=fieldnames(modelStr);
                model=modelStr.(modelF{1});
            end
            
            % get reactions for metabolites to analyze
            if isempty(metList)
                rxnsInModel=model.rxns(find(contains(model.rxns,'IEX_')));
            else
                rxnsInModel=model.rxns(find(contains(model.rxns,metList)));
            end
            
            % perform flux variability analysis
            currentDir=pwd;
            try
                [minFlux,maxFlux,optsol,ret] = fastFVA(model,99.99,'max',{},rxnsInModel,'A',cpxControl);
            catch
                warning('fastFVA could not run, so fluxVariability is instead used. Consider installing fastFVA for shorter computation times.');
                cd(currentDir)
                solution=solveCobraLP(buildOptProblemFromModel(model));
                if solution.stat==0
                    warning('Model infeasible. Could not perform FVA.')
                    ret=NaN;
                else
                    try
                        [minFlux,maxFlux] = fluxVariability(model,99.999,'max',rxnsInModel);
                        ret=0;
                    catch
                        warning('No feasible solution in fluxVariability was found, using FBA instead.');
                        cd(currentDir)
                        minFlux=zeros(length(rxnsInModel),1);
                        maxFlux=zeros(length(rxnsInModel),1);
                        
                        for k=1:length(rxnsInModel)
                            modelFVA = changeObjective(model,rxnsInModel{k});
                            solution = optimizeCbModel(modelFVA,'min');
                            minFlux(k,1) = solution.f;
                            solution = optimizeCbModel(modelFVA,'max');
                            maxFlux(k,1) = solution.f;
                        end
                        ret=0;
                    end
                end
            end
            
            minFluxTmp{j}=minFlux;
            maxFluxTmp{j}=maxFlux;
            sols(j)=ret;
            rxns{j}=rxnsInModel;
        end
    end
    for j=i:i+endPnt
        if j <=length(modelList)
            if isempty(minFluxes)
                newCol=2;
            else
                newCol=size(minFluxes,2)+1;
            end
            minFluxes{1,newCol}=strrep(modelList{j},'.mat','');
            minFluxes(2:end,newCol)={'0'};
            maxFluxes{1,newCol}=strrep(modelList{j},'.mat','');
            maxFluxes(2:end,newCol)={'0'};
            for k=1:length(rxns{j})
                rxnInd=find(strcmp(minFluxes(:,1),rxns{j}{k}));
                if ~isempty(rxnInd)
                    minFluxes{rxnInd,1}=rxns{j}{k};
                    maxFluxes{rxnInd,1}=rxns{j}{k};
                    % if there is a feasible solution
                    if sols(j)==0
                        minFluxes{rxnInd,newCol}=num2str(minFluxTmp{j}(k));
                        maxFluxes{rxnInd,newCol}=num2str(maxFluxTmp{j}(k));
                    end
                else
                    add1Row=size(minFluxes,1)+1;
                    minFluxes(add1Row,2:newCol)={'0'};
                    minFluxes{add1Row,1}=rxns{j}{k};
                    maxFluxes(add1Row,2:newCol)={'0'};
                    maxFluxes{add1Row,1}=rxns{j}{k};
                    % if there is a feasible solution
                    if sols(j)==0
                        minFluxes{add1Row,newCol}=num2str(minFluxTmp{j}(k));
                        maxFluxes{add1Row,newCol}=num2str(maxFluxTmp{j}(k));
                    end
                end
            end
        end
    end
    save('minFluxes','minFluxes');
    save('maxFluxes','maxFluxes');
end

fluxSpans = minFluxes;
for i=2:size(minFluxes,1)
    for j=2:size(minFluxes,2)
        if str2double(maxFluxes{i,j}) > 0.0000000001 && str2double(minFluxes{i,j}) > 0.0000000001
            fluxSpans{i,j}=str2double(maxFluxes{i,j})-str2double(minFluxes{i,j});
        elseif str2double(maxFluxes{i,j}) > 0.0000000001 && str2double(minFluxes{i,j}) <-0.0000000001
            fluxSpans{i,j}=str2double(maxFluxes{i,j}) + abs(str2double(minFluxes{i,j}));
        elseif str2double(maxFluxes{i,j}) < -0.0000000001 && str2double(minFluxes{i,j}) <-0.0000000001
            fluxSpans{i,j}=abs(str2double(minFluxes{i,j})) - abs(str2double(maxFluxes{i,j}));
        elseif str2double(maxFluxes{i,j}) > 0.0000000001 && abs(str2double(minFluxes{i,j})) <0.0000000001
            fluxSpans{i,j}=str2double(maxFluxes{i,j});
        elseif str2double(minFluxes{i,j}) < -0.0000000001 && abs(str2double(maxFluxes{i,j})) <0.0000000001
            fluxSpans{i,j}=abs(str2double(minFluxes{i,j}));
        elseif abs(str2double(maxFluxes{i,j})) < 0.0000000001 && abs(str2double(minFluxes{i,j})) <0.0000000001
            fluxSpans{i,j}=0;
        end
    end
end

% remove empty rows and adapt IDs
minFluxes(2:end,1)=strrep(minFluxes(2:end,1),'_IEX','');
minFluxes(2:end,1)=strrep(minFluxes(2:end,1),'[u]tr','');
minFluxes(1,2:end)=strrep(minFluxes(1,2:end),'microbiota_model_samp_','');
minFluxes(1,2:end)=strrep(minFluxes(1,2:end),'microbiota_model_diet_','');

cnt=1;
delArray=[];
for j=2:size(minFluxes,1)
    if abs(sum(str2double(minFluxes(j,2:end)))) < tol
        delArray(cnt,1)=j;
        cnt=cnt+1;
    end
end
minFluxes(delArray,:)=[];

maxFluxes(2:end,1)=strrep(maxFluxes(2:end,1),'_IEX','');
maxFluxes(2:end,1)=strrep(maxFluxes(2:end,1),'[u]tr','');
maxFluxes(1,2:end)=strrep(maxFluxes(1,2:end),'microbiota_model_samp_','');
maxFluxes(1,2:end)=strrep(maxFluxes(1,2:end),'microbiota_model_diet_','');

cnt=1;
delArray=[];
for j=2:size(maxFluxes,1)
    if abs(sum(str2double(maxFluxes(j,2:end)))) < tol
        delArray(cnt,1)=j;
        cnt=cnt+1;
    end
end
maxFluxes(delArray,:)=[];

minFluxes(:,1)=regexprep(minFluxes(:,1),'pan','','once');
maxFluxes(:,1)=regexprep(maxFluxes(:,1),'pan','','once');
fluxSpans(:,1)=regexprep(fluxSpans(:,1),'pan','','once');

fluxSpans(2:end,1)=strrep(fluxSpans(2:end,1),'_IEX','');
fluxSpans(2:end,1)=strrep(fluxSpans(2:end,1),'[u]tr','');
fluxSpans(1,2:end)=strrep(fluxSpans(1,2:end),'microbiota_model_samp_','');
fluxSpans(1,2:end)=strrep(fluxSpans(1,2:end),'microbiota_model_diet_','');

cnt=1;
delArray=[];
for j=2:size(fluxSpans,1)
    if abs(sum(str2double(fluxSpans(j,2:end)))) < tol
        delArray(cnt,1)=j;
        cnt=cnt+1;
    end
end
fluxSpans(delArray,:)=[];

% minFluxes = secretion
cell2csv([resultsFolder filesep 'Microbe_Secretion.csv'],minFluxes)

% maxFluxes = uptake
cell2csv([resultsFolder filesep 'Microbe_Uptake.csv'],maxFluxes)

% fluxSpans = span between minimal and maximal flux
cell2csv([resultsFolder filesep 'Microbe_Flux_Spans.csv'],fluxSpans)

delete('minFluxes.mat')
delete('maxFluxes.mat')

end

