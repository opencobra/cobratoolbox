function [P,model] = chrrParseModel(model)
% CHRRPARSEMODEL Parse a COBRA model into the right format for the CHRR sampler
% 
% [P,model] = chrrParseModel(model);
% 
% We are trying to sample uniformly at random from the points v that satisfy:
%            Sv = b
%       lb <= v <= ub
% 
% INPUTS:
% model ... COBRA model structure with fields:
% .S ... The m x n stoichiometric matrix
% .lb ... n x 1 lower bounds on fluxes
% .ub ... n x 1 upper bounds on fluxes
% 
% OUTPUTS:
% P ... A structure with fields:
% .A_eq ... Equality constraint matrix (model.S)
% .b_eq ... Right hand side of equality constraints (model.b)
% .A ... Inequality constraint matrix ([I_n 0; 0 -I_n])
% .b ... Right hand side of inequality constraints ([lb; -ub])
% 
% October 2016, Ben Cousins and Hulda S. Haraldsdóttir
%
% --Moved objective function handling to preprocess function: Ben Cousins,
% November 2017

dim = length(model.lb);

P.A = [eye(dim); -eye(dim)];
P.b = [model.ub; -model.lb];

P.A_eq = model.S;
P.b_eq = model.b;


% if norm(model.c)>1e-6
% LP.A = P.A_eq;
% LP.b = P.b_eq;
% LP.csense = repmat('E',size(LP.b));
% LP.osense = -1;
% LP.lb = model.lb;
% LP.ub = model.ub;
% LP.c = model.c;
% 
% solution = solveCobraLP(LP);
% 
% if solution.stat==1
%     if any(model.c)
%         solution.obj
%         P.A_eq = [P.A_eq; model.c'];
%         P.b_eq = [P.b_eq; solution.obj];
%         P.A = [P.A; -model.c'];
%         P.b = [P.b; -solution.obj+1e-6*abs(solution.obj)*norm(model.c)];
%         model.S = 
%         model.c = 0*model.c;
%     end
% else
%     error('Did not find a good solution, exitFlag=%d\n', solution.stat);
% end
% end
end