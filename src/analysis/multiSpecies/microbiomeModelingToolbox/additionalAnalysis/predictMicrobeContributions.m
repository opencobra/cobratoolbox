function [minFluxes,maxFluxes,fluxSpans] = predictMicrobeContributions(modPath, varargin)
% Predicts the minimal and maximal fluxes in a list of models for a list of
% reactions.
%
% [minFluxes,maxFluxes,fluxSpans] = predictMicrobeContributions(modPath, varargin)
%
% INPUTS:
%    modPath              char with path of directory where models are stored
%
% OPTIONAL INPUTS:
%    resPath              char with path of directory where results are saved
%    dietFilePath         char with path to input file with dietary information                   
%    metList              List of VMH IDs for metabolites to analyze 
%                         (default: all exchanged metabolites)              
%    includeHumanMets     boolean indicating if human-derived metabolites
%                         present in the gut should be provided to the models 
%                         (default: true)
%    numWorkers           integer indicating the number of cores to use 
%                         for parallelization
%    lowerBMBound         lower bound on community biomass (default=0.4)
%    adaptMedium          boolean indicating if the medium should be
%                         adapted through the adaptVMHDietToAGORA
%                         function or used as is (default=true)                  
%
% OUTPUTS:
%    minFluxes:           Minimal fluxes through analyzed exchange reactions
%    maxFluxes:           Maximal fluxes through analyzed exchange reactions
%    fluxSpans:           Range between min and max fluxes for analyzed 
%                         exchange reactions
%
% .. Author: Almut Heinken, 12/20
%
%
% Define default input parameters if not specified
parser = inputParser();
parser.addRequired('modPath', @ischar);
parser.addParameter('resPath', pwd, @ischar);
parser.addParameter('dietFilePath', 'AverageEuropeanDiet', @ischar);
parser.addParameter('metList', {}, @iscell);
parser.addParameter('numWorkers', 4, @isnumeric);
parser.addParameter('includeHumanMets', true, @islogical);
parser.addParameter('lowerBMBound', 0.4, @isnumeric);
parser.addParameter('adaptMedium', true, @islogical);

parser.parse(modPath, varargin{:});

modPath = parser.Results.modPath;
resPath = parser.Results.resPath;
dietFilePath = parser.Results.dietFilePath;
metList = parser.Results.metList;
includeHumanMets = parser.Results.includeHumanMets;
numWorkers = parser.Results.numWorkers;
lowerBMBound = parser.Results.lowerBMBound;
adaptMedium = parser.Results.adaptMedium;

if ~exist('lowerBMBound','var')
    lowerBMBound=0.4;
end

tol=0.0000001;

mkdir(resPath)

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
modelList(find(strcmp(modelList(:,1),'.')),:)=[];
modelList(find(strcmp(modelList(:,1),'..')),:)=[];
modelList(find(~strncmp(modelList(:,1),'microbiota',length('microbiota'))),:)=[];


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
            model=readCbModel([modPath filesep modelList{j}]);
            
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

            % get reactions for metabolites to analyze
            if isempty(metList)
                rxnsInModel=model.rxns(find(contains(model.rxns,'IEX_')));
            else
                rxnsInModel=model.rxns(find(contains(model.rxns,metList)));
            end
            
            [minFlux,maxFlux,optsol,ret] = fastFVA(model,99.99,'max',{},rxnsInModel,'A');
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
cnt=1;
delArray=[];
for j=2:size(fluxSpans,1)
    if abs(sum(str2double(fluxSpans(j,2:end)))) < tol
        delArray(cnt,1)=j;
        cnt=cnt+1;
    end
end
fluxSpans(delArray,:)=[];

writetable(cell2table(minFluxes),[resPath filesep 'Contributions_minFluxes.txt'],'FileType','text','Delimiter','tab','WriteVariableNames',false);
writetable(cell2table(maxFluxes),[resPath filesep 'Contributions_maxFluxes.txt'],'FileType','text','Delimiter','tab','WriteVariableNames',false);
writetable(cell2table(fluxSpans),[resPath filesep 'Contributions_fluxSpans.txt'],'FileType','text','Delimiter','tab','WriteVariableNames',false);

delete('minFluxes.mat')
delete('maxFluxes.mat')

end

