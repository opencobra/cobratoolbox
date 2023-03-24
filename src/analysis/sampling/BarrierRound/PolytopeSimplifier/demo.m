configPolytopeSimplifier;

loadModular('Problem');
P = loadProblem('LPnetlib@"lpi_mondou2"');
A = sparse(P.Aeq); b = P.beq; c = P.c; lb = max(P.lb, -1e7); ub = min(P.ub, 1e7);
f = ConvexProgram.LinearProgram(A, b, c, lb, ub);
[x1, info1] = f.findInterior();
% it outputs NaN if the problem is infeasible.

P = loadProblem('LPnetlib@"lp_agg"');
A = sparse(P.Aeq); b = P.beq; c = P.c; lb = max(P.lb, -1e7); ub = min(P.ub, 1e7);
f = ConvexProgram.LinearProgram(A, b, c, lb, ub);
[x2, info2] = f.normalize();
z = f.export(x2);
% z is the solution in the original space