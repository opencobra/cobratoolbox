function fullP = fullification(o)
% Convert a rounded equality-form polytope into full-dimensional inequality form
%
% Converts a polytope described by {Ax = b, lb <= x <= ub} into an equivalent
% full-dimensional polytope {Ax <= b} together with the affine map needed to
% recover samples in the original space
%
% USAGE:
%
%    fullP = fullification(o)
%
% INPUT:
%    o:        Structure with fields:
%
%                * .P - polytope struct {Ax = b, lb <= x <= ub} with fields
%                  .A, .b, .lb, .ub, .x
%                * .T - affine-transformation struct with fields .x0, .idx,
%                  .scale, mapping back to the original space by
%                  x0(idx) + scale .* samples
%
% OUTPUT:
%    fullP:    Structure describing {Ax <= b}, with fields:
%
%                * .A - inequality constraint matrix
%                * .b - inequality right-hand side
%                * .x - feasible interior point
%                * .N - null-space basis used to return to the original space
%                * .p_shift - shift used to return to the original space
%                * .x0 - offset of the original-space affine map
%                * .idx - indices of the recovered variables

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