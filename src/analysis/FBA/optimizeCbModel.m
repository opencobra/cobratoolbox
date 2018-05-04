function solution = optimizeCbModel(model, osenseStr, minNorm, allowLoops, zeroNormApprox)
% Solves a flux balance analysis problem
%
% Solves LP problems of the form
%
% .. math::
%
%    max/min  ~& c^T v \\
%    s.t.     ~& S v = dxdt ~~~~~~~~~~~:y \\
%             ~& C v \leq d~~~~~~~~:y \\
%             ~& lb \leq v \leq ub~~~~:w
%
% USAGE:
%
%    solution = optimizeCbModel(model, osenseStr, minNorm, allowLoops, zeroNormApprox)
%
% INPUT:
%    model:             (the following fields are required - others can be supplied)
%
%                         * S  - `m x 1` Stoichiometric matrix
%                         * c  - `n x 1` Linear objective coefficients
%                         * lb - `n x 1` Lower bounds
%                         * ub - `n x 1` Upper bounds
%
% OPTIONAL INPUTS:
%    model:             
%                         * dxdt - `m x 1` change in concentration with time
%                         * csense - `m x 1` character array with entries in {L,E,G} 
%                           (The code is backward compatible with an m + k x 1 csense vector,
%                           where k is the number of coupling constraints)
%
%                         * C - `k x n` Left hand side of C*v <= d
%                         * d - `k x n` Right hand side of C*v <= d
%                         * dsense - `k x 1` character array with entries in {L,E,G}
%
%    osenseStr:         Maximize ('max')/minimize ('min') (opt, default = 'max')
%    minNorm:           {(0), 'one', 'zero', > 0 , n x 1 vector}, where `[m,n]=size(S)`;
%                       0 - Default, normal LP
%                       'one'  Minimise the Taxicab Norm using LP.
%
%                       .. math::
%
%                          min  ~& |v| \\
%                          s.t. ~& S v = dxdt \\
%                               ~& c^T v = f \\
%                               ~& lb \leq v \leq ub
%
%                       A LP solver is required.
%                       'zero' Minimize the cardinality (zero-norm) of v
%
%                       .. math::
%
%                          min  ~& ||v||_0 \\
%                          s.t. ~& S v = dxdt \\
%                               ~& c^T v = f \\
%                               ~& lb \leq v \leq ub
%
%                       The zero-norm is approximated by a non-convex approximation
%                       Six approximations are available: capped-L1 norm, exponential function
%                       logarithmic function, SCAD function, L_p norm with p<0, L_p norm with 0<p<1
%                       Note : capped-L1, exponential and logarithmic function often give
%                       the best result in term of sparsity.
%
%                       .. See "Le Thi et al., DC approximation approaches for sparse optimization,
%                          European Journal of Operational Research, 2014"
%                          http://dx.doi.org/10.1016/j.ejor.2014.11.031
%                          A LP solver is required.
%
%                       The remaining options work only with a valid QP solver:
%
%                       > 0    Minimises the squared Euclidean Norm of internal fluxes.
%                       Typically 1e-6 works well.
%
%                       .. math::
%
%                          min  ~& 1/2 v'*v \\
%                          s.t. ~& S v = dxdt \\
%                               ~& c^T v = f \\
%                               ~& lb \leq v \leq ub
%
%                       `n` x 1   Forms the diagonal of positive definiate
%                       matrix `F` in the quadratic program
%
%                       .. math::
%
%                          min  ~& 0.5 v^T F v \\
%                          s.t. ~& S v = dxdt \\
%                               ~& c^T v = f \\
%                               ~& lb \leq v \leq ub
%
%    allowLoops:        {0,(1)} If false, then instead of a conventional FBA,
%                       the solver will run an MILP version which does not allow
%                       loops in the final solution.  Default is true.
%                       Runs much slower when set to false.
%                       See `addLoopLawConstraints.m` to for more info.
%
%    zeroNormApprox:    appoximation type of zero-norm (only available when minNorm='zero') (default = 'cappedL1')
%
%                          * 'cappedL1' : Capped-L1 norm
%                          * 'exp'      : Exponential function
%                          * 'log'      : Logarithmic function
%                          * 'SCAD'     : SCAD function
%                          * 'lp-'      : L_p norm with p<0
%                          * 'lp+'      : L_p norm with 0<p<1
%                          * 'all'      : try all approximations and return the best result
%
% OUTPUT:
%    solution:       solution object:
%
%                          * f - Objective value
%                          * v - Reaction rates (Optimal primal variable, legacy FBAsolution.x)
%                          * y - Dual
%                          * w - Reduced costs
%                          * s - Slacks
%                          * stat - Solver status in standardized form:
%
%                            * `-1` - No solution reported (timelimit, numerical problem etc)
%                            * `1` - Optimal solution
%                            * `2` - Unbounded solution
%                            * `0` - Infeasible
%                          * origStat - Original status returned by the specific solver
%
% .. Author:
%       - Markus Herrgard       9/16/03
%       - Ronan Fleming         4/25/09  Option to minimises the Euclidean Norm of internal
%                                        fluxes using 'cplex_direct' solver
%       - Ronan Fleming         7/27/09  Return an error if any imputs are NaN
%       - Ronan Fleming         10/24/09 Fixed 'E' for all equality constraints
%       - Jan Schellenberger             MILP option to remove flux around loops
%       - Ronan Fleming         12/07/09 Reworked minNorm parameter option to allow
%                                        the full range of approaches for getting
%                                        rid of net flux around loops.
%       - Jan Schellenberger    2/3/09   fixed bug with .f being set incorrectly
%                                        when minNorm was set.
%       - Nathan Lewis          12/2/10  Modified code to allow for inequality
%                                        constraints.
%       - Ronan Fleming         12/03/10 Minor changes to the internal handling of
%                                        global parameters.
%       - Ronan Fleming         14/09/11 Fixed bug in minNorm with negative
%                                        coefficient in objective
%       - Minh Le               11/02/16 Option to minimise the cardinality of
%                                        fluxes vector
%       - Stefania Magnusdottir 06/02/17 Replace LPproblem2 upper bound 10000 with Inf
%       - Ronan Fleming         13/06/17 Support for coupling C*v<=d
%
% NOTE:
%
%    `solution.stat` is either 1, 2, 0 or -1, and is a translation from `solution.origStat`,
%    which is returned by each solver in a solver specific way. That is, not all solvers return
%    the same type of `solution.origStat` and because the cobra toolbox can use many solvers,
%    we need to return to the user of `optimizeCbModel.m` a standard representation, which is what
%    `solution.stat` is.
%
%    When running `optimizeCbModel.m`, unless `solution.stat = 1`, then no solution is returned.
%    This means that it is up to the person calling `optimizeCbModel` to adapt their code to the
%    case when no solution is returned, by checking the value of `solution.stat` first.

if exist('osenseStr', 'var') % Process arguments and set up problem
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
elseif strcmpi(osenseStr,'min')
    LPproblem.osense = +1;
else
    error('%s is not a valid osenseStr. Use either ''min'' or ''max''' ,osenseStr);
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

% size of the stoichiometric matrix
[nMets,nRxns] = size(model.S);

%make sure C is present if d is present
if ~isfield(model,'C') && isfield(model,'d')
    error('For the constraints C*v <= d, both must be present')
end

if isfield(model,'C')
    [nIneq,nltC]=size(model.C);
    [nIneq2,nltd]=size(model.d);
    if nltC~=nRxns
        error('For the constraints C*v <= d the number of columns of S and C are inconsisent')
    end
    if nIneq~=nIneq2
        error('For the constraints C*v <= d, the number of rows of C and d are inconsisent')
    end
    if nltd~=1
        error('For the constraints C*v <= d, d must have only one column')
    end
else
    nIneq=0;
end

if ~isfield(model,'dxdt')
    if isfield(model,'b')
        %old style model
        if length(model.b)==nMets
            model.dxdt=model.b;
            %model=rmfield(model,'b'); %tempting to do this
        else
            if isfield(model,'C')
                %new style model, b must be rhs for [S;C]*v {=,<=,>=} [dxdt,d] == b
                if length(model.b)~=nMets+nIneq
                    error('model.b must equal the number of rows of [S;C]')
                end
            else
                error('model.b must equal the number of rows of S or [S;C]')
            end
        end
    else
        fprintf('%s\n','We assume that all mass balance constraints are equalities, i.e., S*v = 0')
        model.dxdt=zeros(nMets,1);
    end
else
    if length(model.dxdt)~=size(model.S,1)
        error('Number of rows in model.dxdt and model.S must match')
    end
end

%check the csense and make sure it is consistent
if isfield(model,'C')
    if ~isfield(model,'csense')
        if printLevel>1
            fprintf('%s\n','No defined csense.')
            fprintf('%s\n','We assume that all mass balance constraints are equalities, i.e., S*v = 0')
        end
        model.csense(1:nMets,1) = 'E';
    else
        if length(model.csense)==nMets
            model.csense = columnVector(model.csense);
        else
            if length(model.csense)==nMets+nIneq
                %this is a workaround, a model should not be like this
                model.dsense=model.csense(nMets+1:nMets+nIneq,1);
                model.csense=model.csense(1:m,1);
            else
                error('Length of csense is invalid!')
            end
        end
    end
    
    if ~isfield(model,'dsense')
        if printLevel>1
            fprintf('%s\n','No defined dsense.')
            fprintf('%s\n','We assume that all constraints C & d constraints are C*v <= d')
        end
        model.dsense(1:nIneq,1) = 'L';
    else
        if length(model.dsense)~=nIneq
            error('Length of dsense is invalid! Defaulting to equality constraints.')
        else
            model.dsense = columnVector(model.dsense);
        end
    end
else
    if ~isfield(model,'csense')
        % If csense is not declared in the model, assume that all constraints are equalities.
        if printLevel>1
            fprintf('%s\n','We assume that all mass balance constraints are equalities, i.e., S*v = dxdt = 0')
        end
        model.csense(1:nMets,1) = 'E';
    else % if csense is in the model, move it to the lp problem structure
        if length(model.csense)~=nMets
            error('The length of csense does not match the number of rows of model.S.')
            model.csense(1:nMets,1) = 'E';
        else
            model.csense = columnVector(model.csense);
        end
    end
end

%now build the equality and inequality constraint matrices
if isfield(model,'d')
    LPproblem.b = [model.dxdt;model.d];
else
    LPproblem.b = model.dxdt;
end

if isfield(model,'C')
    LPproblem.A = [model.S;model.C];
    %copy over the constraint sense also
    LPproblem.csense=[model.csense;model.dsense];
else
    %copy over the constraint sense also
    LPproblem.csense=model.csense;
    LPproblem.A = model.S;
end

%linear objective coefficient
LPproblem.c = model.c;

%box constraints
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
    solution=solution;
    return;
else
    if (solution.stat ~= 1) % check if initial solution was successful.
        if printLevel>0
            warning('Optimal solution was not found');
        end
        solution.f = 0;
        solution.x = [];
        solution.stat = solution.stat;
        solution.origStat = solution.origStat;
        solution.solver = solution.solver;
        solution.time = etime(clock, t1);
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
        if length(model.csense)~=nMets
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
    solutionL0 = sparseLP(constraint, zeroNormApprox);

    %Store results
    solution.stat   = solutionL0.stat;
    solution.full   = solutionL0.x;
    solution.dual   = [];
    solution.rcost  = [];

elseif length(minNorm)> 1 || minNorm > 0
    %THIS SECTION BELOW ASSUMES WRONGLY THAT c HAVE ONLY ONE NONZERO SO I
    %REPLACED IT WITH A MORE GENERAL FORMULATION, WHICH IS ALSO ROBUST TO
    %THE CASE WHEN THE OPTIMAL OBJECIVE WAS ZERO - RONAN June 13th 2017
%     if nnz(LPproblem.c)>1
%         error('Code assumes only one non-negative coefficient in linear
%         part of objective');
%     end
%     % quadratic minimization of the norm.
%     % set previous optimum as constraint.
%     LPproblem.A = [LPproblem.A;
%         (LPproblem.c'~=0 + 0)];%new constraint must be a row with a single unit entry
%     LPproblem.csense(end+1) = 'E';
%
%     LPproblem.b = [LPproblem.b;solution.full(LPproblem.c~=0)];

    % quadratic minimization of the norm.
    % set previous optimum as constraint.
    LPproblem.A = [LPproblem.A;LPproblem.c'];
    LPproblem.b = [LPproblem.b;LPproblem.c'*solution.full];
    LPproblem.csense(end+1) = 'E';

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
                solution.dual=solution.dual(1:size(LPproblem.A,1),1);
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
    solution.x = solution.full(1:nRxns);

    if isfield(solution,'dual')
        if ~isempty(solution.dual)
            solution.dual=solution.dual(1:size(LPproblem.A,1),1);
        end
    end

    %this line IS necessary.
    solution.f = model.c'*solution.full(1:nRxns); %objective from original optimization problem.
    if abs(solution.f - objective) > .01
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
        solution.y = solution.dual;
        solution.w = solution.rcost;
    end
else
    %some sort of error occured.
    if printLevel>0
        warning('Optimal solution was not found');
    end
    solution.f = 0;
    solution.x = [];
end

solution.stat = solution.stat;
solution.origStat = solution.origStat;
solution.solver = solution.solver;
solution.time = etime(clock, t1);
solution.v = solution.x;%eventually we should depreciate solution.x

%remove fields from solveCobraLP
%{
solution   = rmfield(solution,'obj');
solution   = rmfield(solution,'full');
solution   = rmfield(solution,'rcost');
solution   = rmfield(solution,'dual');
solution   = rmfield(solution,'slack');
%}
