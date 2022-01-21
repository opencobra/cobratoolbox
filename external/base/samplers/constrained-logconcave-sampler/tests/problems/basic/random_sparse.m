function P = random_sparse(dim)
    facets = 5*dim;
    P = Problem;
    P.Aineq = zeros(facets,dim);
    k = 5;
    for i=1:facets
        coords = randperm(dim,k);
        coord_signs =  sign(randn(1,k));
        P.Aineq(i,coords) = coord_signs/sqrt(k);
    end
    P.lb = -sqrt(dim)*ones(dim,1);
    P.ub = +sqrt(dim)*ones(dim,1);
    P.bineq = ones(facets,1);
end