function solution = optimizeCbModel(model, osenseStr, minNorm, allowLoops, param)
% Solves flux balance analysis problems, and variants thereof
%
% Solves LP problems of the form
%
% .. math::
%
%    max/min  ~& c^T v \\
%    s.t.     ~& S v = b ~~~~~~~~~~~:y \\
%             ~& C v \leq d~~~~~~~~:y \\
%             ~& lb \leq v \leq ub~~~~:w
%
% Optionally, it also solves a second cardinality optimisation problem
%
%    max/min  ~& g1.*|v|_1
%    s.t.     ~& S v = b ~~~~~~~~~~~:y \\
%             ~& C v \leq d~~~~~~~~:y \\
%             ~& lb \leq v \leq ub~~~~:w
%             ~& c^T*v == c^T*vStar
%
% Optionally, it also solves a second QP problem
%
%    max/min  ~& g2.*|v|_2 + 0.5 v^T*F*v\\
%    s.t.     ~& S v = b ~~~~~~~~~~~:y \\
%             ~& C v \leq d~~~~~~~~:y \\
%             ~& lb \leq v \leq ub~~~~:w
%             ~& c^T*v == c^T*vStar
%
% Optionally, it also solves a second cardinality optimisation problem
%
%    max/min  ~& g0.*|v|_0 + g1.*|v|_1
%    s.t.     ~& S v = b ~~~~~~~~~~~:y \\
%             ~& C v \leq d~~~~~~~~:y \\
%             ~& lb \leq v \leq ub~~~~:w
%             ~& c^T*v == c^T*vStar
%
% where vStar is the optimal solution to the first LP problem.
%
% USAGE:
%
%    solution = optimizeCbModel(model, osenseStr, minNorm, allowLoops, param)
%
% INPUT:
%    model:             (the following fields are required - others can be supplied)
%
%                         * S  - `m x n` Stoichiometric matrix
%                         * c  - `n x 1` Linear objective coefficients
%                         * lb - `n x 1` Lower bounds on net flux
%                         * ub - `n x 1` Upper bounds on net flux
%
% OPTIONAL INPUTS:
%    model:
%                         * b - `m x 1` change in concentration with time
%                         * csense - `m x 1` character array with entries in {L,E,G}
%                           (The code is backward compatible with an m + k x 1 csense vector,
%                           where k is the number of coupling constraints)
%                         * mets `m x 1` metabolite abbreviations
%
%                         * C - `k x n` Left hand side of C*v <= d
%                         * d - `k x 1` Right hand side of C*v <= d
%                         * ctrs `k x 1` Cell Array of Strings giving IDs of the coupling constraints
%                         * dsense - `k x 1` character array with entries in {L,E,G}
%
%                         * `.evars` : evars x 1  Column Cell Array of Strings	IDs of the additional variables
%                         * `.E`     : n x evars  The additional Variable Matrix
%                         * `.evarub`: evars x 1  The upper bounds of the variables from E;
%                         * `.evarlb`: evars x 1  The lower bounds of the variables from E;
%                         * `.evarc` : evars x 1  The objective coefficients of the variables from E;
%                         * `.D`     : k x evars  The matrix coupling additional Constraints (form C), with additional Variables (from E);
%
%                         * g0 - `n x 1` weights on zero norm, where positive is minimisation, negative is maximisation, zero is neither.
%                         * g1 - `n x 1` weights on one norm, where positive is minimisation, negative is maximisation, zero is neither.
%                         * g2 - `n x 1` weights on two norm
%
%    osenseStr:         Maximize ('max')/minimize ('min') (opt, default =
%                       'max') linear part of the objective. Nonlinear
%                       parts of the objective are always assumed to be
%                       minimised.
%
%    minNorm:           {(0), 'one', 'zero', > 0 , n x 1 vector, 'optimizeCardinality'}, where `[m,n]=size(S)`;
%                       0 - Default, normal LP
%                       'one'  Minimise the Taxicab Norm using LP.
%
%                       .. math::
%
%                          min  ~& g0.*|v| \\
%                          s.t. ~& S v = b \\
%                               ~& c^T v = f \\
%                               ~& lb \leq v \leq ub
%
%                       A LP solver is required.

%                       'zero' Minimize the cardinality (zero-norm) of v
%
%                       .. math::
%
%                          min  ~& d.*||v||_0 \\
%                          s.t. ~& S v = b \\
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
%                       'optimizeCardinality' as for 'zero' option but uses
%                       model.g0 - `n x 1` weights on zero norm, where positive is minimisation, negative is maximisation, zero is neither.
%
%                       The remaining options work only with a valid QP solver:
%
%                       > 0    Minimises the squared Euclidean Norm of internal fluxes.
%                       Typically 1e-6 works well.
%
%                       .. math::
%
%                          min  ~& 1/2 v'*v \\
%                          s.t. ~& S v = b \\
%                               ~& c^T v = f \\
%                               ~& lb \leq v \leq ub
%
%                       `n` x 1   Forms the diagonal of positive definite
%                       matrix `F` in the quadratic program
%
%                       .. math::
%
%                          min  ~& 0.5 v^T F v \\
%                          s.t. ~& S v = b \\
%                               ~& c^T v = f \\
%                               ~& lb \leq v \leq ub
%

%
%    allowLoops:        {0,(1)} If false, then instead of a conventional FBA,
%                       the solver will run an MILP version which does not allow
%                       loops in the final solution.  Default is true.
%                       Runs much slower when set to false.
%                       See `addLoopLawConstraints.m` to for more info.
%
%   param:              parameters structure passed directly to solver
%                       The following are some optional fields (amongst many others)
%   *.zeroNormApprox:    appoximation type of zero-norm (only available when minNorm='zero') (default = 'cappedL1')
%
%                          * 'cappedL1' : Capped-L1 norm
%                          * 'exp'      : Exponential function
%                          * 'log'      : Logarithmic function
%                          * 'SCAD'     : SCAD function
%                          * 'lp-'      : L_p norm with p<0
%                          * 'lp+'      : L_p norm with 0<p<1
%                          * 'all'      : try all approximations and return the best result
%
%   *.verify:     verify that the input fields are consistent (default: false);
%
% OUTPUT:
%    solution:       solution object:
%                          * obj - Primal objective value (sum of f0,f1,f2 terms, ignoring NaN)
%                          * f - Linear objective value (from LP problem)
%                          * f0 - Zero-norm objective value
%                          * f1 - Linear part of objective value (c'*v or ||v||_1)
%                          * f2 - Quadratic part of objective value
%                          * v - Reaction rates (Optimal primal variable, legacy FBAsolution.x)
%                          * y - Dual to the matrix inequality constraints (Shadow prices)
%                          * w - Dual to the box constraints (Reduced costs)
%                          * s - Slacks of the metabolites
%
%                          * stat - Solver status in standardized form:
%                               * 0 - Infeasible problem
%                               * 1 - Optimal solution
%                               * 2 - Unbounded solution
%                               * 3 - Almost optimal solution
%                               * -1 - Some other problem (timelimit, numerical problem etc)
%
%                          * origStat - Original status returned by the specific solver
%
%                    If the input model contains `C` the following fields are added to the solution:
%
%                          * ctrs_y - the duals for the constraints from C
%                          * ctrs_s - Slacks of the additional constraints
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
%       - Ronan Fleming         7/27/09  Return an error if any imputs are NaNp
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
%                                        global param.
%       - Ronan Fleming         14/09/11 Fixed bug in minNorm with negative
%                                        coefficient in objective
%       - Minh Le               11/02/16 Option to minimise the cardinality of
%                                        fluxes vector
%       - Stefania Magnusdottir 06/02/17 Replace LPproblem2 upper bound 10000 with Inf
%       - Ronan Fleming         13/06/17 Support for coupling C*v<=d
%       - Ronan Fleming         31/10/20 Support for optimizeCardinality.m
%
% NOTE:
%
%    `solution.stat` is either 1, 2, 3, 0 or -1, and is a translation from `solution.origStat`,
%    which is returned by each solver in a solver specific way. That is, not all solvers return
%    the same type of `solution.origStat` and because the cobra toolbox can use many solvers,
%    we need to return to the user of `optimizeCbModel.m` a standard representation, which is what
%    `solution.stat` is.
%
%    If `solution.stat = 1 or = 3`, then a solution is returned, otherwise no solution is returned
%    and the solution.f = NaN
%    This means that it is up to the person calling `optimizeCbModel` to adapt their code to the
%    case when no solution is returned, by checking the value of `solution.stat` first.

% Process arguments and set up problem


% Figure out linear objective sense
if exist('osenseStr', 'var')
    if isempty(osenseStr)
        model.osenseStr = 'max';
    else
        %second argument may be the parameter structure
        if isstruct(osenseStr)
            if exist('param','var')
                error('osenseStr is a structure and param structure is also present')
            else
                %second argument is be the parameter structure
                param = osenseStr;
                if isfield(param,'osenseStr') && ~isfield(model, 'osenseStr')
                    model.osenseStr = param.osenseStr;
                else
                    model.osenseStr = 'max';
                end
                if isfield(param,'minNorm')
                    minNorm=param.minNorm;
                else
                    minNorm=[];
                end
                if isfield(param,'allowLoops')
                    allowLoops=param.allowLoops;
                else
                    allowLoops=1;
                end
            end
        else
            % Handle osenseStr when it's a string (e.g., 'min' or 'max')
            model.osenseStr = osenseStr;
        end
    end
    % % override if osenseStr already in the model
    % if isfield(model, 'osenseStr')
    %     model.osenseStr = model.osenseStr;
    % else
    %     model.osenseStr = 'max';
    % end
end

if ~exist('param','var')
    param = struct;
end

if exist('minNorm', 'var')
    %backward compatible with minNorm true/false
    if islogical(minNorm)
        if minNorm == true
            minNorm = 1e-6;
        else
            minNorm = [];
        end
    end
    
    if isequal(minNorm,0)
        %replace minNorm = 0 with minNorm = [] to make a clear distinction
        minNorm = []; 
    end
    % if minNorm = 'zero' then check the parameter 'zeroNormApprox'
    if isequal(minNorm,'zero')
        if isfield(param,'zeroNormApprox')
            zeroNormApprox = param.zeroNormApprox;
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
            
%use global solver parameter, unless these these are specified in the input
[printLevel, primalOnlyFlag, verify,feasTol] = getCobraSolverParams('LP',{'printLevel','primalOnly', 'verify','feasTol'},param);

% size of the stoichiometric matrix
[nMets,nRxns] = size(model.S);

if isfield(model,'C')
    modelC = 1;
    nCtrs = size(model.C,1);
else
    modelC = 0;
    nCtrs = 0;
end

if isfield(model,'E')
    modelE = 1;
    nVars = size(model.E,2);
else
    modelE = 0;
    nVars = 0;
end


if ischar(minNorm)
    if strcmp(minNorm, 'oneInternal')
        SConsistentRxnBool=model.SConsistentRxnBool;
    end
end

if isfield(model,'g') && ~isfield(model,'cf')%in case it is a thermodynamic model
    if isfield(model,'g0') || isfield(model,'g1')
        warning('model.g ignored by optimizeCbModel. zero and one norm weights are separately specified in model.g0 and model.g1 respectively')
    else
        error('model.g no longer supported by optimizeCbModel. zero and one norm weights must be separately specified in model.g0 and model.g1 respectively')
    end
end

%weights on zero norm
if isfield(model,'g0')  
    if length(model.g0)~=nRxns
        error('model.g0 must be nRxns x 1')
    end
    zeroNormWeights=columnVector(model.g0);
    if size(zeroNormWeights,2)~=1
        error('model.g0 must be nRxns x 1')
    end
else
    zeroNormWeights=[];
end
    
%weights on one norm
if isfield(model,'g1')  
    if length(model.g1)~=nRxns
        error('model.g1 must be nRxns x 1')
    end
    oneNormWeights=columnVector(model.g1);
    if size(oneNormWeights,2)~=1
        error('model.g1 must be nRxns x 1')
    end
else
    oneNormWeights=[];
end

if ~isempty(zeroNormWeights)
    if all(zeroNormWeights==1) && ischar(minNorm)
        if strcmp('minNorm','optimizeCardinality') && ~isempty(oneNormWeights)
            %no need to use optimize cardinality if effectively only
            %minimisiation of one norm is being requested
            minNorm = 'one';
        end
    end
end

%weights on two norm
if isfield(model,'g2')  
    error('minimisation of two norm in combination with one and zero norm is not yet supported')
    if length(model.g2)~=nRxns
        error('model.g2 must be nRxns x 1')
    end
    twoNormWeights=columnVector(model.g2);
    if size(twoNormWeights,2)~=1
        error('model.g2 must be nRxns x 1')
    end
else
    twoNormWeights=[];
end

%by default, do linear optimisation unless not required
doLinearOptimisationFirst = 1;
%if there is no linear objective, do a QP
if all(model.c==0)
    doLinearOptimisationFirst = 0;
end

% if there is no linear objective and no quadratic objective, do an LP
if isempty(minNorm)
    doLinearOptimisationFirst = 1;
end

% If there is are linear and quadrative objectives but the bounds on the
% corresponding reaction are fixed, then there is no need to solve an LP
% first, so do a QP
if all( (model.lb == model.ub & model.c~=0) == (model.c~=0)) && ~isempty(minNorm)
    doLinearOptimisationFirst = 0;
end

% If this is a quadratically regularised LP, go straight to QP
% TODO This is a hack of the param.minNorm to direct solution to QRLP or QRQP
if isfield(param,'solveWBMmethod')
    if any(strcmp(param.solveWBMmethod,{'QP','QRLP','QRQP'}))%TODO  'QRLP','QRQP' need coded in
        model.c(:)=0;
        doLinearOptimisationFirst = 0;
        minNorm = param.minNorm;
    end
end


% build the optimization problem
optProblem = buildOptProblemFromModel(model,verify,param);
% save the original size of the problem
[~,nTotalVars] = size(optProblem.A); % nTotalVars needed even if optProblem not used for an LP



%%
t1 = clock;
if doLinearOptimisationFirst
    if allowLoops && ~strcmp(minNorm,'optimizeCardinality')
        clear model
    end

    if 0
        %debug
        solution=solveCobraLPCPLEX(optProblem,1,0,0,[],0,'ILOGcomplex');
        solution.f=solution.obj;
        return
    end

    % Solve initial LP
    if allowLoops
        paramLP = param;
        if isfield(paramLP,'minNorm')
            paramLP = rmfield(paramLP,'minNorm');
        end
        solution = solveCobraLP(optProblem, paramLP);
    else
        MILPproblem = addLoopLawConstraints(optProblem, model, 1:nRxns);
        solution = solveCobraMILP(MILPproblem);
    end

    %save objective from LP
    objectiveLP = solution.obj;

    if strcmp(solution.solver,'mps')
        return;
    end
else
    %no need to solve an LP first
    objectiveLP = [];
end

%only run if minNorm is not empty, and either there is no linear objective
%or there is a linear objective and the LP problem solved to optimality
if (doLinearOptimisationFirst==0 && ~isempty(minNorm)) || (doLinearOptimisationFirst==1 && solution.stat==1 && ~isempty(minNorm))

    if strcmp(minNorm, 'optimizeCardinality')
        % DC programming for solving the cardinality optimization problem
        % The `l0` norm is approximated by a capped-`l1` function.
        %
        % :math:`min c'(x, y, z) + lambda_0*k.||*x||_0 + lambda_1*||x||_1
        % .                      -  delta_0*d.||*y||_0 +  delta_1*||y||_1`
        % s.t. :math:`A*(x, y, z) <= b`
        % :math:`l <= (x,y,z) <= u`
        % :math:`x in R^p, y in R^q, z in R^r`
        %
        % USAGE:
        %
        %    solution = optimizeCardinality(problem, param)
        
        %      * .lambda0 - trade-off parameter on minimise `||x||_0`
        if isfield(model,'lambda0')
            optProblem.lambda0=model.lambda0;
        end
        %      * .lambda1 - trade-off parameter on minimise `||x||_1`
        if isfield(model,'lambda1')
            optProblem.lambda1=model.lambda1;
        end
        %      * .delta0 - trade-off parameter on maximise `||y||_0`
        if isfield(model,'delta0')
            optProblem.delta0=model.delta0;
        end
        %      * .delta1 - trade-off parameter on minimise `||y||_1
        if isfield(model,'delta1')
            optProblem.delta1=model.delta1;
        end
        
        if isfield(optProblem,'F')
            error('optimizeCardinality does not (yet) support minimisation of 2-norm')
        end
        
        if any(oneNormWeights<0)
            error('optimizeCardinality does not (yet) support maximisation of 1-norm')
        end
        
        %     * .p - size of vector `x` OR a `size(A,2) x 1` boolean indicating columns of A corresponding to x (min zero norm).
        optProblem.p = zeroNormWeights > 0;
        %     * .q - size of vector `y` OR a `size(A,2) x 1` boolean indicating columns of A corresponding to y (max zero norm).
        optProblem.q = zeroNormWeights < 0;
        %     * .r - size of vector `z` OR a `size(A,2) x 1`boolean indicating columns of A corresponding to z .
        optProblem.r = zeroNormWeights == 0;
        
        %    problem:     Structure containing the following fields describing the problem:
        %      * .k - `p x 1` OR a `size(A,2) x 1` strictly positive weight vector on minimise `||x||_0`
        if isempty(zeroNormWeights)
            error('optimizeCardinality expects weights on zero norm, but model.g0 is empty.')
        end
        k = zeroNormWeights;
        k(k<0)=0;
        optProblem.k = k;
        %      * .d - `q x 1` OR a `size(A,2) x 1` strictly positive weight vector on maximise `||y||_0`
        d = -zeroNormWeights;
        d(d<0)=0;
        optProblem.d = d;
        %      * .o `size(A,2) x 1` strictly positive weight vector on minimise `||[x;y;z]||_1`
        optProblem.o = oneNormWeights;
        
        %    param:      Parameters structure:
        %                   * .printLevel - greater than zero to recieve more output
        % The following use default values, unless they are provided in the
        % param structure
        %                   * .nbMaxIteration - stopping criteria - number maximal of iteration (Default value = 100)
        %                   * .epsilon - stopping criteria - (Default value = 1e-6)
        %                   * .theta - starting parameter of the approximation (Default value = 0.5)
        %                              For a sufficiently large parameter , the Capped-L1 approximate problem
        %                              and the original cardinality optimisation problem are have the same set of optimal solutions
        %                   * .thetaMultiplier - at each iteration: theta = theta*thetaMultiplier
        %                   * .eta - Smallest value considered non-zero (Default value feasTol*1000)
        
        if doLinearOptimisationFirst
            optProblem2 = optProblem;
            optProblem2.A = [optProblem.A ; optProblem.c'];
            optProblem2.b = [optProblem.b ; objectiveLP];
            optProblem2.csense = [optProblem.csense;'E'];
            optProblem2.lb = optProblem.lb;
            optProblem2.ub = optProblem.ub;
            solCard = optimizeCardinality(optProblem2, param);
        else
            % The following are assumed to be inherited correctly from
            % optProblem built above
            %     * .A - `s x size(A,2)` LHS matrix
            %     * .b - `s x 1` RHS vector
            %     * .lb - `size(A,2) x 1` Lower bound vector
            %     * .ub - `size(A,2) x 1` Upper bound vector
            %     * .c -  `size(A,2) x 1` linear objective function vector
            %     * .osense - Objective sense  for problem.c only (1 means minimise (default), -1 means maximise)
            %     * .csense - `s x 1` Constraint senses, a string containing the constraint sense for
            %                  each row in `A` ('E', equality, 'G' greater than, 'L' less than).
            solCard = optimizeCardinality(optProblem, param);
        end
        
        solution.stat   = solCard.stat;
        solution.full   = solCard.xyz;
        solution.dual   = [];
        solution.rcost  = [];
        solution.slack  = [];

    elseif strcmp(minNorm, 'zero')
        % Minimize the cardinality (zero-norm) of v
        %       min ||v||_0
        %           s.t.    S*v = b
        %                   c'v = f
        %                   lb <= v <= ub
        
        % Define the constraints structure
        if doLinearOptimisationFirst
            optProblem2.A = [optProblem.A ; optProblem.c'];
            optProblem2.b = [optProblem.b ; objectiveLP];
            optProblem2.csense = [optProblem.csense;'E'];
            optProblem2.lb = optProblem.lb;
            optProblem2.ub = optProblem.ub;
            % Call the sparse LP solver
            solutionL0 = sparseLP(optProblem2, zeroNormApprox);
        else
            % Call the sparse LP solver
            solutionL0 = sparseLP(optProblem, zeroNormApprox);
        end

        %Store results
        solution.stat   = solutionL0.stat;
        solution.full   = solutionL0.x;
        solution.dual   = [];
        solution.rcost  = [];
        solution.slack  = [];

    elseif strcmp(minNorm, 'one')
        % Optimize the absolute value of fluxes
        % Solve secondary LP to optimize weighted 1-norm of v
        % Weight provided by model.g1
        % Set up the optimization problem
        % min model.g1'*(vf + vr)
        % 1: S*vf -S*vr = b
        % 3: vf >= -v
        % 4: vr >= v
        % 5: c'v >= f or c'v <= f (optimal value of objectiveLP)
        %
        % vf,vr >= 0
        
        optProblem2.A = [optProblem.A sparse(nMets+nCtrs,2*nRxns);
             speye(nRxns,nTotalVars) speye(nRxns,nRxns) sparse(nRxns,nRxns);
            -speye(nRxns,nTotalVars) sparse(nRxns,nRxns) speye(nRxns,nRxns);
            optProblem.c' sparse(1,2*nRxns)];

        if ~isempty(oneNormWeights)
            %weighted one norm
            optProblem2.c  = [zeros(nTotalVars,1);[oneNormWeights;oneNormWeights].*ones(2*nRxns,1)];
        else
            optProblem2.c  = [zeros(nTotalVars,1);ones(2*nRxns,1)];
        end
        optProblem2.lb = [optProblem.lb;zeros(2*nRxns,1)];
        optProblem2.ub = [optProblem.ub;Inf*ones(2*nRxns,1)];
        if isempty(objectiveLP)
            objectiveLP = 0;
        end
        optProblem2.b  = [optProblem.b;zeros(2*nRxns,1);objectiveLP];
        
        %csense for 3 & 4 above
        optProblem2.csense = [optProblem.csense; repmat('G',2*nRxns,1)];
        % constrain the optimal value according to the original problem
        if optProblem.osense==-1
            optProblem2.csense = [optProblem2.csense; 'G'];
            %LPproblem2.csense(nTotalVars+1) = 'G'; %wrong
        else
            optProblem2.csense = [optProblem2.csense; 'L'];
            %LPproblem2.csense(nTotalVars+1) = 'L';  %wrong
        end
        
        optProblem2.osense = 1;
        % Re-solve the problem
        if allowLoops
            solution = solveCobraLP(optProblem2, param);
        else
            MILPproblem2 = addLoopLawConstraints(optProblem2, model, 1:nRxns);
            solution = solveCobraMILP(MILPproblem2);
        end
    elseif strcmp(minNorm, 'oneInternal')
        % Minimize the absolute value of internal fluxes to eliminate
        % thermodynamically infeasible solutions
        %  CycleFreeFlux: efficient removal of thermodynamically infeasible loops from flux distributions
        % Desouki et al Bioinformatics, Volume 31, Issue 13, 1 July 2015, Pages 2159–2165, https://doi.org/10.1093/bioinformatics/btv096
        %
        % Solve secondary LP to minimise weighted 1-norm of v
        % Set up the optimization problem
        % min model.g1'*(p + q)
        % 1: S*v1 = b
        % 3: v1 - p + q = 0
        % 4: c'v1 >= f or c'v1 <= f (optimal value of objectiveLP)
        % 5: p,q >= 0
        
        nIntRxns=nnz(SConsistentRxnBool);
        A2 = sparse(nIntRxns,nTotalVars);
        A2(:,SConsistentRxnBool)=speye(nIntRxns,nIntRxns);
        optProblem2.A = [...
                         optProblem.A,                            sparse(nMets,2*nIntRxns);
                                  A2, -speye(nIntRxns,nIntRxns), speye(nIntRxns,nIntRxns);
                        optProblem.c',                                sparse(1,2*nIntRxns)];
                            
        %only minimise the absolute value of internal reactions
        if ~isempty(oneNormWeights)
            %only the weights on the internal reactions have an effect, the
            %rest are discarded
            oneNormWeightsInt=oneNormWeights(SConsistentRxnBool);
            if any(oneNormWeightsInt<0)
                warning('minNorm = ''oneInternal'' may not eliminate thermodynamically infeasible fluxes if model.g1(SConsistentRxnBool) entries are negative')
            end
            %weighted one norm of internal reactions
            optProblem2.c  = [zeros(nTotalVars,1);[oneNormWeightsInt;oneNormWeightsInt].*ones(2*nIntRxns,1)];
        else
            optProblem2.c  = [zeros(nTotalVars,1);ones(2*nIntRxns,1)];
        end
        optProblem2.lb = [optProblem.lb;zeros(2*nIntRxns,1)];
        optProblem2.ub = [optProblem.ub;Inf*ones(2*nIntRxns,1)];
        optProblem2.b  = [optProblem.b;zeros(nIntRxns,1);objectiveLP];
        
        %csense for 3 above
        optProblem2.csense = [optProblem.csense; repmat('E',nIntRxns,1)];
        % constrain the optimal value according to the original problem
        if optProblem.osense==-1
            optProblem2.csense = [optProblem2.csense; 'G'];
        else
            optProblem2.csense = [optProblem2.csense; 'L'];
        end
        %minimise absolute value of internal reaction fluxes
        optProblem2.osense = 1;
        
        % Re-solve the problem
        solution = solveCobraLP(optProblem2, param);

    elseif strcmp(minNorm, 'QRLP')
        buildOptProblemFromModel_param = param;
        buildOptProblemFromModel_param.minNorm = param.minNormWBM;
        optProblem = buildOptProblemFromModel(model, 0, buildOptProblemFromModel_param);
        solutionQRLP = solveCobraQP(optProblem,param);

        solution.full     = solutionQRLP.full(1:optProblem.n);%       Full QP solution vector
        solution.rcost    = solutionQRLP.rcost(1:optProblem.n);%       Reduced costs, dual solution to :math:`lb <= x <= ub`
        solution.dual     = solutionQRLP.dual(1:optProblem.m);%        dual solution to :math:`A*x <=/=/>= b`
        solution.slack    = solutionQRLP.full(1:optProblem.m);%       slack variable such that :math:`A*x + s = b`
        solution.obj      = model.c'*solution.full;%         Objective value
        solution.solver   = solutionQRLP.solver;%      Solver used to solve QP problem
        solution.origStat = solutionQRLP.origStat;%    Original status returned by the specific solver
        solution.time     = solutionQRLP.time;%        Solve time in seconds
        solution.stat     = solutionQRLP.stat;%        Solver status in standardized form (see below)
        solution.r = solutionQRLP.full(optProblem.n+1:optProblem.m); % A*x + r <=> b
        solution.p = solutionQRLP.full(optProblem.n+optProblem.m+1:optProblem.n+optProblem.m+optProblem.n);
        solution.p(solution.p < feasTol) = 0; % lb + p <= x <= ub + q
        solution.q = solutionQRLP.full(optProblem.n+optProblem.m+1:optProblem.n+optProblem.m+optProblem.n); % lb + p <= x <= ub + q
        solution.q(solution.q > -feasTol) = 0; % lb + p <= x <= ub + q
        solution.q = -solution.q; % lb + p <= x <= ub + q

    elseif strcmp(minNorm, 'QRQP')
        minNorm = minNormWBM;
        optProblem = buildOptProblemFromModel(model, 0, param);
        solution = solveCobraQP(optProblem);

    elseif length(minNorm)> 1 || minNorm > 0
        %THIS SECTION BELOW ASSUMES WRONGLY THAT c HAVE ONLY ONE NONZERO SO I
        %REPLACED IT WITH A MORE GENERAL FORMULATION, WHICH IS ALSO ROBUST TO
        %THE CASE WHEN THE OPTIMAL OBJECIVE WAS ZERO - RONAN June 13th 2017
        %     if nnz(optProblem.c)>1
        %         error('Code assumes only one non-negative coefficient in linear
        %         part of objectiveLP');
        %     end
        %     % quadratic minimization of the norm.
        %     % set previous optimum as constraint.
        %     optProblem.A = [optProblem.A;
        %         (optProblem.c'~=0 + 0)];%new constraint must be a row with a single unit entry
        %     optProblem.csense(end+1) = 'E';
        %
        %     optProblem.b = [optProblem.b;solution.full(optProblem.c~=0)];
        
        %Minimise Euclidean norm using quadratic programming
        if isnumeric(minNorm)
            if length(minNorm)==nTotalVars && size(minNorm,1)~=size(minNorm,2)
                minNorm=columnVector(minNorm);
            elseif isscalar(minNorm)
                minNorm=ones(nTotalVars,1)*minNorm;
            else
                error(['minNorm has dimensions ' int2str(size(minNorm,1)) ' x ' int2str(size(minNorm,2)) ' but it can only of the form {(0), ''one'', ''zero'', > 0 , n x 1 vector}.'])
            end
        elseif ischar(minNorm) && length(minNorm)==4 && strcmp(minNorm,'1e-6')
            %handle the aberrant case when minNorm is provided as a string
            minNorm=1e-6;
            minNorm=ones(nTotalVars,1)*minNorm;
        else
            error(['minNorm has dimensions ' int2str(size(minNorm,1)) ' x ' int2str(size(minNorm,2)) ' but it can only of the form {(0), ''one'', ''zero'', > 0 , n x 1 vector}.'])
        end

        % quadratic minimization of the norm.
        if doLinearOptimisationFirst
            % set previous linear optimum as constraint.
            optProblem2 = optProblem;
            optProblem2.A = [optProblem.A;optProblem.c'];
            optProblem2.b = [optProblem.b;objectiveLP];
            optProblem2.csense = [optProblem.csense; 'E'];
            optProblem2.F = spdiags(minNorm,0,nTotalVars,nTotalVars);
            optProblem2.osense=1;
            if allowLoops
                %quadratic optimization will get rid of the loops unless you are maximizing a flux which is
                %part of a loop. By definition, exchange reactions are not part of these loops, more
                %properly called stoichiometrically balanced cycles.
                solution = solveCobraQP(optProblem2,param);
            else
                %this is slow, but more useful than minimizing the Euclidean norm if one is trying to
                %maximize the flux through a reaction in a loop. e.g. in flux variablity analysis
                MIQPproblem = addLoopLawConstraints(optProblem2, model, 1:nTotalVars);
                solution = solveCobraMIQP(MIQPproblem);
            end
        else
            optProblem.F = spdiags(minNorm,0,nTotalVars,nTotalVars);
            if allowLoops
                %quadratic optimization will get rid of the loops unless you are maximizing a flux which is
                %part of a loop. By definition, exchange reactions are not part of these loops, more
                %properly called stoichiometrically balanced cycles.

                solution = solveCobraQP(optProblem,param);
            else
                %this is slow, but more useful than minimizing the Euclidean norm if one is trying to
                %maximize the flux through a reaction in a loop. e.g. in flux variablity analysis
                MIQPproblem = addLoopLawConstraints(optProblem, model, 1:nTotalVars);
                solution = solveCobraMIQP(MIQPproblem);
            end
        end
    end
end

% %TODO fix this Hack in case param.minNorm is used again
% if ~isempty(param.solveWBMmethod)
%     param.minNorm = param.minNormWBM;
% end

%dummy parts of the solution
solution.f0 = NaN;
solution.f1 = NaN;
solution.f2 = NaN;

switch solution.stat
    case 1
        if printLevel>0
            fprintf('%s\n','Optimal solution found.')
        end
    case -1
        if printLevel>0
            warning('%s\n','No solution reported (timelimit, numerical problem etc).')
        end
    case 0
        if printLevel>0
            warning('Infeasible model.')
        end
    case 2
        if printLevel>0
            warning('Unbounded model.');
        end
    case 3
        if printLevel>0
            warning('Solution exists, but either scaling problems or not proven to be optimal.');
        end
    otherwise
        solution.stat
        error('solution.stat must be in {-1, 0 , 1, 2, 3}')
end

if ~isfield(solution,'dual') || isempty(solution.dual)
    primalOnlyFlag=1;
end

% Return a solution or an almost optimal solution
if solution.stat == 1 || solution.stat == 3 
    % solution found. Set corresponding values
    
    %the value of the linear part of the objective is always the optimal objective from the first LP
    if isempty(objectiveLP)
        solution.f = objectiveLP;
    else
        solution.f = optProblem.c'*solution.full(1:nTotalVars,1);
    end
        
    if isempty(minNorm)
        minNorm = 'empty';
    end
    if isnumeric(minNorm)
        minNorm = 'two';
    end
    %the value of the second part of the objective depends on the norm
    switch minNorm
        case 'empty'
            solution.f0 = NaN;
            solution.f1 = optProblem.c'*solution.full(1:nTotalVars,1);
            solution.f2 = NaN;
        case 'zero'
            %zero norm
            solution.f0 = sum(abs(solution.full(1:nTotalVars,1)) > feasTol);
            solution.f1 = NaN;
            solution.f2 = NaN;
        case 'one'
            solution.f0 = NaN;
            %one norm
            solution.f1 = sum(abs(solution.full(1:nTotalVars,1)));
            solution.f2 = NaN;
        case 'two'
            solution.f0 = NaN;
            if isfield(optProblem,'c')
                solution.f1 = optProblem.c'*solution.full(1:nTotalVars,1);
                if isfield(solution,'objLinear')
                    solution = rmfield(solution,'objLinear');
                end
            else
                solution.f1 = NaN;
            end
            if isfield(optProblem,'F')
                solution.f2 = 0.5*solution.full'*optProblem.F*solution.full;
            else
                disp(param)
                warning('optProblem.F missing')
            end
            if isfield(solution,'objQuadratic')
                solution.f2 = solution.objQuadratic;
                solution = rmfield(solution,'objQuadratic');
            end
        otherwise
            if exist('LPproblem2','var')
                if isfield(optProblem2,'F')
                    solution.f0 = NaN;
                    solution.f1 = optProblem.c'*solution.full(1:nTotalVars,1);
                    solution.f2 = 0.5*solution.full'*optProblem2.F*solution.full;
                end
            else
                solution.f0 = NaN;
                solution.f1 = NaN;
                solution.f2 = NaN;
            end
    end
    solution.obj = sum([solution.f0,solution.f1,solution.f2],'omitnan');
    
    %primal optimal variables
    solution.v = solution.full(1:nRxns);
    if modelE
        solution.vars_v = solution.full(nRxns+1:nRxns+nVars);
    else
        solution.vars_v = [];
    end
    %provided for backward compatibility
    solution.x = solution.v;
    
    % handle the duals, reducing them to fields in the model.
    if isfield(solution,'dual')
        if ~isempty(solution.dual)
            solution.y = solution.dual(1:nMets,1);
            if modelC
                solution.ctrs_y = solution.dual(nMets+1:nMets+nCtrs,1);
            end
        end
    end
    
    % handle reduced costs
    if isfield(solution,'rcost')
        if ~isempty(solution.rcost)
            solution.w=solution.rcost(1:nRxns,1);
            if modelE
                solution.vars_w = solution.rcost(nRxns+1:nRxns+nVars,1);
            end
        end
    end
    
    % handle slacks
    if isfield(solution,'slack')
        if ~isempty(solution.slack)
            solution.s=solution.slack(1:nMets,1);
            if modelC
                solution.ctrs_s = solution.slack(nMets+1:nMets+nCtrs,1);
            end
        end
    end
    
    %if (~primalOnlyFlag && allowLoops && any(~minNorm)) % LP rcost/dual only correct if not doing minNorm
    % LP rcost/dual are still meaninful if doing, one simply has to be aware that there is a
    % perturbation to them the magnitude of which depends on norm(minNorm) - Ronan
    if (~primalOnlyFlag && allowLoops)
        if ~isempty(solution.dual)
            solution.y = solution.dual(1:nMets,1);
        end
        if modelC
            solution.ctrs_y = solution.dual(nMets+1:nMets+nCtrs,1);
        end
        solution.w = solution.rcost;
        solution.s = solution.slack;
    end
    
    solution.time = etime(clock, t1);
    
    fieldOrder = {'f';'f0';'f1';'f2';'v';'y';'w';'s';'solver';'lpmethod';'qpmethod';'stat';'origStat';'time';'basis';'vars_v';'vars_w';'ctrs_y';'ctrs_s';'x';'full';'obj';'rcost';'dual';'slack'};
    % reorder fields for better readability
    currentfields = fieldnames(solution);
    presentfields = ismember(fieldOrder,currentfields);
    absentfields = ~ismember(currentfields,fieldOrder);
    solution = orderfields(solution,[currentfields(absentfields);fieldOrder(presentfields)]);
else
    if 0
        %return NaN of correct dimensions if problem does not solve properly
        solution.f = NaN;

        solution.v = NaN*ones(nRxns,1);
        solution.y = NaN*ones(nMets,1);
        solution.w = NaN*ones(nRxns,1);
        solution.s = NaN*ones(nMets,1);
        if modelC
            solution.ctrs_y = NaN*ones(nCtrs,1);
            solution.ctrs_s = NaN*ones(nCtrs,1);
        end
        if modelE
            solution.vars_v = NaN*ones(nVars,1);
            solution.vars_w = NaN*ones(nVars,1);
        end
    else
        %return empty fields if problem does not solve properly (backward
        %compatible)
        solution.obj = NaN;
        solution.f = NaN;
        solution.f0 = NaN;
        solution.f1 = NaN;
        solution.f2 = NaN;
        solution.v = [];
        solution.y = [];
        solution.w = [];
        solution.s = [];
        if modelC
            solution.ctrs_y = [];
            solution.ctrs_s = [];
        end
        if modelE
            solution.vars_v = [];
            solution.vars_w = [];
        end
    end
    solution.x = solution.v;
    solution.time = etime(clock, t1);
end

if 1 %this may not be very backward compatible
    %remove fields coming from solveCobraLP/QP but not part of the specification
    %of the output from optimizeCbModel
    if isfield(solution,'full')
        solution = rmfield(solution,'full');
    end
    if isfield(solution,'dual')
        solution = rmfield(solution,'dual');
    end
    if isfield(solution,'rcost')
        solution = rmfield(solution,'rcost');
    end
    if isfield(solution,'slack')
        solution = rmfield(solution,'slack');
    end
end
