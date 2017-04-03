function solution = sparseLP_cappedL1(constraint,params)
% DC programming for solving the sparse LP
% min   ||x||_0 subject to linear constraints
% The l0 norm is approximated by capped-l1 function.
% See "Le Thi et al., DC approximation approaches for sparse optimization,
% European Journal of Operational Research, 2014"
% http://dx.doi.org/10.1016/j.ejor.2014.11.031
%
% solution = sparseLP_cappedL1(constraint,params)
%
% INPUT
% constraint                Structure containing the following fields describing the linear constraints
%       A                   m x n LHS matrix
%       b                   m x 1 RHS vector
%       lb                  n x 1 Lower bound vector
%       ub                  n x 1 Upper bound vector
%       csense              m x 1 Constraint senses, a string containting the constraint sense for
%                           each row in A ('E', equality, 'G' greater than, 'L' less than).
%
% OPTIONAL INPUTS
% params                    parameters structure
%       nbMaxIteration      stopping criteria - number maximal of iteration (Defaut value = 1000)
%       epsilon             stopping criteria - (Defaut value = 10e-6)
%       theta               parameter of the approximation (Defaut value = 0.5)
%
% OUTPUT
% solution                  Structure containing the following fields
%       x                   n x 1 solution vector
%       stat                status
%                           1 =  Solution found
%                           2 =  Unbounded
%                           0 =  Infeasible
%                           -1=  Invalid input
% Hoai Minh Le	20/10/2015

stop = false;
solution.x = [];
solution.stat = 1;

% Check inputs
if nargin < 2
    params.nbMaxIteration = 1000;
    params.epsilon = 1e-6;
    params.theta   = 0.5;
else
    if isfield(params,'nbMaxIteration') == 0
        params.nbMaxIteration = 1000;
    end

    if isfield(params,'epsilon') == 0
        params.epsilon = 10e-6;
    end

    if isfield(params,'theta') == 0
        params.theta   = 0.5;
    end
    
        if isfield(params,'feasTol') == 0
        params.feasTol = 1e-9;
    end

    if isfield(params,'optTol') == 0
        params.optTol   = 1e-9;
    end
end

if isfield(constraint,'A') == 0
    error('Error:LHS matrix is not defined');
    solution.stat = -1;
    return;
end
if isfield(constraint,'b') == 0
    error('RHS vector is not defined');
    solution.stat = -1;
    return;
end
if isfield(constraint,'lb') == 0
    error('Lower bound vector is not defined');
    solution.stat = -1;
    return;
end
if isfield(constraint,'ub') == 0
    error('Upper bound vector is not defined');
    solution.stat = -1;
    return;
end
if isfield(constraint,'csense') == 0
    error('Constraint sense vector is not defined');
    solution.stat = -1;
    return;
end

[nbMaxIteration,epsilon,theta,optTol,feasTol] = deal(params.nbMaxIteration,params.epsilon,params.theta,params.optTol,params.feasTol);
[A,b,lb,ub,csense] = deal(constraint.A,constraint.b,constraint.lb,constraint.ub,constraint.csense);

%Parameters
nbIteration = 0;
[m,n] = size(A);

%Initialisation
x = zeros(n,1);
obj_old = sparseLP_cappedL1_obj(x,theta);

%Create the linear sub-programme that one needs to solve at each iteration, only its
%objective function changes, the constraints set remains.

% Define objective - variable (x,t)
obj = [zeros(n,1);theta*ones(n,1)];

% Constraints
% Ax <=b
% t >= x
% t >= -x
A2 = [A         sparse(m,n);
      speye(n)  -speye(n);
      -speye(n) -speye(n)];
b2 = [b; zeros(2*n,1)];
csense2 = [csense;repmat('L',2*n, 1)];

% Bound;
% lb <= x <= ub
% 0  <= t <= max(|lb|,|ub|)
lb2 = [lb;zeros(n,1)];
ub2 = [ub;max(abs(lb),abs(ub))];

%Define the linear sub-problem
subLPproblem = struct('c',obj,'osense',1,'A',A2,'csense',csense2,'b',b2,'lb',lb2,'ub',ub2);

%DCA
while nbIteration < nbMaxIteration && stop ~= true,

    x_old = x;

    %Compute x_bar in subgradient of second DC component
    x(abs(x) < 1/theta) = 0;
    x_bar = sign(x)*theta;

    %Solve the linear sub-program to obtain new x
    [x,LPsolution] = sparseLP_cappedL1_solveSubProblem(subLPproblem,x_bar,theta,optTol,feasTol);

    switch LPsolution.stat
        case 0
            solution.x = [];
            solution.stat = 0;
            error('Problem infeasible !');
        case 2
            solution.x = [];
            solution.stat = 2;
            error('Problem unbounded !');
        case 1
            %Check stopping criterion
            error_x = norm(x - x_old);
            obj_new = sparseLP_cappedL1_obj(x,theta);
            error_obj = abs(obj_new - obj_old);
            if (error_x < epsilon) || (error_obj < epsilon)
                stop = true;
            else
                obj_old = obj_new;
            end
            % Automatically update the approximation parameter theta
            if theta < 1000
                theta = theta * 1.5;
            end
            nbIteration = nbIteration + 1;
%             disp(strcat('DCA - Iteration: ',num2str(nbIteration)));
%             disp(strcat('Obj:',num2str(obj_new)));
%             disp(strcat('Stopping criteria error: ',num2str(min(error_x,error_obj))));
%             disp('=================================');

    end
end
if solution.stat == 1
    solution.x = x;
end

end

%Solve the linear sub-program to obtain new x
function [x,LPsolution] = sparseLP_cappedL1_solveSubProblem(subLPproblem,x_bar,theta,optTol,feasTol)

    n = length(x_bar);

    % Change the objective - variable (x,t)
    subLPproblem.obj = [-x_bar;theta*ones(n,1)];

    %Solve the linear problem
    LPsolution = solveCobraLP(subLPproblem,'optTol',optTol,'feasTol',feasTol);

    if LPsolution.stat == 1
        x = LPsolution.full(1:n);
    else
        x = [];
    end

end

%Compute the objective function
function obj = sparseLP_cappedL1_obj(x,theta)
    n = length(x);
    obj = ones(n,1)'*min(ones(n,1),theta*abs(x));
end
