function [objectives,shadowPrices]=analyseObjectiveShadowPrices(modelFolder,objectiveList,varargin)
% This function determines the shadow prices indicating metabolites that
% are relevant for the flux through one or multiple objective functions
% optimized in one or more COBRA model structures. The objective functions
% entered are optimized one by one. By default, all metabolites with
% nonzero shadow prices are extracted from the computed flux solutions. The
% function was written for the Microbiome Modeling Toolbox, with the aim of
% allowing the computation of metabolic dependencies for metabolites of
% interest secreted by the personalzied models, though it can also be used
% for any other COBRA model.
%
% USAGE:
%
%   [objectives,shadowPrices]=analyseObjectiveShadowPrices(modelFolder,objectiveList,varargin)
%
% INPUTS:
%   modelFolder       Folder containing one or more COBRA model structures
%   objectiveList     Cell array containing the names of one or more
%                     objective functions of interest in vertical order
%                     Optional: second column with exchange reaction IDs
%                     for objective-specific precursors
%
% OPTIONAL INPUTS:
%   resultsFolder     char with path of directory where results are saved
%   osenseStr         String indicating whether objective function(s)
%                     should be maximized or minimized. Allowed inputs:
%                     'min','max', default:'max'.
%   SPDef             String indicating whether positive, negative, or
%                     all nonzero shadow prices should be collected.
%                     Allowed inputs: 'Positive','Negative','Nonzero',
%                     default: 'Nonzero'.
%   numWorkers        Number indicating number of workers in parallel pool
%                     (default: 0).
%
% OUTPUT:
%   objectives        Computed objectives values
%   shadowPrices      Table with shadow prices for metabolites that are
%                     relevant for each analyzed objective in each analyzed
%                     model
%
% .. Author:
%       - Almut Heinken, 07/2018
%                        01/2020: changed to models being loaded one by one
%                        to reduce memory usage for large microbiome
%                        sample sets
%                        01/2021: included setting dietary constraints
%                        inside the function

parser = inputParser();  % Define default input parameters if not specified
parser.addRequired('modelFolder', @ischar);
parser.addRequired('objectiveList', @iscell);
parser.addParameter('resultsFolder',[pwd filesep 'ShadowPrices'], @ischar);
parser.addParameter('osenseStr','max', @ischar);
parser.addParameter('SPDef','Nonzero', @ischar);
parser.addParameter('numWorkers', 0, @(x) isnumeric(x))

parser.parse(modelFolder,objectiveList, varargin{:})

modelFolder = parser.Results.modelFolder;
resultsFolder = parser.Results.resultsFolder;
objectiveList = parser.Results.objectiveList;
numWorkers = parser.Results.numWorkers;
SPDef = parser.Results.SPDef;

mkdir(resultsFolder)

% set a solver if not done already
global CBT_LP_SOLVER
solver = CBT_LP_SOLVER;
if isempty(solver)
    initCobraToolbox;
    solver = CBT_LP_SOLVER;
end
% initialize parallel pool
if numWorkers > 0
    % with parallelization
    poolobj = gcp('nocreate');
    if isempty(poolobj)
        parpool(numWorkers)
    end
end
environment = getEnvironment();

dInfo = dir(modelFolder);
modelList={dInfo.name};
modelList=modelList';
% remove everything that is not a model
modelList(find(strcmp(modelList,'.')),:)=[];
modelList(find(strcmp(modelList,'..')),:)=[];
modelList(~any(contains(modelList(:,1),{'.mat','.sbml','.xml'})),:)=[];

if size(modelList,1) ==0
    error('There are no models to load in the model folder!')
end

objectives=cell(length(objectiveList)+1,length(modelList)+2);
objectives{1,1}='Objective';
shadowPrices{1,1}='Metabolite';
shadowPrices{1,2}='Objective';
if size(objectiveList,2)>1
    objectives{1,2}='Source';
    shadowPrices{1,3}='Source';
end

% Compute the solutions for all entered models and objective functions
for j=1:length(objectiveList)
    objectives{j+1,1} = objectiveList{j,1};
    if size(objectiveList,2)>1
        objectives{j+1,2} = objectiveList{j,2};
    end
end

% first perform the computations
steps = 50;

for s=1:steps:length(modelList)
    if length(modelList)-s>=steps-1
        endPnt=steps-1;
    else
        endPnt=length(modelList)-s;
    end
    modelsTmp = {};

    parfor i=s:s+endPnt
        restoreEnvironment(environment);
        changeCobraSolver(solver, 'LP', 0, -1);

        % check if stored solution already exists
        if ~isfile([resultsFolder filesep strrep(modelList{i,1},'.mat','') '_solution.mat'])

        % load model
        % workaround for models that give an error in readCbModel
        %         try
        %             modelLoaded=readCbModel([modelFolder filesep modelList{i,1}]);
        %         catch
        %         warning('Model could not be read through readCbModel. Consider running verifyModel.')
        modelStr = load([modelFolder filesep modelList{i,1}]);
        modelF = fieldnames(modelStr);
        model = modelStr.(modelF{1});
        modelsTmp{i} = model;

        % implement constraints on the model
        for k = 1:length(model.rxns)
            if strfind(model.rxns{k}, 'biomass')
                model.lb(k) = 0;
            end
        end

        % compute the flux balance analysis solution
        FBAsolution = computeSolForObj(model, objectiveList);
        % save solutions one by one-complete file would be enormous
        parsave([resultsFolder filesep strrep(modelList{i,1},'.mat','') '_solution.mat'],FBAsolution)
        end
    end
end

% now save the results

for s=1:steps:length(modelList)
    if length(modelList)-s>=steps-1
        endPnt=steps-1;
        modelsTmp = cell(steps,1);
        solutionsTmp = cell(steps,1);
    else
        endPnt=length(modelList)-s;
        modelsTmp = cell(length(modelList),1);
        solutionsTmp = cell(length(modelList),1);
    end

    parfor i=s:s+endPnt
        % load model
        % workaround for models that give an error in readCbModel
        %         try
        %             modelLoaded=readCbModel([modelFolder filesep modelList{i,1}]);
        %         catch
        %         warning('Model could not be read through readCbModel. Consider running verifyModel.')
        modelStr = load([modelFolder filesep modelList{i,1}]);
        modelF = fieldnames(modelStr);
        model = modelStr.(modelF{1});
        modelsTmp{i} = model;

        % load solution
        solutionStr = load([resultsFolder filesep strrep(modelList{i,1},'.mat','') '_solution.mat']);
        solutionSF = fieldnames(solutionStr);
        FBAsolution = solutionStr.(solutionSF{1});
        solutionsTmp{i} = FBAsolution;
    end

    for i=s:s+endPnt
        objectives{1,2+i}=strrep(modelList{i,1},'.mat','');
        shadowPrices{1,3+i}=strrep(modelList{i,1},'.mat','');
        model = modelsTmp{i};

        % Extract all shadow prices and save them in a table
        objectives{1,2+i} = strrep(modelList{i,1},'.mat','');
        shadowPrices{1,3+i} = strrep(modelList{i,1},'.mat','');
        FBAsolution = solutionsTmp{i};

        for j=1:size(objectiveList,1)
            % get the computed solutions
            solution = FBAsolution{j,1};

            % verify that a feasible solution was obtained
            if ~isempty(solution)
                % 3 = "Optimal solution is available, but with infeasibilities after unscaling"
                if solution.stat==1 || solution.stat==3
                    objectives{j+1,2+i} = solution.obj;

                    [extractedShadowPrices]=extractShadowPrices(model,solution,SPDef);
                    for k=1:size(extractedShadowPrices,1)
                        % check if the metabolite relevant for this objective
                        % function is already in the table
                        % only certain SPs
                        if contains(extractedShadowPrices{k,1},'biomass') || contains(extractedShadowPrices{k,1},'[d]') || contains(extractedShadowPrices{k,1},'[fe]')
                            findMet=find(strcmp(shadowPrices(:,1),extractedShadowPrices{k,1}));
                            findObj=find(strcmp(shadowPrices(:,2),objectiveList{j,1}));
                            if ~isempty(intersect(findMet,findObj))
                                % Add the shadow price for this model
                                shadowPrices{intersect(findMet,findObj),3+i}=extractedShadowPrices{k,2};
                            else
                                % Add a new row for this metabolite and objective function with the shadow price for this model
                                newRow=size(shadowPrices,1)+1;
                                shadowPrices{newRow,1}=extractedShadowPrices{k,1};
                                shadowPrices{newRow,2}=objectiveList{j,1};
                                if size(objectiveList,2)>1
                                    shadowPrices{newRow,3}=objectiveList{j,2};
                                end
                                shadowPrices(newRow,4:size(modelList,1)+3)={'0'};
                                shadowPrices{newRow,3+i}=extractedShadowPrices{k,2};
                            end
                        end
                    end
                else
                    objectives{j+1,2+i} = 0;
                end
            else
                objectives{j+1,2+i} = 0;
            end
        end
    end
end

if size(objectiveList,2)<2
    objectives(:,2)=[];
    shadowPrices(:,3)=[];
end

writetable(cell2table(objectives),[resultsFolder filesep 'Objectives'],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
writetable(cell2table(shadowPrices),[resultsFolder filesep 'ShadowPrices'],'FileType','text','WriteVariableNames',false,'Delimiter','tab');

end

function FBAsolution = computeSolForObj(model, objectiveList)
% Compute the solutions for all objectives

FBAsolution = cell(size(objectiveList,1),1);
for j = 1:size(objectiveList, 1)
    modelTemp=model;
    % optimize for the objective if it is present in the model
    if ~isempty(find(ismember(modelTemp.rxns,objectiveList{j,1})))
        modelTemp = changeObjective(modelTemp,objectiveList{j,1});
        if size(objectiveList,2) > 1
            % add corresponding metabolite
            modelTemp=changeRxnBounds(modelTemp,objectiveList{j,2},-1000,'l');
        end
        FBA = solveCobraLP(buildOptProblemFromModel(modelTemp));
        FBAsolution{j,1}=FBA;
    end
end
end

function [extractedShadowPrices] = extractShadowPrices(model,FBAsolution,SPDef)
% Finds all shadow prices in a solution computed for a COBRA model
% structure that indicate the metabolite is relevant for the flux through the objective function.

extractedShadowPrices={};
% Find all shadow prices (negative or positive depending on variable
% SPDef)
cnt=1;
tol = 1e-8;

for i=1:length(model.mets)
    % Do not include slack variables
    if ~strncmp('slack_',model.mets{i},6)
        if strcmp(SPDef,'Negative')
            if FBAsolution.dual(i)  <0 && abs(FBAsolution.dual(i)) > tol
                extractedShadowPrices{cnt,1}=model.mets{i};
                extractedShadowPrices{cnt,2}=FBAsolution.dual(i);
                cnt=cnt+1;
            end
        elseif strcmp(SPDef,'Positive')
            if FBAsolution.dual(i)  >0 && abs(FBAsolution.dual(i)) > tol
                extractedShadowPrices{cnt,1}=model.mets{i};
                extractedShadowPrices{cnt,2}=FBAsolution.dual(i);
                cnt=cnt+1;
            end
        elseif strcmp(SPDef,'Nonzero')
            if FBAsolution.dual(i)  ~=0 && abs(FBAsolution.dual(i)) > tol
                extractedShadowPrices{cnt,1}=model.mets{i};
                extractedShadowPrices{cnt,2}=FBAsolution.dual(i);
                cnt=cnt+1;
            end
        end
    end
end
end
