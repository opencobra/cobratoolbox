function V = LP3cvx(J, model)
% CVX implementation of LP-3 for input set J (see FASTCORE paper).
% Maximises the total flux through the reactions indexed by J.
%
% USAGE:
%
%    V = LP3cvx(J, model)
%
% INPUTS:
%    J:        indices of reactions whose summed flux is maximised
%    model:    COBRA model structure with fields:
%
%                * .S - `m x n` stoichiometric matrix
%                * .lb - `n x 1` lower flux bounds
%                * .ub - `n x 1` upper flux bounds
%
% OUTPUT:
%    V:        steady state flux vector returned by the CVX solve
%

n = size(model.S,2);

cvx_begin quiet

    variable v(n);

    maximize (ones(1,numel(J)) * v(J) );

    model.S*v==0;
    v>=model.lb;
    v<=model.ub;

cvx_end

V = v;
