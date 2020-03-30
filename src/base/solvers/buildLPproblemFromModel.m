function optProblem = buildoptProblemFromModel(model, verify)
% Builds an COBRA Toolbox LP/QP problem structure from a COBRA Toolbox model structure.
%
% 
%.. math::
%
%    max/min  ~& c^T x + 0.5 x^T F x \\
%    s.t.     ~& [S, E; C, D] x <=> b ~~~~~~~~~~~:y \\
%             ~& lb \leq x \leq ub~~~~:w
%
% USAGE:
%
%    optProblem = buildoptProblemFromModel(model)
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
%                  * `.F`: Quadratic part of objective (F*osense must be
%                  positive semidefinite)
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

if ~exist('verify','var')
    verify = false;
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

%add quadratic part
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

[~,optProblem.osense] = getObjectiveSense(model);
