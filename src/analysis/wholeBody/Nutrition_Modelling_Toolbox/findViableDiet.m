function [viableModel,pointsModel,pointsSln,dietChanges] = findViableDiet(model,targetString,varargin)
% Identifies changes to the diet that must be made for viability. If 
% no solution is possible for viability, returns NaN.
%
% [viableModel,pointsModel,pointsSln,dietChanges] = findViableDiet(model,targetString,varargin)
%
% Example: findViableDiet(modelHM,'Diet_EX_','supplyScalar',100,'lbValues',-5)
%
% INPUTS:
%   model:         COBRA model to make viable 
%   targetString:  String identifier for targeted reactions (e.g., 'EX_')

% OPTIONAL INPUTS:
%    supplyScalar:  A scalar that dictates the magnitude that metabolites
%                  are supplied with respect to the minimal necessary.
%                  (e.g., a value of one returns the minimal flux necessary
%                  for a viable diet and a scalar of ten returns ten times
%                  the necessary flux)
%    specifiedWeights: A cell array that can be used to manipulate
%                         weights to favor specific nutrients over
%                         others. Default weights are equal to one
%                         (e.g. {'Diet_EX_glu[d]',0.1;'Diet_EX_fru[d]',10})%
%    tol:         A numerical value (double) indicating the threshold that
%                 is assumed to be associated with a zero flux (default is
%                 1e-8)
%    lbValues:    The maximum flux to add for a given dietary reaction
%                (double). The default is -100000
% OUTPUT:
%    viableModel:    An copy of the input model with updated diet
%                    reaction bounds 
%   pointsModel:     The resulting model that is used to identify
%                    recomended dietary changes. It includes points
%                    reactions and food added/removed reactions.
%   pointsSln:       Returns the solution for the pointsModel
%   dietChanges:     A table of recomended dietary changes
%
% .. Authors: - Bronson R. Weston   2022 


parser = inputParser();
parser.addRequired('model', @isstruct);
parser.addRequired('targetString', @ischar);
parser.addParameter('supplyScalar', 1, @isnumeric);
parser.addParameter('specifiedWeights', cell(0), @iscell);
parser.addParameter('tol', 1e-7, @isnumeric);
parser.addParameter('lbValues', -100000, @isnumeric);

parser.parse(model, targetString, varargin{:});

model = parser.Results.model;
targetString = parser.Results.targetString;
supplyScalar = parser.Results.supplyScalar;
specifiedWeights = parser.Results.specifiedWeights;
lbValues = parser.Results.lbValues;
tol = parser.Results.tol;

if supplyScalar<1
    error('supplyScalar must be greater than or equal to one')
end
if lbValues>=0
    error('lbValues must be less than zero')
end


viableModel=model;

%Set up points and food added/removed rxns
model=addMetabolite(model, 'unitOfChange[dP]');
model=addMetabolite(model, 'point[P]');
targetRxnIDs=find(contains(model.rxns,targetString));
Metabolites=model.mets;
RxnsAdd=strcat('Adding_',model.rxns(targetRxnIDs));
removeInd=targetRxnIDs(model.ub(targetRxnIDs)<0);

RxnsRemove=strcat('Removing_',model.rxns(removeInd));
sMatrixAdd=model.S(:,targetRxnIDs);
sMatrixAdd(strcmp(model.mets,'unitOfChange[dP]'),:)= -1*ones(1,length(targetRxnIDs));
sMatrixRemove=-1*model.S(:,removeInd);
sMatrixRemove(strcmp(model.mets,'unitOfChange[dP]'),:)= -1*ones(1,length(removeInd));

%Set up weighting if specified
if exist('specifiedWeights','var') && ~isempty(specifiedWeights)
    for i=1:length(specifiedWeights(:,1))
        f=find(strcmp(model.rxns(targetRxnIDs),specifiedWeights{i,1}));
        sMatrixAdd(end,f)=-1*cell2mat(specifiedWeights(i,2));
    end
end

%Include food added and removed reaction to model
model = addMultipleReactions(model, RxnsAdd, Metabolites, sMatrixAdd, 'lb', lbValues*ones(1,length(RxnsAdd)), 'ub', zeros(1,length(RxnsAdd)));
model = addMultipleReactions(model, RxnsRemove, Metabolites, sMatrixRemove, 'lb', model.ub(removeInd), 'ub', zeros(1,length(RxnsRemove)));
model = addMultipleReactions(model, {'unitOfChange[dP][dP]_[P]','Point_EX_Point[P]'}, {'unitOfChange[dP]','point[P]'}, [-1 0;1 -1], 'lb', [-1000000,-1000000], 'ub', [1000000,1000000]);

%Find solution
model = changeObjective(model,'Point_EX_Point[P]');
model.osenseStr = 'min';
pointsModel=model;
pointsSln = optimizeWBModel(pointsModel);

if isnan(pointsSln.f) %if no viable solution is found
    viableModel=nan;
    dietChanges=nan;
    return
end

%Set up viableModel in accordence with suggested dietary changes
foodAddedIndexes=find(contains(model.rxns,'Adding_'));
foodRemovedIndexes=find(contains(model.rxns,'Removing_'));
slnIndexes1=foodAddedIndexes(pointsSln.v(foodAddedIndexes)<-1*abs(tol));
slnIndexes2=foodRemovedIndexes(pointsSln.v(foodRemovedIndexes)<-1*abs(tol));
dietChanges=table([model.rxns(slnIndexes1);model.rxns(slnIndexes2)],pointsSln.v([supplyScalar*slnIndexes1;slnIndexes2]),'VariableNames',{'Food Rxn', 'Flux'});
foodItemsAdd= regexprep(model.rxns(slnIndexes1),'Adding_','');
foodItemsRemove= regexprep(model.rxns(slnIndexes2),'Removing_','');
modelOindexAdd=zeros(1,length(foodItemsAdd));
sl2IndexAdd=zeros(1,length(foodItemsAdd));
modelOindexRemove=zeros(1,length(foodItemsRemove));
sl2IndexRemove=zeros(1,length(foodItemsRemove));
for i=1:length(foodItemsAdd)
    modelOindexAdd(i)=find(strcmp(viableModel.rxns,foodItemsAdd(i)));
    sl2IndexAdd(i)=find(strcmp(model.rxns,foodItemsAdd(i)));
end
for i=1:length(foodItemsRemove)
    modelOindexRemove(i)=find(strcmp(viableModel.rxns,foodItemsRemove(i)));
    sl2IndexRemove(i)=find(strcmp(model.rxns,foodItemsRemove(i)));
end
viableModel.lb(modelOindexAdd)=(pointsSln.v(sl2IndexAdd)+supplyScalar*pointsSln.v(slnIndexes1));
viableModel.ub(modelOindexAdd)=(pointsSln.v(sl2IndexAdd)+supplyScalar*pointsSln.v(slnIndexes1));
viableModel.lb(modelOindexRemove)=(pointsSln.v(sl2IndexRemove)-pointsSln.v(slnIndexes2));
viableModel.ub(modelOindexRemove)=(pointsSln.v(sl2IndexRemove)-pointsSln.v(slnIndexes2));

end

