function V = tmplp7cvx(J, model, epsilon)
% CVX implementation of LP-7 for input set J (see FASTCORE paper).
% Maximises the number of reactions in J that carry a flux of at least epsilon.
%
% USAGE:
%
%    V = tmplp7cvx(J, model, epsilon)
%
% INPUTS:
%    J:          indices of reactions to drive above the epsilon threshold
%    model:      COBRA model structure with fields:
%
%                  * .S - `m x n` stoichiometric matrix
%                  * .lb - `n x 1` lower flux bounds
%                  * .ub - `n x 1` upper flux bounds
%    epsilon:    smallest flux value that is considered nonzero
%
% OUTPUT:
%    V:          steady state flux vector returned by the CVX solve
%

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
