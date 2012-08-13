function FBAsolution = optimizeCbModel(model,osenseStr, minNorm, allowLoops)
%optimizeCbModel Solve a flux balance analysis problem
%
% Solves LP problems of the form: max/min c'*v
%                                 subject to S*v = b
%                                            lb <= v <= ub
% FBAsolution = optimizeCbModel(model,osenseStr,minNormFlag)
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
% osenseStr      Maximize ('max')/minimize ('min') (opt, default = 'max')
%
% minNorm        {(0), 'one', > 0 , n x 1 vector}, where [m,n]=size(S);
%                0      Default, normal LP
%                'one'  Minimise the Taxicab Norm using LP.
%                                 min |v|
%                                   s.t. S*v = b
%                                        c'v = f
%                                        lb <= v <= ub
%                -----
%                The remaining options work only with a valid QP solver:
%                -----
%                > 0    Minimises the Euclidean Norm of internal fluxes.
%                       Typically 1e-6 works well.
%                                 min ||v||
%                                   s.t. S*v = b
%                                        c'v = f
%                                        lb <= v <= ub
%               n x 1   Forms the diagonal of positive definiate
%                       matrix F in the quadratic program
%                               min 0.5*v'*F*v
%                               st. S*v = b
%                                   c'*v = f
%                                   lb <= v <= ub
%
% allowLoops    {0,(1)} If true, then instead of a conventional FBA,
%               the solver will run an MILP version which does not allow
%               loops in the final solution.  Default is true.
%               Runs much slower when set to false.
%               See addLoopLawConstraints.m to for more info.
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
%

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
% Ronan Fleming         12/03/10 Minor changes to the internal handling of global parameters.
%% Process arguments and set up problem

if exist('osenseStr', 'var')
    if isempty(osenseStr)
        osenseStr = 'max';
    end
else
    osenseStr = 'max';
end

if exist('minNorm', 'var')
    if isempty(minNorm)
        minNorm = false;
        changeOK = changeCobraSolverParams('LP','minNorm',minNorm);
    else
        changeOK = changeCobraSolverParams('LP','minNorm',minNorm);
    end
else
    minNorm = false;
    changeOK = changeCobraSolverParams('LP','minNorm',minNorm);
end
if exist('allowLoops', 'var')
    if isempty(allowLoops)
        allowLoops = true;
    end
else
    allowLoops = true;
end

[minNorm, printLevel, primalOnlyFlag, saveInput] = getCobraSolverParams('LP',{'minNorm','printLevel','primalOnly','saveInput'});


% if exist('minNorm', 'var')
%     if isempty(minNorm)
%         minNorm = false;
%     end
% else
%     minNorm = false;
% end
% if exist('allowLoops', 'var')
%     if isempty(allowLoops)
%         allowLoops = true;
%     end
% else
%     allowLoops = true;
% end
% 
% 
% global CBT_LP_PARAMS
% if (exist('CBT_LP_PARAMS', 'var'))
%     if isfield(CBT_LP_PARAMS, 'objTol')
%         tol = CBT_LP_PARAMS.objTol;
%     else
%         tol = 1e-6;
%     end
%     if isfield(CBT_LP_PARAMS, 'primalOnly')
%         primalOnlyFlag = CBT_LP_PARAMS.primalOnly;
%     else
%         primalOnlyFlag = false;
%     end
%     if isfield(CBT_LP_PARAMS, 'printLevel')
%         printLevel = CBT_LP_PARAMS.printLevel;
%     else
%         printLevel = 0;
%     end
% else
%     tol = 1e-6;
%     primalOnlyFlag = false;
%     printLevel = 0;
% end

% Figure out objective sense
if strcmpi(osenseStr,'max')
    LPproblem.osense = -1;
else
    LPproblem.osense = +1;
end

% this is dangerous... if model does not have S, it should not be called in
% this function.
% if ~isfield(model,'S')
%     model.S=model.A;
% end

[nMets,nRxns] = size(model.S);

% add csense
%Doing this makes csense a double array.  Totally smart design move.
%LPproblem.csense = [];
if ~isfield(model,'csense')
    % If csense is not declared in the model, assume that all
    % constraints are equalities.
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
if (~isfield(model,'b'))
    LPproblem.b = zeros(size(model.S,1),1);
else
    LPproblem.b = model.b;
end

% Rest of the LP problem
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

objective = solution.obj; % save for later use.

if strcmp(minNorm, 'one')
    % Minimize the absolute value of fluxes to 'avoid' loopy solutions
    % Solve secondary LP to minimize one-norm of |v|
    % Set up the optimization problem
    % min sum(delta+ + delta-)
    % 1: S*v1 = 0
    % 3: delta+ >= -v1
    % 4: delta- >= v1
    % 5: c'v1 >= f (optimal value of objective)
    %
    % delta+,delta- >= 0
    LPproblem2.A = [model.S sparse(nMets,2*nRxns);
        speye(nRxns,nRxns) speye(nRxns,nRxns) sparse(nRxns,nRxns);
        -speye(nRxns,nRxns) sparse(nRxns,nRxns) speye(nRxns,nRxns);
        model.c' sparse(1,2*nRxns)];
    LPproblem2.c = [zeros(nRxns,1);ones(2*nRxns,1)];
    LPproblem2.lb = [model.lb;zeros(2*nRxns,1)];
    LPproblem2.ub = [model.ub;10000*ones(2*nRxns,1)];
    LPproblem2.b = [LPproblem.b;zeros(2*nRxns,1);solution.obj];
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
    LPproblem2.csense(nMets+2*nRxns+1) = 'G';
    LPproblem2.csense = columnVector(LPproblem2.csense);
    LPproblem2.osense = 1;
    % Re-solve the problem
    if allowLoops
        solution = solveCobraLP(LPproblem2); %,printLevel,minNorm);
        solution.dual = []; % slacks and duals will not be valid for this computation.
        solution.rcost = [];
    else
        MILPproblem2 = addLoopLawConstraints(LPproblem, model, 1:nRxns);
        solution = solveCobraMILP(MILPproblem2);
    end
elseif length(minNorm)> 1 || minNorm > 0
    % quadratic minimization of the norm.
    % set previous optimum as constraint.
    LPproblem.A = [LPproblem.A;
        LPproblem.c'];
    LPproblem.csense(end+1) = 'E';
    if nnz(LPproblem.c)>1
        error('Code assumes only one non-negative coefficient in linear part of objective');
    end
    LPproblem.b = [LPproblem.b;solution.full(LPproblem.c~=0)];
    LPproblem.c = zeros(size(LPproblem.c)); % no need for c anymore.
    %Minimise Euclidean norm using quadratic programming
    if length(minNorm)==1
        minNorm=ones(nRxns,1)*minNorm;
    end
    LPproblem.F = spdiags(minNorm,0,nRxns,nRxns);
    %quadratic optimization
    if allowLoops
        solution = solveCobraQP(LPproblem);
    else
        MIQPproblem = addLoopLawConstraints(LPproblem, model, 1:nRxns);
        solution = solveCobraMIQP(MIQPproblem);
    end
    %     if isempty(solution.full)
    %         % QP problem did not work.  This will return empty structure later.
    %     else
    %         %dont include dual variable to additional constraint
    %         %solution.dual=solution.dual(1:end-1,1);
    %     end
end

% Store results
if (solution.stat == 1)
    %solution found.
    FBAsolution.x = solution.full(1:nRxns);
    
    %this line IS necessary.
    FBAsolution.f = model.c'*solution.full(1:nRxns); %objective from original optimization problem.
    if abs(FBAsolution.f - objective) > .01
        display('warning:  objective appears to have changed while performing secondary optimization (minNorm)');
    end
    
    if (~primalOnlyFlag && allowLoops && any(~minNorm)) % rcost/dual only correct if not doing minNorm
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

