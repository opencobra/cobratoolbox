function P = brownian_motion(dim)
    e = ones(dim,1);
    P = Problem;
    P.Aeq = [spdiags([e -e], 0:1, dim-1, dim) spdiags(e, 0, dim-1, dim-1)];
    P.beq = zeros(dim-1,1);
    P.lb = -ones(2*dim-1,1);
    P.ub = ones(2*dim-1,1);
    P.lb(1:(dim-1)) = -5*sqrt(dim);
    P.ub(1:(dim-1)) = 5*sqrt(dim);
end