function solution = optimizeCbModel(model, osenseStr, minNorm, allowLoops, zeroNormApprox, parameters)
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
% USAGE:
%
%    solution = optimizeCbModel(model, osenseStr, minNorm, allowLoops, zeroNormApprox)
%
% INPUT:
%    model:             (the following fields are required - others can be supplied)
%
%                         * S  - `m x n` Stoichiometric matrix
%                         * c  - `n x 1` Linear objective coefficients
%                         * lb - `n x 1` Lower bounds
%                         * ub - `n x 1` Upper bounds
%
% OPTIONAL INPUTS:
%    model:
%                         * b - `m x 1` change in concentration with time
%                         * csense - `m x 1` character array with entries in {L,E,G}
%                           (The code is backward compatible with an m + k x 1 csense vector,
%                           where k is the number of coupling constraints)
%
%                         * C - `k x n` Left hand side of C*v <= d
%                         * d - `k x n` Right hand side of C*v <= d
%                         * dsense - `k x 1` character array with entries in {L,E,G}
%                         * g - `n x 1` weights on zero or one norm
%
%    osenseStr:         Maximize ('max')/minimize ('min') (opt, default =
%                       'max') linear part of the objective. Nonlinear
%                       parts of the objective are always assumed to be
%                       minimised.
%
%    minNorm:           {(0), 'one', 'zero', > 0 , n x 1 vector}, where `[m,n]=size(S)`;
%                       0 - Default, normal LP
%                       'one'  Minimise the Taxicab Norm using LP.
%
%                       .. math::
%
%                          min  ~& d.*|v| \\
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
%                       `n` x 1   Forms the diagonal of positive definiate
%                       matrix `F` in the quadratic program
%
%                       .. math::
%
%                          min  ~& 0.5 v^T F v \\
%                          s.t. ~& S v = b \\
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
%    verify:     verify that the input fields are consistent (default: false);
%
%
% OUTPUT:
%    solution:       solution object:
%
%                          * f - Objective value
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
    %backward compatible with minNorm true/false
    if islogical(minNorm)
        if minNorm == true
            minNorm = 1e-6;
        else
            minNorm = 0;
        end
    end
    
    if isequal(minNorm,0)
        %replace minNorm = 0 with minNorm = [] to make a clear distinction
        minNorm = []; 
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

if ~exist('parameters','var')
    parameters = '';
end

%use global solver parameter, unless these these are specified in the input
[printLevel, primalOnlyFlag, verify] = getCobraSolverParams('LP',{'printLevel','primalOnly', 'verify'},parameters);

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

% build the optimization problem, after it has been actively requested to be verified
LPproblem = buildLPproblemFromModel(model,verify);
if strcmp(minNorm, 'oneInternal')
    SConsistentRxnBool=model.SConsistentRxnBool;
end

%weights on norm
if isfield(model,'g')  
    if length(model.g)~=nRxns
        error('model.g must be nRxns x 1')
    end
    normWeights=columnVector(model.g);
else
    normWeights=[];
end

if allowLoops
    clear model
end

% save the original size of the problem
[~,nTotalVars] = size(LPproblem.A);

%check in case there is no linear objective
noLinearObjective = all(LPproblem.c==0);

%%
t1 = clock;

if noLinearObjective && ~isempty(minNorm)
    %no need to solve an LP first
    objective = 0;
else
    if 0
        %debug
        solution=solveCobraLPCPLEX(LPproblem,1,0,0,[],0,'ILOGcomplex');
        solution.f=solution.obj;
        return
    end
    
    % Solve initial LP
    if allowLoops
        solution = solveCobraLP(LPproblem);
    else
        MILPproblem = addLoopLawConstraints(LPproblem, model, 1:nRxns);
        solution = solveCobraMILP(MILPproblem);
    end
    
    %save objective from LP
    objective = solution.obj;
    
    if strcmp(solution.solver,'mps')
        return;
    end
end

%only run if minNorm is not empty, and either there is no linear objective
%or there is a linear objective and the LP problem solved to optimality
if (noLinearObjective==1 && ~isempty(minNorm)) || (noLinearObjective==0 && solution.stat==1 && ~isempty(minNorm))
    if strcmp(minNorm, 'one')
        % Minimize the absolute value of fluxes to 'avoid' loopy solutions
        % Solve secondary LP to minimize one-norm of |v|
        % Set up the optimization problem
        % min sum(vf + vr)
        % 1: S*vf -S*vr = b
        % 3: vf >= -v
        % 4: vr >= v
        % 5: c'v >= f or c'v <= f (optimal value of objective)
        %
        % vf,vr >= 0
        
        LPproblem2.A = [LPproblem.A sparse(nMets+nCtrs,2*nRxns);
             speye(nRxns,nTotalVars) speye(nRxns,nRxns) sparse(nRxns,nRxns);
            -speye(nRxns,nTotalVars) sparse(nRxns,nRxns) speye(nRxns,nRxns);
            LPproblem.c' sparse(1,2*nRxns)];

        if ~isempty(normWeights)
            %weighted one norm
            LPproblem2.c  = [zeros(nTotalVars,1);[normWeights;normWeights].*ones(2*nRxns,1)];
        else
            LPproblem2.c  = [zeros(nTotalVars,1);ones(2*nRxns,1)];
        end
        LPproblem2.lb = [LPproblem.lb;zeros(2*nRxns,1)];
        LPproblem2.ub = [LPproblem.ub;Inf*ones(2*nRxns,1)];
        LPproblem2.b  = [LPproblem.b;zeros(2*nRxns,1);objective];
        
        %csense for 3 & 4 above
        LPproblem2.csense = [LPproblem.csense; repmat('G',2*nRxns,1)];
        % constrain the optimal value according to the original problem
        if LPproblem.osense==-1
            LPproblem2.csense = [LPproblem2.csense; 'G'];
            %LPproblem2.csense(nTotalVars+1) = 'G'; %wrong
        else
            LPproblem2.csense = [LPproblem2.csense; 'L'];
            %LPproblem2.csense(nTotalVars+1) = 'L';  %wrong
        end
        
        LPproblem2.osense = 1;
        % Re-solve the problem
        if allowLoops
            solution = solveCobraLP(LPproblem2);
        else
            MILPproblem2 = addLoopLawConstraints(LPproblem2, model, 1:nRxns);
            solution = solveCobraMILP(MILPproblem2);
        end
    elseif strcmp(minNorm, 'oneInternal')
        % Minimize the absolute value of internal fluxes to 'avoid' loopy solutions
        % Solve secondary LP to minimize one-norm of |v|
        % Set up the optimization problem
        % min sum(delta+ + delta-)
        % 1: S*v1 = b
        % 3: v1 - p + q = 0
        % 4: c'v1 >= f or c'v1 <= f (optimal value of objective)
        % 5: p,q >= 0
        
        nIntRxns=nnz(SConsistentRxnBool);
        A2 = sparse(nIntRxns,nTotalVars);
        A2(:,SConsistentRxnBool)=speye(nIntRxns,nIntRxns);
        LPproblem2.A = [...
                         LPproblem.A,                            sparse(nMets,2*nIntRxns);
                                  A2, -speye(nIntRxns,nIntRxns), speye(nIntRxns,nIntRxns);
                        LPproblem.c',                                sparse(1,2*nIntRxns)];
                            
        %only minimise the absolute value of internal reactions
        if ~isempty(normWeights)
            %only the weights on the internal reactions have an effect, the
            %rest are discarded
            normWeightsInt=normWeights(SConsistentRxnBool);
            %weighted one norm of internal reactions
            LPproblem2.c  = [zeros(nTotalVars,1);[normWeightsInt;normWeightsInt].*ones(2*nIntRxns,1)];
        else
            LPproblem2.c  = [zeros(nTotalVars,1);ones(2*nIntRxns,1)];
        end
        LPproblem2.lb = [LPproblem.lb;zeros(2*nIntRxns,1)];
        LPproblem2.ub = [LPproblem.ub;Inf*ones(2*nIntRxns,1)];
        LPproblem2.b  = [LPproblem.b;zeros(nIntRxns,1);objective];
        
        %csense for 3 above
        LPproblem2.csense = [LPproblem.csense; repmat('E',nIntRxns,1)];
        % constrain the optimal value according to the original problem
        if LPproblem.osense==-1
            LPproblem2.csense = [LPproblem2.csense; 'G'];
        else
            LPproblem2.csense = [LPproblem2.csense; 'L'];
        end
        %minimise absolute value of internal reaction fluxes
        LPproblem2.osense = 1;
        
        % Re-solve the problem
        solution = solveCobraLP(LPproblem2);
        
    elseif strcmp(minNorm, 'zero')
        % Minimize the cardinality (zero-norm) of v
        %       min ||v||_0
        %           s.t.    S*v = b
        %                   c'v = f
        %                   lb <= v <= ub
        
        % Define the constraints structure
        if noLinearObjective
            % Call the sparse LP solver
            solutionL0 = sparseLP(LPproblem, zeroNormApprox);
        else
            LPproblem2.A = [LPproblem.A ; LPproblem.c'];
            LPproblem2.b = [LPproblem.b ; objective];
            LPproblem2.csense = [LPproblem.csense;'E'];
            LPproblem2.lb = LPproblem.lb;
            LPproblem2.ub = LPproblem.ub;
            % Call the sparse LP solver
            solutionL0 = sparseLP(LPproblem2, zeroNormApprox);
        end

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
        
        %Minimise Euclidean norm using quadratic programming
        if isnumeric(minNorm)
            if length(minNorm)==nTotalVars && size(minNorm,1)~=size(minNorm,2)
                minNorm=columnVector(minNorm);
            elseif length(minNorm)==1
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
        if noLinearObjective
            LPproblem.F = spdiags(minNorm,0,nTotalVars,nTotalVars);
            if allowLoops
                %quadratic optimization will get rid of the loops unless you are maximizing a flux which is
                %part of a loop. By definition, exchange reactions are not part of these loops, more
                %properly called stoichiometrically balanced cycles.
                
                solution = solveCobraQP(LPproblem);
            else
                %this is slow, but more useful than minimizing the Euclidean norm if one is trying to
                %maximize the flux through a reaction in a loop. e.g. in flux variablity analysis
                MIQPproblem = addLoopLawConstraints(LPproblem, model, 1:nTotalVars);
                solution = solveCobraMIQP(MIQPproblem);
            end
        else
            % set previous optimum as constraint.
            LPproblem2 = LPproblem;
            LPproblem2.A = [LPproblem.A;LPproblem.c'];
            LPproblem2.b = [LPproblem.b;objective];
            LPproblem2.csense = [LPproblem.csense; 'E'];
            LPproblem2.F = spdiags(minNorm,0,nTotalVars,nTotalVars);
            LPproblem2.osense=1;
            if allowLoops
                %quadratic optimization will get rid of the loops unless you are maximizing a flux which is
                %part of a loop. By definition, exchange reactions are not part of these loops, more
                %properly called stoichiometrically balanced cycles.
                solution = solveCobraQP(LPproblem2);
            else
                %this is slow, but more useful than minimizing the Euclidean norm if one is trying to
                %maximize the flux through a reaction in a loop. e.g. in flux variablity analysis
                MIQPproblem = addLoopLawConstraints(LPproblem2, model, 1:nTotalVars);
                solution = solveCobraMIQP(MIQPproblem);
            end
        end
    end
end


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
            warning('Unbounded solution.');
        end
    case 3
        if printLevel>0
            warning('Solution exists, but either scaling problems or not proven to be optimal.');
        end
    otherwise
        solution.stat
        error('solution.stat must be in {-1, 0 , 1, 2, 3}')
end

% Return a solution or an almost optimal solution
if solution.stat == 1 || solution.stat == 3
    % solution found. Set corresponding values
    
    %the value of the linear part of the objective is always the optimal objective from the first LP
    solution.f = objective;
    
    %the value of the second part of the objective depends on the norm
    if strcmp(minNorm, 'zero')
        %zero norm
        zeroNormTol = 0; %TODO set based on sparseLP tolerance
        solution.f2 = sum(solution.full(1:nTotalVars,1) > zeroNormTol);
    elseif strcmp(minNorm, 'one')
        %one norm
        solution.f2 = sum(abs(solution.full(1:nTotalVars,1)));
    else
        if exist('LPproblem2','var')
            if isfield(LPproblem2,'F')
                %two norm
                solution.f2 = 0.5*solution.full'*LPproblem2.F*solution.full;
            end
        end
    end
    
    if ~isfield(solution,'full')
        pause(0.1);
    end
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
        solution.y = solution.dual;
        solution.w = solution.rcost;
        solution.s = solution.slack;
    end
    
    solution.time = etime(clock, t1);
    
    fieldOrder = {'f';'v';'y';'w';'s';'solver';'algorithm';'stat';'origStat';'time';'basis';'vars_v';'vars_w';'ctrs_y';'ctrs_s';'x';'full';'obj';'rcost';'dual';'slack'};
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
        solution.f = NaN;
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
    if isfield(solution,'obj')
        solution = rmfield(solution,'obj');
    end
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
