function [newDietModel,pointsModel,roiFlux,pointsModelSln,menuChanges] = nutritionAlgorithmWBM(model,obj,objMinMax,rois,roisMinMax,options)
% Identifies the minimal changes to a diet necessary to get a desired
% change in one or more reactions of interest. One may enter a metabolite
% of the pointsModel instead of a reaction and the algorithm will optimize the
% diet with a sink or demand reaction for the corresponding metabolite of
% interest.
%
% USAGE:
%
%    [newDietModel,pointsModel,slnMin,slnMax,pointsModelSln,itemsRemoved,itemsAdded] = nutritionAlgorithmWBM(pointsModel,obj,objMinMax,rois,roisMinMax,options)
%
%     Example: [newDietModel,pointsModel,roiFlux,pointsModelSln,itemsRemoved,itemsAdded] = nutritionAlgorithmWBM(WBmodel,'Whole_body_objective_rxn','max',{},{})
%
% INPUTS:
%    pointsModel:          COBRA pointsModel structure with the fields:
%                      * .S
%                      * .b
%                      * .ub
%                      * .ub
%                      * .mets  (required if pointsModel.SIntRxnBool absent)
%                      * .rxns  (required if pointsModel.SIntRxnBool absent)
%
%   obj:           organism's objective function
%
%   objMinMax:     minimize ('min') or maximize ('max') objective function
%
%   rois:          cell array of all reactions of interest
%
%   roisMinMax:    cell array of 'min'/'max' entries for rois
%
% OPTIONAL INPUTS:
%   options:  Structure containing the optional specifications:
%
%       * .foodOrMets:  dictates if the algorithm adds individual
%       metabolites to the diet or food items. Default is food items.
%       "Food Cat" adjust algorithm to identify categories of food rather 
%       than specific items."AllMets" allows any dietary metabolite into 
%       the solution and "FoodMets" only allows metabolites that are in 
%       the fdTable spreadsheet into the solution.
%       Possible inputs are: "Food Items", "Food Cat", "AllMets", "FoodMets".
%
%       * .roiWeights:   a vector of weights for each reaction of interest
%       default is equal to 1
%
%       * .weightedFoodItems: A cell vector that specifies any food items 
%       or metabolites that should be weighted and the corresponding weight. 
%
%       * .initObjSln: provide an initial solution for the objective
%       function. Output from optimizeWBmodel.
%
%       * .caloricRange: 1x2 vector defining boundries for diet calories
%
%       * .slnType: Specify if solution should be 'Detailed' or 'Quick'.
%                   Default setting is 'Detailed'
%
%       * .roiBound: 'Unbounded' or 'Bounded'. Default is 'Bounded'.
%
%       * .foodAddedLimit: Specify a limit for the units of food that can
%                          be added to the diet
%
%       * .foodRemovedLimit: Specify a limit for the units of food that can
%                          be removed from the diet
%
%       * .freeMets: Specifies any metabolites that should be freely
%       available to the model.
%
%       * .calorieWeight: set to 'True' to weight by caloric content rather
%       than servings. Default is 'False'
%
%       * .graphicalAnalysis: set to 'True' include graphical analysis and
%       'False' to not include. Default is 'False' if .slnType is set to
%       'Quick but is 'True; if .slnType is 'Detailed'. 
%
% OUTPUT:
%    solution:       Structure containing the following fields:
%
% relaxedModel       pointsModel structure that admits a flux balance solution
%
% .. Authors: - Bronson R. Weston   2021-2022


disp('_____________________________________________________')
%is foodOrMets variable established in the options struct?
if exist('options','var')
    if isfield(options,'foodOrMets')
        foodOrMets=options.foodOrMets;
    else
        foodOrMets='Food Items';
    end
end

%Identify which tables should be loaded
if strcmp(foodOrMets,'Food Items')
    load('fdTable.mat')
elseif strcmp(foodOrMets,'Food Cat')
    try
        load('FoodCategories/fdCategoriesTable.mat')
    catch
        load('fdCategoriesTable.mat')
    end
    fdTable=fdCategoriesTable;
elseif ~strcmp(foodOrMets,'FoodMets') && ~strcmp(foodOrMets,'AllMets')
    error('foodOrMets invalid. Possible inputs are: "Food Items", "Food Cat", "AllMets", "FoodMets".')
else
    options.graphicalAnalysis
    try
        strcmp(options.graphicalAnalysis,'True')
        warning('graphicalAnalysis not available for metabolite based solutions at this time. Only for food items or categories')
        options.graphicalAnalysis='False';
    catch
    end
    load('fdTable.mat')
end

model = changeObjective(model,obj);
model.osenseStr = objMinMax;

% Determine if any rois are metabolites
metRois=[];
for i=1:length(rois)
    if any(strcmp(model.mets,rois{i}))
        metRois=[metRois,i];
        %         if strcmp(slnType,'Detailed')
        %             slnType='Quick';
        %             disp('slnType changed to Quick because one or more rois defined as a metabolite')
        %         end
        if strcmp(roisMinMax{i},'max')
            model=addDemandReaction(model,rois{i}); %adds demand reaction as 'DM_metabolite'
            rois{i}=['DM_',rois{i}];
            model=changeRxnBounds(model,rois{i},100000,'u');
        else
            model=addSinkReactions(model,rois(i),-100000,0);
            rois{i}=['sink_',rois{i}];
        end
    end
end

%initialize optional variables
roiWeights=10*ones(1,length(rois));
initObjSln=[];
weightedFoodItems={};
caloricRange=[0 1e6];
slnType='Detailed';
roiBound='Bounded';
foodAddedLimit=1000000;
foodRemovedLimit=1000000;
calorieWeight='False';
freeMets={};
try
    if strcmp(options.slnType,'Detailed')
        graphicalAnalysis='True';
    else
        graphicalAnalysis='False';
    end
catch
    graphicalAnalysis='True';
end

if exist('options','var')
    fn = fieldnames(options);
    for k=1:numel(fn)
        %         if( isnumeric(options.(fn{k})) )
        %             % do stuff
        %         end
        if strcmp(fn{k},'roiWeights')
            roiWeights=options.roiWeights;
            if length(roiWeights)~=length(rois)
                error('length of roiWeights vector must be the same as items rois')
            end
        elseif strcmp(fn{k},'foodOrMets')
            foodOrMets=options.foodOrMets;
        elseif strcmp(fn{k},'calorieWeight')
            try
                foodOrMets=options.foodOrMets;
            catch
            end
            if strcmp(foodOrMets,'Food Items') || strcmp(foodOrMets,'Food Cat')
                calorieWeight=options.calorieWeight;
            else
                if strcmp(options.calorieWeight,'True') || strcmp(options.calorieWeight,'true')
                    error('"calorieWeight" cannot be True for metabolite solutions')
                end
            end
        elseif strcmp(fn{k},'roiBound')
            roiBound=options.roiBound;
            if ~strcmp(roiBound,'Unbounded') && ~strcmp(roiBound,'Bounded')
                error('Invalid roiBound input. Must be "Unbounded" or "Bounded"')
            end
        elseif strcmp(fn{k},'graphicalAnalysis')
            graphicalAnalysis=options.graphicalAnalysis;
            if ~strcmp(graphicalAnalysis,'True') && ~strcmp(graphicalAnalysis,'False')
                error('Invalid graphicalAnalysis input. Must be "True" or "False"')
            end
        elseif strcmp(fn{k},'foodAddedLimit')
            foodAddedLimit=options.foodAddedLimit;
        elseif strcmp(fn{k},'foodRemovedLimit')
            foodRemovedLimit=options.foodRemovedLimit;
        elseif strcmp(fn{k},'initObjSln')
            initObjSln=options.initObjSln;
        elseif strcmp(fn{k},'freeMets')
            freeMets=options.freeMets;
        elseif strcmp(fn{k},'caloricRange')
            caloricRange=options.caloricRange;
        elseif strcmp(fn{k},'slnType')
            slnType=options.slnType;
            if ~strcmp(slnType,'Detailed') && ~strcmp(slnType,'Quick')
                error('Invalid slnType input. Must be "Detailed" or "Quick"')
            end
        elseif strcmp(fn{k},'weightedFoodItems')
            weightedFoodItems=options.weightedFoodItems;
            if any(contains(options.weightedFoodItems(:,1),'Any_'))
                for i=length(options.weightedFoodItems(:,1)):-1:1
                    word=strsplit(options.weightedFoodItems{i,1},'Any_');
                    if isempty(word{1}) %If the word starts with 'Any_'
                        tmp=fdTable.Properties.VariableNames(contains(fdTable.Properties.VariableNames,word{2})).';
                        tmp=[tmp,num2cell(weightedFoodItems{i,2}*ones(length(tmp),1))];
                        weightedFoodItems(i,:)=[];
                        weightedFoodItems=[weightedFoodItems;tmp];
                    end
                end
            end
        else
            error(['Invalid "options" field entered: ', fn{k}])
        end
    end
end

if any(roiWeights<=0)
    error('"roiWeights" variable must be greater than zero')
end

%adjust ub and lb if roiBound specifies 'Unbound'
if strcmp(roiBound, 'Unbounded')
    for i=1:length(rois)
        f=find(strcmp(model.rxns,rois{i}));
        if strcmp(roisMinMax{i},'max')
            if model.ub(f)~=0
                model.ub(f)=100000;
            end
        else
            if model.lb(f)~=0
                model.lb(f)=-100000;
            end
        end
    end
end

for i=1:length(freeMets)
    str=['Diet_EX_',freeMets{i},'[d]'];
    try
        if strcmp(freeMets{i},'h2o')
            model = changeRxnBounds(model, str, -1e7, 'l');
        else
            model = changeRxnBounds(model, str, -1e5, 'l');
        end
    catch
        error(['Invalid metabolite specified in freeMets: ', freeMets{i}])
    end
end



newDietModel=model; %Copy original instance of model for new diet pointsModel
pointsModel=model; %Copy original instance of model for points pointsModel


%Calculate newDietModel objective function and restrict obj in main pointsModel
objIndex=find(contains(model.rxns,obj));
%
% roiIndex=find(strcmp(newDietModel.rxns,roi));
% disp(['Reaction of Interest = ', newDietModel.rxns{roiIndex}])
roiIndexO=zeros(1,length(rois));
for i=1:length(roiIndexO)
    roiIndexO(i)=find(strcmp(newDietModel.rxns,rois{i}));
    disp(['Reaction of Interest ', num2str(i),' = ', newDietModel.rxns{roiIndexO(i)}])
end


% get flux of objective function
if ~isempty(initObjSln)
    model_Obj=initObjSln;
    f1=model_Obj.f;
    initRoiFlux=model_Obj.v(roiIndexO);
elseif model.ub(objIndex)~=model.lb(objIndex)
    model_Obj = optimizeWBModel(newDietModel);
    f1=model_Obj.f;
    initRoiFlux=model_Obj.v(roiIndexO);
else
    f1=model.ub(objIndex);
    initRoiFlux=NaN(1,length(rois));
end




% If sln type is detailed, check if roi is already min or maxed out and
% if not, define min max range for roi

if strcmp(slnType,'Detailed')
    for i=1:length(rois)
        if initRoiFlux(i)==newDietModel.lb(roiIndexO)
            OroiFluxMin(i)=newDietModel.lb(roiIndexO(i));
        else
            pointsModel = changeObjective(pointsModel,rois{i});
            pointsModel.osenseStr = 'min';
            sln = optimizeWBModel(pointsModel);
            OroiFluxMin(i)=sln.v(roiIndexO(i));
        end
        if initRoiFlux(i)==newDietModel.ub(roiIndexO)
            OroiFluxMax(i)=newDietModel.ub(roiIndexO(i));
        else
            pointsModel = changeObjective(pointsModel,rois{i});
            pointsModel.osenseStr = 'max';
            sln = optimizeWBModel(pointsModel);
            OroiFluxMax(i)=sln.v(roiIndexO(i));
        end
    end
end
pointsModel=addMetabolite(pointsModel, 'unitOfFoodAdded[dP]');
pointsModel=addMetabolite(pointsModel, 'unitOfFoodRemoved[dP]');
pointsModel=addMetabolite(pointsModel, 'unitOfFoodChange[dP]');
pointsModel=addMetabolite(pointsModel, 'roiPoint[roiP]');
pointsModel=addMetabolite(pointsModel, 'point[P]');

fdTableMod=fdTable;
pro_Dindex=find(contains(fdTableMod.Var1,'pro_D')); %for now, remove pro_D from table.
fdTableMod(pro_Dindex,:)=[];
% eIndex=find(contains(fdTableMod.Var1,'Energy in Kcal'));  %remove Energy row from table.
% fdTableMod(eIndex,:)=[];

%Now add row for unitOfFoodAdded variable
tableChange=num2cell(ones(1,length(fdTableMod.Properties.VariableNames)-1));
tableChange=['unitOfFoodAdded',tableChange];
tableChange=cell2table(tableChange,'VariableNames',fdTableMod.Properties.VariableNames);
fdTableMod=[fdTableMod;tableChange];

%Modify unitOfFoodAdded points based on weight from weightedFoodItems
if ~isempty(weightedFoodItems)
    fdTableMod(end, fdTableMod.Properties.VariableNames(weightedFoodItems(:,1)))=(weightedFoodItems(:,2).');
end

if strcmp(foodOrMets,'Food Items') || strcmp(foodOrMets,'Food Cat')
    %Specify all food reactions and food metabolites
    if strcmp(calorieWeight,'True')
        fdTableMod{end,2:end}=fdTableMod{end-1,2:end}/206.28;
    end
    foodRxns=fdTableMod.Properties.VariableNames(2:end);
    foodRxns=strcat('Food_Added_EX_',foodRxns);
    foodRxns=strcat(foodRxns,'[d]');
    foodMetabolites= fdTableMod.Var1;
    foodMetabolites= strcat(foodMetabolites.','[d]');
    uof=find(contains(foodMetabolites,'unitOfFoodAdded'));
    foodMetabolites{uof}='unitOfFoodAdded[dP]';
    %Include food added reaction to pointsModel
    sMatrix=-1*table2array(fdTableMod(1:length(foodMetabolites),2:end));
    pointsModel = addMultipleReactions(pointsModel, foodRxns, foodMetabolites, sMatrix, 'lb', -100000*ones(1,length(foodRxns)), 'ub', zeros(1,length(foodRxns)));
    pointsModel = addMultipleReactions(pointsModel, {'Point_EX_unitOfFoodRemoved2Change[dp]','Point_EX_unitOfFoodAdded2Change[dp]','Point_EX_unitOfFoodChange[dP]_[P]','Point_EX_Point[P]'}, {'unitOfFoodRemoved[dP]','unitOfFoodAdded[dP]','unitOfFoodChange[dP]','point[P]'}, [-1 0 0 0;0 -1 0 0;1 1 -1 0;0 0 1 -1], 'lb', [-1000000,-1000000, -1000000,-1000000], 'ub', [foodRemovedLimit,foodAddedLimit,1000000,1000000]);
    % pointsModel = addMultipleReactions(pointsModel, {'Point_EX_unitOfFoodChange[dP]_[P]','Point_EX_Point[P]','Excretion_EX_Energy'}, {'unitOfFoodChange[dP]','point[P]','Energy in Kcal[d]'}, [-1 0 0;1 -1 0; 0 0 -1], 'lb', [-1000000,-1000000,caloricRange(1)], 'ub', [1000000,1000000,caloricRange(2)]);
elseif strcmp(foodOrMets,'AllMets') || strcmp(foodOrMets,'allMets')
    foodRxns= find(contains(pointsModel.rxns,'Diet_EX_'));
    foodMetabolites= foodRxns;
    foodMetabolites=regexprep(pointsModel.rxns(foodMetabolites),'Diet_EX_','');
    foodRxns=pointsModel.rxns(foodRxns);
    foodRxns=regexprep(foodRxns,'Diet_EX_','Food_Added_EX_');
    foodMetabolites{end+1}='unitOfFoodAdded[dP]';
    
    %Include food added reaction to pointsModel
    sMatrix=-1*eye(length(foodRxns));
    sMatrix=[sMatrix;-1*ones(1,length(foodRxns))];
    pointsModel = addMultipleReactions(pointsModel, foodRxns, foodMetabolites, sMatrix, 'lb', -100000*ones(1,length(foodRxns)), 'ub', zeros(1,length(foodRxns)));
    pointsModel = addMultipleReactions(pointsModel, {'Point_EX_unitOfFoodAdded2Change[dp]','Point_EX_unitOfFoodChange[dP]_[P]','Point_EX_Point[P]'}, {'unitOfFoodAdded[dP]','unitOfFoodChange[dP]','point[P]'}, [-1 0 0;1 -1 0;0 1 -1], 'lb', [-1000000, -1000000,-1000000], 'ub', [foodAddedLimit,1000000,1000000]);
elseif strcmp(foodOrMets,'FoodMets') || strcmp(foodOrMets,'foodMets')
    foodMetabolites= fdTableMod.Var1;
    foodMetabolites= strcat(foodMetabolites.','[d]');
    uof=find(contains(foodMetabolites,'unitOfFoodAdded'));
    foodMetabolites{uof}='unitOfFoodAdded[dP]';
    foodRxns=foodMetabolites;
    foodRxns(uof)=[];
    f=find(contains(foodMetabolites,'Energy_in_Kcal'));
    foodRxns(f)=[];
%     foodRxns=regexprep(foodRxns,'Diet_EX_','Food_Added_EX_');
    foodRxns=strcat('Food_Added_EX_',foodRxns);
    foodMetabolites(f)=[];
    %     foodRxns= strcat('Food_Added_EX_',foodRxns);
    %Include food added reaction to pointsModel
    sMatrix=-1*eye(length(foodRxns));
    sMatrix=[sMatrix;-1*ones(1,length(foodRxns))];
    pointsModel = addMultipleReactions(pointsModel, foodRxns, foodMetabolites, sMatrix, 'lb', -100000*ones(1,length(foodRxns)), 'ub', zeros(1,length(foodRxns)));
    pointsModel = addMultipleReactions(pointsModel, {'Point_EX_unitOfFoodAdded2Change[dp]','Point_EX_unitOfFoodChange[dP]_[P]','Point_EX_Point[P]'}, {'unitOfFoodAdded[dP]','unitOfFoodChange[dP]','point[P]'}, [-1 0 0;1 -1 0;0 1 -1], 'lb', [-1000000, -1000000,-1000000], 'ub', [foodAddedLimit,1000000,1000000]);
else
    error('Invalid foodOrMets specification')
end


uof=find(contains(foodMetabolites,'unitOfFoodAdded[dP]'));
foodMetabolites{uof}='unitOfFoodRemoved[dP]';
if strcmp(foodOrMets,'Food Items') || strcmp(foodOrMets,'Food Cat')
    %Identify food items already in the diet
    foodDietIndex=find(contains(pointsModel.rxns,'Food_EX_'));
    foodInDietIndex=foodDietIndex(pointsModel.lb(foodDietIndex)<0);
    %Build reaction matrix for food to be removed from diet
    sMatrix=zeros(length(foodMetabolites),length(foodInDietIndex));
    for i=1:length(foodInDietIndex)
        foodItem = regexprep(pointsModel.rxns{foodInDietIndex(i)},'Food_EX_','');
        foodRxn=strcat('Food_Removed_EX_',foodItem);
%         foodItem = regexprep(foodItem,'\[d\]','');
%         sMatrix(:,i)=fdTableMod.(foodItem);
%         sMatrix(end,i)=-1/sMatrix(end,i);
%         sMatrix(:,i)
        RxnFormula=printRxnFormula(pointsModel,pointsModel.rxns{foodInDietIndex(i)},0);
        [metaboliteList, stoichCoeffList, ~]=parseRxnFormula(RxnFormula{1});
        metaboliteList=[metaboliteList,{'unitOfFoodRemoved[dP]'}];
        stoichCoeffList=-1*stoichCoeffList;
        stoichCoeffList=[stoichCoeffList,-1];
        pointsModel = addMultipleReactions(pointsModel, {foodRxn}, metaboliteList, stoichCoeffList, 'lb', pointsModel.ub(foodInDietIndex(i)), 'ub', 0);
    end
    
%     pointsModel = addMultipleReactions(pointsModel, foodRxns, foodMetabolites, sMatrix, 'lb', pointsModel.ub(foodInDietIndex), 'ub', zeros(1,length(foodRxns)));
else
    
    %Build reaction matrix for food to be removed from diet
    sMatrix=-1*sMatrix;
    sMatrix(end,:)=-1./sMatrix(end,:);
    foodRxns = regexprep(foodRxns,'Food_Added_EX_','Food_Removed_EX_');
    pointsModel = addMultipleReactions(pointsModel, foodRxns, foodMetabolites, sMatrix, 'lb', -1000000*ones(1,length(foodRxns)), 'ub', zeros(1,length(foodRxns)));
    
end

%note that previous line makes food removal lb equal to food consumption ub
%as more food should not be able to be removed than the food consumption
%capabilities. If removing all of a food item yeilds the optimum solution,
%the diet consumption of said food item should hug the ub and food removal
%will then be equivalent to said ub yeilding 0.


% Introduce any sink or demand reactions if necessary
% if ~isempty(metRois)
%     for i=length(metRois):-1:1
%         if strcmp(roisMinMax{metRois(i)},'max')
%             pointsModel = addMultipleReactions(pointsModel, {strcmp(rois{metRois(i)},'_Demand')}, {rois{metRois(i)},'roiPoint[roiP]'}, [-1; -1*roiWeights(metRois(i))], 'lb', 0, 'ub', 1000000);
%             rois{metRois(i)}=[];
%             roiIndexO(metRois(i))=[];
%         else
%             pointsModel = addMultipleReactions(pointsModel, {strcmp(rois{metRois(i)},'_Sink')}, {rois{metRois(i)},'roiPoint[roiP]'}, [-1; roiWeights(metRois(i))], 'lb', -1000000, 'ub', 0);
%             rois{metRois(i)}=[];
%             roiIndexO(metRois(i))=[];
%         end
%     end
% end

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
% [pointsModel,~,~]= removeRxns(pointsModel, rois{i});
end

pointsModel = addMultipleReactions(pointsModel, [rois,'Point_EX_roiPoints[roiP]_[P]'], [metsRoi,'roiPoint[roiP]','point[P]'], [metsStoich,[zeros(length(metsStoich(:,1))-2,1);-1;1]], 'lb', [roiLB.',-1000000], 'ub', [roiUB.',1000000]);
caloriesRxn=find(contains(pointsModel.rxns,'EX_DietEnergy'));
pointsModel.lb(caloriesRxn)=caloricRange(1);
pointsModel.ub(caloriesRxn)=caloricRange(2);


%Find solution
pointsModel = changeObjective(pointsModel,'Point_EX_Point[P]');
pointsModel.osenseStr = 'min';
pointsModelSln = optimizeWBModel(pointsModel);
% pointsModelSln.v(roiIndex)

disp(['Solution points =',num2str(pointsModelSln.f)])
disp([num2str(pointsModelSln.v(find(strcmp(pointsModel.rxns,'Point_EX_unitOfFoodChange[dP]_[P]')))),' come from diet']);
disp([num2str(pointsModelSln.v(find(strcmp(pointsModel.rxns,'Point_EX_roiPoints[roiP]_[P]')))),' come from roi']);
foodAddedIndexes=find(contains(pointsModel.rxns,'Food_Added_EX_'));
foodRemovedIndexes=find(contains(pointsModel.rxns,'Food_Removed_EX_'));
slnIndexes1=foodAddedIndexes(pointsModelSln.v(foodAddedIndexes)<0);
slnIndexes2=foodRemovedIndexes(pointsModelSln.v(foodRemovedIndexes)<0);

disp('Food items of interest are:')
T=table([pointsModel.rxns(slnIndexes1);pointsModel.rxns(slnIndexes2)],pointsModelSln.v([slnIndexes1;slnIndexes2]),'VariableNames',{'Food Rxn', 'Flux'})
if ~strcmp(foodOrMets,'AllMets') && ~strcmp(foodOrMets,'FoodMets')
    disp(['Diet Energy = ',num2str(pointsModelSln.v(contains(pointsModel.rxns,'EX_DietEnergy')))])
end

%Add and remove relevant food items from diet in newDietModel
if strcmp(foodOrMets,'Food Items') || strcmp(foodOrMets,'Food Cat')
    foodItemsAdd= regexprep(pointsModel.rxns(slnIndexes1),'Food_Added_EX_','Food_EX_');
    foodItemsRemove= regexprep(pointsModel.rxns(slnIndexes2),'Food_Removed_EX_','Food_EX_');
else
    foodItemsAdd= regexprep(pointsModel.rxns(slnIndexes1),'Food_Added_EX_','Diet_EX_');
    foodItemsRemove= regexprep(pointsModel.rxns(slnIndexes2),'Food_Removed_EX_','Diet_EX_');
end
modelOindexAdd=zeros(1,length(foodItemsAdd));
sl2IndexAdd=zeros(1,length(foodItemsAdd));
modelOindexRemove=zeros(1,length(foodItemsRemove));
sl2IndexRemove=zeros(1,length(foodItemsRemove));
for i=1:length(foodItemsAdd)
    modelOindexAdd(i)=find(contains(newDietModel.rxns,foodItemsAdd(i)));
    sl2IndexAdd(i)=find(contains(pointsModel.rxns,foodItemsAdd(i)));
end
for i=1:length(foodItemsRemove)
    modelOindexRemove(i)=find(contains(newDietModel.rxns,foodItemsRemove(i)));
    sl2IndexRemove(i)=find(contains(pointsModel.rxns,foodItemsRemove(i)));
end
newDietModel.lb(modelOindexAdd)=(pointsModelSln.v(sl2IndexAdd)+pointsModelSln.v(slnIndexes1))*1.01;
newDietModel.ub(modelOindexAdd)=(pointsModelSln.v(sl2IndexAdd)+pointsModelSln.v(slnIndexes1))*0.99;
newDietModel.lb(modelOindexRemove)=(pointsModelSln.v(sl2IndexRemove)-pointsModelSln.v(slnIndexes2))*1.01;
newDietModel.ub(modelOindexRemove)=(pointsModelSln.v(sl2IndexRemove)-pointsModelSln.v(slnIndexes2))*0.99;

if strcmp(graphicalAnalysis,'True')
    [ogCatTable] = getDietComposition(model,'Off');
    [newCatTable] = getDietComposition(newDietModel,'Off');
    OgMacros=ogCatTable.('Mass (g)');
    NewCategories=newCatTable.('Category');
    NewMacros=newCatTable.('Mass (g)');
    figure()
    t = tiledlayout(1,2,'TileSpacing','compact');
    ax1 = nexttile;
    pie(ax1,OgMacros(1:4))
    title('Original Diet')
    ax2 = nexttile;
    pie(ax2,NewMacros(1:4))
    title('New Diet')
    legend(NewCategories(1:4),'Location','South')
end

menuChanges=T;
if strcmp(slnType,'Quick')
    for i=1:length(rois)
        ind=find(strcmp(pointsModel.rxns,rois{i}));
        disp([rois{i},' flux = ', num2str(pointsModelSln.v(ind))])
    end
    roiFlux(i)=pointsModelSln.v(ind);
    slnRanges=pointsModelSln.v(roiIndexP);
    %     menuChanges.itemsRemoved=[];
    %     menuChanges.itemsAdded=[];
    %     menuChanges.fullMenu=[];
    newDietModel = changeObjective(newDietModel,obj);
    newDietModel.osenseStr = objMinMax;
    return
end


%Find new obj flux with new diet

if model.ub(objIndex)~=model.lb(objIndex)
    model_Obj = optimizeWBModel(newDietModel);
    f2=model_Obj.f;
    newDietModel=changeRxnBounds(newDietModel,obj,f2,'b'); %constrain pointsModel obj flux
else
    f2=model.ub(objIndex);
end

disp(['f1 =',num2str(f1), ' & f2=', num2str(f2)])

%Compute new min max ranges for roi with new diet
%%
for i=1:length(rois)
    disp(rois{i})
    newDietModel = changeObjective(newDietModel,rois{i});
    newDietModel.osenseStr = 'min';
    tmp=optimizeWBModel(newDietModel);
    slnMin.(['Rxn',num2str(i)]) = tmp;
    NroiFluxMin(i)=slnMin.(['Rxn',num2str(i)]).v(roiIndexO(i));
    newDietModel.osenseStr = 'max';
    tmp=optimizeWBModel(newDietModel);
    slnMax.(['Rxn',num2str(i)]) = tmp;
    NroiFluxMax(i)=slnMax.(['Rxn',num2str(i)]).v(roiIndexO(i));
    disp(['Original Diet RoI range = ', num2str(OroiFluxMin(i)), ':', num2str(OroiFluxMax(i))])
    disp(['New Diet RoI range = ', num2str(NroiFluxMin(i)), ':', num2str(NroiFluxMax(i))])
end

% slnMin
roiFlux=[slnMin.',slnMax.'];
newDietModel.ub(objIndex)=model.ub(objIndex);
newDietModel.lb(objIndex)=model.lb(objIndex);
newDietModel = changeObjective(newDietModel,obj);
newDietModel.osenseStr = objMinMax;

disp('___________________________________________________________________')


end

%TO DO:
% -Impliment itemsRemoved and itemsAdded
% -Introduce option for metabolite adjustments
% -Include intelligent default weighting for roi
% -slnMin & slnMax turn to structs or convert to flux values

%Finished:
%-introduced Quick/Detailed functionality
%-renamed variables to be more obvious
%-commented code

% figure()
% t = tiledlayout(2,2,'TileSpacing','compact');
% ax1 = nexttile;
% pie(ax1,OgMacros(1:4))
% title('Original Diet')
% ax2 = nexttile;
% x=pie(ax2,NewMacros(1:4))
% title('New Diet')
% legend(NewCategories(1:4),'Location','South')
% ax3 = nexttile;
% bar(ax3,(NewMacros(1:4)-OgMacros(1:4))./OgMacros(1:4))
% ylim([-1 14])
% ax4= nexttile;
% legend(x,NewCategories(1:4))