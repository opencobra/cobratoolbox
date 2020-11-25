function solution = optimizeWBModel(model, param)
% Solves flux balance analysis problems, and variants thereof
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
%    * solverName:    Solver name {'tomlab_cplex','ibm_cplex','cplex_direct'}
%
%    * printLevel:    verbose level
%                      *   if `0`, warnings and errors are silenced. (default: 0)
%                      *   if `> 0`, warnings and errors are thrown.
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
        quadraticObjective = ~isempty(param.minNorm);
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

if exist('param','var')
    if isfield(param,'minNorm')
        if param.minNorm == 0
            param.minNorm = [];
        end
    else
        param.minNorm=[];
    end
    if ~isfield(param,'verify')
        param.verify=0;
    end
else
    param.minNorm=[];
    param.verify = 0;
end

validatedSolvers={'tomlab_cplex','ibm_cplex','cplex_direct'};

if 1
    %mlb = magnitude of a large bound
    mlb = 1000000; %original
else
    mlb = inf;
end

allowLoops =1;
zeroNormApprox = [];

if isempty(param.minNorm) %Linear optimisation
    
    [solverName, solverOK] = getCobraSolver('LP');
    if ~any(strcmp(solverName,validatedSolvers))
        fprintf('%s\n','Note that the solvers validated for use with the PSCM toolbox are:')
        disp(validatedSolvers)
        [solverOK, solverInstalled] = changeCobraSolver('tomlab_cplex', 'LP',1,1);
        if ~solverOK
            error([solverName ' has not been validated for use with the PSCM toolbox. Tried to change to tomlab_cplex, but it failed.'])
        end
    end
    
    solution = optimizeCbModel(model, model.osenseStr, param.minNorm, allowLoops, param);
elseif isnumeric(param.minNorm) %quadratic optimisation, proceeds in two steps
    
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
    
    param.printLevel = getCobraSolverParams('QP','printLevel',param);
    
    solution = optimizeCbModel(model, model.osenseStr, param.minNorm, allowLoops, zeroNormApprox, param);
    
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
    if solution.stat == 3
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
        
        solution = optimizeCbModel(model, model.osenseStr, param.minNorm, allowLoops, zeroNormApprox, param);
        
        
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

