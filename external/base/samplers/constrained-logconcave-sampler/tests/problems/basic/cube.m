function P = cube(dim)
    P = Problem;
	P.lb = -0.5*ones(dim,1);
	P.ub = 0.5*ones(dim,1);
end