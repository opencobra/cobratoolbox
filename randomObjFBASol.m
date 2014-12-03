function x0 = randomObjFBASol(model,initArgs)
%randomObjFBASol Solves an FBA problem with a random objective function
%
% x0 = randomObjSol(model,initArgs)
%
%INPUTS
% model             COBRA model structure
% initArgs          Cell array containing the following data:
%   {1}osenseStr      Maximize ('max')/minimize ('min')
%   {2}minObjFrac     Minimum initial objective fraction
%   {3}minObjValue    Minimum initial objective value (opt)
%                     (Default = minObjFrac*sol.f)
%
% Markus Herrgard

osenseStr = initArgs{1};
minObjFrac = initArgs{2};

if (length(initArgs) < 3)
    solOpt = optimizeCbModel(model,osenseStr);
    model.lb(model.c==1) = minObjFrac*solOpt.f;
else
    model.lb(model.c==1) = initArgs{3};
end

nRxns = length(model.rxns);

model.c = rand(nRxns,1)-0.5;
sol = optimizeCbModel(model,osenseStr);
x0 = sol.x;