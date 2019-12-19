function P = cube_ineq(dim)
    P = Problem;
    P.lb = -Inf*ones(dim,1);
    P.ub = Inf*ones(dim,1);
    P.Aineq = [speye(dim); -speye(dim)];
    P.bineq = [ones(dim,1); zeros(dim,1)];
end