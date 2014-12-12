function V = LP7cvx( J, model, epsilon )

nJ = numel(J);

cvx_begin quiet

  variable v(n);
  variable z(nJ);
  
  maximize( ones(1,nJ) * z );

  z>=0; z<=epsilon;
  
  v(J)>=z;

  model.S*v==0; v>=model.lb; v<=model.ub;

cvx_end

V = v;