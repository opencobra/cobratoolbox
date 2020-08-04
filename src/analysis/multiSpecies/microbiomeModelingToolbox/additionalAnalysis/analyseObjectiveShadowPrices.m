function [objectives,shadowPrices]=analyseObjectiveShadowPrices(modelFolder,objectiveList,varargin)
% This function determines the shadow prices indicating metabolites that
% are relevant for the flux through one or multiple objective functions
% optimized in one or more COBRA model structures. The objective functions
% entered are optimized one by one. By default, all metabolites with
% nonzero shadow prices are extracted from the computed flux solutions. The
% function was written for the Microbiome Modeling Toolbox but can be used
% for any COBRA model structure(s) and objective function(s).
% When used with the Microbiome Modeling Toolbox, this function should be
% used after running mgPipe and determining metabolites of interest that
% are stratifying the modeled personalized microbiomes. The fecal exchanges
% secreting the metabolites of interest (e.g., EX_co2[fe]) should be used
% as the objective functions entered in the present function to determine
% model compounds that have value for the secretion of the metabolite of
% interest.
%
% USAGE:
%
%   [objectives,shadowPrices]=analyseObjectiveShadowPrices(modelFolder,objectiveList,varargin)
%
% INPUTS:
%   modelFolder       Folder containing one or more COBRA model
%                     structures
%   objectiveList     Cell array containing the names of one or more
%                     objective functions of interest in vertical order
%                     Optional: second column with exchange reaction IDs
%                     for objective-specific precursors
%
% OPTIONAL INPUTS:
%   modelIDs          Cell array containing IDs of the models displayed in
%                     the output table in same order as corresponding models
%                     (default IDs assigned if not entered)
%   osenseStr         String indicating whether objective function(s)
%                     should be maximized or minimized. Allowed inputs:
%                     'min','max', default:'max'.
%   SPDef             String indicating whether positive, negative, or
%                     all nonzero shadow prices should be collected.
%                     Allowed inputs: 'Positive','Negative','Nonzero',
%                     default: 'Nonzero'.
%   numWorkers        Number indicating number of workers in parallel pool
%                     (default: 0).
%   solutionFolder    Folder where the flux balance analysis solutions
%                     should be stored (default =  current folder)
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

parser = inputParser();  % Define default input parameters if not specified
parser.addRequired('modelFolder', @ischar);
parser.addRequired('objectiveList', @iscell);
parser.addParameter('osenseStr','max', @ischar);
parser.addParameter('modelIDs',@ischar);
parser.addParameter('SPDef','Nonzero', @ischar);
parser.addParameter('numWorkers', 0, @(x) isnumeric(x))
parser.addParameter('solutionFolder',pwd, @ischar);
parser.parse(modelFolder,objectiveList, varargin{:})

modelFolder = parser.Results.modelFolder;
objectiveList = parser.Results.objectiveList;
numWorkers = parser.Results.numWorkers;
modelIDs = parser.Results.modelIDs;
SPDef = parser.Results.SPDef;
solutionFolder = parser.Results.solutionFolder;

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
shadowPrices{1,1}='Metabolite';
shadowPrices{1,2}='Objective';
if size(objectives,2)>1
shadowPrices{1,3}='Source';
end

dInfo = dir(modelFolder);
modelList={dInfo.name};
modelList=modelList';
modelList=modelList(3:end);

if isempty(modelIDs)
    for i=1:size(modelList,1)
        modelIDs{i,1}=strcat('model_',num2str(i));
    end
end

% Compute the solutions for all entered models and objective functions
solutions={};
for j=1:length(objectiveList)
    objectives{1,j+1} = objectiveList{j,1};
    if size(objectives,2)>1
    objectives{2,j+1} = objectiveList{j,2};
    end
end

for i=1:size(modelList,1)
    i
    objectives{i+2,1}=modelIDs{i,1};
    shadowPrices{1,i+3}=modelIDs{i,1};
    load(strcat(modelFolder,modelList{i,1}));
    
    [model, FBAsolution] = computeSolForObj(model, objectiveList, solver);
    % store computed objective values
    for j=1:length(objectiveList)
        if ~isempty(FBAsolution{j,1})
            objectives{i+2,j+1} = FBAsolution{j,1}.obj;
        else
            objectives{i+2,j+1} = 0;
        end
    end
    % save one model by one-file would be enourmous otherwise
    save([solutionFolder filesep modelIDs{i,1} '_solution'],'FBAsolution');
    
    % Extract all shadow prices and save them in a table
    objectives{i+2,1} = strrep(modelList{i,1},'.mat','');
    shadowPrices{1,i+3} = strrep(modelList{i,1},'.mat','');
    solutions(:,i)=FBAsolution;

    for j=1:size(objectiveList,1)
        % get the computed solutions
        solution = FBAsolution{j,1};
        objectives{i+2,j+1} = solution.obj;
        % verify that a feasible solution was obtained
        if solution.stat==1
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
                        shadowPrices{intersect(findMet,findObj),i+3}=extractedShadowPrices{k,2};
                    else
                        % Add a new row for this metabolite and objective function with the shadow price for this model
                        newRow=size(shadowPrices,1)+1;
                        shadowPrices{newRow,1}=extractedShadowPrices{k,1};
                        shadowPrices{newRow,2}=objectiveList{j,1};
                        shadowPrices{newRow,3}=objectiveList{j,2};
                        shadowPrices(newRow,4:length(modelList)+2)={'0'};
                        shadowPrices{newRow,i+3}=extractedShadowPrices{k,2};
                    end
                end
            end
        end
    end
    % Regularly save results
    if floor(i/10) == i/10
        save('objectives','objectives');
    end
    if floor(i/50) == i/50
        save('shadowPrices','shadowPrices');
    end
end

if size(objectives,2)<2
    objectives(2,:)=[];
    shadowPrices(:,3)=[];
end

save('objectives','objectives');
save('shadowPrices','shadowPrices');

end

function [model, FBAsolution] = computeSolForObj(model, objectiveList,solver)
% Compute the solutions for all objectives

parfor j = 1:size(objectiveList, 1)
    changeCobraSolver(solver, 'LP');
    % prevent creation of log files
    changeCobraSolverParams('LP', 'logFile', 0);
    modelTemp=model;
    % optimize for the objective if it is present in the model
    if ~isempty(find(ismember(modelTemp.rxns,objectiveList{j,1})))
        modelTemp = changeObjective(modelTemp,objectiveList{j,1});
        if size(objectiveList,2) > 1
            % add corresponding metabolite
            modelTemp=changeRxnBounds(modelTemp,objectiveList{j,2},-1000,'l');
        end
        FBA = solveCobraLP(buildLPproblemFromModel(modelTemp));
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
