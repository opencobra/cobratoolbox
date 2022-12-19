function sol = thermoQP(model,q,param)
% Compute an approximately thermodynamically feasible flux by minimising
% the Euclidean norm, weighted by the conductances provided in q.
%
% INPUT:
%    model:             (the following fields are required - others can be supplied)
%
%                         * S  - `m x 1` Stoichiometric matrix
%                         * c  - `n x 1` Linear objective coefficients
%                         * lb - `n x 1` Lower bounds
%                         * ub - `n x 1` Upper bounds
%
%    q:                   `n x 1` vector of reaction conductances
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
%
% OUTPUT:
%    sol:       sol object:
%
%                          * f - Objective value
%                          * v - Reaction rates (Optimal primal variable, legacy FBAsolution.x)
%                          * y - Dual
%                          * w - Reduced costs
%                          * s - Slacks (tbc)
%                          * stat - Solver status in standardized form:

% size of the stoichiometric matrix
[nMets,nRxns] = size(model.S);

if ~exist('param','var')
    param=struct();
end

if ~isfield(param,'param.printLevel')
    param.param.printLevel=0;
end

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
        if param.printLevel>1
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
                model.csense=model.csense(1:nMets,1);
            else
                error('Length of csense is invalid!')
            end
        end
    end
    
    if ~isfield(model,'dsense')
        if param.printLevel>1
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
        if param.printLevel>1
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
    QPproblem.b = [model.dxdt;model.d];
else
    QPproblem.b = model.dxdt;
end

if isfield(model,'C')
    QPproblem.A = [model.S;model.C];
    %copy over the constraint sense also
    QPproblem.csense=[model.csense;model.dsense];
else
    %copy over the constraint sense also
    QPproblem.csense=model.csense;
    QPproblem.A = model.S;
end

if ~isfield(model,'c')
    QPproblem.c=zeros(nRxn,1);
end
if ~isfield(model,'osenseStr')
    model.osense=-1;
else
    % Figure out objective sense
    if strcmpi(model.osenseStr,'max')
        model.osense = -1;
    elseif strcmpi(model.osenseStr,'min')
        model.osense = +1;
    else
        error('%s is not a valid osenseStr. Use either ''min'' or ''max''' ,osenseStr);
    end
end

if param.fbaOptimal
    %require the thermodynamically feasible solution to approximate the fba
    %objective
    FBAsol = optimizeCbModel(model, model.osenseStr, 0);
    if FBAsol.stat==1
        dxdt = model.b - model.S(:,~model.SConsistentRxnBool)*FBAsol.v(~model.SConsistentRxnBool);
    else
        FBAsol
        error('FBA model did not solve properly')
    end
else
    dxdt = model.b;
end

if ~exist('q','var')
    q=rand(nRxn,1);
end

QPproblem.c=model.c;
QPproblem.osense=model.osense;

QPproblem.lb=model.lb;
QPproblem.ub=model.ub;

if 0
    QPproblem.lb(model.SIntRxnBool)=-inf;
    QPproblem.ub(model.SIntRxnBool)=inf;
end

QPproblem.F = diag(1./q);

% OUTPUT:
%    QPsol:        Structure containing the following fields describing a QP sol
%
%                       * .full:        Full QP sol vector
%                       * .rcost:       Reduced costs, dual sol to :math:`lb <= x <= ub`
%                       * .dual:        dual sol to :math:`A*x <=/=/>= b`
%                       * .slack:       slack variable such that :math:`A*x + s = b`
%                       * .obj:         Objective value
%                       * .solver:      Solver used to solve QP problem
%                       * .origStat:    Original status returned by the specific solver
%                       * .time:        Solve time in seconds
%                       * .stat:        Solver status in standardized form (see below)
QPsol = solveCobraQP(QPproblem, 'param.printLevel',0);

%                          * f - Objective value
%                          * v - Reaction rates (Optimal primal variable, legacy FBAsolution.x)
%                          * y - Dual
%                          * w - Reduced costs
%                          * s - Slacks
%                          * stat - Solver status in standardized form:
sol.f=QPsol.obj;
sol.v=QPsol.full;
sol.y=QPsol.dual;
sol.w=QPsol.rcost;
sol.s=[];
sol.stat=QPsol.stat;
sol.origStat=QPsol.origStat;

end

