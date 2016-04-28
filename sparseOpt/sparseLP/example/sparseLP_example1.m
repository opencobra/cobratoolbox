% Example of using sparseLP solver on randomly created linear constraints
% Hoai Minh Le	07/01/2016
changeCobraSolver('gurobi6','all');

% Randomly create m linear constraints
n = 100;
m = 50;
x0 = rand(n,1);
constraint.A = rand(m,n);
constraint.b = constraint.A*x0;
constraint.lb = -1000*ones(n,1);
constraint.ub = 1000*ones(n,1);
constraint.csense = repmat('E', m, 1);    

    
%Define the parameters
params.nbMaxIteration = 100;    % stopping criteria
params.epsilon = 10e-6;         % stopping criteria
params.theta   = 2;             % parameter of l0 approximation  

% Call the solver
solution = sparseLP('cappedL1',constraint,params);
% solution = sparseLP('cappedL1',constraint);

% solution = sparseLP('exp',constraint,params);
% solution = sparseLP('log',constraint,params);
% solution = sparseLP('SCAD',constraint,params);
% solution = sparseLP('lp-',constraint,params);
% solution = sparseLP('lp+',constraint,params);

% Display results
display(strcat('Feasibily error =',num2str(norm(constraint.A * solution.x - constraint.b,2))));
display(strcat('|x|_0 = ',num2str(length(find(abs(solution.x)>10e-6)))));