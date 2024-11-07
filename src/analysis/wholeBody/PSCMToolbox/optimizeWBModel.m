function solution = optimizeWBModel(model, param)
% Optimise whole body metabolic model
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
%                         * dxdt - `m x 1` change in concentration with time
%                         * csense - `m x 1` character array with entries in {L,E,G} 
%                           (The code is backward compatible with an m + k x 1 csense vector,
%                           where k is the number of coupling constraints)
%
%                         * C - `k x n` Left hand side of C*v <= d
%                         * d - `k x n` Right hand side of C*v <= d
%                         * dsense - `k x 1` character array with entries in {L,E,G}
%
% OPTIONAL INPUT:
%    param:      Additional parameters as a parameter struct
%                   All fields of the struct which are not COBRA parameters
%                   (see `getCobraSolverParamsOptionsForType`) for this
%                   problem type will be passed on to the solver in a
%                   solver specific manner.
%
%                   Some optional parameters which can be passed to the function
%                   as part of the options struct (DONE), or as parameter value
%                   pairs (TODO), or are listed below:
%
%    * osenseStr:         Maximize ('max')/minimize ('min') (opt, default =
%                         'max') linear part of the objective. Nonlinear
%                         parts of the objective are always assumed to be
%                         minimised.
%
%    * solverName:    Solver name {'tomlab_cplex','ibm_cplex','cplex_direct','mosek'}
%
%    * printLevel:    verbose level
%                      *   if `-1`, warnings are silenced.
%                      *   if  `0`, warnings only. (default)
%                      *   if  `1`, print from optimizeWBModel, optimizeCbModel, or both.
%                      *   if  `2`, also print from solveCobraLP, solveCobraQP, or both.
%                      *   if  `3`, also progress info from solver
%                      *   if  `4`, also detailed progress info from solver
%
%    * minNorm:       {(0), scalar , `n x 1` vector}, where `[m, n] = size(S)`;
%                   If not zero then, minimise the Euclidean length
%                   of the solution to the LP problem. minNorm ~1e-6 should be
%                   high enough for regularisation yet maintain the same value for
%                   the linear part of the objective. However, this should be
%                   checked on a case by case basis, by optimization with and
%                   without regularisation.
%
% OUTPUT:
%    solution:       solution object:
%
%                          * f - Objective value
%                          * v - Reaction rates (Optimal primal variable, legacy FBAsolution.x)
%                          * y - Dual for the molecular species
%                          * w - Reduced costs of the reactions
%                          * s - Slacks of the molecular species
%                          * stat - Solver status in standardized form:
%                            * `-1` - No solution reported (timelimit, numerical problem etc)
%                            *  `0` - Infeasible
%                            *  `1` - Optimal solution
%                            *  `2` - Unbounded solution
%                          * origStat - Original status returned by the specific solver
%                          * ctrs_y - the duals for the constraints from C
%                          * ctrs_slack - Slacks of the additional constraints


if ~exist('param','var')
    param = struct;
end

if ~isfield('param','minNorm')
    param.minNorm = 0;
end
if ~isfield('param','secondsTimeLimit')
    param.secondsTimeLimit = 100;
end
if isfield(model,'osenseStr')
    if ~any(strcmp(model.osenseStr,{'min','max'}))
        error('model.osenseStr can only be either min or max')
    end
else
    %this is in for backward compatibility only, use model.osenseStr
    %instead
    if isfield(model,'osense')
        if model.osense == 1
            model.osenseStr = 'min';
        elseif model.osense == -1
            model.osenseStr = 'max';
        else
            error('model.osense can only be either 1 or -1')
        end
    else
        %check in case there is no linear objective
        linearObjective = any(model.c);
        quadraticObjective = param.minNorm~=0;
        if linearObjective && quadraticObjective
            model.osenseStr = 'min';
        elseif linearObjective && ~quadraticObjective
            model.osenseStr = 'max';
        elseif ~linearObjective && quadraticObjective
            model.osenseStr = 'min';
        elseif ~linearObjective && ~quadraticObjective
            model.osenseStr = 'min';
        end
        warning(['optimizeWBModel: assuming model.osenseStr is ' model.osenseStr ', but this should be specified explicitly.'])
    end
end

if ~isfield(param,'verify')
    param.verify=0;
end

if ~isfield(param,'printLevel')
    param.printLevel = getCobraSolverParams('QP','printLevel',param);
end

if ~isfield(param,'solveWBMmethod')
    if param.minNorm~=0
        param.solveWBMmethod = 'QP';
    else
        param.solveWBMmethod = 'LP';
    end
end

validatedSolvers={'tomlab_cplex','ibm_cplex','cplex_direct', 'gurobi','cplex','mosek'};

[solverName, solverOK] = getCobraSolver('LP');
if ~any(strcmp(solverName,validatedSolvers))
    fprintf('%s\n','Note that the solvers validated for use with the PSCM toolbox are:')
    disp(validatedSolvers)
    [solverOK, solverInstalled] = changeCobraSolver('tomlab_cplex', 'LP',1,1);
    if ~solverOK
        error([solverName ' has not been validated for use with the PSCM toolbox. Tried to change to tomlab_cplex, but it failed.'])
    end
end

if 1
    %mlb = magnitude of a large bound
    % mlb = max([abs(model.lb);abs(model.ub)]); 
    mlb = 1000000; %original
else
    mlb = inf;
end

allowLoops = 1;

switch solverName
    case 'gurobi'
        % Model scaling
        %  	Type:	int
        %  	Default value:	-1
        %  	Minimum value:	-1
        %  	Maximum value:	3
        % Controls model scaling. By default, the rows and columns of the model are scaled in order to improve the numerical
        % properties of the constraint matrix. The scaling is removed before the final solution is returned. Scaling typically
        % reduces solution times, but it may lead to larger constraint violations in the original, unscaled model. Turning off
        % scaling (ScaleFlag=0) can sometimes produce smaller constraint violations. Choosing a different scaling option can
        % sometimes improve performance for particularly numerically difficult models. Using geometric mean scaling (ScaleFlag=2)
        % is especially well suited for models with a wide range of coefficients in the constraint matrix rows or columns.
        % Settings 1 and 3 are not as directly connected to any specific model characteristics, so experimentation with both
        % settings may be needed to assess performance impact.
        param.ScaleFlag=0;

    case 'ibm_cplex'
        % https://www.ibm.com/docs/en/icos/12.10.0?topic=infeasibility-coping-ill-conditioned-problem-handling-unscaled-infeasibilities
        param.minNorm = 0;

        % Decides how to scale the problem matrix.
        % Value  Meaning
        % -1	No scaling
        % 0	Equilibration scaling; default
        % 1	More aggressive scaling
        % https://www.ibm.com/docs/en/icos/12.10.0?topic=parameters-scale-parameter
        param.scaind = -1;

        % Emphasizes precision in numerically unstable or difficult problems.
        % This parameter lets you specify to CPLEX that it should emphasize precision in
        % numerically difficult or unstable problems, with consequent performance trade-offs in time and memory.
        % Value Meaning
        % 0   Do not emphasize numerical precision; default
        % 1	Exercise extreme caution in computation
        % https://www.ibm.com/docs/en/icos/12.10.0?topic=parameters-numerical-precision-emphasis
        param.emphasis_numerical=1;
    case 'mosek'
        param.MSK_DPAR_OPTIMIZER_MAX_TIME=param.secondsTimeLimit;
        param.MSK_IPAR_WRITE_DATA_PARAM='MSK_ON';
        param.MSK_IPAR_LOG_INTPNT=10;
        param.MSK_IPAR_LOG_PRESOLVE=10;

        % MSK_IPAR_INTPNT_SCALING
        % Controls how the problem is scaled before the interior-point optimizer is used.
        % Default
        % "FREE"
        % Accepted
        % "FREE", "NONE"
        % param..MSK_IPAR_INTPNT_SCALING = 'MSK_SCALING_FREE';
        param.MSK_IPAR_INTPNT_SCALING='MSK_SCALING_NONE';

        % MSK_IPAR_SIM_SCALING
        % Controls how much effort is used in scaling the problem before a simplex optimizer is used.
        % Default
        % "FREE"
        % Accepted
        % "FREE", "NONE"
        % Example
        % param.MSK_IPAR_SIM_SCALING = 'MSK_SCALING_FREE'
        param.MSK_IPAR_SIM_SCALING='MSK_SCALING_NONE';

        % MSK_IPAR_SIM_SCALING_METHOD
        % Controls how the problem is scaled before a simplex optimizer is used.
        % Default
        % "POW2"
        % Accepted
        % "POW2", "FREE"
        % Example
        % param.MSK_IPAR_SIM_SCALING_METHOD = 'MSK_SCALING_METHOD_POW2'
        % param.MSK_IPAR_SIM_SCALING_METHOD='MSK_SCALING_METHOD_FREE';
end


switch param.solveWBMmethod
    case 'LP'
        solution = optimizeCbModel(model, model.osenseStr, param.minNorm, allowLoops, param);

    case 'QP'
        solution = optimizeCbModel(model, model.osenseStr, param.minNorm, allowLoops, param);

    case 'QRLP'
        % param.solveWBMmethod = 'QRLP' passed to optimizeCbModel
        solution = optimizeCbModel(model, model.osenseStr, param.minNorm, allowLoops, param);

    case 'QRQP'
        % param.solveWBMmethod = 'QRLP' passed to optimizeCbModel
        solution = optimizeCbModel(model, model.osenseStr, param.minNorm, allowLoops, param);

    case 'QPold'
        %quadratic optimisation, proceeds in two steps

        %check in case there is no linear objective
        noLinearObjective = all(model.c==0);

        if noLinearObjective
            [tmp, solverOK] = getCobraSolver('QP');
            solverName{1,1} = tmp;
            solverName{1,2} = 'QP';
        else
            [solverName{1,1}, solverOK] = getCobraSolver('LP');
            solverName{1,2} = 'QP';
            [solverName{2,1}, solverOK] = getCobraSolver('QP');
            solverName{2,2} = 'QP';
        end

        for i = 1:size(solverName,1)
            if ~any(strcmp(solverName{i,1},validatedSolvers))
                fprintf('%s\n','Note that the solvers validated for use with the PSCM toolbox are:')
                disp(validatedSolvers)
                %switch over to a validated solver
                [solverOK, solverInstalled] = changeCobraSolver('tomlab_cplex', solverName{i,2},1,1);
                if solverOK
                    fprintf('%s\n',[solverName{i,1} ' has not been validated for use with the PSCM toolbox. Tried to change to tomlab_cplex, but it failed.'])
                else
                    error([solverName{i,1} ' has not been validated for use with the PSCM toolbox. Tried to change to tomlab_cplex, but it failed.'])
                end
            end
        end

        solution = optimizeCbModel(model, model.osenseStr, param.minNorm, allowLoops, param);

        if param.printLevel>0
            fprintf('%s%i\n','First solution.stat = ', solution.stat)
            fprintf('%s%i\n','First solution.origStat = ', solution.origStat)
            if param.printLevel>1 && any(contains(solverName(:,1),'cplex'))
                [ExitText,~] = cplexStatus(solution.origStat);
                fprintf('%s%s\n','First solution.origStatText = ', ExitText)
            end
        end

        %       1 (S,B) Optimal solution found
        %       2 (S,B) Model has an unbounded ray
        %       3 (S,B) Model has been proven infeasible
        %       4 (S,B) Model has been proven either infeasible or unbounded
        %       5 (S,B) Optimal solution is available, but with infeasibilities after unscaling
        %       6 (S,B) Solution is available, but not proven optimal, due to numeric difficulties

        % origStat == 5 means Optimal solution is available, but with infeasibilities after unscaling
        % origStat == 6 means Solution is available, but not proved optimal, due to numeric difficulties during optimization
        %if solution.stat~=0 && (solution.origStat == 5 || solution.origStat == 6)
        if solution.stat == 3 ||solution.stat == 1
            %rescale the problem and try to solve it again
            if 1
                if ~isempty(solution.v)
                    %rescale with help from previous solution
                    bigN=max(abs(solution.v));
                else
                    %rescale without any previous solution
                    bigN = 500000;
                end
                % all high flux values in the solution vector of the first QP retain a high bound
                model.lb(solution.v<-1e4) = -bigN;
                model.ub(solution.v>1e4)  =  bigN;
            end

            if 1
                % reduce the "infinity" bounds on all other reactions.
                % note this step does not affect any non-infinity bounds set on the
                % whole-body metabolic model
                model.lb(model.lb==-mlb)= -10000; % reduce the effective unbound constraints to lower number, representing inf
                model.ub(model.ub==mlb)=   10000;% reduce the effective unbound constraints to lower number, representing inf
            end

            if 1
                % we then rescale all bounds on the model reactions by a factor of 1/1000,
                % which proven to result in an optimal QP solution
                model.lb=model.lb/1000;
                model.ub=model.ub/1000;
            end

            solution = optimizeCbModel(model, model.osenseStr, param.minNorm, allowLoops,  param);


            % rescale the computed solution by the factor of 1000
            %  * f - Objective value
            %  * v - Reaction rates (Optimal primal variable, legacy FBAsolution.x)
            %  * y - Dual for the molecular species
            %  * w - Reduced costs of the reactions
            %  * s - Slacks of the molecular species
            %  * ctrs_y - the duals for the constraints from C
            %  * ctrs_slack - Slacks of the additional constraints

            % rescale the computed solution by the factor of 1000
            solution.f = solution.f*1000;
            solution.v = solution.v*1000;
            solution.y = solution.y*1000;
            solution.w = solution.w*1000;
            solution.s = solution.s*1000;
            if isfield(solution,'ctrs_y')
                solution.ctrs_y = solution.ctrs_y*1000;
            end
            if isfield(solution,'ctrs_slack')
                solution.ctrs_slack = solution.ctrs_slack*1000;
            end

            if param.printLevel>0
                fprintf('%s%i\n','Second solution.stat = ', solution.stat)
                fprintf('%s%i\n','Second solution.origStat = ', solution.origStat)
                if param.printLevel>1 && any(contains(solverName(:,1),'cplex'))
                    [ExitText,~] = cplexStatus(solution.origStat);
                    fprintf('%s%s\n','Second solution.origStatText = ', ExitText)
                end
            end
        else
            if 0
                %return NaN of correct dimensions if problem does not solve properly
                solution.f = NaN;
                solution.v = NaN*ones(size(model.S,2),1);
                solution.y = NaN*ones(size(model.S,1),1);
                solution.w = NaN*ones(size(model.S,2),1);
                solution.s = NaN*ones(size(model.S,1),1);
                if isfield(model,'C')
                    solution.ctrs_y = NaN*ones(size(model.C,1),1);
                    solution.ctrs_slack = NaN*ones(size(model.C,1),1);
                end
                if isfield(model,'E')
                    solution.vars_v = NaN*ones(size(model.E,2),1);
                    solution.vars_w = NaN*ones(size(model.E,2),1);
                end
            else
                %return empty fields if problem does not solve properly (backward
                %compatible)
                solution.f = NaN;
                solution.v = [];
                solution.y = [];
                solution.w = [];
                solution.s = [];
                if isfield(model,'C')
                    solution.ctrs_y = [];
                end
                if isfield(model,'E')
                    solution.vars_v = [];
                    solution.vars_w = [];
                end
            end
            solution.x = solution.v;
            if param.printLevel>1 && any(contains(solverName(:,1),'cplex'))
                [ExitText,~] = cplexStatus(solution.origStat);
                warning(['Second solution.origStatText = ', ExitText])
            end
        end
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
    if isfield(solution,'rcost')
        solution = rmfield(solution,'rcost');
    end
    if isfield(solution,'slack')
        solution = rmfield(solution,'slack');
    end
end

