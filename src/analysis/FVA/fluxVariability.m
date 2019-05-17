function [minFlux, maxFlux, Vmin, Vmax] = fluxVariability(model, varargin)
% Performs flux variablity analysis
%
% USAGE:
%
%    [minFlux, maxFlux] = fluxVariability(model, optPercentage, osenseStr, rxnNameList, printLevel, allowLoops)
%    [minFlux, maxFlux, Vmin, Vmax] = fluxVariability(model, optPercentage, osenseStr, rxnNameList, printLevel, allowLoops, method, solverParams, advind, threads, heuristics)
%    [...] = fluxVariability(model, ..., 'name', value, ..., solverParams)
%    [...] = fluxVariability(model, ..., paramStruct)
%
% INPUT:
%    model:            COBRA model structure
%
% OPTIONAL INPUTS:
%   (support name-value argument inputs or a single [function + solver] parameter structure input)
%    optPercentage:    Only consider solutions that give you at least a certain
%                      percentage of the optimal solution (Default = 100
%                      or optimal solutions only)
%    osenseStr:        Objective sense, 'min' or 'max' (default)
%    rxnNameList:      List of reactions for which FVA is performed
%                      (Default = all reactions in the model)
%    printLevel:       Verbose level (default: 0). 1 to show a progress bar. 2 to print results for each reaction
%    allowLoops:       Whether loops are allowed in solution or which method to block loops.
%
%                        * 1 (or true) : loops allowed (default)
%                        * 0 (or false): loops not allowed. Use LLC-NS to find loopless solutions
%                        * 'original'  : original loopless FVA 
%                        * 'fastSNP'   : loopless FVA with with Fast-SNP preprocessing of nullspace
%                        * 'LLC-NS'    : localized loopless FVA using information from nullsapce
%                        * 'LLC-EFM'   : localized loopless FVA using information from EFMs. 
%                                        Require CalculateFluxModes.m from EFMtool to calculate EFMs.
%    method:           when Vmin and Vmax are in the output, the flux vector can be (Default = 2-norm):
%
%                        * 'FBA'    : standards FBA solution
%                        * '0-norm' : minimzes the vector  0-norm
%                        * '1-norm' : minimizes the vector 1-norm
%                        * '2-norm' : minimizes the vector 2-norm
%                        * 'minOrigSol' : minimizes the euclidean distance of each vector to the original solution vector
%
%    solverParams:     solver-specific parameter structure. Can also be inputted as the first or last arguement 
%                      if using name-value argument inputs (with or without the keyword 'solverParams').
%                      Can also be inputted as part of a parameter structure together with other function parameters
%
%    advind:           switch to use the solution basis
%
%                           - 0 : default
%                           - 1 : uses the original problem solution basis as advanced basis
%
%    threads:          number of threads used for the analysis
%                        * 1, 2, 3, ...: number of threads
%                        * 0:            defaulted number of threads for the parallel computing toolbox
%                        (default to be 1 if no parpool is activited, otherwise use the existing parpool)
%
%    heuristics:       level of heuristics to accelerate FVA. 
%                      0: no heuristics (default if rxnNameList has < 5 reactions)
%                      1: solve max-sum-flux and min-sum-flux LPs to get reactions which already hit the bounds
%                      2: solve additionally a single LP to find all blocked irreversible reactions (default if rxnNameList has >= 5 reactions)
%
%    paramStruct:      one single parameter structure including any of the inputs above and the solver-specific parameter
%
% OUTPUTS:
%    minFlux:          Minimum flux for each reaction
%    maxFlux:          Maximum flux for each reaction
%
% OPTIONAL OUTPUT:
%    Vmin:             Matrix of column flux vectors, where each column is a separate minimization.
%    Vmax:             Matrix of column flux vectors, where each column is a separate maximization.
%
% EXAMPLES:
%    FVA for all rxns at 100% max value of the objective function:
%        [minFlux, maxFlux] = fluxVariability(model);  
%    Loopless FVA for rxns in `rxnNames` at <= 90% min value of the objective function, print results for each reaction:
%        [minFlux, maxFlux] = fluxVariability(model, 90, 'min', rxnNames, 2, 0);
%    Same as the 1st example, but also return the corresponding flux distributions with 2-norm minimized:
%        [minFlux, maxFlux, Vmin, Vmax] = fluxVariability(model, [], [],    [],       0, 1, '2-norm');
%    Name-value inputs, with Cobra LP parameter `feasTol` and solver-specific (gurobi) parameter `Presolve`:
%        [minFlux, maxFlux] = fluxVariability(model, 'optPercentage', 99, 'allowLoops', 0, 'threads', 0, 'feasTol', 1e-8, struct('Presolve', 0));
%    Single parameter structure input including function, Cobra LP and solver parameters:
%        [minFlux, maxFlux] = fluxVariability(model, struct('optPercentage', 99, 'allowLoops', 'original', 'threads', 0, 'feasTol', 1e-8, 'Presolve', 0)); 
%
% .. Authors:
%       - Markus Herrgard  8/21/06 Original code.
%       - Ronan Fleming   01/20/10 Take the extremal flux from the flux vector,
%                         not from the objective since this is invariant
%                         to the value and sign of the coefficient
%       - Ronan Fleming   27/09/10 Vmin, Vmax
%       - Marouen Ben Guebila 22/02/2017 Vmin,Vmax method

global CBT_LP_PARAMS

optArgin = {     'optPercentage', 'osenseStr',              'rxnNameList', 'printLevel', 'allowLoops', 'method', 'solverParams', 'advind', 'threads', 'heuristics'}; 
defaultValues = {100,             getObjectiveSense(model), model.rxns,    0,            true,         '2-norm', struct(),       0,       [],         []};
validator = {@(x) isscalar(x) & isnumeric(x) & x >= 0 & x <= 100, ...  % optPercentage
    @(x) strcmp(x, 'max') | strcmp(x, 'min'), ...  % osenseStr
    @(x) ischar(x) | iscellstr(x), ...  % rxnNameList
    @(x) isscalar(x) & (islogical(x) | isnumeric(x)) & x >= 0, ...  % printLevel
    @(x) isscalar(x) | ischar(x), ...    % allowLoops
    @(x) ischar(x), ...  % method
    @isstruct, ...  % solverParams
    @(x) true, ...  % advind
    @(x) isscalar(x) & (islogical(x) | isnumeric(x)), ...  % threads
    @(x) isscalar(x) & (islogical(x) | isnumeric(x)) ...  % heuristics
    };  

% get all potentially supplied COBRA parameter names
problemTypes = {'LP', 'MILP', 'QP', 'MIQP'};

[funParams, cobraParams, solverVarargin] = parseCobraVarargin(varargin, optArgin, defaultValues, validator, problemTypes, 'solverParams', true);

% solverParams not outputted as a function parameter since it is individually handled and embedded in solverVarargin
[optPercentage, osenseStr, rxnNameList, printLevel, allowLoops, method, advind, threads, heuristics] = deal(funParams{:});

allowLoopsError = false;
loopMethod = '';
if isscalar(allowLoops) && ~ischar(allowLoops)
    if allowLoops
        loopMethod = 'none';
    else
        % default using LLCs when the method is not specified
        loopMethod = 'LLC-NS';
    end
elseif ischar(allowLoops)
    for str = {'none', 'original', 'fastSNP', 'LLC-NS', 'LLC-EFM'}
        if strncmpi(allowLoops, str{:}, length(allowLoops))
            loopMethod = str{:};
            break
        end
    end
    allowLoops = strcmp(loopMethod, 'none');
    if isempty(loopMethod)
        allowLoopsError = true;
    end
else
    allowLoopsError = true;
end
if allowLoopsError
    error('"allowLoops" must be one of the following: 1 (usual FVA), 0 (default using ''LLC-NS''), ''original'', ''fastSNP'', ''LLC-NS'' or ''LLC-EFM''')
end

if ischar(rxnNameList)
    rxnNameList = {rxnNameList};
end
%Stop if there are reactions, which are not part of the model
if any(~ismember(rxnNameList,model.rxns))
    presence = ismember(rxnNameList,model.rxns);
    error('There were reactions in the rxnList which are not part of the model:\n%s\n',strjoin(rxnNameList(~presence),'\n'));
end

% Set up the problem size
[~, nRxns] = size(model.S);

% LP solution tolerance
[minNorm, tol] = deal(0, 1e-6);
if exist('CBT_LP_PARAMS', 'var') && isfield(CBT_LP_PARAMS, 'objTol')
    tol = CBT_LP_PARAMS.objTol;
end
if nargout >= 3
    minNorm = 1;
end

% Return if minNorm is minOrigSol but allowloops is set to false
if ~allowLoops && minNorm && strcmp(method,'minOrigSol')
    error(['minOrigSol is meant for finding a minimally adjusted solution from an FBA solution. ', ...
        'Cannot return solutions if allowLoops is set to false. ', ...
        'If you want solutions without loops please set method to ''FBA'', ''2-norm'', ''1-norm'' or ''0-norm''.']);
end

% Determine constraints for the correct space (0-100% of the full space)
if sum(model.c ~= 0) > 0
    hasObjective = true;
else
    hasObjective = false;
end

if ~isfield(model,'b')
    model.b = zeros(size(model.S,1),1);
end
% Set up the general problem
LPproblem = buildLPproblemFromModel(model);

loopInfo = struct('method', loopMethod, 'printLevel', printLevel);

% Solve initial (normal) LP
if allowLoops
    tempSolution = solveCobraLP(LPproblem, solverVarargin.LP{:});
else
    % Both Fast-SNP and solving an MILP return a minimal feasible nullspace
    if printLevel
        switch loopMethod
            case 'original'
            % find the usual internal nullspace (Schellenberger et al., 2009)
            fprintf('Use the original loop law\n');
        case 'fastSNP'
            % find a minimal feasible nullspace Fast-SNP (Saa and Nielson, 2016)
            fprintf('Reduce complexity by nullspace preprocessing (Fast-SNP)\n')
        otherwise
            % find a minimal feasible nullspace by one single MILP (Chan et al., 2017)
            % then implement localized loopless constraints
            fprintf('Reduce complexity by nullspace preprocessing and implementing localized loopless constraints (LLCs)\n')
        end
    end
    [MILPproblem, loopInfo] = addLoopLawConstraints(LPproblem, model, 1:nRxns, [], [], loopInfo);
    
    if ~strncmp(loopMethod, 'LLC', 3)
        tempSolution = solveCobraMILP(MILPproblem, solverVarargin.MILP{:});
    else
        % preprocessing for LLCs
        [solveLP, MILPproblem, loopInfo] = processingLLCs('preprocess', loopInfo, LPproblem, model, nRxns, osenseStr, MILPproblem);
        if solveLP
            tempSolution = solveCobraLP(LPproblem, solverVarargin.LP{:});
        else
            tempSolution = solveCobraMILP(MILPproblem, solverVarargin.MILP{:});
        end
    end
end

if tempSolution.stat == 1
    if strcmp(osenseStr,'max')
        objValue = floor(tempSolution.obj / tol) * tol * optPercentage / 100;
    else
        objValue = ceil(tempSolution.obj / tol) * tol * optPercentage / 100;
    end
else
    error('The FVA could not be run because the model is infeasible or unbounded')
end

%set the objective
if hasObjective
    LPproblem.A = [LPproblem.A; columnVector(LPproblem.c)'];
    LPproblem.b = [LPproblem.b; objValue];    
    if strcmp(osenseStr, 'max')
        LPproblem.csense(end+1) = 'G';
    else
        LPproblem.csense(end+1) = 'L';
    end
    model = addCOBRAConstraints(model, model.rxns(model.c ~= 0), objValue, 'dsense', LPproblem.csense(end));
end

% get the initial basis
if advind == 1
    LPproblem.basis = tempSolution.basis;
end
LPproblem.S = LPproblem.A;  % needed for sparse optimisation

%Thats not true. The Euclidean norm does not get rid of loops if the
%objective reaction is part of the loop.
% if length(minNorm)> 1 || minNorm > 0
%     %minimizing the Euclidean norm gets rid of the loops, so there
%     %is no need for a second slower MILP approach
%     allowLoops=1;
% end


v = ver;
PCT = 'Parallel Computing Toolbox';
parpoolOn = false;
if  any(strcmp(PCT, {v.Name})) && license('test', 'Distrib_Computing_Toolbox')
    try
        parpoolOn = ~isempty(gcp('nocreate'));
        PCT_status = 1;
    catch
        PCT_status = 0;
    end
else
    PCT_status = 0;  % Parallel Computing Toolbox not found.
end
parallelJob = false;
if isempty(threads) && PCT_status  % no input for threads and parallel toolbox exists
    % do parallel job if a parpool already exists, otherwise not
    parallelJob = parpoolOn;
elseif ~isempty(threads) && threads ~= 1 && PCT_status  % explicit input for parallel job
    parallelJob = true;
    if ~parpoolOn
        % create a parpool if no existing one
        if threads <= 0  % <= 0 for the default number of workers
            parpool;
        elseif threads > 1  % otherwise specified number of workers
            parpool(threads);
        end
    end
end

minFlux = model.lb(findRxnIDs(model, rxnNameList));
maxFlux = model.ub(findRxnIDs(model, rxnNameList));
% preCompMaxSols(i) = k => the k-th heuristic solution solves max v_i
% k = 1: no heuristic solution
% k = 2: reactions that hit bounds during max-sum-flux heuristic
% k = 3: reactions that hit bounds during min-sum-flux heuristic
% k = 4: reactions that hit bounds during blocked-irreversible-reaction heuristic
% k = 5: blocked reactions found during blocked-irreversible-reaction heuristic
[preCompMaxSols, preCompMinSols] = deal(ones(numel(rxnNameList), 1));
heuristicSolutions = cell(5, 1);
[maxSolved, minSolved] = deal(false(numel(rxnNameList), 1));
[Vmax, Vmin] = deal([]);
if minNorm
    [Vmax, Vmin] = deal(zeros(nRxns, numel(rxnNameList)));
end

if isempty(heuristics)
    if numel(rxnNameList) >= 5
        heuristics = 2;
    else
        heuristics = 0;
    end
end
% each cell in rxnNameList must be a reaction at this point, otherwise there would be error earlier
Order = findRxnIDs(model, rxnNameList);
if heuristics
    %We will calculate a min and max sum flux solution.
    %This solution will (hopefully) provide multiple solutions for individual
    %reactions.
    QuickProblem = LPproblem;
    QuickProblem.c(:) = 0;
    QuickProblem.c(Order) = 1;
    if any(strcmp(loopMethod, {'original', 'fastSNP'}))
        % Skip this when using localized loopless constraints (LLCs) for two reasons:
        % 1. With loopless constraints, one does not expect to have many reactions hitting the bounds
        % 2. LLCs invoke a subset of all loopless constraints and the associated binary
        %    variables. Maximize everything at once will require invoking almost all binary variables
        QuickProblem = addLoopLawConstraints(QuickProblem, model, 1:nRxns, [], [], loopInfo);
    end
    %Maximise all reactions
    QuickProblem.osense = -1;
    quickSolultionFound = false;
    switch loopMethod
        case {'original', 'fastSNP'}
            % Set a short time limit or do not this at all for MILP with loop law
            % because if the model and the number of reactions in the objective is large,
            % it is non-trivial for solvers to find the optimal solution under the loop law.
            idTimeLimit = strcmp(solverVarargin.MILP, 'timeLimit');
            if any(idTimeLimit)
                idTimeLimit(find(idTimeLimit) + 1) = true;
            end
            sol = solveCobraMILP(QuickProblem, solverVarargin.MILP{~idTimeLimit}, 'timeLimit', 10);
            if sol.stat == 1 || (sol.stat == 3 && ~isempty(sol.full))
                % accept if there is a feasible solution for the MILP
                quickSolultionFound = true;
            end
        case 'none'
            sol = solveCobraLP(QuickProblem, solverVarargin.LP{:});
            if sol.stat == 1 || checkSolFeas(QuickProblem, sol) <= cobraParams.LP.feasTol
                quickSolultionFound = true;
            end
    end
    
    % If we reach this point, we can be certain, that there is a solution, i.e.
    % if the stat is not 1, we have to check all reactions.
    if quickSolultionFound  % accept if there is a feasible solution for the MILP
        % Obtain fluxes at their boundaries
        maxSolved = model.ub(Order) == sol.full(Order);
        minSolved = model.lb(Order) == sol.full(Order);
        % If preCompMaxSols/preCompMinSols is non-empty, no need to solve LP again
        sol.heuristics = 'maxSumFlux';
        heuristicSolutions{2} = sol;
        [preCompMaxSols(maxSolved), preCompMinSols(minSolved)] = deal(2);
    end

    %Minimise reactions
    QuickProblem.osense = 1;
    quickSolultionFound = false;
    switch loopMethod
        case {'original', 'fastSNP'}
            % Set a short time limit or do not this at all for MILP with loop law
            % because if the model and the number of reactions in the objective is large,
            % it is non-trivial for solvers to find the optimal solution under the loop law.
            sol = solveCobraMILP(QuickProblem, solverVarargin.MILP{~idTimeLimit}, 'timeLimit', 10);
            if sol.stat == 1 || (sol.stat == 3 && ~isempty(sol.full))
                % accept if there is a feasible solution for the MILP
                quickSolultionFound = true;
            end
        case 'none'
            sol = solveCobraLP(QuickProblem, solverVarargin.LP{:});
            if sol.stat == 1 || checkSolFeas(QuickProblem, sol) <= cobraParams.LP.feasTol
                quickSolultionFound = true;
            end
    end
    
    if quickSolultionFound
        %Again obtain fluxes at their boundaries
        maxSolved = maxSolved | (model.ub(Order) == sol.full(Order));
        minSolved = minSolved | (model.lb(Order) == sol.full(Order));
        % If preCompMaxSols/preCompMinSols is non-empty, no need to solve LP again
        sol.heuristics = 'minSumFlux';
        heuristicSolutions{3} = sol;
        [preCompMaxSols(model.ub(Order) == sol.full(Order)), preCompMinSols(model.lb(Order) == sol.full(Order))] = deal(3);
    end
end

% generate the loopless problem beforehand instead of during each loop
[MILPproblem, LPproblemLLC] = deal([]);
switch loopMethod
    case {'original', 'fastSNP'}
        % always run MILP. Can directly replace the LP
        LPproblem = addLoopLawConstraints(LPproblem, model, 1:nRxns, [], [], loopInfo);
    case {'LLC-NS', 'LLC-EFM'}
        % keep both LP and MILP. Also update the constraint indices in loopInfo
        [MILPproblem, loopInfo] = addLoopLawConstraints(LPproblem, model, 1:nRxns, [], [], loopInfo);
        % store the default RHS without problem-specific LLCs
        loopInfo.rhs0 = MILPproblem.b;
        LPproblemLLC = LPproblem;
end

if heuristics > 1
    % solve one LP to find all blocked irreversible reactions
    if any((model.lb(Order) >= 0 | model.ub(Order) <= 0) & ~(minSolved & maxSolved))
        [~, sol] = findBlockedIrrRxns(model, [], solverVarargin.LP{:});
        % for irreversible reactions with fluxes < feasTol, we can safely say that they are blocked
        sol.full(abs(sol.full) < cobraParams.LP.feasTol) = 0;
        rxnBlocked = (sol.full(Order) == 0) & (model.lb(Order) >= 0 | model.ub(Order) <= 0);
        rxnHitUB = (sol.full(Order) == model.ub(Order)) & ~rxnBlocked & ~maxSolved;
        rxnHitLB = (sol.full(Order) == model.lb(Order)) & ~rxnBlocked & ~minSolved;
        sol.heuristics = 'hitBounds';
        if any(rxnHitUB) || any(rxnHitLB)
            % store the heuristic solutions
            heuristicSolutions{4} = sol;
            [preCompMaxSols(rxnHitUB), preCompMinSols(rxnHitLB)] = deal(4);
        end
        if any(rxnBlocked)
            if minNorm
                % if flux distributions are to be returned, get one for one of the blocked reactions. It works for all blocked reactions
                allowLoopsI = allowLoops;
                % For LLCs, solve LP if the problem constraints do not necessitate the loop law and the target reaction has its forward diretion in loops
                if strncmpi(loopMethod, 'LLC', 3)
                    [allowLoopsI, MILPproblem] = processingLLCs('update', loopInfo, 'max', MILPproblem, zeros(nRxns, 1));
                    if allowLoopsI
                        % solving LP is sufficient
                        LPproblem = LPproblemLLC;
                    else
                        % need to solve MILP
                        LPproblem = MILPproblem;
                    end
                end
                
                [~, V] = calcSolForEntry(model, Order(find(rxnBlocked, 1)), LPproblem, method, allowLoopsI, minNorm, solverVarargin, sol, 1);
                sol.fluxMinNorm = V;
            end
             % store the heuristic solutions
             sol.heuristics = 'blockedIrr';
             heuristicSolutions{5} = sol;
             [preCompMaxSols(rxnBlocked), preCompMinSols(rxnBlocked)] = deal(5);
        end
       
        [minSolved, maxSolved] = deal(minSolved | rxnBlocked | rxnHitLB, maxSolved | rxnBlocked | rxnHitUB);
    end
end


if ~parallelJob  % single-thread FVA
    if printLevel == 1
        showprogress(0,'Single-thread flux variability analysis in progress ...');
    elseif printLevel > 1
        fprintf('%4s\t%4s\t%10s\t%9s\t%9s\n','No','Perc','Name','Min','Max');
    end
    
    % Do this to keep the progress printing in place
    for i = 1:length(rxnNameList)
        
        rxnID = findRxnIDs(model, rxnNameList(i));
        objVector = sparse(rxnID, 1, 1, nRxns, 1);
        
        %Calc minimums
        allowLoopsI = allowLoops;
        
        % For LLCs, solve LP if the problem constraints do not necessitate the
        % loop law and the target reaction has its reverse diretion in loops
        if (~minSolved(i) || minNorm) && strncmpi(loopMethod, 'LLC', 3)
            [allowLoopsI, MILPproblem] = processingLLCs('update', loopInfo, 'min', MILPproblem, objVector);
            if allowLoopsI
                % solving LP is sufficient
                LPproblem = LPproblemLLC;
            else
                % need to solve MILP
                LPproblem = MILPproblem;
            end
        end
        
        [minFlux(i), V] = calcSolForEntry(model, rxnID ,LPproblem, method, allowLoopsI, minNorm, solverVarargin, heuristicSolutions{preCompMinSols(i)}, 1);
        
        % store the flux distribution
        if minNorm
            Vmin(:, i) = V;
        end
        
        %Calc maximums
        allowLoopsI = allowLoops;
        
        % For LLCs, solve LP if the problem constraints do not necessitate the
        % loop law and the target reaction has its forward diretion in loops
        if (~maxSolved(i) || minNorm) && strncmpi(loopMethod, 'LLC', 3)
            [allowLoopsI, MILPproblem] = processingLLCs('update', loopInfo, 'max', MILPproblem, objVector);
            if allowLoopsI
                % solving LP is sufficient
                LPproblem = LPproblemLLC;
            else
                % need to solve MILP
                LPproblem = MILPproblem;
            end
        end
        
        [maxFlux(i), V] = calcSolForEntry(model, rxnID ,LPproblem, method, allowLoopsI, minNorm, solverVarargin, heuristicSolutions{preCompMaxSols(i)}, -1);
        
        % store the flux distribution
        if minNorm
            Vmax(:, i) = V;
        end
        
        if printLevel == 1
            showprogress(i/length(rxnNameList));
        end
        if printLevel > 1
            fprintf('%4d\t%4.0f\t%10s\t%9.3f\t%9.3f\n',i,100*i/length(rxnNameList),rxnNameList{i},minFlux(i),maxFlux(i));
        end
    end
    
else % parallel job.  pretty much does the same thing.
    environment = getEnvironment();
    
    if printLevel == 1
        fprintf('Parallel flux variability analysis in progress ...\n');
    elseif printLevel > 1
        fprintf('%4s\t%10s\t%9s\t%9s\n','No','Name','Min','Max');
    end
    
    parfor i = 1:length(rxnNameList)
        restoreEnvironment(environment,0);
        parLPproblem = LPproblem;
        
        rxnID = findRxnIDs(model, rxnNameList(i));
        objVector = sparse(rxnID, 1, 1, nRxns, 1);
        
        %Calc minimums
        allowLoopsI = allowLoops;
        
        % For LLCs, solve LP if the problem constraints do not necessitate the
        % loop law and the target reaction has its reverse diretion in loops
        if (~minSolved(i) || minNorm) && strncmpi(loopMethod, 'LLC', 3)
            [allowLoopsI, parMILPproblem] = processingLLCs('update', loopInfo, 'min', MILPproblem, objVector);
            if allowLoopsI
                % solving LP is sufficient
                parLPproblem = LPproblemLLC;
            else
                % need to solve MILP
                parLPproblem = parMILPproblem;
            end
        end
        
        [minFlux(i), V] = calcSolForEntry(model, rxnID ,parLPproblem, method, allowLoopsI, minNorm, solverVarargin, heuristicSolutions{preCompMinSols(i)}, 1);
        
        % store the flux distribution
        if minNorm
            Vmin(:, i) = V;
        end
        
        %Calc maximums
        allowLoopsI = allowLoops;
        
        % For LLCs, solve LP if the problem constraints do not necessitate the
        % loop law and the target reaction has its forward diretion in loops
        if (~maxSolved(i) || minNorm) && strncmpi(loopMethod, 'LLC', 3)
            [allowLoopsI, parMILPproblem] = processingLLCs('update', loopInfo, 'max', MILPproblem, objVector);
            if allowLoopsI
                % solving LP is sufficient
                parLPproblem = LPproblemLLC;
            else
                % need to solve MILP
                parLPproblem = parMILPproblem;
            end
        end
        
        [maxFlux(i), V] = calcSolForEntry(model, rxnID ,parLPproblem, method, allowLoopsI, minNorm, solverVarargin, heuristicSolutions{preCompMaxSols(i)}, -1);
        
        % store the flux distribution
        if minNorm
            Vmax(:, i) = V;
        end
        
        if printLevel > 1
            fprintf('%4d\t%10s\t%9.3f\t%9.3f\n', i, rxnNameList{i}, minFlux(i), maxFlux(i));
        end
    end
end

maxFlux = columnVector(maxFlux);
minFlux = columnVector(minFlux);
end

function [Flux, V] = calcSolForEntry(model, rxnID, LPproblem, method, allowLoops, minNorm, solverVarargin, sol, osense)

%Set the correct objective
LPproblem.osense = sign(osense);
LPproblem.c(:) = 0;
LPproblem.c(rxnID) = 1;
if isempty(sol)
    if allowLoops
        % solve LP
        LPsolution = solveCobraLP(LPproblem, solverVarargin.LP{:});
    else
        % solve MILP
        LPsolution = solveCobraMILP(LPproblem, solverVarargin.MILP{:});
    end
    
    % take the maximum flux from the flux vector, not from the obj -Ronan
    % A solution is possible, so the only problem should be if its
    % unbounded and if it is unbounded, the max flux is infinity.
    if LPsolution.stat == 2
        Flux = -LPproblem.osense * inf;
    elseif LPsolution.stat == 1
        Flux = getObjectiveFlux(LPsolution, LPproblem);
    else
        error(sprintf(['A Solution could not be found!\nThis should not be possible but can happen',...
            'if the used solver cannot properly handle unboundedness, or if there are numerical issues.\n',...
            'Please try to use a different solver.\n']))
    end
else
    % use pre-computed solutions from heuristics
    Flux = sol.full(rxnID);
    if minNorm
        LPsolution = sol;
    end    
end

V = [];
if minNorm
    if ~isempty(sol) && strcmp(sol.heuristics, 'blockedIrr')
        % use the solution calculated during heuristics
        V = sol.fluxMinNorm;
    elseif allowLoops
        V = getMinNorm(LPproblem, LPsolution, numel(model.rxns), Flux, model, method, solverVarargin);
    else
        V = getMinNormWoLoops(LPproblem, LPsolution, numel(model.rxns), Flux, method, solverVarargin);
    end
end
end

function V = getMinNorm(LPproblem, LPsolution, nRxns, cFlux, model, method, solverVarargin)
% get the Flux distribution for the specified min norm.

% update LPproblem to fix objective function value for 1-norm and
% 0-norm to work
LPproblem.lb(LPproblem.c ~= 0) = cFlux - 1e-12;
LPproblem.ub(LPproblem.c ~= 0) = cFlux + 1e-12;
switch method
    case '2-norm'
        LPproblem.c(:)=0;
        %Minimise Euclidean norm using quadratic programming
        LPproblem.F = [speye(nRxns, nRxns), sparse(nRxns, size(LPproblem.A, 2) - nRxns);...
            sparse(size(LPproblem.A, 2) - nRxns, size(LPproblem.A, 2))];
        LPproblem.osense = 1;
        %quadratic optimization
        solution = solveCobraQP(LPproblem, solverVarargin.QP{:});
        V = solution.full(1:nRxns, 1);
    case '1-norm'
        V = sparseFBA(LPproblem, 'min', 0, 0, 'l1');
    case '0-norm'
        V = sparseFBA(LPproblem, 'min', 0, 0);
    case 'FBA'
        V= LPsolution.full(1:nRxns);
    case 'minOrigSol'
        % we take the original model, and constrain the objective reaction
        % accordingly.
        LPproblemMOMA = model;
        LPproblemMOMA.lb(LPproblem.c(1:nRxns)~=0) = cFlux - 1e-11;
        LPproblemMOMA.ub(LPproblem.c(1:nRxns)~=0) = cFlux + 1e-11;
        momaSolution = linearMOMA(model,LPproblemMOMA);
        V = momaSolution.x;
end
end

function V = getMinNormWoLoops(MILPproblem, MILPsolution, nRxns, cFlux, method, solverVarargin)
% It will be great if sparseFBA can somehow support MILP problems
[m, n] = size(MILPproblem.A);
% too small gap between lb and ub may cause numerical difficulty for solvers
MILPproblem.lb(MILPproblem.c ~= 0) = floor(cFlux * 1e9) / 1e9;
MILPproblem.ub(MILPproblem.c ~= 0) = ceil(cFlux * 1e9) / 1e9;
switch method
    case '2-norm'
        MILPproblem.c(:)=0;
        %Minimise Euclidean norm using quadratic programming
        MILPproblem.F = [speye(nRxns,nRxns), sparse(nRxns, n - nRxns); ...
            sparse(n - nRxns, n)];
        MILPproblem.osense = 1;
        % supplying a known initial solution has a much higher chance for the solver to return a solution
        MILPproblem.x0 = MILPsolution.full;
                %quadratic optimization
        solution = solveCobraMIQP(MILPproblem, solverVarargin.MIQP{:});
        V = solution.full(1:nRxns);
    case '1-norm'
        MILPproblem.A = [MILPproblem.A,             sparse(m, nRxns); ... original problem
            sparse(1:nRxns, 1:nRxns, 1, nRxns, n),  -speye(nRxns); ...  v - |v| <= 0
            sparse(1:nRxns, 1:nRxns, -1, nRxns, n), -speye(nRxns)]; %  -v - |v| <= 0
        MILPproblem.b = [MILPproblem.b; zeros(nRxns * 2, 1)];
        MILPproblem.csense = [MILPproblem.csense(:); repmat('L', nRxns * 2, 1)];
        MILPproblem.c = [zeros(n, 1); ones(nRxns, 1)];
        MILPproblem.osense = 1;
        MILPproblem.vartype = [MILPproblem.vartype(:); repmat('C', nRxns, 1)];
        MILPproblem.lb = [MILPproblem.lb; zeros(nRxns, 1)];
        MILPproblem.ub = [MILPproblem.ub; max(abs([MILPproblem.lb(1:nRxns), MILPproblem.ub(1:nRxns)]), [],  2)];
        % supplying a known initial solution has a much higher chance for the solver to return a solution
        MILPproblem.x0 = [MILPsolution.full; abs(MILPsolution.full(1:nRxns))];
        solution = solveCobraMILP(MILPproblem, solverVarargin.MILP{:});
        V = solution.full(1:nRxns);
    case '0-norm'
        % use binary switch
        MILPproblem.A = [MILPproblem.A,             sparse(m, nRxns); ... original problem
            sparse(1:nRxns, 1:nRxns, 1, nRxns, n),  sparse(1:nRxns, 1:nRxns, -MILPproblem.ub(1:nRxns), nRxns, nRxns); ...   v - ub*a <= 0
            sparse(1:nRxns, 1:nRxns, -1, nRxns, n),  sparse(1:nRxns, 1:nRxns, MILPproblem.lb(1:nRxns), nRxns, nRxns)];  %  -v + lb*a <= 0
        MILPproblem.b = [MILPproblem.b; zeros(nRxns * 2, 1)];
        MILPproblem.c = [zeros(n, 1); ones(nRxns, 1)];
        MILPproblem.csense = [MILPproblem.csense(:); repmat('L', nRxns * 2, 1)];
        MILPproblem.osense = 1;
        MILPproblem.vartype = [MILPproblem.vartype(:); repmat('B', nRxns, 1)];
        MILPproblem.lb = [MILPproblem.lb; zeros(nRxns, 1)];
        MILPproblem.ub = [MILPproblem.ub; ones(nRxns, 1)];
        intTol = getCobraSolverParams('MILP', 'intTol');
        % supplying a known initial solution has a much higher chance for the solver to return a solution
        V = MILPsolution.full(1:nRxns);
        V(V > 0 & MILPproblem.ub(1:nRxns) > 0 & V ./ MILPproblem.ub(1:nRxns) <= intTol) = 0;
        V(V < 0 & MILPproblem.lb(1:nRxns) < 0 & V ./ MILPproblem.lb(1:nRxns) <= intTol) = 0;
        MILPproblem.x0 = [MILPsolution.full; V ~= 0];
        solution = solveCobraMILP(MILPproblem, solverVarargin.MILP{:});
        V = solution.full(1:nRxns);
    case 'FBA'
        V= MILPsolution.full(1:nRxns);
    case 'minOrigSol'
        warning('method ''minOrigSol'' not supported with ''allowLoops'' turned on. Return the ''FBA'' solution');
        V= MILPsolution.full(1:nRxns);
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