fprintf('Checking gurobi solver ...\n')

params.OutputFlag = 0;

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
result = gurobi(qp,params);

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

QPproblem2.Q = sparse([1, 0, 0; 0, 1, 0; 0, 0, 1]); 
QPproblem2.modelsense = 'min';
QPproblem2.obj = -1*[0, 0, 0]';
QPproblem2.A = sparse([1, -1, -1 ; 0, 0, 1]);
QPproblem2.rhs = [0, 5]'; 
QPproblem2.lb = [0, -inf, 0]';
QPproblem2.ub = [inf, inf, inf]';
QPproblem2.sense = ['='; '='];

result = gurobi(QPproblem2,params);
result.objval
result.x

QPproblem3.Q = sparse([1, 0, 0; 0, 1, 0; 0, 0, 1]); 
QPproblem3.modelsense = 'min'; 
QPproblem3.obj = -1*[1, 1, 1]'; 
QPproblem3.A = sparse([1, -1, 0 ; 0, 1, -1]); 
QPproblem3.rhs = [0, 0]'; 
QPproblem3.lb = [0, 0, 0]';
QPproblem3.ub = [inf, inf, inf]';
QPproblem3.sense = ['='; '='];

result = gurobi(QPproblem3,params);
result.objval
result.x

QPproblem4.obj = [200; 400];
QPproblem4.A = sparse([1 / 40, 1 / 60; 1 / 50, 1 / 50]);
QPproblem4.b = [1; 1];
QPproblem4.lb = [0; 0];
QPproblem4.ub = [1; 1];
QPproblem4.modelsense = 'max';
QPproblem4.sense = ['<'; '<'];
QPproblem4.Q = sparse(2,2);

result = gurobi(QPproblem4,params);
result.objval
result.x

fprintf('Done.\n')

