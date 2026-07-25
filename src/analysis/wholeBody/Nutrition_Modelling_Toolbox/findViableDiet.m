function [viableModel, pointsModel, pointsSln, dietChanges] = findViableDiet(model, targetString, varargin)
% Identify the changes to a diet needed for a model to be viable
%
% If no viable solution exists, viableModel and dietChanges are returned as
% NaN.
%
% USAGE:
%
%    [viableModel, pointsModel, pointsSln, dietChanges] = findViableDiet(model, targetString, varargin)
%
% INPUTS:
%    model:            COBRA model to make viable, with fields:
%
%                        * .rxns - reaction identifiers
%                        * .mets - metabolite identifiers
%                        * .S - stoichiometric matrix
%                        * .ub - upper flux bounds
%                        * .osenseStr - objective sense (set to 'min' internally)
%    targetString:     String identifier for the targeted reactions
%                      (e.g. 'Diet_EX_')
%
% OPTIONAL INPUTS:
%    varargin:         Name-value pairs:
%
%                        * supplyScalar - scalar setting the magnitude that
%                          metabolites are supplied relative to the minimal
%                          necessary; e.g. one returns the minimal flux for a
%                          viable diet and ten returns ten times that flux
%                          (default 1)
%                        * specifiedWeights - cell array used to weight
%                          specific nutrients above others; default weights
%                          are one (e.g. {'Diet_EX_glu[d]', 0.1; 'Diet_EX_fru[d]', 10})
%                        * tol - numerical threshold assumed to correspond to
%                          a zero flux (default 1e-7)
%                        * lbValues - maximum (most negative) flux that may be
%                          added for a dietary reaction (default -100000)
%
% OUTPUTS:
%    viableModel:      Copy of the input model with updated diet reaction
%                      bounds
%    pointsModel:      Model used to identify the recommended dietary changes;
%                      it includes the points reactions and the food
%                      added/removed reactions
%    pointsSln:        Solution returned for pointsModel
%    dietChanges:      Table of the recommended dietary changes
%
% .. Author: - Bronson R. Weston, 2022


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

