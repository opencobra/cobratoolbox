
cvx_begin quiet
  variable v(n);
  variable w(n);
  
  minimize( sum(w(Penal)))

  v(Penal)>=-w(Penal); v(Penal)<=w(Penal);
  v(K)>=z;
  model.S*v==0; v>=model.lb; v<=model.ub;
cvx_end
