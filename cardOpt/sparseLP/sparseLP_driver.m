
changeCobraSolver('gurobi6','all');


%Load data
% n = 5;
% m = 5;
% constraint.A = diag(ones(m,1));
% constraint.b = ones(m,1);
% constraint.lb = [-2 -1 -1 -2 1]';
% constraint.ub = [-1 1 2 2 3]';
% constraint.csense = repmat('<', 5, 1);    

n = 100;
m = 50;
constraint.A = rand(m,n);
x0 = rand(n,1);
constraint.b = constraint.A*x0;
constraint.lb = -1000*ones(n,1);
constraint.ub = 1000*ones(n,1);
constraint.csense = repmat('E', m, 1);    

    
%Define the parameters
params.nbMaxIteration = 1000;
params.epsilon = 10e-6;
params.theta   = 2;    %parameter of l0 approximation  
params.p = 0.5;


% solution = sparseLP('exp',constraint,params);
% solution = sparseLP('cappedL1',constraint,params);
% solution = sparseLP('log',constraint,params);
% solution = sparseLP('SCAD',constraint,params);
% solution = sparseLP('lp-',constraint,params);
solution = sparseLP('lp+',constraint,params);

display(strcat('Feasibily error =',num2str(norm(constraint.A * solution.x - constraint.b,2))));
display(strcat('|x|_0 = ',num2str(length(find(abs(solution.x)>10e-6)))));