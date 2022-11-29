function [newDietModel,pointsModel,roiFlux,pointsModelSln,menuChanges,detailedAnalysis] = nutritionAlgorithm(model,rois,roisMinMax,options)
% This algorithm identifies the minimal changes to a diet necessary to get
% a desired change in one or more reactions of interest (rois). If a 
% metabolite is entered instead of a reaction, the algorithm will optimize 
% the diet with a sink or demand reaction for the corresponding metabolite 
% of interest. For a walkthrough of the algorithm, see NutritionAlgorithmWalkthrough.mlx
% To cite the algorithm, please cite Weston and Thiele, 2022 and the COBRA
% Toolbox as specified on opencobra.github.io/cobratoolbox/stable/cite.html
% USAGE:
%
%    [newDietModel,pointsModel,roiFlux,pointsModelSln,menuChanges,detailedAnalysis] = nutritionAlgorithm(model,rois,roisMinMax,options)
%
% INPUTS:
%    model:          COBRA model structure with minimal fields:
%                      * .S
%                      * .c
%                      * .ub
%                      * .lb
%                      * .mets  
%                      * .rxns  
%   rois:          cell array of all reactions of interest
%   roisMinMax:    cell array of 'min'/'max' entries for rois
%
% OPTIONAL INPUTS:
%   options:  Structure containing the optional specifications:
%   
%       * .display: display results "off" or "on"?
%
%       * .roiWeights:   a vector of weights for each reaction of interest
%       default is equal to 1
%
%       * .targetedDietRxns: A nx2 cell array that specifies any dietary
%       items to target and the corresponding weight for adding the item.
%
%       * .foodRemovalWeighting: Determines the relationship of food
%       removal weight with the weights specified by targetedDietRxns.
%       The following are valid inputs for foodRemovalWeighting.
%            - 'ones'    -> all dietary reactions from targetedDietRxns have a removal weight of one 
%            - 'inverse' -> all dietary reactions from targetedDietRxns have a removal weight of one 
%            - 'ditto'   -> weights are equal to that of targetedDietRxns
%            added weights
%            - nx2 cell array -> a customized cell array that functions like
%            targedDietRxns but instead allows costomized weights for
%            removing a food item rather than adding it. 
%            - {} empty cell array -> (default) An empty array
%            assumes all dietary reactions are available from removal with
%            a weight of one
%
%       * .slnType: Specify if solution should be 'Detailed' or 'Quick'.
%                   Default setting is 'Detailed'
%
%       * .roiBound: 'Unbounded' or 'Bounded'. Default is 'Bounded'.
%
%       * .foodAddedLimit: Specify a limit to the points produced by
%                     adding food to the diet
%
%       * .foodRemovedLimit: Specify a limit to the points produced by
%                     removing food from the diet
%
%       * .OFS: the Objective Flux Scalar initiates a limiting threshold
%       for the solution's objective function performance. A OFS of 1 means
%       that the nutrition algorithm solution will produce a result that is
%       atleast equal to, or greater than the maximum flux of the objective
%       reaction on the original diet
%
%
% OUTPUT:
%    newDietModel:   An copy of the input model with updated diet
%                    reaction bounds to reflect recomended dietary changes
%
%   pointsModel:     The resulting model that is used to identify
%                    recomended dietary changes. It includes points
%                    reactions and food added/removed reactions.
%
%   roiFlux:         Returns the flux values for each roi in the points sln
%
%   pointsModelSln:  Returns the entire points solution to pointsModel
%
%   menuChanges:     Summarizes the recommended dietary changes
%
%   detailedAnalysis: Provides solutions for each simulation conducted in
%                     the detailed analysis
%
% .. Authors: - Bronson R. Weston   2022

% Determine if any rois are metabolites
obj=model.rxns(find(model.c==1));
if isfield(model, 'osenseStr')
    objMinMax=model.osenseStr;
    if strcmp(objMinMax,'min')
        error('osensStr is set to "min". A minimized objective function is not currently supported by the nutrition algorithm. It is recomended that you flip the reaction such that products<-reactants and then set osensStr to maximize')
    end
else
    error('Model fieldname "osenseStr" required to specify if the objective function is to be minimized or maximized.')
end
if isa(rois,'char')
    rois={rois};
end
if isa(roisMinMax,'char')
    roisMinMax={roisMinMax};
end
%Create a demand or sink reaction, as appropriate, for any rois that are
%metabolites
metRois=[];
for i=1:length(rois)
    if any(strcmp(model.mets,rois{i}))
        metRois=[metRois,i];
        if strcmp(roisMinMax{i},'max')
            model=addDemandReaction(model,rois{i}); %adds demand reaction as 'DM_metabolite'
            rois{i}=['DM_',rois{i}];
            model=changeRxnBounds(model,rois{i},1000000,'u');
        else
            model=addSinkReactions(model,rois(i),-1000000,0);
            rois{i}=['sink_',rois{i}];
        end
    end
end

%If any reactions are targeting the exit reactions accumulation of a specific element
%then create relative changes to the model
for i=1:length(rois)
    if contains(rois{i},'Exit(')
       
    end
end


%initialize optional variables
roiWeights=ones(1,length(rois));
targetedDietRxns={};
slnType='Detailed';
roiBound='Bounded';
foodAddedLimit=1000000;
foodRemovedLimit=1000000;
foodRemovalWeighting={};
display='on';
OFS=1;
if exist('options','var') && ~isempty(options)
    fn = fieldnames(options);
    for k=1:numel(fn)
        if strcmp(fn{k},'roiWeights')
            roiWeights=options.roiWeights;
            if length(roiWeights)~=length(rois)
                error('The length of the roiWeights vector must be equivalent to the length of rois.')
            end
            if any(roiWeights<0)
                error('All roiWeight elements must be greater than zero.')
            end
        elseif strcmp(fn{k},'OFS')
            if OFS>1 || OFS<0
                OFS=1;
                warning('Invalid OFS specified. OFS set to 1.')
            else
                OFS=options.OFS;
            end
        elseif strcmp(fn{k},'foodRemovalWeighting')
            foodRemovalWeighting=options.foodRemovalWeighting;
            
            if ischar(foodRemovalWeighting) && ~strcmp(foodRemovalWeighting,'ones') && ~strcmp(foodRemovalWeighting,'inverse') ... 
                    && ~strcmp(foodRemovalWeighting,'ditto') %&& ~strcmp(foodRemovalWeighting,'cost')
                error('Invalid foodRemovalWeighting input. Must be "ones", "inverse", "ditto" or a nx2 cell array specifiying specific deitary reactions (first column) and the associated weight (second column)')
            end
        elseif strcmp(fn{k},'roiBound')
            roiBound=options.roiBound;
            if ~strcmp(roiBound,'Unbounded') && ~strcmp(roiBound,'Bounded')
                error('Invalid roiBound input. Must be "Unbounded" or "Bounded"')
            end
        elseif strcmp(fn{k},'display')
            display=options.display;
            if ~strcmp(display,'on') && ~strcmp(display,'off')
                error('Invalid display input. Must be "on" or "off"')
            end
        elseif strcmp(fn{k},'foodAddedLimit')
            foodAddedLimit=options.foodAddedLimit;
        elseif strcmp(fn{k},'foodRemovedLimit')
            foodRemovedLimit=options.foodRemovedLimit;
            if ~isnumeric(foodRemovedLimit) || foodRemovedLimit<0
                error('Invalid foodRemovedLimit input')
            end
        elseif strcmp(fn{k},'slnType')
            slnType=options.slnType;
            if strcmp(slnType,'Quick')
                detailedAnalysis=[];
            end
            if ~strcmp(slnType,'Detailed') && ~strcmp(slnType,'Quick')
                error('Invalid slnType input. Must be "Detailed" or "Quick"')
            end
        elseif strcmp(fn{k},'targetedDietRxns')
            targetedDietRxns=options.targetedDietRxns;
        else
            error(['Invalid "options" field entered: ', fn{k}])
        end
    end
end

%adjust ub and lb if roiBound specifies 'Unbound'
if strcmp(roiBound, 'Unbounded')
    for i=1:length(rois)
        f=find(strcmp(model.rxns,rois{i}));
        if strcmp(roisMinMax{i},'max')
            if model.ub(f)~=0
                model.ub(f)=1000000;
            end
        else
            if model.lb(f)~=0
                model.lb(f)=-1000000;
            end
        end
    end
end

if strcmp(display,'on')
    disp('_____________________________________________________')
end

newDietModel=model; %Copy original instance of model for new diet pointsModel
pointsModel=model; %Copy original instance of model for points pointsModel


%Calculate newDietModel objective function and restrict obj in main pointsModel
objIndex=find(model.c==1);

roiIndexO=zeros(1,length(rois));
for i=1:length(roiIndexO)
    roiInd = find(strcmp(newDietModel.rxns,rois{i}));
    if isempty(roiInd)
        error(['The following roi is not a valid rxn in the model: ', rois{i}])
    end
    roiIndexO(i)=find(strcmp(newDietModel.rxns,rois{i}));
end

% get flux of objective function

if model.ub(objIndex)~=model.lb(objIndex)
    model_Obj = optimizeCbModel(newDietModel);
    f1=model_Obj.f;
    if ~isnan(f1)
        pointsModel=changeRxnBounds(pointsModel,obj,f1,'l'); %constrain pointsModel obj flux
    end
    try
        initRoiFlux=model_Obj.v(roiIndexO);
    catch
        initRoiFlux=NaN(1,length(rois));
    end
else
    f1=model.ub(objIndex);
    initRoiFlux=NaN(1,length(rois));
end

% If sln type is detailed, check if roi is already min or maxed out and
% if not, define min max range for roi

if strcmp(slnType,'Detailed') && ~isnan(f1)
    OroiFluxMin=[];
    OroiFluxMax=[];
    for i=1:length(rois)
        if initRoiFlux(i)==newDietModel.lb(roiIndexO)
            OroiFluxMin(i)=newDietModel.lb(roiIndexO(i));
            detailedAnalysis.(['Rxn',num2str(i)]).min.OD=model_Obj;
        else
            pointsModel = changeObjective(pointsModel,rois{i});
            pointsModel.osenseStr = 'min';
            if strcmp(rois{i},obj)
                pointsModel=changeRxnBounds(pointsModel,obj,model.lb(objIndex),'l'); %constrain pointsModel obj flux
                sln = optimizeCbModel(pointsModel);
                pointsModel=changeRxnBounds(pointsModel,obj,f1,'l'); %constrain pointsModel obj flux
            else
                sln = optimizeCbModel(pointsModel);
            end
            detailedAnalysis.(['Rxn',num2str(i)]).min.OD=sln;
            if isnan(sln.f)
                warning('model input into function does not have a viable initial solution');
                OroiFluxMin(i)=NaN;
                OroiFluxMax(i)=NaN;
                continue
            end
            OroiFluxMin(i)=sln.v(roiIndexO(i));
        end
        if initRoiFlux(i)==newDietModel.ub(roiIndexO)
            OroiFluxMax(i)=newDietModel.ub(roiIndexO(i));
            detailedAnalysis.(['Rxn',num2str(i)]).max.OD=model_Obj;
        else
            pointsModel = changeObjective(pointsModel,rois{i});
            pointsModel.osenseStr = 'max';
            if strcmp(rois{i},obj)
                sln = model_Obj;
            else
                sln = optimizeCbModel(pointsModel);
            end
            detailedAnalysis.(['Rxn',num2str(i)]).max.OD=sln;
            if isnan(sln.f)
                warning('Not a viable initial solution, recommend adding nutrients to initial diet');
                OroiFluxMax(i)=NaN;
                continue
            end
            OroiFluxMax(i)=sln.v(roiIndexO(i));
        end
    end
elseif isnan(f1)
    for i=1:length(rois)
        OroiFluxMax(i)=NaN;
        OroiFluxMin(i)=NaN;
    end
    warning('Not a viable initial solution, recommend adding nutrients to initial diet');
end
if model.ub(objIndex)~=model.lb(objIndex) && ~isnan(f1)
    pointsModel.lb(objIndex)=OFS*f1;
end

pointsModel=addMetabolite(pointsModel, 'unitOfFoodAdded[dP]');
pointsModel=addMetabolite(pointsModel, 'unitOfFoodRemoved[dP]');
pointsModel=addMetabolite(pointsModel, 'unitOfFoodChange[dP]');
pointsModel=addMetabolite(pointsModel, 'roiPoint[roiP]');
pointsModel=addMetabolite(pointsModel, 'point[P]');

%If necessary, add all diet exchange reactions to targetedDietRxns
if isempty(targetedDietRxns)
    %Add all Diet_EX reactions, and set weight to 1
    dietRxns=find(contains(pointsModel.rxns,'Diet_EX'));
    targetedDietRxns=[pointsModel.rxns(dietRxns),num2cell(ones(length(dietRxns),1))];
elseif any(strcmp(targetedDietRxns(:,1),'All')) && length(targetedDietRxns(:,1))>1
    dietRxns=find(contains(pointsModel.rxns,'Diet_EX'));
    targetedFoodItemsTemp=[pointsModel.rxns(dietRxns), ... 
        num2cell(cell2mat(targetedDietRxns(strcmp(targetedDietRxns(:,1),'All'),2))*ones(length(dietRxns),1))];
    [~,ai,bi]=intersect(targetedFoodItemsTemp(:,1),targetedDietRxns(:,1));
    targetedFoodItemsTemp(ai,2)=targetedDietRxns(bi,2);
    targetedDietRxns=targetedFoodItemsTemp;
elseif any(strcmp(targetedDietRxns(:,1),'All'))
    dietRxns=find(contains(pointsModel.rxns,'Diet_EX'));
    targetedDietRxns=[pointsModel.rxns(dietRxns),num2cell(targetedDietRxns{1,2}*ones(length(dietRxns),1))];    
end

%Set up foodRemovalWeighting
if isempty(foodRemovalWeighting)
    %Add all Diet_EX reactions, and set weight to 1
    dietRxns=find(contains(pointsModel.rxns,'Diet_EX'));
    foodRemovalWeighting=[pointsModel.rxns(dietRxns),num2cell(ones(length(dietRxns),1))];
elseif ischar(foodRemovalWeighting)
    foodRemoveTemp=targetedDietRxns;
    switch foodRemovalWeighting
        case 'ones'
            foodRemoveTemp(:,2)=num2cell(ones(length(foodRemoveTemp(:,2)),1));
        case 'ditto'
        case 'inverse'
            foodRemoveTemp(:,2)=num2cell(cell2mat(targetedDietRxns(:,2)).^-1);
%         case 'cost'
%             foodRemoveTemp(:,2)=num2cell(cell2mat(targetedDietRxns(:,2))*-1);
    end
    foodRemovalWeighting=foodRemoveTemp; clear foodRemoveTemp;
elseif any(strcmp(foodRemovalWeighting(:,1),'All')) && length(foodRemovalWeighting(:,1))>1
    dietRxns=find(contains(pointsModel.rxns,'Diet_EX'));
    targetedFoodItemsTemp=[pointsModel.rxns(dietRxns), ... 
        num2cell(cell2mat(foodRemovalWeighting(strcmp(foodRemovalWeighting(:,1),'All'),2))*ones(length(dietRxns),1))];
    [~,ai,bi]=intersect(targetedFoodItemsTemp(:,1),foodRemovalWeighting(:,1));
    targetedFoodItemsTemp(ai,2)=foodRemovalWeighting(bi,2);
    foodRemovalWeighting=targetedFoodItemsTemp;
elseif any(strcmp(foodRemovalWeighting(:,1),'All'))
    dietRxns=find(contains(pointsModel.rxns,'Diet_EX'));
    foodRemovalWeighting=[pointsModel.rxns(dietRxns),num2cell(foodRemovalWeighting{1,2}*ones(length(dietRxns),1))];    
end


%Add "Food_Added" reactions to points model

Mets= pointsModel.mets;
[~,ai,bi]=intersect(pointsModel.rxns,targetedDietRxns(:,1));
if isempty(bi)
    error('targetedDietRxns does not include any valid reactions in the model')
end
foodRxns=pointsModel.rxns(ai);
foodRxns=regexprep(foodRxns,'Diet_EX_','Food_Added_EX_');
sMatrix=pointsModel.S(:,ai);
f=find(strcmp(pointsModel.mets,'unitOfFoodAdded[dP]'));
sMatrix(f,:)=-1*cell2mat(targetedDietRxns(bi,2)).';
pointsModel = addMultipleReactions(pointsModel, foodRxns, Mets, sMatrix, 'lb', -1000000*ones(1,length(foodRxns)), 'ub', zeros(1,length(foodRxns)));
pointsModel = addMultipleReactions(pointsModel, {'Point_EX_unitOfFoodRemoved2Change[dp]','Point_EX_unitOfFoodAdded2Change[dp]','Point_EX_unitOfFoodChange[dP]_[P]','Point_EX_Point[P]'}, {'unitOfFoodRemoved[dP]','unitOfFoodAdded[dP]','unitOfFoodChange[dP]','point[P]'}, [-1 0 0 0;0 -1 0 0;1 1 -1 0;0 0 1 -1], 'lb', [-1000000,-1000000, -1000000,-1000000], 'ub', [foodRemovedLimit,foodAddedLimit,1000000,1000000]);
%Add "Food Removed" reactions to points model
[~,ai,bi]=intersect(pointsModel.rxns,foodRemovalWeighting(:,1));
bi=bi(pointsModel.lb(ai)<0); % only includes removal reactions for dietary reactions that have a non-zero influx
ai=ai(pointsModel.lb(ai)<0);
if ~isempty(ai)
    foodRxns=pointsModel.rxns(ai);
    foodRxns=regexprep(foodRxns,'Diet_EX_','Food_Removed_EX_');
    sMatrix=-1*pointsModel.S(:,ai);
    f=find(strcmp(pointsModel.mets,'unitOfFoodRemoved[dP]'));
    sMatrix(f,:)=-1*cell2mat(foodRemovalWeighting(bi,2)).';
    pointsModel = addMultipleReactions(pointsModel, foodRxns, pointsModel.mets, sMatrix, 'lb', pointsModel.lb(ai), 'ub', zeros(1,length(ai)));
end

%Get roi Indexes
for i=1:length(rois)
    roiIndexP(i)=find(strcmp(pointsModel.rxns,rois{i}));
end
roiUB=pointsModel.ub(roiIndexP);
roiLB=pointsModel.lb(roiIndexP);

%replace roi function
stoich=pointsModel.S(:,roiIndexP);
if length(roiIndexP)>1
    metInd=find(any(stoich.'~=0));
    metsRoi=pointsModel.mets(any(stoich.'~=0)).';
    metsStoich=full(stoich(any(stoich.'~=0),:));
else
    metsRoi=pointsModel.mets(find(stoich~=0)).';
    metsStoich=full(stoich(find(stoich~=0)));
end

weightVector=zeros(1,length(roiIndexP));
weightVector(contains(roisMinMax,'max'))=-1;
weightVector(contains(roisMinMax,'min'))=1;
metsStoich=[metsStoich;weightVector.*roiWeights;zeros(1,length(roiIndexP))];

for i=1:length(rois)
    evalc('[pointsModel,~,~]= removeRxns(pointsModel, rois{i})');
end

pointsModel = addMultipleReactions(pointsModel, [rois,'Point_EX_roiPoints[roiP]_[P]'], [metsRoi,'roiPoint[roiP]','point[P]'], [metsStoich,[zeros(length(metsStoich(:,1))-2,1);-1;1]], 'lb', [roiLB.',-1000000], 'ub', [roiUB.',1000000]);



%Find solution
pointsModel = changeObjective(pointsModel,'Point_EX_Point[P]');
pointsModel.osenseStr = 'min';
pointsModelSln = optimizeCbModel(pointsModel);

if strcmp(display,'on')
    disp(['Solution points =',num2str(pointsModelSln.f)])
end

if strcmp(display, 'on')
    disp([num2str(pointsModelSln.v(find(strcmp(pointsModel.rxns,'Point_EX_unitOfFoodChange[dP]_[P]')))),' come from diet']);
    disp([num2str(pointsModelSln.v(find(strcmp(pointsModel.rxns,'Point_EX_roiPoints[roiP]_[P]')))),' come from rois']);
end
foodAddedIndexes=find(contains(pointsModel.rxns,'Food_Added_EX_'));
foodRemovedIndexes=find(contains(pointsModel.rxns,'Food_Removed_EX_'));
slnIndexes1=foodAddedIndexes(pointsModelSln.v(foodAddedIndexes)<0);
slnIndexes2=foodRemovedIndexes(pointsModelSln.v(foodRemovedIndexes)<0);

menuChanges=table([pointsModel.rxns(slnIndexes1);pointsModel.rxns(slnIndexes2)],pointsModelSln.v([slnIndexes1;slnIndexes2]),'VariableNames',{'Food Rxn', 'Flux'});
if strcmp(display,'on')
    menuChanges
end

%Add and remove relevant food items from diet in newDietModel
foodItemsAdd= regexprep(pointsModel.rxns(slnIndexes1),'Food_Added_EX_','Diet_EX_');
foodItemsRemove= regexprep(pointsModel.rxns(slnIndexes2),'Food_Removed_EX_','Diet_EX_');
modelOindexAdd=zeros(1,length(foodItemsAdd));
sl2IndexAdd=zeros(1,length(foodItemsAdd));
modelOindexRemove=zeros(1,length(foodItemsRemove));
sl2IndexRemove=zeros(1,length(foodItemsRemove));
for i=1:length(foodItemsAdd)
    modelOindexAdd(i)=find(strcmp(newDietModel.rxns,foodItemsAdd(i)));
    sl2IndexAdd(i)=find(strcmp(pointsModel.rxns,foodItemsAdd(i)));
end
for i=1:length(foodItemsRemove)
    modelOindexRemove(i)=find(strcmp(newDietModel.rxns,foodItemsRemove(i)));
    sl2IndexRemove(i)=find(strcmp(pointsModel.rxns,foodItemsRemove(i)));
end
% newDietModel.lb(modelOindexAdd)=(pointsModelSln.v(sl2IndexAdd)+pointsModelSln.v(slnIndexes1))*1.01;
newDietModel.lb(modelOindexAdd)=(pointsModelSln.v(sl2IndexAdd)+pointsModelSln.v(slnIndexes1));
newDietModel.ub(modelOindexAdd)=(pointsModelSln.v(sl2IndexAdd)+pointsModelSln.v(slnIndexes1));
% newDietModel.lb(modelOindexRemove)=(pointsModelSln.v(sl2IndexRemove)-pointsModelSln.v(slnIndexes2))*1.01;
newDietModel.lb(modelOindexRemove)=(pointsModelSln.v(sl2IndexRemove)-pointsModelSln.v(slnIndexes2));
newDietModel.ub(modelOindexRemove)=(pointsModelSln.v(sl2IndexRemove)-pointsModelSln.v(slnIndexes2));

if strcmp(display,'on')
    disp('Points Simulation Solution:')
end
for i=1:length(rois)
    ind=find(strcmp(pointsModel.rxns,rois{i}));
    if strcmp(display,'on')
        disp(['   ',rois{i},' flux = ', num2str(pointsModelSln.v(ind(1)))])
    end
    roiFlux(i)=pointsModelSln.v(ind(1));
end
if strcmp(slnType,'Quick')
    detailedAnalysis=[];
    return
end


%Find new obj flux with new diet
if strcmp(display,'on')
    disp('Detailed Analysis:')
end
if model.ub(objIndex)~=model.lb(objIndex)
    ind=find(newDietModel.c==1);
    model_Obj = optimizeCbModel(newDietModel);
    f2=model_Obj.f;
    newDietModel=changeRxnBounds(newDietModel,obj,f2,'l'); %constrain pointsModel obj flux
    if ~any(strcmp(obj,rois)==1) && strcmp(display,'on')
        disp([' ','Original objective max flux =',num2str(f1), ' & New objective max flux =', num2str(f2)])
    end
else
    f2=model.ub(objIndex);
    if ~any(strcmp(obj,rois)==1) && strcmp(display,'on')
        disp([' ','Original objective max flux =',num2str(f1), ' & New objective max flux =', num2str(f2)])
    end
end



%Compute new min max ranges for roi with new diet
%%
for i=1:length(rois)
    if strcmp(display,'on')
        disp([' ' rois{i}])
    end
    newDietModel = changeObjective(newDietModel,rois{i});
    newDietModel.osenseStr = 'min';
    if  strcmp(rois{i},obj)
        newDietModel=changeRxnBounds(newDietModel,obj,model.lb(objIndex),'l'); %constrain pointsModel obj flux
        tmp = optimizeCbModel(newDietModel);
        newDietModel=changeRxnBounds(newDietModel,obj,f2,'l'); %constrain pointsModel obj flux
        detailedAnalysis.(['Rxn',num2str(i)]).min.ND = tmp;
        NroiFluxMin(i)=tmp.v(roiIndexO(i));
        newDietModel.osenseStr = 'max';
        tmp=model_Obj;
        detailedAnalysis.(['Rxn',num2str(i)]).max.ND = tmp;
        NroiFluxMax(i)=tmp.v(roiIndexO(i));
    else
        tmp=optimizeCbModel(newDietModel);
        detailedAnalysis.(['Rxn',num2str(i)]).min.ND = tmp;
        NroiFluxMin(i)=tmp.v(roiIndexO(i));
        newDietModel.osenseStr = 'max';
        tmp=optimizeCbModel(newDietModel);
        detailedAnalysis.(['Rxn',num2str(i)]).max.ND = tmp;
        NroiFluxMax(i)=tmp.v(roiIndexO(i));
    end
    if strcmp(display,'on')
        disp(['   Original Diet RoI range = ', num2str(OroiFluxMin(i)), ':', num2str(OroiFluxMax(i))])
        disp(['   New Diet RoI range = ', num2str(NroiFluxMin(i)), ':', num2str(NroiFluxMax(i))])
    end
end

newDietModel.ub(objIndex)=model.ub(objIndex);
newDietModel.lb(objIndex)=model.lb(objIndex);
newDietModel = changeObjective(newDietModel,obj);
newDietModel.osenseStr = objMinMax;

if strcmp(display,'on')
    disp('_____________________________________________________')
end

end
