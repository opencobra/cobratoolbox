function o = logBarrierRound(problem)
% Round a polytope in log-barrier coordinates for sampling
%
% Normalizes and rounds the polytope {Aeq x = beq, lb <= x <= ub} using a
% log-barrier linear program and returns the rounded polytope together with the
% affine transformation needed to recover samples in the original space
%
% USAGE:
%
%    o = logBarrierRound(problem)
%
% INPUT:
%    problem:    Structure describing the polytope {Aeq x = beq, lb <= x <= ub},
%                with fields:
%
%                  * .Aeq - equality constraint matrix
%                  * .beq - equality right-hand side
%                  * .lb - lower bounds
%                  * .ub - upper bounds
%
% OUTPUT:
%    o:          Problem structure with fields:
%
%                  * .P - rounded polytope struct with feasible point (fields
%                    .A, .b, .lb, .ub, .x)
%                  * .T - affine transformation used to recover samples in the
%                    original space (fields .x0, .idx, .scale)

A = problem.Aeq; b = problem.beq; 
lb = problem.lb; ub = problem.ub;

f = ConvexProgram.LinearProgram(A, b, [], lb, ub);
f.normalize();
assert(f.feasible, 'The problem is not feasible.')

A = double(f.A);
b = double(f.b);
x = double(f.interior);
lb = double(f.barrier.lb);
ub = double(f.barrier.ub);

x0 = f.x0;
idx = f.idx;
scale = double(f.scale);

o = struct;
o.P = struct('A', A, 'b', b, 'lb', lb, 'ub', ub, 'x', x); % rounded polytope with feasible point x
o.T = struct('x0', x0, 'idx', idx, 'scale', scale); % used to recover sample in original space by x(idx) = x0(idx) + scale.*samples
end

