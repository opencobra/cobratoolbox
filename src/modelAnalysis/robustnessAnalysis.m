function [controlFlux, objFlux] = robustnessAnalysis(model, controlRxn, nPoints, plotResFlag, objRxn,objType)
%robustnessAnalysis Performs robustness analysis for a reaction of
% interest and an objective of interest
%
% [controlFlux, objFlux] = robustnessAnalysis(model, controlRxn, nPoints, plotResFlag, objRxn, objType)
%
%INPUTS
% model         COBRA model structure
% controlRxn    Reaction of interest whose value is to be controlled
%
%OPTIONAL INPUTS
% nPoints       Number of points to show on plot (Default = 20)
% plotResFlag   Plot results (Default true)
% objRxn        Objective reaction to be maximized
%               (Default = whatever is defined in model)
% objType       Maximize ('max') or minimize ('min') objective
%               (Default = 'max')
%
%OUTPUTS
% controlFlux   Flux values within the range of the maximum and minimum for
%               reaction of interest
% objFlux       Optimal values of objective reaction at each control
%               reaction flux value
%
% Monica Mo and Markus Herrgard 8/17/06

if (nargin < 3)
    nPoints = 20;
end
if (nargin < 4)
    plotResFlag = true;
end
if (nargin > 4)
    baseModel = changeObjective(model,objRxn);
else
    baseModel = model;
end
if (nargin <6)
    objType = 'max';
end

if (findRxnIDs(model,controlRxn))
    tmpModel = changeObjective(model,controlRxn);
    solMin = optimizeCbModel(tmpModel,'min');
    solMax = optimizeCbModel(tmpModel,'max');
else
    error('Control reaction does not exist!');
end

objFlux = [];
controlFlux = linspace(solMin.f,solMax.f,nPoints)';

showprogress(0,'Robustness analysis in progress ...');
for i=1:length(controlFlux)
    showprogress(i/length(controlFlux));
    modelControlled = changeRxnBounds(baseModel,controlRxn,controlFlux(i),'b');
    solControlled = optimizeCbModel(modelControlled,objType);
    objFlux(i) = solControlled.f;
end

objFlux = objFlux';

if (plotResFlag)
    plot(controlFlux,objFlux)
    xlabel(strrep(controlRxn,'_','-'));
    ylabel('Objective');
    axis tight;
end
