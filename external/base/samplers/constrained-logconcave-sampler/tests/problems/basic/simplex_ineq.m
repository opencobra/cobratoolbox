function P = simplex_ineq(dim)
    P = Problem;
    P.Aineq = ones(1,dim); 
    P.bineq = 1;
    P.lb = zeros(dim,1);
end