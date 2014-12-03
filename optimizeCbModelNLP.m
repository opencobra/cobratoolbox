function [currentSol,allObjValues,allSolutions] = ...
    optimizeCbModelNLP(model,osenseStr,objFunction,initFunction,nOpt,objArgs,initArgs)
%optimizeCbModelNLP Optimize constraint-based model using a non-linear objective
%
% [currentSol,allObjValues,allSolutions] =
%   optimizeCbModelNLP(model,osenseStr,objFunction,initFunction,nOpt,objArgs,
%   initArgs)
%
%INPUT
% model         COBRA model structure
%
%OPTIONAL INPUT
% objFunction   Name of the non-linear matlab function to be optimized (the
%               corresponding m-file must be in the current matlab path)
% initFunction  Name of the matlab function used to generate random initial
%               starting points
% osenseStr     Optimization direction ('max' or 'min')
% nOpt          Number of independent optimization runs performed
% objArgs       Cell array of arguments to the 'objFunction'
% initArgs      Cell array of arguments to the 'initFunction'
%
%OUTPUT
% currentSol    Solution structure
% allObjValues  Array of objective value of each iteration
% allSolutions  Array of flux distribution of each iteration
%
% Markus Herrgard 8/24/07
%
% Modified for new options in solveCobraNLP by Daniel Zielinski 3/19/10

if (nargin < 2)
    osenseStr = 'max';
end
if strcmp(osenseStr,'max')
    osense = -1;
else
    osense = 1;
end
if (nargin < 3)
    objFunction = 'NLPobjPerFlux';
    objArgs{1} = osense*model.c;
end
if (nargin < 4)
    initFunction = 'randomObjFBASol';
    initArgs{1} = osenseStr;
    initArgs{2} = .5; %Minimum fraction of the objective function to select start points from
    solOpt = optimizeCbModel(model,osenseStr);
    initArgs{3} = initArgs{2}*solOpt.f; %Same as above, sets a starting point within a certain fraction of the maximum linear objective
end
if (nargin < 5)
    nOpt = 100;
end

[nMets,nRxns] = size(model.S);

NLPproblem.A = model.S;
NLPproblem.b = model.b;
NLPproblem.lb = model.lb;
NLPproblem.ub = model.ub;
NLPproblem.objFunction = objFunction;
NLPproblem.csense(1:nMets) = 'E';

% Current best solution
currentSol.f = osense*inf;
allObjValues = zeros(nOpt,1);
allSolutions = zeros(nRxns,nOpt);

%Define additional options for solveCobraNLP
majorIterationLimit = 100000;
printLevel = 3; %3 prints every iteration.  1 does a summary.  0 = silent.
NLPproblem.userParams.model = model; %pass the model into the problem for access by the nonlinear objective function

for i = 1:nOpt
    x0 = feval(initFunction,model,initArgs);
    NLPproblem.x0 = x0; %x0 now a cell within the NLP problem structure
    solNLP = solveCobraNLP(NLPproblem, 'printLevel', printLevel, 'intTol', 1e-7, 'iterationLimit', majorIterationLimit); %New function call
    %solNLP = solveCobraNLP(NLPproblem,[],objArgs); Old Code
    fprintf('%d\t%f\n',i,osense*solNLP.obj);
    allObjValues(i) = osense*solNLP.obj;
    allSolutions(:,i) = solNLP.full;
    if osense*solNLP.obj > currentSol.f
       currentSol.f = osense*solNLP.obj;
       currentSol.x = solNLP.full;
       currentSol.stat = solNLP.stat;
    end
end


