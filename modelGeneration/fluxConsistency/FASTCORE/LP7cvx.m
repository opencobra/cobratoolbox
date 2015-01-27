function V = LP7cvx( J, model, epsilon )

n = size(model.S,2);
nj = numel(J);

cvx_begin quiet

  variable v(n);
  variable z(nj);
  
  maximize( ones(1,nj) * z );

  z>=0; z<=epsilon;
  
  v(J)>=z;

  model.S*v==0; v>=model.lb; v<=model.ub;

cvx_end

V = v; 
