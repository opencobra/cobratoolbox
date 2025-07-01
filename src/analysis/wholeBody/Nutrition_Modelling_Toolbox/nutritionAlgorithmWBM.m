function [newDietModel,pointsModel,roiFlux,pointsModelSln,menuChanges, macroChanges, roiChanges] = nutritionAlgorithmWBMnew(model,obj,objMinMax,rois,roisMinMax,options)
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
%       Possible inputs are: "Food", "AllMets", "FoodMets".
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
%
%       * .graphicalAnalysis: set to 'True' include graphical analysis and
%       'False' to not include. Default is 'False' if .slnType is set to
%       'Quick but is 'True; if .slnType is 'Detailed'.
%       
%       * .removeFoodItem: A nx2 cell array with the first column the food
%       item ID and the second column the name of the database of the food
%       items that should be removed from the analysis
% 
%       * .addPrice: a nx3 cell array with the first column the food item
%       ID, the second column the name of the database, and in the third
%       column the price (any currency) associated with that food item.
%       Allows for optimizing the price of a diet, but only if enough
%       information is available.
% 
% OUTPUT:
%   newDietModel
%   pointsModel
%   roiFlux
%   pointsModelSln
%   menuChanges
%   macroChanges
%   roiChanges
%
% .. Authors: - Bronson R. Weston   2021-2022
%             - Bram Nap 04-2025 Enabled food item calculations with the 
% usda and frida database. Enabled options for constraints with various
% macronutrients. Removed old/not used code. Added additional outputs for
% the user to better store and interpret the results.
%% Set up the options and initialise variables
disp('_____________________________________________________')

%is foodOrMets variable established in the options struct?
if exist('options','var')
    if isfield(options,'foodOrMets')
        foodOrMets=options.foodOrMets;
    else
        foodOrMets='Food';
    end
else
    foodOrMets = 'Food';
end

% Check if WBM already already has food items set on the model
if any(contains(model.rxns, 'Food_EX_'))
    foodItemInModel = true;
else
    foodItemInModel = false;
end


% Change the objective of the model
model = changeObjective(model,obj);
% Set the osense (maximisation or minimisation of the problem)
model.osenseStr = objMinMax;

% Determine if any rois are metabolites
metRois=[];
for i=1:length(rois)
    % If a rois is formulated as demand reaction, remove DM_ from
    % metabolite.
    if startsWith(rois(i), 'DM_')
        rois(i) = strrep(rois(i), 'DM_', '');
    end
    if any(strcmp(model.mets,rois{i}))
        metRois=[metRois,i];
        %         if strcmp(slnType,'Detailed')
        %             slnType='Quick';
        %             disp('slnType changed to Quick because one or more rois defined as a metabolite')
        %         end
        % If maximisation problem for a ROI metabolite set create a demand
        % reaction
        if strcmpi(roisMinMax{i},'max')
            model=addDemandReaction(model,rois{i}); %adds demand reaction as 'DM_metabolite'
            rois{i}=['DM_',rois{i}];
            % Update reaction bounds as by default demand reactions have
            % upper bound of 1000 mmol/human/day
            model=changeRxnBounds(model,rois{i},100000,'u');
        % if minimsation set a sink reaction, supplying the model with a
        % metabolite of interest
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
carbohydrateRange = [0 1e6];
lipidRange = [0 1e6];
proteinRange = [0 1e6];
sugarsRange = [0 1e6];
slnType='Detailed';
roiBound='Bounded';
foodAddedLimit=1000000;
foodRemovedLimit=1000000;
freeMets={};
removeFoodItem = {};
addPrice = {};

% Overwrite the variables by the ones specified in the options input
if exist('options','var')
    fn = fieldnames(options);
    for k=1:numel(fn)
        if strcmpi(fn{k},'roiweights')
            roiWeights=options.(fn{k});
            if length(roiWeights)~=length(rois)
                error('length of roiWeights vector must be the same as items rois')
            end
        elseif strcmpi(fn{k},'foodOrMets')
            foodOrMets=options.(fn{k});
        
        elseif strcmpi(fn{k},'roiBound')
            roiBound=options.(fn{k});
            if ~strcmpi(roiBound,'Unbounded') && ~strcmpi(roiBound,'Bounded')
                error('Invalid roiBound input. Must be "Unbounded" or "Bounded"')
            end
        elseif strcmpi(fn{k},'graphicalAnalysis')
            graphicalAnalysis=options.(fn{k});
            if ~strcmpi(graphicalAnalysis,'True') && ~strcmpi(graphicalAnalysis,'False')
                error('Invalid graphicalAnalysis input. Must be "True" or "False"')
            end
        elseif strcmpi(fn{k},'foodAddedLimit')
            foodAddedLimit=options.(fn{k});
        elseif strcmpi(fn{k},'foodRemovedLimit')
            foodRemovedLimit=options.(fn{k});
        elseif strcmpi(fn{k},'initObjSln')
            initObjSln=options.(fn{k});
        elseif strcmpi(fn{k},'freeMets')
            freeMets=options.(fn{k});
        elseif strcmpi(fn{k},'caloricRange')
            caloricRange=options.(fn{k});
        elseif strcmpi(fn{k},'carbohydrateRange')
            carbohydrateRange = options.(fn{k});
        elseif strcmpi(fn{k},'lipidRange')
            lipidRange = options.(fn{k});
        elseif strcmpi(fn{k},'proteinRange')
            proteinRange = options.(fn{k});
        elseif strcmpi(fn{k},'sugarsRange')
            sugarsRange = options.(fn{k});
            if sugarsRange(1) > carbohydrateRange(2)
                error('Your range of allowed sugar intake conflicts with the bounds of allowed carbohydrate intake. Please ensure allowed sugar intake is within the bounds of allowed carbohydrate intake')
            end
        elseif strcmpi(fn{k},'slnType')
            slnType=options.(fn{k});
            if ~strcmpi(slnType,'Detailed') && ~strcmpi(slnType,'Quick')
                error('Invalid slnType input. Must be "Detailed" or "Quick"')
            end
        elseif strcmpi(fn{k},'weightedFoodItems')
            weightedFoodItems=options.(fn{k});
            if any(contains(options.(fn{k})(:,1),'Any_'))
                for i=length(options.(fn{k})(:,1)):-1:1
                    word=strsplit(options.(fn{k}){i,1},'Any_');
                    if isempty(word{1}) %If the word starts with 'Any_'
                        tmp=fdTable.Properties.VariableNames(contains(fdTable.Properties.VariableNames,word{2})).';
                        tmp=[tmp,num2cell(weightedFoodItems{i,2}*ones(length(tmp),1))];
                        weightedFoodItems(i,:)=[];
                        weightedFoodItems=[weightedFoodItems;tmp];
                    end
                end
            end
        elseif strcmpi(fn{k},'removeFoodItem')
            removeFoodItem = options.(fn{k});
            if size(removeFoodItem, 2) ~= 2
                error('You give more than two columns for the foods that have to be excluded from analysis. Please give in column 1 the food ID and column 2 the food database name (frida or usda)')
            end
        elseif strcmpi(fn{k},'addPrice')
            addPrice = options.(fn{k});
            if size(addPrice, 2) ~= 3
                error('You give more than two columns for the foods that have to be excluded from analysis. Please give in column 1 the food ID, column 2 the food database name (frida or usda), and column three the price of the food item (any currency)')
            end
        else
            error(['Invalid "options" field entered: ', fn{k}])
        end
    end
end

if any(roiWeights<=0)
    error('"roiWeights" variable must be greater than zero')
end

% Add food items if not yet set on the WBMs
if strcmpi(foodOrMets,'Food')
    if ~foodItemInModel
        model = setFoodRxnsWbm(model, {'usda', 'frida'}, false, addPrice);
    end
elseif ~strcmpi(foodOrMets,'foodmets') && ~strcmpi(foodOrMets,'allmets')
    error('foodOrMets invalid. Possible inputs are: "Food", "AllMets", "FoodMets".')
end

% Add the price to the model if food reactions were already added
if ~isempty(addPrice) && foodItemInModel
    % Store the original food dietary bounds
    originalFoodBounds = [model.lb(contains(model.rxns, 'Food_EX_')), model.ub(contains(model.rxns, 'Food_EX_'))];
    
    % remove all food_EX and breakdown_ reactions
    model = removeRxns(model, model.rxns(contains(model.rxns, 'Food_EX_')));
    model = removeRxns(model, model.rxns(contains(model.rxns, 'Breakdown_')));
    model = removeRxns(model, {'Diet_EX_energy[d]', 'Diet_EX_carbohydrate[d]', 'Diet_EX_protein[d]', 'Diet_EX_lipid[d]', 'Diet_EX_sugars[d]', 'Diet_EX_money[d]'});
    
    % Re-introduce the food reactions with the money metabolite associated
    model = setFoodRxnsWbm(model, {'usda', 'frida'}, false, addPrice);
    
    % Reset the dietary food bounds on the model
    model.lb(contains(model.rxns, 'Food_EX_')) = originalFoodBounds(:,1);
    model.ub(contains(model.rxns, 'Food_EX_')) = originalFoodBounds(:,2);

end

% remove reactions if so specified
if ~isempty(removeFoodItem)
    rxns2Remove = strcat('Food_EX_', removeFoodItem(:,1), '_', removeFoodItem(:,2));
    model = removeRxns(model, rxns2Remove);
end

%adjust ub and lb if roiBound specifies 'Unbound'
if strcmpi(roiBound, 'Unbounded')
    for i=1:length(rois)
        f=find(strcmp(model.rxns,rois{i}));
        if strcmpi(roisMinMax{i},'max')
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
        if strcmpi(freeMets{i},'h2o')
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
else
    model_Obj = optimizeWBModel(newDietModel);
    f1=model_Obj.f;
    initRoiFlux=model_Obj.v(roiIndexO);
end

% Extract the macros if a food item model has been given
if foodItemInModel
    macroExRxns = {'Diet_EX_energy[d]';'Diet_EX_carbohydrate[d]';'Diet_EX_protein[d]';'Diet_EX_lipid[d]';'Diet_EX_sugars[d]'};
    orgMacrosVals = model_Obj.v(findRxnIDs(newDietModel, macroExRxns));
end

if model_Obj.stat ~= 1
    warning('The original model is not feasible on the original diet. Please bugfix')
    return
end

%% Obtain the original solution without any new dietary changes
% If sln type is detailed, check if roi is already min or maxed out and
% if not, define min max range for roi

if strcmpi(slnType,'Detailed')
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

%% Set up the points for the model to track removal and addition of mets/items

% Set up new tracking metabolites used to find the optimal change in diet
pointsModel=addMetabolite(pointsModel, 'unitOfFoodAdded[dP]');
pointsModel=addMetabolite(pointsModel, 'unitOfFoodRemoved[dP]');
pointsModel=addMetabolite(pointsModel, 'unitOfFoodChange[dP]');
pointsModel=addMetabolite(pointsModel, 'roiPoint[roiP]');
pointsModel=addMetabolite(pointsModel, 'point[P]');

% If there are any weighted food items
if ~isempty(weightedFoodItems)
    % Extract the food names
    weightedFoods = weightedFoodItems(:,1);
    % Check if they have Food_EX_ in the name
    if any(~contains(weightedFoodItems, 'Food_EX_'))
        % Add it one if they do not
        weightedFoods(~contains(weightedFoods, 'Food_EX_')) = strcat('Food_EX_', weightedFoods(~contains(weightedFoods, 'Food_EX_'))); 
    end
end

% Set reactions to track the addition of food items or dietary metabolites
if strcmpi(foodOrMets,'Food')
    % Set up tracking structure in the model to track addition of
    % metabolites
    
    % Obtain all indexes of all food item exchange reactions
    foodInd = contains(model.rxns, 'Food_EX_');

    % Set up the reaction names of the added food reactions. It is the
    % same exchange reaction but is called different
    foodRxns= model.rxns(foodInd);
    foodRxns=strrep(foodRxns, 'Food_EX_', 'Food_Added_EX_');
    
    % Obtain all the model metabolites
    foodMetabolites = model.mets;
    % Add in tracking metabolite of food added
    foodMetabolites{end+1}='unitOfFoodAdded[dP]';
    
    % Extract the S-matrix for the food exchange reactions
    sMatrixFoodAdded = model.S(:,foodInd);

    % Adjust the S-matrix so that a consumed food item leads to a added
    % food tracking metabolite. AKA instead of food[f] <- the reaction of
    % added foods is now food[f] + unitOfFoodAdded[dP] <-
    sMatrixFoodAdded(end+1,:) = -1;
    
    % Adjust the the amount of tracked points accumulated by the added food
    % item by adjusting the weights, if defined
    if ~isempty(weightedFoodItems)
    [~,idx,~] = intersect(foodRxns, weightedFoods);
    sMatrixFoodAdded(end, idx) = weightedFoodItems(:,2)';
    end

    % Add the food added tracking reactions to the model
    pointsModel = addMultipleReactions(pointsModel, foodRxns, foodMetabolites, sMatrixFoodAdded, 'lb', -100000*ones(1,length(foodRxns)), 'ub', zeros(1,length(foodRxns)));
    
    % Add additional reactions to transport the tracking metabolites for
    % added and removed food items to general points. Constrain the
    % transfer changed food items by the maximum and minimum amounts of
    % food removed and added as set up by the options variable.
    pointsModel = addMultipleReactions(pointsModel, {'Point_EX_unitOfFoodRemoved2Change[dp]','Point_EX_unitOfFoodAdded2Change[dp]','Point_EX_unitOfFoodChange[dP]_[P]','Point_EX_Point[P]'}, {'unitOfFoodRemoved[dP]','unitOfFoodAdded[dP]','unitOfFoodChange[dP]','point[P]'}, [-1 0 0 0;0 -1 0 0;1 1 -1 0;0 0 1 -1], 'lb', [-1000000,-1000000, -1000000,-1000000], 'ub', [foodRemovedLimit,foodAddedLimit,1000000,1000000]);

elseif strcmpi(foodOrMets,'allmets')
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
else
    error('Invalid foodOrMets specification')
end
%% Add in tracker for removed food items

% Metabolites for removed food are the same, only the point tracker for
% removed foods is renamed.
uof=find(contains(foodMetabolites,'unitOfFoodAdded[dP]'));
foodMetabolites{uof}='unitOfFoodRemoved[dP]';

if strcmpi(foodOrMets,'Food')
    % Set up tracking structure in the model to track removal of
    % foods
    
    % Initialise the new reaction IDs
    foodRxns=strrep(foodRxns, 'Food_Added_EX_', 'Food_Removed_EX_');
    
    % Duplicate the food added S-matrix
    sMatrixFoodRemoved = sMatrixFoodAdded;
    
    % Invert the matrix so that foods are removed and not consumed
    % The new reactions look like unitOfFoodRemoved[dP] <- food[f]
    sMatrixFoodRemoved(1:end-1,:) = sMatrixFoodRemoved(1:end-1,:) * -1;
    
    % Add reactions to model
    pointsModel = addMultipleReactions(pointsModel, foodRxns, foodMetabolites, sMatrixFoodRemoved, 'lb', pointsModel.ub(contains(pointsModel.rxns,'Food_EX_')), 'ub', zeros(size(sMatrixFoodRemoved,2),1));

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
%will then be equivalent to said ub yielding 0.
%% Set up the ROIs

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

%% Set up additional constraints on macros. This is only relevant when food items are searched.
if strcmpi(foodOrMets, 'food')
    macroExRxns = {'Diet_EX_energy[d]';'Diet_EX_carbohydrate[d]';'Diet_EX_protein[d]';'Diet_EX_lipid[d]';'Diet_EX_sugars[d]'};
    macroExBounds = [caloricRange;carbohydrateRange;proteinRange;lipidRange;sugarsRange];
    pointsModel = changeRxnBounds(pointsModel, macroExRxns, macroExBounds(:,1),'l');
    pointsModel = changeRxnBounds(pointsModel, macroExRxns, macroExBounds(:,2),'u');
end

%% Find the adjusted diet

%Find solution
pointsModel = changeObjective(pointsModel,'Point_EX_Point[P]');
pointsModel.osenseStr = 'min';
pointsModelSln = optimizeWBModel(pointsModel);
% pointsModelSln.v(roiIndex)

if pointsModelSln.stat ~= 1
    warning('The optimum solution was not found and no dietary changes can be given. Consider having broader bounds on the macronutrients or less reactions of interest.')
    return
end

disp(['Solution points =',num2str(pointsModelSln.f)])
disp([num2str(pointsModelSln.v(find(strcmp(pointsModel.rxns,'Point_EX_unitOfFoodChange[dP]_[P]')))),' come from diet']);
disp([num2str(pointsModelSln.v(find(strcmp(pointsModel.rxns,'Point_EX_roiPoints[roiP]_[P]')))),' come from roi']);
foodAddedIndexes=find(contains(pointsModel.rxns,'Food_Added_EX_'));
foodRemovedIndexes=find(contains(pointsModel.rxns,'Food_Removed_EX_'));
slnIndexes1=foodAddedIndexes(pointsModelSln.v(foodAddedIndexes)<0);
slnIndexes2=foodRemovedIndexes(pointsModelSln.v(foodRemovedIndexes)<0);

% Load in the food item names to translate the food item IDs
load("USDAfoodItems.mat", 'allFoods');
load("frida2024_foodIdDictionary.mat", "foodIdDictionaryFrida")

% Create table with the dietary changes
disp('Food items of interest are:')
T=table([pointsModel.rxns(slnIndexes1);pointsModel.rxns(slnIndexes2)],pointsModelSln.v([slnIndexes1;slnIndexes2]),'VariableNames',{'Food Rxn', 'Flux'});

if strcmpi(foodOrMets, 'food')
% obtain the food item IDs
    foodIds = T.("Food Rxn");
    
    % Split the database name from the identifier
    foodIds = split(foodIds, '_');
    
    if size(foodIds,2) == 1
        foodIds = foodIds';
    end
    
    % Obtain the names for the usda items
    for k = 1:size(foodIds,1)
        if strcmpi(foodIds(k,5), 'usda')
            foodIds{k,6} = allFoods.description(allFoods.fdc_id==str2double(string(foodIds(k,4))));
        else
            foodIds{k,6} = foodIdDictionaryFrida.foodName(strcmp(foodIdDictionaryFrida.foodId, foodIds(k,4)));
        end
    end
    
    % Set the food names as a column in table T
    T.foodNames = foodIds(:,6);
    T.foodID = foodIds(:,4);
    T.status = foodIds(:,2);
    T.databaseName = foodIds(:,5);
    T.("Food Rxn") = [];
    
    % Reorder and display
    T = T(:, [2,4,1,3,5]);
    disp(T);
else
    % Obtain the IDs
    metIDs = T.("Food Rxn");
    metIDs(contains(metIDs(:,1), 'Added'),2) = {'Added'};
    metIDs(contains(metIDs(:,1), 'Removed'),2) = {'Removed'};

    metIDs(:,1) = strrep(metIDs(:,1), 'Food_Added_EX_', '');
    metIDs(:,1) = strrep(metIDs(:,1), 'Food_Removed_EX_', '');
    metIDs(:,1) = strrep(metIDs(:,1), '[d]', '');

    vmh = loadVMHDatabase;
    vmhMets = vmh.metabolites;

    [~, idxT, idxVmh] = intersect(metIDs, vmhMets(:,1));
    metIDs(idxT,3) = vmhMets(idxVmh, 2);

    T.vmhID = metIDs(:,1);
    T.status = metIDs(:,2);
    T.metName = metIDs(:,3);
    T.("Food Rxn") = [];

    T = T(:, [2 3 1 4]);
    disp(T);
end


% If diet energy is available in the model, display.
if ~strcmpi(foodOrMets,'AllMets') && ~strcmpi(foodOrMets,'FoodMets')
    disp(['Diet Energy = ',num2str(pointsModelSln.v(contains(pointsModel.rxns,'Diet_EX_energy[d]')))])
end

%Add and remove relevant food items from diet in newDietModel
if strcmpi(foodOrMets,'Food')
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

menuChanges=T;
if strcmpi(slnType,'Quick')
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

model_ObjNew = optimizeWBModel(newDietModel);
f2=model_ObjNew.f;
newDietModel=changeRxnBounds(newDietModel,obj,f2,'b'); %constrain pointsModel obj flux

disp(['f1 =',num2str(f1), ' & f2=', num2str(f2)])

if foodItemInModel
    % Extract the new macronutrient values from the updated diet
    macroExRxns = {'Diet_EX_energy[d]';'Diet_EX_carbohydrate[d]';'Diet_EX_protein[d]';'Diet_EX_lipid[d]';'Diet_EX_sugars[d]'};
    updatedMacrosVals = model_ObjNew.v(findRxnIDs(newDietModel, macroExRxns));
    
    % Create the table with the macronutrient changes
    macroChanges = [orgMacrosVals, updatedMacrosVals];
    macroChanges = array2table(macroChanges, 'VariableNames', {'originalMacro', 'newMacro'});
    macroChanges.macroNames = strrep(macroExRxns, 'Diet_EX_', '');
    macroChanges.macroNames = strrep(macroChanges.macroNames, '[d]', '');
    macroChanges = macroChanges(:, [3 1 2]);

    macroChanges.relChange = macroChanges.newMacro - macroChanges.originalMacro;
end

%Compute new min max ranges for roi with new diet
%%

% initialise storage
if size(rois,1) == 1
    roiChanges = rois';
else
    roiChanges = rois;
end

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
    roiChanges(i,2) = {strcat(num2str(OroiFluxMin(i)), ':', num2str(OroiFluxMax(i)))};
    disp(['New Diet RoI range = ', num2str(NroiFluxMin(i)), ':', num2str(NroiFluxMax(i))])
    roiChanges(i,3) = {strcat(num2str(NroiFluxMin(i)), ':', num2str(NroiFluxMax(i)))};
end
% Convert roiChanges into a table
roiChanges = cell2table(roiChanges,'VariableNames', {'rxnName', 'originalRange', 'newRange'});

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