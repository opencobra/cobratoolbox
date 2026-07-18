% CVX code fragment for a weighted LP-8 style solve: minimise the summed
% absolute flux over the penalised reaction set (Penal) subject to the steady
% state constraint and flux bounds, while forcing the core set (K) above the
% threshold z. Expects n, Penal, K, z, and model to be defined in the workspace.
%
cvx_begin quiet
  variable v(n);
  variable w(n);

  minimize( sum(w(Penal)))

  v(Penal)>=-w(Penal); v(Penal)<=w(Penal);
  v(K)>=z;
  model.S*v==0; v>=model.lb; v<=model.ub;
cvx_end
