function o = logBarrierRound(problem)
%Input: a structure P with the following fields
%  .Aeq
%  .beq
%  .lb
%  .ub
% describing the polytope {Aeq x = beq, lb <= x <= ub}
%Output:
% o - problem structure

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

