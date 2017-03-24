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
%                 The function receives two arguments, the current flux
%                 vector, and the NLPProblem structure. 
% initFunction    Name of the matlab function used to generate random initial
%                 starting points. The function will be supplied with two
%                 arguments: the model and a cell array of input arguments
%                 (specified in the initArgs parameter)
% osenseStr       Optimization direction ('max' or 'min'), this will
%                 override any mention in the model.
% nOpt            Number of independent optimization runs performed
% objArgs         Cell array of arguments that are supplied to the
%                 objective function as objArguments in the NLPProblem
%                 structure (i.e. the second element, will have a field
%                 objArguments.)
% initArgs        Cell array of arguments to the 'initFunction', will be
%                 provided as second input Argument to the initFunction
% solveroptions   A Struct with options for the solver used. This is
%                 specific to the solver in question, but the fields should
%                 relate to options accepted by the solver.
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


global CBT_NLP_SOLVER
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
addParameter(p,'objArgs',{},@iscell)
addParameter(p,'initArgs',[],@iscell)
addParameter(p,'solverOptions',[],@isstruct)

parse(p,model,varargin{:}); 

[osenseStr,objFunction,initFunction,nOpt,objArgs,initArgs,solverOptions] = ...
    deal( p.Results.osenseStr,p.Results.objFunction,p.Results.initFunction, ...
    p.Results.nOpt,p.Results.objArgs,p.Results.initArgs, p.Results.solverOptions);
%To assure, that we don't have any complications, we replace the model
%osenseStr during the processing.
model.osenseStr = osenseStr;

if strcmp(osenseStr,'max')
    osense = -1;
else
    osense = 1;
end
%Set some defaults for fmincon:

if isnumeric(solverOptions)
    if strcmp(CBT_NLP_SOLVER,'matlab')
        if verLessThan('matlab','9')
                solverOptions = struct('TolFun',1e-20);
           else
        solverOptions = struct('FunctionTolerance', 1e-20,'OptimalityTolerance',1e-20);        
        end
    else
        solverOptions = struct();
    end
    
end
%Set default values, if they are not set.
if ~isfield(solverOptions,'iterationLimit')
    solverOptions.iterationLimit = 100000;
end

if ~isfield(solverOptions,'printLevel')
    solverOptions.printLevel = 3; %3 prints every iteration.  1 does a summary.  0 = silent.
end

%The same as above for the objective Function
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

NLPproblem.osense = osense;
NLPproblem.A = model.S;
NLPproblem.b = model.b;
NLPproblem.lb = model.lb;
NLPproblem.ub = model.ub;
NLPproblem.objFunction = objFunction;
NLPproblem.objArguments = objArgs;
NLPproblem.csense(1:nMets) = 'E';

% Current best solution
currentSol.f = osense*inf;
allObjValues = zeros(nOpt,1);
allSolutions = zeros(nRxns,nOpt);


NLPproblem.user.model = model; %pass the model into the problem for access by the nonlinear objective function

for i = 1:nOpt
    x0 = feval(initFunction,model,initArgs);
    NLPproblem.x0 = x0; %x0 now a cell within the NLP problem structure
    solNLP = solveCobraNLP(NLPproblem,solverOptions); %New function call
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


