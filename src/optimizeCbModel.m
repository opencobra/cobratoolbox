function FBAsolution = optimizeCbModel(model,osenseStr, minNorm, allowLoops, zeroNormApprox)
%optimizeCbModel Solve a flux balance analysis problem
%
% Solves LP problems of the form: max/min c'*v
%                                 subject to S*v = b         : y
%                                            lb <= v <= ub   : w
% optimizeCbModel(model,osenseStr, minNorm, allowLoops, zeroNormApprox)
%
% FBAsolution.stat is either 1,2,0 or -1, and is a translation from FBAsolution.origStat,
% which is returned by each solver in a solver specific way. That is, not all solvers return 
% the same type of FBAsolution.origStat and because the cobra toolbox can use many solvers, 
% we need to return to the user of optimizeCbModel.m a standard representation, which is what
% FBAsolution.stat is.
%
% When running optimizeCbModel.m, unless FBAsolution.stat = 1, then no solution is returned.
% This means that it is up to the person calling optimizeCbModel to adapt their code to the
% case when no solution is returned, by checking the value of FBAsolution.stat first.
%
%INPUT
% model (the following fields are required - others can be supplied)
%   S            Stoichiometric matrix
%   b            Right hand side = dx/dt
%   c            Objective coefficients
%   lb           Lower bounds
%   ub           Upper bounds
%
%OPTIONAL INPUTS
% osenseStr         Maximize ('max')/minimize ('min') (opt, default = 'max')
%
% minNorm           {(0), 'one', 'zero', > 0 , n x 1 vector}, where [m,n]=size(S);
%                   0      Default, normal LP
%                   'one'  Minimise the Taxicab Norm using LP.
%                                 min |v|
%                                   s.t. S*v = b
%                                        c'v = f
%                                        lb <= v <= ub
%                       A LP solver is required.
%                   'zero' Minimize the cardinality (zero-norm) of v
%                                 min ||v||_0
%                                   s.t. S*v = b
%                                        c'v = f
%                                        lb <= v <= ub
%                       The zero-norm is approximated by a non-convex approximation
%                       Six approximations are available: capped-L1 norm, exponential function
%                       logarithmic function, SCAD function, L_p norm with p<0, L_p norm with 0<p<1
%                       Note : capped-L1, exponential and logarithmic function often give 
%                       the best result in term of sparsity.
% 
%                       See "Le Thi et al., DC approximation approaches for sparse optimization,
%                       European Journal of Operational Research, 2014"
%                       http://dx.doi.org/10.1016/j.ejor.2014.11.031
%                       A LP solver is required.
%                   -----
%                   The remaining options work only with a valid QP solver:
%                   -----
%                   > 0    Minimises the Euclidean Norm of internal fluxes.
%                       Typically 1e-6 works well.
%                                 min ||v||
%                                   s.t. S*v = b
%                                        c'v = f
%                                        lb <= v <= ub
%                   n x 1   Forms the diagonal of positive definiate
%                       matrix F in the quadratic program
%                               min 0.5*v'*F*v
%                               st. S*v = b
%                                   c'*v = f
%                                   lb <= v <= ub
%
% allowLoops        {0,(1)} If false,  then instead of a conventional FBA,
%                   the solver will run an MILP version which does not allow
%                   loops in the final solution.  Default is true.
%                   Runs much slower when set to false.
%                   See addLoopLawConstraints.m to for more info.
%
% zeroNormApprox    appoximation type of zero-norm (only available when minNorm='zero') (default = 'cappedL1')
%                           'cappedL1' : Capped-L1 norm
%                           'exp'      : Exponential function
%                           'log'      : Logarithmic function
%                           'SCAD'     : SCAD function
%                           'lp-'      : L_p norm with p<0
%                           'lp+'      : L_p norm with 0<p<1
%                           'all'      : try all approximations and return the best result
%
%OUTPUT
% FBAsolution
%   f         Objective value
%   x         Primal
%   y         Dual
%   w         Reduced costs
%   s         Slacks
%   stat      Solver status in standardized form
%              1   Optimal solution
%              2   Unbounded solution
%              0   Infeasible
%             -1  No solution reported (timelimit, numerical problem etc)
%   origStat  Original status returned by the specific solver

% Markus Herrgard       9/16/03
% Ronan Fleming         4/25/09  Option to minimises the Euclidean Norm of internal
%                                fluxes using 'cplex_direct' solver
% Ronan Fleming         7/27/09  Return an error if any imputs are NaN
% Ronan Fleming         10/24/09 Fixed 'E' for all equality constraints
% Jan Schellenberger             MILP option to remove flux around loops
% Ronan Fleming         12/07/09 Reworked minNorm parameter option to allow
%                                the full range of approaches for getting
%                                rid of net flux around loops.
% Jan Schellenberger    2/3/09   fixed bug with .f being set incorrectly
%                                when minNorm was set.
% Nathan Lewis          12/2/10  Modified code to allow for inequality
%                                constraints.
% Ronan Fleming         12/03/10 Minor changes to the internal handling of 
%                                global parameters.
% Ronan Fleming         14/09/11 Fixed bug in minNorm with negative
%                                coefficient in objective
% Minh Le               11/02/16 Option to minimise the cardinality of
%                                fluxes vector
% Stefania Magnusdottir 06/02/17 Replace LPproblem2 upper bound 10000 with 
%                                Inf

%% Process arguments and set up problem

if exist('osenseStr', 'var')
    if isempty(osenseStr)
        osenseStr = 'max';
    end
else
    if isfield(model, 'osenseStr')
        osenseStr = model.osenseStr;
    else        
        osenseStr = 'max';
    end
end
% Figure out objective sense
if strcmpi(osenseStr,'max')
    LPproblem.osense = -1;
else
    LPproblem.osense = +1;
end

if exist('minNorm', 'var')
    if isempty(minNorm)
        %use global solver parameter for minNorm
        minNorm = getCobraSolverParams('LP','minNorm');
    end
    % if minNorm = 'zero' then check the parameter 'zeroNormApprox'
    if isequal(minNorm,'zero')
        if exist('zeroNormApprox', 'var')
            availableApprox = {'cappedL1','exp','log','SCAD','lp-','lp+','all'};
            if ~ismember(zeroNormApprox,availableApprox)
                warning('Approximation is not valid. Default value will be used');
                zeroNormApprox = 'cappedL1';
            end
        else
            zeroNormApprox = 'cappedL1';
        end
    end
else
    %use global solver parameter for minNorm
    minNorm = getCobraSolverParams('LP','minNorm');
end
if exist('allowLoops', 'var')
    if isempty(allowLoops)
        allowLoops = true;
    end
else
    allowLoops = true;
end

%use global solver parameter for printLevel
[printLevel,primalOnlyFlag] = getCobraSolverParams('LP',{'printLevel','primalOnly'});

[nMets,nRxns] = size(model.S);

% add csense
%Doing this makes csense a double array.  Totally smart design move.
%LPproblem.csense = [];
if ~isfield(model,'csense')
    % If csense is not declared in the model, assume that all
    % constraints are equalities.
    if printLevel>1
        fprintf('%s\n','LP problem has no defined csense. We assume that all constraints are equalities.')
    end
    LPproblem.csense(1:nMets,1) = 'E';
else % if csense is in the model, move it to the lp problem structure
    if length(model.csense)~=nMets,
        warning('Length of csense is invalid! Defaulting to equality constraints.')
        LPproblem.csense(1:nMets,1) = 'E';
    else
        model.csense = columnVector(model.csense);
        LPproblem.csense = model.csense;
    end
end

% Fill in the RHS vector if not provided
if ~isfield(model,'b')
    warning('LP problem has no defined b in S*v=b. b should be defined, for now we assume b=0')
    LPproblem.b=zeros(nMets,1);
else
    LPproblem.b = model.b;
end

% Rest of the LP problem
[m,n] = size(model.S);
LPproblem.A = model.S;
LPproblem.c = model.c;
LPproblem.lb = model.lb;
LPproblem.ub = model.ub;

%Double check that all inputs are valid:
if ~(verifyCobraProblem(LPproblem, [], [], false) == 1)
    warning('invalid problem');
    return;
end

%%
t1 = clock;
% Solve initial LP
if allowLoops
    solution = solveCobraLP(LPproblem);
else
    MILPproblem = addLoopLawConstraints(LPproblem, model, 1:nRxns);
    solution = solveCobraMILP(MILPproblem);
end

global CBT_LP_SOLVER
if strcmp(CBT_LP_SOLVER,'mps')
    FBAsolution=solution;
    return;
else
    if (solution.stat ~= 1) % check if initial solution was successful.
        if printLevel>0
            warning('Optimal solution was not found');
        end
        FBAsolution.f = 0;
        FBAsolution.x = [];
        FBAsolution.stat = solution.stat;
        FBAsolution.origStat = solution.origStat;
        FBAsolution.solver = solution.solver;
        FBAsolution.time = etime(clock, t1);
        return;
    end
end

objective = solution.obj; % save for later use.

if strcmp(minNorm, 'one')
    % Minimize the absolute value of fluxes to 'avoid' loopy solutions
    % Solve secondary LP to minimize one-norm of |v|
    % Set up the optimization problem
    % min sum(delta+ + delta-)
    % 1: S*v1 = 0
    % 3: delta+ >= -v1
    % 4: delta- >= v1
    % 5: c'v1 >= f or c'v1 <= f (optimal value of objective)
    %
    % delta+,delta- >= 0
    LPproblem2.A = [model.S sparse(nMets,2*nRxns);
        speye(nRxns,nRxns) speye(nRxns,nRxns) sparse(nRxns,nRxns);
        -speye(nRxns,nRxns) sparse(nRxns,nRxns) speye(nRxns,nRxns);
        model.c' sparse(1,2*nRxns)];
    LPproblem2.c  = [zeros(nRxns,1);ones(2*nRxns,1)];
    LPproblem2.lb = [model.lb;zeros(2*nRxns,1)];
    LPproblem2.ub = [model.ub;Inf*ones(2*nRxns,1)];
    LPproblem2.b  = [LPproblem.b;zeros(2*nRxns,1);solution.obj];
    if ~isfield(model,'csense')
        % If csense is not declared in the model, assume that all
        % constraints are equalities.
        LPproblem2.csense(1:nMets) = 'E';
    else % if csense is in the model, move it to the lp problem structure
        if length(model.csense)~=nMets,
            warning('Length of csense is invalid! Defaulting to equality constraints.')
            LPproblem2.csense(1:nMets) = 'E';
        else
            LPproblem2.csense = columnVector(model.csense);
        end
    end
    LPproblem2.csense((nMets+1):(nMets+2*nRxns)) = 'G';
    
    % constrain the optimal value according to the original problem
    if LPproblem.osense==-1
        LPproblem2.csense(nMets+2*nRxns+1) = 'G';
    else
        LPproblem2.csense(nMets+2*nRxns+1) = 'L';
    end
    LPproblem2.csense = columnVector(LPproblem2.csense);
    LPproblem2.osense = 1;
    % Re-solve the problem
    if allowLoops
        solution = solveCobraLP(LPproblem2);
        solution.dual = []; % slacks and duals will not be valid for this computation.
        solution.rcost = [];
    else
        MILPproblem2 = addLoopLawConstraints(LPproblem, model, 1:nRxns);
        solution = solveCobraMILP(MILPproblem2);
    end
elseif strcmp(minNorm, 'zero')
    % Minimize the cardinality (zero-norm) of v
    %       min ||v||_0
    %           s.t.    S*v = b
    %                   c'v = f
    %                   lb <= v <= ub
    
    % Define the constraints structure
    constraint.A = [LPproblem.A ; LPproblem.c'];
    constraint.b = [LPproblem.b ; solution.obj];
    constraint.csense = [LPproblem.csense;'E'];    
    constraint.lb = LPproblem.lb;
    constraint.ub = LPproblem.ub;
    
    % Call the sparse LP solver
    solutionL0 = sparseLP(zeroNormApprox,constraint);
    
    %Store results
    solution.stat   = solutionL0.stat;
    solution.full   = solutionL0.x;
    solution.dual   = [];
    solution.rcost  = [];        
    
elseif length(minNorm)> 1 || minNorm > 0
    if nnz(LPproblem.c)>1
        error('Code assumes only one non-negative coefficient in linear part of objective');
    end
    % quadratic minimization of the norm.
    % set previous optimum as constraint.
    LPproblem.A = [LPproblem.A;
        (LPproblem.c'~=0 + 0)];%new constraint must be a row with a single unit entry
    LPproblem.csense(end+1) = 'E';
    
    LPproblem.b = [LPproblem.b;solution.full(LPproblem.c~=0)];
    LPproblem.c = zeros(size(LPproblem.c)); % no need for c anymore.
    %Minimise Euclidean norm using quadratic programming
    if length(minNorm)==1
        minNorm=ones(nRxns,1)*minNorm;
    end
    LPproblem.F = spdiags(minNorm,0,nRxns,nRxns);
    LPproblem.osense=1;
    
    if allowLoops
        %quadratic optimization will get rid of the loops unless you are maximizing a flux which is
        %part of a loop. By definition, exchange reactions are not part of these loops, more
        %properly called stoichiometrically balanced cycles.
        solution = solveCobraQP(LPproblem);
        
        if isfield(solution,'dual')
            if ~isempty(solution.dual)
                solution.dual=solution.dual(1:m,1);
            end
        end
    else
        %this is slow, but more useful than minimizing the Euclidean norm if one is trying to
        %maximize the flux through a reaction in a loop. e.g. in flux variablity analysis
        MIQPproblem = addLoopLawConstraints(LPproblem, model, 1:nRxns);
        solution = solveCobraMIQP(MIQPproblem);
    end
end

% Store results
if (solution.stat == 1)
    %solution found.
    FBAsolution.x = solution.full(1:nRxns);
    
    if isfield(solution,'dual')
        if ~isempty(solution.dual)
            solution.dual=solution.dual(1:m,1);
        end
    end
    
    %this line IS necessary.
    FBAsolution.f = model.c'*solution.full(1:nRxns); %objective from original optimization problem.
    if abs(FBAsolution.f - objective) > .01
        if strcmp(minNorm,'one')
            display('optimizeCbModel.m warning:  objective appears to have changed while minimizing taxicab norm');
        else
            error('optimizeCbModel.m: minimizing Euclidean norm did not work')
        end
    end
    
    %if (~primalOnlyFlag && allowLoops && any(~minNorm)) % LP rcost/dual only correct if not doing minNorm
    % LP rcost/dual are still meaninful if doing, one simply has to be aware that there is a
    % perturbation to them the magnitude of which depends on norm(minNorm) - Ronan   
    if (~primalOnlyFlag && allowLoops)
        FBAsolution.y = solution.dual;
        FBAsolution.w = solution.rcost;
    end
else
    %some sort of error occured.
    if printLevel>0
        warning('Optimal solution was not found');
    end
    FBAsolution.f = 0;
    FBAsolution.x = [];
end

FBAsolution.stat = solution.stat;
FBAsolution.origStat = solution.origStat;
FBAsolution.solver = solution.solver;
FBAsolution.time = etime(clock, t1);

