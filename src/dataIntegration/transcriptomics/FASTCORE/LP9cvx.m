function V = LP9cvx( K, P, model, epsilon )
%
% V = LP9( K, P, model, epsilon )
%
% CPLEX implementation of LP-9 for input sets K, P (see FASTCORE paper)

% (c) Nikos Vlassis, Maria Pires Pacheco, Thomas Sauter, 2013
%     LCSB / LSRU, University of Luxembourg


scalingfactor = 1e3;

V = [];
if isempty(P) || isempty(K)
    return;
end

np = numel(P);
nk = numel(K);
n = size(model.S,2);


cvx_begin 

  variable v(n);
  variable z(np);
  
  minimize( ones(1,np) * z );

  z>=0;
  v(P)>=-z;
  v(P)<=z;
  
  v(K)>=epsilon*scalingfactor;

  model.S*v==0; 
  
  v>=model.lb*scalingfactor; 
  v<=model.ub*scalingfactor;

cvx_end

V = v;
