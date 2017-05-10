function P = chrrParseModel(model)
% Parses a COBRA model into the right format for the CHRR sampler
%
% USAGE:
%
%    P = chrrParseModel(model);
%
% INPUTS:
%    model:      COBRA model structure with fields:
%
%                 * `.S` - The `m` x `n` stoichiometric matrix
%                 * `.lb` - `n` x 1 lower bounds on fluxes
%                 * `.ub` - `n` x 1 upper bounds on fluxes
%                 * `.c` - `n` x 1 linear objective
%
% OUTPUT:
%    P:          A structure with fields:
%
%                 * `.A_eq` - Equality constraint matrix (`model.S`)
%                 * `.b_eq` - Right hand side of equality constraints (`model.b`)
%                 * `.A` - Inequality constraint matrix ([`I_n` 0; 0 ``-I_n`])
%                 * `.b` - Right hand side of inequality constraints ([`lb`; ``-ub`])
%
% .. Authors: - Ben Cousins and Hulda S. Haraldsdóttir, October 2016
%
% We are trying to sample uniformly at random from the points `v` that satisfy:
%
%    * min   `c*v`
%    * s.t.  `Sv = b`
%    * `lb <= v <= ub`
dim = length(model.lb);

P.A = [eye(dim); -eye(dim)];
P.b = [model.ub; -model.lb];

P.A_eq = model.S;
P.b_eq = model.b;

LP.A = P.A_eq;
LP.b = P.b_eq;
LP.csense = repmat('E',size(LP.b));
LP.osense = 1;
LP.lb = model.lb;
LP.ub = model.ub;
LP.c = model.c;

solution = solveCobraLP(LP);

if solution.stat==1
    if any(model.c)
        P.A_eq = [P.A_eq; model.c'];
        P.b_eq = [P.b_eq; solution.obj];
    end
else
    error('Did not find a good solution, exitFlag=%d\n', solution.stat);
end
end
