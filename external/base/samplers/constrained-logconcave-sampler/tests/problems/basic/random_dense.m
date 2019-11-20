function P = random_dense(dim)
    P = Problem;
    facets = 5*dim;
    P.Aineq = zeros(facets, dim);
    for i=1:facets
        w = randn(1,dim);
        w = w/norm(w);
        P.Aineq(i,:) = w;
    end
    P.bineq = ones(facets,1);
end