function [controlFlux1, controlFlux2, objFlux] = doubleRobustnessAnalysis(model, controlRxn1, controlRxn2, nPoints, plotResFlag, objRxn,objType)
%doubleRobustnessAnalysis Performs robustness analysis for a pair of reactions of
% interest and an objective of interest
%
% [controlFlux1, controlFlux2, objFlux] = doubleRobustnessAnalysis(model, controlRxn1, controlRxn2, nPoints, plotResFlag, objRxn, objType)
%
%INPUTS
% model         COBRA model structure
% controlRxn1   Reaction of interest whose value is to be controlled
% controlRxn2   Reaction of interest whose value is to be controlled
%
%OPTIONAL INPUTS
% nPoints       Number of flux values per dimension (Default = 20)
% plotResFlag   Plot results (Default = true)
% objRxn        Objective reaction to be maximized (Default = whatever
%               is defined in model)
% objType       Maximize ('max') or minimize ('min') objective
%               (Default = 'max')
%
%OUTPUTS
% controlFlux   Flux values within the range of the maximum and minimum for
%               reaction of interest
% objFlux       Optimal values of objective reaction at each control
%               reaction flux value
%
% Monica Mo and Markus Herrgard 8/20/07

if (nargin < 4)
    nPoints = 20;
end
if (nargin < 5)
    plotResFlag = true;
end
if (nargin > 6)
    baseModel = changeObjective(model,objRxn);
else
    baseModel = model;
end
if (nargin <7)
    objType = 'max';
end

if (findRxnIDs(model,controlRxn1))
    tmpModel = changeObjective(model,controlRxn1);
    solMin1 = optimizeCbModel(tmpModel,'min');
    solMax1 = optimizeCbModel(tmpModel,'max');
else
    error('Control reaction 1 does not exist!');
end
if (findRxnIDs(model,controlRxn2))
    tmpModel = changeObjective(model,controlRxn2);
    solMin2 = optimizeCbModel(tmpModel,'min');
    solMax2 = optimizeCbModel(tmpModel,'max');
else
    error('Control reaction 2 does not exist!');
end

objFlux = [];
controlFlux1 = linspace(solMin1.f,solMax1.f,nPoints)';
controlFlux2 = linspace(solMin2.f,solMax2.f,nPoints)';

showprogress(0,'Double robustness analysis in progress ...');
for i=1:nPoints
    for j = 1:nPoints
        showprogress(((i-1)*nPoints+j)/nPoints^2);
        modelControlled = changeRxnBounds(baseModel,controlRxn1,controlFlux1(i),'b');
        modelControlled = changeRxnBounds(modelControlled,controlRxn2,controlFlux2(j),'b');
        solControlled = optimizeCbModel(modelControlled,objType);
        objFlux(i,j) = solControlled.f;
    end
end

if (plotResFlag)
    clf
    surf(controlFlux1,controlFlux2,objFlux);
    %shading interp
    xlabel(strrep(controlRxn1,'_','-'));
    ylabel(strrep(controlRxn2,'_','-'));
    axis tight
end
