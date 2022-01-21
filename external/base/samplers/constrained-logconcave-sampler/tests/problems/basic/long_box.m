function P = long_box(dim)
    P = Problem;
    P.lb = -0.5*ones(dim,1);
    P.ub = 0.5*ones(dim,1);
    P.ub(1) = 1e6;
end