function optProblem = buildOptProblemFromModel(model, verify, param)
% Builds an COBRA Toolbox LP,QP,RLP,or RQP problem structure from a COBRA Toolbox model structure.
%
% LP - linear optimisation
%.. math::
%
%    max/min  ~& c^T x + 0.5 x^T F x \\
%    s.t.     ~& [S, E; C, D] x <=> b ~~~~~~~~~~~:y \\
%             ~& lb \leq x \leq ub~~~~:w
%
% QRLP - quadratically regularised LP
%.. math::
%
%    max/min  ~& c^T x + 0.5 x^T F x \\
%    s.t.     ~& [S, E; C, D] x + r <=> b ~~~~~~~~~~~:y \\
%             ~& lb \leq x + u \leq ub~~~~:w
%
% QP - quadratic optimisation
%.. math::
%
%    max/min  ~& c^T x + 0.5 x^T F x \\
%    s.t.     ~& [S, E; C, D] x <=> b ~~~~~~~~~~~:y \\
%             ~& lb \leq x \leq ub~~~~:w
%
% QRLP - quadratically regularised QP
%.. math::
%
%    max/min  ~& c^T x + 0.5 x^T F x \\
%    s.t.     ~& [S, E; C, D] x + r <=> b ~~~~~~~~~~~:y \\
%             ~& lb \leq x + u \leq ub~~~~:w
%
% USAGE:
%
%    optProblem = buildoptProblemFromModel(model,verify)
%
% INPUT:
%    model:     A COBRA model structure with at least the following fields
%
%                * `.S` - The stoichiometric matrix
%                * `.c` - Objective coeff vector
%                * `.lb` - Lower bound vector
%                * `.ub` - Upper bound vector              
%
% OPTIONAL INPUTS:
%    model:       The model structure can also have these additional fields:
% 
%                  * `.b`: accumulation/depletion vector (default 0 for each metabolite).
%                  * `.osense`: Objective sense (-1 means maximise (default), 1 means minimise)
%                  * `.csense`: a string with the constraint sense for each row in A ('E', equality(default), 'G' greater than, 'L' less than).
%                  * `.C`: the Constraint matrix;
%                  * `.d`: the right hand side vector for C;
%                  * `.dsense`: the constraint sense vector;
%                  * `.E`: the additional Variable Matrix
%                  * `.evarub`: the upper bounds of the variables from E;
%                  * `.evarlb`: the lower bounds of the variables from E;
%                  * `.evarc`: the objective coefficients of the variables from E;
%                  * `.D`: The matrix coupling additional Constraints (form C), with additional Variables (from E);
%                 A QPproblem structure will also have the following field:
%                  * `.F`: Quadratic part of objective 
%                          (F*osense must be positive semidefinite, for all solvers except Gurobi)
%
%    verify:     Check the input (default: true);
%
% OUTPUT:
%    optProblem: A COBRA optProblem structure with the following fields:
%
%                * `.A`: LHS matrix
%                * `.b`: RHS vector
%                * `.c`: Objective coeff vector
%                * `.lb`: Lower bound vector
%                * `.ub`: Upper bound vector
%                * `.osense`: Objective sense (`-1`: maximise (default); `1`: minimise)
%                * `.csense`: string with the constraint sense for each row in A ('E', equality, 'G' greater than, 'L' less than).
%                * `.F`: Positive semidefinite matrix for quadratic part of objective
% OPTIONAL OUTPUT:


[nMet,nRxn]=size(model.S);

if ~exist('verify','var')
    verify = false;
end

if ~exist('param','var')
    param=struct;
end

if isfield(model,'C')
    modelC = 1;
else
    modelC = 0;
end

if isfield(model,'E')
    modelE = 1;
else
    modelE = 0;
end

if isfield(model,'csense')
    if size(model.csense,1)<size(model.csense,2)
        model.csense=model.csense';
    end
end

%backward compatibility with old formulation of coupling constraints

%Build some fields, if they don't exist
modelFields = fieldnames(model);
basicFields = {'b','csense','osenseStr'};
rowFields = {'C','d','dsense'};
columnFields = {'E','evarlb','evarub','evarc','D'};


basicFieldsToBuild = setdiff(basicFields,modelFields);
rowFieldsToBuild = setdiff(rowFields,modelFields);
columnFieldsToBuild = setdiff(columnFields,modelFields);

if length(unique([rowFieldsToBuild,rowFields])) == length(rowFields)
    rowFieldsToBuild = [];
end

if length(unique([columnFieldsToBuild,columnFields])) == length(columnFields)
    columnFieldsToBuild = [];
end

fieldsToBuild=[basicFieldsToBuild, rowFieldsToBuild, columnFieldsToBuild];

if ~isempty(fieldsToBuild)
    model = createEmptyFields(model,fieldsToBuild);
end

if verify    
    res = verifyModel(model,'FBAOnly',true);
    if ~isempty(fieldnames(res))
        error('The input model does have inconsistent fields! Use verifyModel(model) for further information.')
    end
    
    if isfield(model,'F')
        if size(model.F,1)~=size(model.F,2)
            error('model.F must be a square and positive definite matrix')
        end
    end
    
    if isfield(model,'dxdt')
        if length(model.dxdt)~=size(model.S,1)
            error('Number of rows in model.dxdt and model.S must match')
        end
    end
end

if isfield(model,'dxdt')
    model.b = model.dxdt; %Overwrite b
end

if ~isfield(model,'c')
    model.c = zeros(nRxn,1);
end


% case 'LP'
if ~modelC && ~modelE
    optProblem.A = model.S;
    optProblem.b = model.b;
    optProblem.ub = model.ub;
    optProblem.lb = model.lb;
    optProblem.csense = model.csense;
    optProblem.c = model.c;
else
    if modelC && ~modelE
        optProblem.A = [model.S;model.C];
        optProblem.b = [model.b;model.d];
        optProblem.ub = model.ub;
        optProblem.lb = model.lb;
        optProblem.csense = [model.csense;model.dsense];
        optProblem.c = model.c;
    elseif modelE && ~modelC
        optProblem.A = [model.S,model.E];
        optProblem.b = model.b;
        optProblem.ub = [model.ub;model.evarub];
        optProblem.lb = [model.lb;model.evarlb];
        optProblem.c = [model.c;model.evarc];
    else
        optProblem.A = [model.S,model.E;model.C,model.D];
        optProblem.b = [model.b;model.d];
        optProblem.csense = [model.csense;model.dsense];
        optProblem.ub = [model.ub;model.evarub];
        optProblem.lb = [model.lb;model.evarlb];
        optProblem.c = [model.c;model.evarc];
    end
end

if isfield(model,'F')
    if modelE
        optProblem.F = spdiags(zeros(size(optProblem.A,2),1),0,size(optProblem.A,2),size(optProblem.A,2));
        %assume that the remainder of the variables are not being quadratically
        %minimised
        optProblem.F(1:size(model.F,1),1:size(model.F,1)) = model.F;
    else
        optProblem.F = model.F;
    end
end

if isfield(param,'solveWBMmethod') && ~isempty(param.solveWBMmethod)
    switch param.solveWBMmethod
        case 'LP'
            %nothing to do - done above already
        case 'QP'
            %nothing to do - done above already
        case 'QRLP'
            [m,n]=size(optProblem.A);
            optProblem.A = [...
                %          v           r             p            z
                optProblem.A,  speye(m,m),  sparse(m,n), sparse(m,n);
                speye(n,n), sparse(n,m),  -speye(n,n), -speye(n,n)]; % x - p = z;

            optProblem.b  = [optProblem.b;sparse(n,1)];
            optProblem.lb = [-inf(2*n+m,1); model.lb];
            optProblem.ub = [ inf(2*n+m,1); model.ub];
            optProblem.csense = [optProblem.csense;repmat('E',n,1)];
            optProblem.c = [model.c; sparse(m+2*n,1)];
            optProblem.F = speye(size(optProblem.A,2),size(optProblem.A,2))*1e-16;%small amound of regularistion makes matrix positive definite numerically
            optProblem.F(n+1:2*n+m,n+1:2*n+m) = speye(n+m,n+m)*max(abs(model.c))*100; %regularisation must dominate linear objective
            %dimensions needed to extract non-regularised part of solution
            optProblem.m = m;
            optProblem.n = n;

            if 0 %use to test if regularisation enough
                F2 = optProblem.F;
                %This line modifies the diagonal elements of F2 by setting them to zero.
                F2(1:size(optProblem.F,1):end)=0;
                if all(all(F2)) == 0
                    %only nonzeros in QPproblem.F are on the diagonal
                    try
                        %try cholesky decomposition
                        B = chol(optProblem.F);
                    catch
                        optProblem.F = optProblem.F + diag((diag(optProblem.F)==0)*1e-16);
                    end
                    try
                        B = chol(optProblem.F);
                    catch
                        error('QPproblem.F only has non-zeros along the main diagnoal and is still not positive semidefinite after adding 1e-16')
                    end
                end
            end

        case 'QRQP'
            if modelE
                optProblem.F = spdiags(zeros(size(optProblem.A,2),1),0,size(optProblem.A,2),size(optProblem.A,2));
                %assume that the remainder of the variables are not being quadratically
                %minimised
                optProblem.F(1:size(model.F,1),1:size(model.F,1)) = model.F;
            else
                optProblem.F = model.F;
            end

            [m,n]=size(optProblem.A);
            optProblem.A = [...
                optProblem.A,  speye(m,m),  sparse(m,n), sparse(m,n); % A*x + r <=> b
                speye(n,n), sparse(n,m),  -speye(n,n), -speye(n,n)]; % x - p = z;

            optProblem.b  = [optProblem.b;sparse(n,1)];
            optProblem.lb = [-inf(2*n+m,1); model.lb]; % lb <= x - p       ----> lb <= z
            optProblem.ub = [ inf(2*n+m,1); model.ub]; %       x - p <= ub ---->       z <= ub
            optProblem.csense = model.csense;
            optProblem.c = [model.c; sparse(m+2*n,1)];
            optProblem.F = sparse(size(optProblem.A,2),size(optProblem.A,2));
            optProblem.F(1:n,1:n) = model.F;
            optProblem.F(n+1:2*n+m,n+1:2*n+m) = speye(n+m,n+m)*max(abs(model.c))*100;  %regularisation must dominate linear and quadratic objective
            %dimensions needed to extract non-regularised part of solution
            optProblem.m = m;
            optProblem.n = n;

        otherwise
            error('param.method unrecognised')
    end
end

[~,optProblem.osense] = getObjectiveSense(model);

if isfield(param,'debug') && param.debug
    switch param.solver
        case 'mosek'
            % names
            % This structure is used to store all the names of individual items in the optimization problem such as the constraints and the variables.
            %
            % Fields
            % name (string) – contains the problem name.
            %
            % obj (string) – contains the name of the objective.
            %
            % con (cell) – a cell array where names.con{i} contains the name of the
            % -th constraint.
            %
            % var (cell) – a cell array where names.var{j} contains the name of the
            % -th variable.
            optProblem.names.name='optimizeCbModel';
            if any(model.c~=0)
                optProblem.names.obj=model.rxns{model.c~=0};
            else
                optProblem.names.obj='noLP';
            end
            if isfield(model,'ctrs')
                optProblem.names.con=[model.mets;model.ctrs];
            else
                optProblem.names.con=model.mets;
            end
            if isfield(model,'evars')
                optProblem.names.var=[model.rxns;model.evars];
            else
                optProblem.names.var=model.rxns;
            end
    end
else
    optProblem.names=[];
end