function [rxnsInCommon, MedianChange] = pValDistForModelOverlap(model1, model2)
% Compute for each reaction in common in both sampled modelw
% the magnitude of median flux value change
%
% USAGE:
%
%    [rxnsInCommon, MedianChange] = pValDistForModelOverlap(model1, model2)
%
% INPUTS:
%    model1:          Model sampled under first condition
%    model2:          Model sampled under second condition
%
% OUTPUTS:
%    rxnsInCommon:    Reactions shared by both sampled models
%    MedianChange:    Magnitude of median flux value change for
%                     each reaction listed in 'rxnsInCommon'
%
% .. Authors:
%       - Nathan E. Lewis, May 2010-May 2011
%       - Anne Richelle, May 2017

ZeroRxns1 = setdiff(model1.rxns, model2.rxns);
ZeroRxns2 = setdiff(model2.rxns, model1.rxns);

% Add in changed zero flux rxns %%% make sure this doesn't conflict with
% later steps
model1.rxns(end+1:end+length(ZeroRxns2))=ZeroRxns2;
model2.rxns(end+1:end+length(ZeroRxns1))=ZeroRxns1;
model1.points(end+1:end+length(ZeroRxns2),:)=0;
model2.points(end+1:end+length(ZeroRxns1),:)=0;

% make a list of reactions that are shared
rxnsInCommon = model1.rxns;
checkInCommon = intersect(model1.rxns,model2.rxns);
if sum(ismember(rxnsInCommon,checkInCommon))~=length(rxnsInCommon)
    warning('Preprocessing has not been properly performed: some reactions from the reference model are not present in the sampled models')
end

% scale points if needed (set to 1 by default)
scalingFactor = 1;

% specify the number of points to use if you have memory issues
numPnts = min([length(model2.points(1,:)) length(model1.points(1,:))]);

% grab the points for the two conditions
Cntrlpts = model2.points(findRxnIDs(model2,model2.rxns),1:numPnts)*scalingFactor;
model2.points = [];% clear the model points from memory
Modpts = model1.points(findRxnIDs(model1,model1.rxns),1:numPnts);
model1.points = [];% clear the model points from memory

% get indicies for the shared rxns
ModInd = findRxnIDs(model1,rxnsInCommon);
CntrlInd = findRxnIDs(model2,rxnsInCommon);

% Compute much the average median flux value for each reaction
MedianFlux_m = median(abs(Modpts(ModInd,:)),2);
MedianFlux_c = median(abs(Cntrlpts(CntrlInd,:)),2);

% get the median change in magnitude for each reaction
MedianChange = MedianFlux_c - MedianFlux_m;

end
