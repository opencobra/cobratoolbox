function LPproblem = buildLPproblemFromModel(model, verify)
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
%    LPproblem = buildLPproblemFromModel(model)
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
%                  * '.F': Positive semidefinite matrix for quadratic part of objective
%
%    verify:     Check the input (default: true);
%
% OUTPUT:
%    LPproblem: A COBRA LPproblem structure with the following fields:
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
    verify = true;
end

%backward compatibility with old formulation of coupling constraints

%Build some fields, if they don't exist

optionalFields = {'C','d','dsense','E','evarlb','evarub','evarc','D'};
basicFields = { 'b','csense','osenseStr'};
basicFieldsToBuild = setdiff(basicFields,fieldnames(model));
fieldsToBuild = setdiff(optionalFields,fieldnames(model));
if ~isempty(basicFieldsToBuild)
    model = createEmptyFields(model,basicFieldsToBuild );
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
end
    
if isfield(model,'dxdt')
    if length(model.dxdt)~=size(model.S,1)
        error('Number of rows in model.dxdt and model.S must match')
    end
    model.b = model.dxdt; %Overwrite b
end
% create empty fields if necessary
if ~isempty(fieldsToBuild)
    model = createEmptyFields(model,fieldsToBuild);
end

LPproblem.A = [model.S,model.E;model.C,model.D];

%add quadratic part
if isfield(model,'F')
    if size(model.F,1)~=size(LPproblem.A,2)
        LPproblem.F = spdiags(zeros(size(LPproblem.A,2),1),0,size(LPproblem.A,2),size(LPproblem.A,2));
        %assume that the remainder of the variables are not being quadratically
        %minimised
        LPproblem.F(1:size(model.F,1),1:size(model.F,1)) = model.F;
    end
end

LPproblem.ub = [model.ub;model.evarub];
LPproblem.lb = [model.lb;model.evarlb];
LPproblem.c = [model.c;model.evarc];
LPproblem.b = [model.b;model.d];
[~,LPproblem.osense] = getObjectiveSense(model);
LPproblem.csense = [model.csense;model.dsense];
