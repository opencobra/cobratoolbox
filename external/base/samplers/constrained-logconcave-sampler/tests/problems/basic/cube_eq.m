function P = cube_eq(dim)
    P = Problem;
    P.lb = zeros(2*dim,1);
    P.ub = Inf*ones(2*dim,1);
    P.Aeq = [speye(dim) speye(dim)];
    P.beq = ones(dim,1);
end