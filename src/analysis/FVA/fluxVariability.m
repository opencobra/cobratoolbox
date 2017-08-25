function [minFlux, maxFlux, Vmin, Vmax] = fluxVariability(model, optPercentage, osenseStr, rxnNameList, verbFlag, allowLoops, method, cpxControl, advind)
% Performs flux variablity analysis
%
% USAGE:
%
%    [minFlux, maxFlux] = fluxVariability(model, optPercentage, osenseStr, rxnNameList, verbFlag, allowLoops, method)
%
% INPUT:
%    model:            COBRA model structure
%
% OPTIONAL INPUTS:
%    optPercentage:    Only consider solutions that give you at least a certain
%                      percentage of the optimal solution (Default = 100
%                      or optimal solutions only)
%    osenseStr:        Objective sense ('min' or 'max') (Default = 'max')
%    rxnNameList:      List of reactions for which FVA is performed
%                      (Default = all reactions in the model)
%    verbFlag:         Verbose output (opt, default false)
%    allowLoops:       Whether loops are allowed in solution. (Default = true)
%                      See `optimizeCbModel` for description
%    method:           when Vmin and Vmax are in the output, the flux vector can be (Default = 2-norm):
%
%                        * 'FBA'    : standards FBA solution
%                        * '0-norm' : minimzes the vector  0-norm
%                        * '1-norm' : minimizes the vector 1-norm
%                        * '2-norm' : minimizes the vector 2-norm
%                        * 'minOrigSol' : minimizes the euclidean distance of each vector to the original solution vector
%
%   cpxControl:        solver-specific parameter structure
%
%   advind:            switch to use the solution basis
%
%                           - 0 : default
%                           - 1 : uses the original problem solution basis as advanced basis
%
% OUTPUTS:
%    minFlux:          Minimum flux for each reaction
%    maxFlux:          Maximum flux for each reaction
%
% OPTIONAL OUTPUT:
%    Vmin:             Matrix of column flux vectors, where each column is a
%                      separate minimization.
%    Vmax:             Matrix of column flux vectors, where each column is a
%                      separate maximization.
%
% .. Authors:
%       - Markus Herrgard  8/21/06 Original code.
%       - Ronan Fleming   01/20/10 Take the extremal flux from the flux vector,
%                         not from the objective since this is invariant
%                         to the value and sign of the coefficient
%       - Ronan Fleming   27/09/10 Vmin, Vmax
%       - Marouen Ben Guebila 22/02/2017 Vmin,Vmax method

global CBT_LP_PARAMS

if nargin < 2
    optPercentage = 100;
end
if nargin < 3
    if isfield(model, 'osenseStr')
        osenseStr = model.osenseStr;
    else
        osenseStr = 'max';
    end
end
if nargin < 4
    rxnNameList = model.rxns;
end
if nargin < 5
    verbFlag = false;
end
if nargin < 6
    allowLoops = true;
end
if nargin < 7
    method = '2-norm';
end
if nargin < 8
    cpxControl = struct();
end
if nargin < 9
   advind = 0;
end
if isempty(optPercentage)
    optPercentage = 100;
end
if isempty(osenseStr)
    osenseStr = 'max';
end
if isempty(rxnNameList)
    rxnNameList = model.rxns;
end

% Set up the problem size
[nMets,nRxns] = size(model.S);
Vmin=[];
Vmax=[];
if nargout > 2
    OutputMatrix = 1;
else
    OutputMatrix = 0;
end

% LP solution tolerance
if exist('CBT_LP_PARAMS', 'var')
    if isfield(CBT_LP_PARAMS, 'objTol')
        tol = CBT_LP_PARAMS.objTol;
    else
        tol = 1e-6;
    end
    if nargout < 3
        minNorm = 0;
    else
        minNorm = 1;
    end
end

% Determine constraints for the correct space (0-100% of the full space)
if sum(model.c ~= 0) > 0
    hasObjective = true;
else
    hasObjective = false;
end

if verbFlag == 1
    showprogress(0,'Flux variability analysis in progress ...');
end
if verbFlag > 1
    fprintf('%4s\t%4s\t%10s\t%9s\t%9s\n','No','Perc','Name','Min','Max');
end

if ~isfield(model,'b')
    model.b = zeros(size(model.S,1),1);
end
% Set up the general problem
rxnListFull = model.rxns;
LPproblem.c = model.c;
LPproblem.lb = model.lb;
LPproblem.ub = model.ub;
if ~isfield(model,'csense')
    LPproblem.csense(1:nMets) = 'E';
else
    LPproblem.csense = model.csense;
end
LPproblem.csense = LPproblem.csense';
LPproblem.A = model.S;
LPproblem.b = model.b;

%solve to get the original model optimal objective
if ~isfield(model,'osense')
    LPproblem.osense = -1;
else
    LPproblem.osense = model.osense;
end
tempSolution = solveCobraLP(LPproblem, cpxControl);

if tempSolution.stat == 1
    objRxn = model.rxns(model.c~=0);
    if strcmp(osenseStr,'max')
        objValue = floor(tempSolution.obj/tol)*tol*optPercentage/100;
    else
        objValue = ceil(tempSolution.obj/tol)*tol*optPercentage/100;
    end
else
    error('The FVA could not be run because the model is infeasible or unbounded')
end


%set the objective
if hasObjective
    LPproblem.A = [model.S;columnVector(model.c)'];
    LPproblem.b = [model.b;objValue];
    if strcmp(osenseStr, 'max')
        LPproblem.csense(end+1) = 'G';
    else
        LPproblem.csense(end+1) = 'L';
    end
end

%get the initial basis
if advind == 1
    tempSolution = solveCobraLP(LPproblem, cpxControl);
    LPproblem.basis = tempSolution.basis;
end
LPproblem.S = LPproblem.A;%needed for sparse optimisation

% Loop through reactions
maxFlux = zeros(length(rxnNameList), 1);
minFlux = zeros(length(rxnNameList), 1);

%Thats not true. The eucleadean norm does not get rid of loops if the
%objective reaction is part of the loop.
% if length(minNorm)> 1 || minNorm > 0
%     %minimizing the Euclidean norm gets rid of the loops, so there
%     %is no need for a second slower MILP approach
%     allowLoops=1;
% end

solutionPool = zeros(length(model.lb), 0);

v=ver;
PCT = 'Parallel Computing Toolbox';
if  any(strcmp(PCT,{v.Name})) && license('test','Distrib_Computing_Toolbox')
    p = gcp('nocreate');
    if isempty(p)
        poolsize = 0;
    else
        poolsize = p.NumWorkers;
    end
    PCT_status=1;
else
    PCT_status=0;  % Parallel Computing Toolbox not found.
end

if ~PCT_status && (~exist('parpool') || poolsize == 0)  %aka nothing is active

    for i = 1:length(rxnNameList)
        if minNorm
            [minFlux(i),maxFlux(i),Vmin(:,i),Vmax(:,i)] = calcSolForEntry(model,rxnNameList,i,LPproblem,0, method, allowLoops,verbFlag,minNorm,cpxControl);
        else
            [minFlux(i),maxFlux(i)] = calcSolForEntry(model,rxnNameList,i,LPproblem,0, method, allowLoops,verbFlag,minNorm,cpxControl);
        end
    end
else % parallel job.  pretty much does the same thing.

    global CBT_LP_SOLVER;
    global CBT_QP_SOLVER;
    lpsolver = CBT_LP_SOLVER;
    qpsolver = CBT_QP_SOLVER;
    parfor i = 1:length(rxnNameList)
        changeCobraSolver(qpsolver,'QP',0,1);
        changeCobraSolver(lpsolver,'LP',0,1);
        parLPproblem = LPproblem;
        if minNorm
            [minFlux(i),maxFlux(i),Vmin(:,i),Vmax(:,i)] = calcSolForEntry(model,rxnNameList,i,parLPproblem,1, method, allowLoops,verbFlag,minNorm,cpxControl);
        else
            [minFlux(i),maxFlux(i)] = calcSolForEntry(model,rxnNameList,i,parLPproblem,1, method, allowLoops,verbFlag,minNorm,cpxControl);
        end
    end
end

maxFlux = columnVector(maxFlux);
minFlux = columnVector(minFlux);
end

function [minFlux,maxFlux,Vmin,Vmax] = calcSolForEntry(model,rxnNameList,i,LPproblem,parallel, method, allowLoops, verbFlag, minNorm, cpxControl)

    if verbFlag == 1 && ~parallel
        fprintf('iteration %d.\n', i);
    end
    LPproblem.c = double(ismember(model.rxns,rxnNameList{i}));
    nRxns = numel(model.rxns);
    % do LP always
    LPproblem.osense = -1;
    if allowLoops
        LPsolution = solveCobraLP(LPproblem, cpxControl);
    else
        LPsolution = solveCobraMILP(addLoopLawConstraints(LPproblem, model));
    end
    % take the maximum flux from the flux vector, not from the obj -Ronan
    % A solution is possible, so the only problem should be if its
    % unbounded and if it is unbounded, the max flux is infinity.
    if LPsolution.stat == 2
        maxFlux = inf;
    else
        maxFlux = getObjectiveFlux(LPsolution, LPproblem);
    end

    % minimise the Euclidean norm of the optimal flux vector to remove loops -Ronan
    if minNorm == 1
        Vmax = getMinNorm(LPproblem, LPsolution, nRxns, maxFlux, model, method);
    end
    LPproblem.osense = 1;
    if allowLoops
        LPsolution = solveCobraLP(LPproblem, cpxControl);
    else
        LPsolution = solveCobraMILP(addLoopLawConstraints(LPproblem, model));
    end

    % take the maximum flux from the flux vector, not from the obj -Ronan
    % A solution is possible, so the only problem should be if its
    % unbounded and if it is unbounded, the max flux is infinity.
    if LPsolution.stat == 2
        minFlux = -inf;
    else
        minFlux = getObjectiveFlux(LPsolution, LPproblem);
    end

    %minimise the Euclidean norm of the optimal flux vector to remove loops
    if minNorm == 1
        Vmin = getMinNorm(LPproblem,LPsolution,nRxns,maxFlux,model, method);
    end

    if verbFlag == 1 && ~parallel
        showprogress(i/length(rxnNameList));
    end
    if verbFlag > 1 && ~parallel
        fprintf('%4d\t%4.0f\t%10s\t%9.3f\t%9.3f\n',i,100*i/length(rxnNameList),rxnNameList{i},minFlux(i),maxFlux(i));
    end
end


function V = getMinNorm(LPproblem,LPsolution,nRxns,cFlux, model, method)
% get the Flux distribution for the specified min norm.

    if strcmp(method, '2-norm')
        QPproblem=LPproblem;
        QPproblem.lb(LPproblem.c~=0) = cFlux - 1e-12;
        QPproblem.ub(LPproblem.c~=0) = cFlux + 1e12;
        QPproblem.c(:)=0;
        %Minimise Euclidean norm using quadratic programming
        QPproblem.F = speye(nRxns,nRxns);
        QPproblem.osense = 1;
        %quadratic optimization
        solution = solveCobraQP(QPproblem);
        V=solution.full(1:nRxns,1);
    elseif strcmp(method, '1-norm')
        vSparse = sparseFBA(LPproblem, 'min', 0, 0, 'l1');
        V = vSparse;
    elseif strcmp(method, '0-norm')
        vSparse = sparseFBA(LPproblem, 'min', 0, 0);
        V = vSparse;
    elseif strcmp(method, 'FBA')
        V=LPsolution.full;
    elseif strcmp(method, 'minOrigSol')
        LPproblemMOMA = LPproblem;
        LPproblemMOMA=rmfield(LPproblemMOMA, 'csense');
        LPproblemMOMA.A = model.S;
        LPproblemMOMA.S = LPproblemMOMA.A;
        LPproblemMOMA.b = model.b;
        LPproblemMOMA.lb(LPproblem.c~=0) = cFlux - 1e-12;
        LPproblemMOMA.ub(LPproblem.c~=0) = cFlux + 1e-12;
        LPproblemMOMA.rxns = model.rxns;
        momaSolution = linearMOMA(model,LPproblemMOMA);
        V=momaSolution.x;
    end
end


function flux = getObjectiveFlux(LPsolution,LPproblem)
% Determine the current flux based on an LPsolution, the original LPproblem
% The LPproblem is used to retrieve the current objective position.
% min indicates, whether the minimum or maximum is requested, the
% upper/lower bounds are used, if the value is exceeding them

    Index = LPproblem.c~=0;
    if LPsolution.full(Index)<LPproblem.lb(Index) %takes out tolerance issues
        flux = LPproblem.lb(Index);
    elseif LPsolution.full(Index)>LPproblem.ub(Index)
        flux = LPproblem.ub(Index);
    else
        flux = LPsolution.full(Index);
    end
end
