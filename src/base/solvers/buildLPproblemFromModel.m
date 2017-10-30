function LPproblem = buildLPproblemFromModel(model)
% Builds an COBRA Toolbox LP problem structure from a COBRA Toolbox model structure. 
%
% USAGE:
%
%    LPproblem = buildLPproblemFromModel(model)
%
% INPUT:
%    model:     A COBRA model structure with at least the following fields
%
%                     * .S - The stoichiometric matrix
%                     * .c - Objective coeff vector
%                     * .lb - Lower bound vector
%                     * .ub - Upper bound vector
%
% OPTIONAL INPUTS:
%    model:     The model structure can also have these additional fields:
%                     * .b the accumulation/depletion vector (default 0 for each metabolite).
%                     * .osense - Objective sense (-1 means maximise (default), 1 means minimise)
%                     * .csense - Constraint senses, a string containting the constraint sense for
%                       each row in A ('E', equality(default), 'G' greater than, 'L' less than).
%    
% OUTPUT:
%    LPproblem:       A COBRA LPproblem structure with the following
%                     fields:
%                     * .A - LHS matrix
%                     * .b - RHS vector
%                     * .c - Objective coeff vector
%                     * .lb - Lower bound vector
%                     * .ub - Upper bound vector
%                     * .osense - Objective sense (-1 means maximise (default), 1 means minimise)
%                     * .csense - Constraint senses, a string containting the constraint sense for
%                       each row in A ('E', equality, 'G' greater than, 'L' less than).



LPproblem.A = model.S;
LPproblem.ub = model.ub;
LPproblem.lb = model.lb;
LPproblem.c = model.c;

if isfield(model,'b')
    LPproblem.b = model.b;
else
    LPproblem.b = repmat(0,size(model.mets));
end

if isfield(model,'osense')
    LPproblem.osense = model.osense;
else
    LPproblem.osense = -1;
end

if isfield(model,'csense')
    LPproblem.csense = model.csense;
else
    LPproblem.csense = repmat('E',size(model.mets));
end
