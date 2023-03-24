function fullP = fullification(o)
%Input: a structure o with the following fields
%  .P: struct for a polytope with fields describing the polytope {Ax = b, lb <= x <= ub}
%        .A
%        .b
%        .lb
%        .ub
%        .x
%  .T: struct for affine transformation used to go back to original space by x0(idx) + scale.*samples
%        .x0
%        .idx
%        .scale
%
%Output: a structure fullP with the following fields, describing {Ax <= b}
%  .A
%  .b
%  .x
%  .N - used to go back to original space
%  .p_shift - used to go back to original space
%  .x0
%  .idx

Aeq = o.P.A;
%beq = o.P.b;
lb = o.P.lb;
ub = o.P.ub;
x = o.P.x;

fullP = struct;
N = null(full(Aeq));
fullP.A = [N; -N];
fullP.b = [ub-x; x-lb];
fullP.N = o.T.scale .* N;
fullP.p_shift = o.T.scale .* x;
fullP.x = zeros(size(fullP.A, 2), 1);
fullP.x0 = o.T.x0;
fullP.idx = o.T.idx;
end