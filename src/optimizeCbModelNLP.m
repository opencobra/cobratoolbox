function [currentSol,allObjValues,allSolutions] = ...
    optimizeCbModelNLP(model,varargin)
%optimizeCbModelNLP Optimize constraint-based model using a non-linear objective
%
% [currentSol,allObjValues,allSolutions] =
%   optimizeCbModelNLP(model,osenseStr,objFunction,initFunction,nOpt,objArgs,
%   initArgs)
%
%INPUT
% model         COBRA model structure
%
%OPTIONAL INPUT (all as parameter/value pairs)
% Parameter Name
% objFunction     Name of the non-linear matlab function to be optimized (the
%                 corresponding m-file must be in the current matlab path)
% initFunction    Name of the matlab function used to generate random initial
%                 starting points
% osenseStr       Optimization direction ('max' or 'min')
% nOpt            Number of independent optimization runs performed
% objArgs         Cell array of arguments to the 'objFunction'
% initArgs        Cell array of arguments to the 'initFunction'
%
%OUTPUT
% currentSol    Solution structure
% allObjValues  Array of objective value of each iteration
% allSolutions  Array of flux distribution of each iteration
%
% Markus Herrgard 8/24/07
%
% Modified for new options in solveCobraNLP by Daniel Zielinski 3/19/10
% Changed the function to use parameter/value pairs, Thomas Pfau 07/22/17

defaultosenseStr = 'max';
if isfield(model,'osenseStr')
       defaultosenseStr = model.osenseStr;
end
defaultObjFunction = 'NLPobjPerFlux';
defaultInitFunction = 'randomObjFBASol';

p = inputParser;
addRequired(p,'model',@isstruct)
addParameter(p,'objFunction',defaultObjFunction,@ischar)
addParameter(p,'initFunction',defaultInitFunction,@ischar)
addParameter(p,'osenseStr',defaultosenseStr,@(x) strcmp(x,'min') | strcmp(x,'max'));
addParameter(p,'nOpt',100,@(x) rem(x,1) == 0);
addParameter(p,'objArgs',[],@iscell)
addParameter(p,'initArgs',[],@iscell)

parse(p,model,varargin{:}); 

[osenseStr,objFunction,initFunction,nOpt,objArgs,initArgs] = ...
    deal( p.Results.osenseStr,p.Results.objFunction,p.Results.initFunction,p.Results.nOpt,p.Results.objArgs,p.Results.initArgs);

if strcmp(osenseStr,'max')
    osense = -1;
else
    osense = 1;
end
if strcmp(objFunction,defaultObjFunction) && isnumeric(objArgs)    
    objArgs = {osense*model.c};
else
    if isnumeric(objArgs)
        objArgs = {};
    end
end
if strcmp(initFunction,defaultInitFunction) && isnumeric(initArgs)        
    solOpt = optimizeCbModel(model,osenseStr);
    %Minimum fraction of the objective function to select start points from
    %is 50% of the maximal objective    
    initArgs = {osenseStr,0.5, 0.5 * solOpt.f}; 
else
    if isnumeric(initArgs)
        initArgs = {};
    end
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
NLPproblem.user.model = model; %pass the model into the problem for access by the nonlinear objective function

for i = 1:nOpt
    x0 = feval(initFunction,model,initArgs);
    NLPproblem.x0 = x0; %x0 now a cell within the NLP problem structure
    solNLP = solveCobraNLP(NLPproblem, 'printLevel', printLevel,'iterationLimit', majorIterationLimit); %New function call
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


