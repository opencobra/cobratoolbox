function [objectives,shadowPrices]=analyseObjectiveShadowPrices(modelFolder,objectiveList,varargin)
% This function determines the shadow prices indicating metabolites that
% are relevant for the flux through one or multiple objective functions
% optimized in one or more COBRA model structures. The objective functions
% entered are optimized one by one. By default, all metabolites with
% nonzero shadow prices are extracted from the computed flux solutions. The
% function was written for the Microbiome Modeling Toolbox and should be
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
%   modelFolder       Folder containing one or more COBRA model structures  
%   objectiveList     Cell array containing the names of one or more
%                     objective functions of interest in vertical order
%                     Optional: second column with exchange reaction IDs
%                     for objective-specific precursors
%
% OPTIONAL INPUTS:
%   resultsFolder     char with path of directory where results are saved
%                     (default: current folder)
%   osenseStr         String indicating whether objective function(s)
%                     should be maximized or minimized. Allowed inputs:
%                     'min','max', default:'max'.
%   SPDef             String indicating whether positive, negative, or
%                     all nonzero shadow prices should be collected.
%                     Allowed inputs: 'Positive','Negative','Nonzero',
%                     default: 'Nonzero'.
%   numWorkers        Number indicating number of workers in parallel pool
%                     (default: 0).
%   dietFilePath      char with path to input file with dietary information                   
%   includeHumanMets  boolean indicating if human-derived metabolites
%                     present in the gut should be provided to the models 
%                     (default: true)
%   lowerBMBound      lower bound on community biomass (default=0.4)
%   adaptMedium       boolean indicating if the medium should be
%                     adapted through the adaptVMHDietToAGORA
%                     function or used as is (default=true)  
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
parser.addParameter('resultsFolder',pwd, @ischar);
parser.addParameter('osenseStr','max', @ischar);
parser.addParameter('SPDef','Nonzero', @ischar);
parser.addParameter('numWorkers', 0, @(x) isnumeric(x))
parser.addParameter('dietFilePath', 'AverageEuropeanDiet', @ischar);
parser.addParameter('includeHumanMets', true, @islogical);
parser.addParameter('lowerBMBound', 0.4, @isnumeric);
parser.addParameter('adaptMedium', true, @islogical);

parser.parse(modelFolder,objectiveList, varargin{:})

modelFolder = parser.Results.modelFolder;
resultsFolder = parser.Results.resultsFolder;
objectiveList = parser.Results.objectiveList;
numWorkers = parser.Results.numWorkers;
SPDef = parser.Results.SPDef;
dietFilePath = parser.Results.dietFilePath;
includeHumanMets = parser.Results.includeHumanMets;
lowerBMBound = parser.Results.lowerBMBound;
adaptMedium = parser.Results.adaptMedium;

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

objectives{1,1}='Objective';
shadowPrices{1,1}='Metabolite';
shadowPrices{1,2}='Objective';
if size(objectiveList,2)>1
    objectives{1,2}='Source';
    shadowPrices{1,3}='Source';
end

dInfo = dir(modelFolder);
modelList={dInfo.name};
modelList=modelList';
modelList(find(strcmp(modelList(:,1),'.')),:)=[];
modelList(find(strcmp(modelList(:,1),'..')),:)=[];
modelList(find(~strncmp(modelList(:,1),'microbiota',length('microbiota'))),:)=[];


% Compute the solutions for all entered models and objective functions
solutions={};
for j=1:length(objectiveList)
    objectives{j+1,1} = objectiveList{j,1};
    if size(objectiveList,2)>1
        objectives{j+1,2} = objectiveList{j,2};
    end
end

for i=1:size(modelList,1)
    i
    objectives{1,2+i}=strrep(modelList{i,1},'.mat','');
    shadowPrices{1,3+i}=strrep(modelList{i,1},'.mat','');
    model=readCbModel([modelFolder filesep modelList{i,1}]);
    
    % implement constraints on the model
    for k = 1:length(model.rxns)
        if strfind(model.rxns{k}, 'biomass')
            model.lb(k) = 0;
        end
    end
    
    % adapt constraints
    BiomassNumber=find(strcmp(model.rxns,'communityBiomass'));
    Components = model.mets(find(model.S(:, BiomassNumber)));
    Components = strrep(Components,'_biomass[c]','');
    for k=1:length(Components)
        % remove constraints on demand reactions to prevent infeasibilities
        findDm= model.rxns(find(strncmp(model.rxns,[Components{k} '_DM_'],length([Components{k} '_DM_']))));
        model = changeRxnBounds(model, findDm, 0, 'l');
        % constrain flux through sink reactions
        findSink= model.rxns(find(strncmp(model.rxns,[Components{k} '_sink_'],length([Components{k} '_sink_']))));
        model = changeRxnBounds(model, findSink, -1, 'l');
    end
    
    model = changeObjective(model, 'EX_microbeBiomass[fe]');
    AllRxn = model.rxns;
    RxnInd = find(cellfun(@(x) ~isempty(strfind(x, '[d]')), AllRxn));
    EXrxn = model.rxns(RxnInd);
    EXrxn = regexprep(EXrxn, 'EX_', 'Diet_EX_');
    model.rxns(RxnInd) = EXrxn;
    model = changeRxnBounds(model, 'communityBiomass', lowerBMBound, 'l');
    model = changeRxnBounds(model, 'communityBiomass', 1, 'u');
    model=changeRxnBounds(model,model.rxns(strmatch('UFEt_',model.rxns)),1000000,'u');
    model=changeRxnBounds(model,model.rxns(strmatch('DUt_',model.rxns)),1000000,'u');
    model=changeRxnBounds(model,model.rxns(strmatch('EX_',model.rxns)),1000000,'u');
    
    if adaptMedium
        diet = adaptVMHDietToAGORA(dietFilePath,'Microbiota');
    else
        diet = readtable(dietFilePath, 'Delimiter', '\t');
        diet = table2cell(diet);
        for k = 1:length(diet)
            diet{k, 2} = num2str(-(diet{k, 2}));
        end
    end
    model = useDiet(model, diet);
    
    if includeHumanMets
        % add the human metabolites
        HumanMets={'gchola','-10';'tdchola','-10';'tchola','-10';'dgchol','-10';'34dhphe','-10';'5htrp','-10';'Lkynr','-10';'f1a','-1';'gncore1','-1';'gncore2','-1';'dsT_antigen','-1';'sTn_antigen','-1';'core8','-1';'core7','-1';'core5','-1';'core4','-1';'ha','-1';'cspg_a','-1';'cspg_b','-1';'cspg_c','-1';'cspg_d','-1';'cspg_e','-1';'hspg','-1'};
        for l=1:length(HumanMets)
            model=changeRxnBounds(model,strcat('Diet_EX_',HumanMets{l},'[d]'),str2num(HumanMets{l,2}),'l');
        end
    end
    
    % compute the flux balance analysis solution
    [model, FBAsolution] = computeSolForObj(model, objectiveList, solver);
%     % store computed objective values
%     for j=1:length(objectiveList)
%         if ~isempty(FBAsolution{j,1})
%             objectives{j+1,3+i} = FBAsolution{j,1}.obj;
%         else
%             objectives{j+1,3+i} = 0;
%         end
%     end
    % save one model by one-file would be enourmous otherwise
    save([resultsFolder filesep strrep(modelList{i,1},'.mat','') '_solution'],'FBAsolution');
    
    % Extract all shadow prices and save them in a table
    objectives{1,2+i} = strrep(modelList{i,1},'.mat','');
    shadowPrices{1,3+i} = strrep(modelList{i,1},'.mat','');
    solutions(:,i)=FBAsolution;

    for j=1:size(objectiveList,1)
        % get the computed solutions
        solution = FBAsolution{j,1};
        objectives{j+1,2+i} = solution.obj;
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
                        shadowPrices{intersect(findMet,findObj),3+i}=extractedShadowPrices{k,2};
                    else
                        % Add a new row for this metabolite and objective function with the shadow price for this model
                        newRow=size(shadowPrices,1)+1;
                        shadowPrices{newRow,1}=extractedShadowPrices{k,1};
                        shadowPrices{newRow,2}=objectiveList{j,1};
                        if size(objectiveList,2)>1
                            shadowPrices{newRow,3}=objectiveList{j,2};
                        end
                        shadowPrices(newRow,4:length(modelList)+2)={'0'};
                        shadowPrices{newRow,3+i}=extractedShadowPrices{k,2};
                    end
                end
            end
        end
    end
    % Regularly save results
    if floor(i/10) == i/10
        save([resultsFolder filesep 'objectives'],'objectives');
    end
    if floor(i/50) == i/50
        save([resultsFolder filesep 'shadowPrices'],'shadowPrices');
    end
end

if size(objectiveList,2)<2
    objectives(:,2)=[];
    shadowPrices(:,3)=[];
end

writetable(cell2table(objectives),[resultsFolder filesep 'Objectives'],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
writetable(cell2table(shadowPrices),[resultsFolder filesep 'ShadowPrices'],'FileType','text','WriteVariableNames',false,'Delimiter','tab');

end

function [model, FBAsolution] = computeSolForObj(model, objectiveList,solver)
% Compute the solutions for all objectives
environment = getEnvironment();

parfor j = 1:size(objectiveList, 1)
    restoreEnvironment(environment);
    changeCobraSolver(solver, 'LP', 0, -1);
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
