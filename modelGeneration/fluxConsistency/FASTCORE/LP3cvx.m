function V = LP3cvx( J, model )

n = size(model.S,2);

cvx_begin quiet
 
    variable v(n);
    
    maximize (ones(1,numel(J)) * v(J) );
    
    model.S*v==0;
    v>=model.lb;
    v<=model.ub;
    
cvx_end

V = v;
