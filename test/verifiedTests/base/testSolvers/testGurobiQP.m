fprintf('Checking gurobi solver ...\n')

c = [3; -4];
b = [5; 0];
Q = sparse([8, 1; 1, 8]);
A = sparse([1, 1; -1, 1]);

% Build model
qp.Q = Q;
qp.obj = c;
qp.A = A;
qp.rhs = b;
qp.lb = [0, 0];
qp.ub = [inf, inf];
qp.modelsense = 'min';
qp.sense = ['<'; '<'];

% Solve
result = gurobi(qp);

% Get primal/dual values
x = result.x;
lam = result.pi;

% Check optimality conditions
disp("Check 2*Q*x + c - A'*lam = 0 (stationarity):");
disp(2*Q*x + c - A'*lam);
assert(norm(2*Q*x + c - A'*lam,inf)<1e-8)

disp('Check A*x - b <= 0 (primal feasibility):');
disp(A*x - b);
assert(all((A*x - b)<=0))

disp('Check x >= 0 (primal feasibility):');
disp(x);
assert(all(x>0))

disp('Check lam <= 0 (dual feasibility):');
disp(lam);
assert(all(lam<=0))

disp("Check lam'*(A*x - b) = 0 (complementarity):");
disp(lam'*(A*x - b))
assert(norm(lam'*(A*x - b),inf)<1e-8)

fprintf('Done.\n')