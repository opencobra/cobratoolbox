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
%                          * y - Dual for the metabolites
%                          * w - Reduced costs of the reactions
%                          * s - Slacks of the metabolites
%                          * stat - Solver status in standardized form:
%
%                            * `-1` - No solution reported (timelimit, numerical problem etc)
%                            * `1` - Optimal solution
%                            * `2` - Unbounded solution
%                            * `0` - Infeasible
%                          * origStat - Original status returned by the specific solver
%                    
%                    If the input model contains `C` the following fields are added to the solution:
%
%                          * ctrs_y - the duals for the constraints from C
%                          * ctrs_slack - Slacks of the additional constraints
%
%                    If the model contains the `E` field, the following fields are added to the solution:
%
%                          * vars_v - The optimal primal values of the variables
%                          * vars_w - The reduced costs of the additional variables from E 
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
        model.osenseStr = 'max';
    else
        model.osenseStr = osenseStr;
    end
else
    if isfield(model, 'osenseStr')
        model.osenseStr = model.osenseStr;
    else
        model.osenseStr = 'max';
    end
end
% Figure out objective sense

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

LPproblem = buildLPproblemFromModel(model);

%Double check that all inputs are valid:
if ~(verifyCobraProblem(LPproblem, [], [], false) == 1)
    warning('invalid problem');
    return;
end

if isfield(model,'C')
    nCtrs = size(model.C,1);
end

if isfield(model,'E')
    nVars = size(model.E,2);
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

[nTotalConstraints,nTotalVars] = size(LPproblem.A);

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
    
    LPproblem2.A = [LPproblem.A sparse(nMets,2*nRxns);
        speye(nRxns,nTotalVars) speye(nRxns,nRxns) sparse(nRxns,nRxns);
        -speye(nRxns,nTotalVars) sparse(nRxns,nRxns) speye(nRxns,nRxns);
        LPproblem.c' sparse(1,2*nRxns)];
    LPproblem2.c  = [zeros(nTotalVars,1);ones(2*nRxns,1)];
    LPproblem2.lb = [LPproblem.lb;zeros(2*nRxns,1)];
    LPproblem2.ub = [LPproblem.ub;Inf*ones(2*nRxns,1)];
    LPproblem2.b  = [LPproblem.b;zeros(2*nRxns,1);solution.obj];
    LPproblem2.csense = [LPproblem.csense; repmat('G',2*nRxns,1)];    

    % constrain the optimal value according to the original problem
    if LPproblem.osense==-1
        LPproblem2.csense(end+1) = 'G';
    else
        LPproblem2.csense(end+1) = 'L';
    end
    LPproblem2.osense = 1;
    % Re-solve the problem
    if allowLoops
        solution = solveCobraLP(LPproblem2);
        solution.dual = []; % slacks and duals will not be valid for this computation.
        solution.rcost = [];
    else
        MILPproblem2 = addLoopLawConstraints(LPproblem2, model, 1:nRxns);
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
    % solution found. Set corresponding values
    solution.x = solution.full(1:nRxns);
    solution.v = solution.x;
    % handle the objective, otherwise another objective value could be 
    % returned and we only want to return the value of the defined
    % model objective
    if isfield(model,'E')
        solution.vars_v = solution.full(nRxns+1:nRxns+nVars);        
        solution.f = model.c'*solution.v + model.evarc' * solution.vars_v; % We need to consider the 
    else
        solution.f = model.c'*solution.full(1:nRxns); %objective from original optimization problem.
    end
    % Check objective quality
    if abs(solution.f - objective) > .01
        if strcmp(minNorm,'one')
            display('optimizeCbModel.m warning:  objective appears to have changed while minimizing taxicab norm');
        else
            error('optimizeCbModel.m: minimizing Euclidean norm did not work')
        end
    end
    
    % handle the duals, reducing them to fields in the model.
    if isfield(solution,'dual')
        if ~isempty(solution.dual)
            if isfield(model,'C')
                solution.ctrs_y = solution.dual(nMets+1:nMets+nCtrs,1);
            end
            solution.dual=solution.dual(1:nMets,1);            
        end    
    end            
    
    % handle reduced costs 
    if isfield(solution,'rcost')
        if ~isempty(solution.rcost)
            if isfield(model,'E')
                solution.vars_w = solution.rcost(nRxns+1:nRxns+nVars,1);
            end
            solution.rcost=solution.rcost(1:nRxns,1);            
        end
    end     
    
    % handle slacks
    if isfield(solution,'slack')
        if ~isempty(solution.slack)
            if isfield(model,'C')
                solution.ctrs_s = solution.slack(nMets+1:nMets+nCtrs,1);
            end
            solution.slack=solution.slack(1:nMets,1);            
        end
    end     
    
    %if (~primalOnlyFlag && allowLoops && any(~minNorm)) % LP rcost/dual only correct if not doing minNorm
    % LP rcost/dual are still meaninful if doing, one simply has to be aware that there is a
    % perturbation to them the magnitude of which depends on norm(minNorm) - Ronan
    if (~primalOnlyFlag && allowLoops)
        solution.y = solution.dual;          
        solution.w = solution.rcost; 
        solution.s = solution.slack;
    end
    fieldOrder = {'full';'obj';'rcost';'dual';'slack';'solver';'algorithm';'stat';'origStat';'time';'basis';'vars_v';'vars_w';'ctrs_y';'ctrs_s';'f';'x';'v';'w';'y';'s'};
    % reorder fields for better readability
    currentfields = fieldnames(solution);
    presentfields = ismember(fieldOrder,currentfields);
    absentfields = ~ismember(currentfields,fieldOrder);
    solution = orderfields(solution,[currentfields(absentfields);fieldOrder(presentfields)]);
else
    %some sort of error occured.
    if printLevel>0
        warning('Optimal solution was not found');
    end
    solution.f = 0;
    solution.x = [];
    solution.v = solution.x;
end

solution.time = etime(clock, t1);





