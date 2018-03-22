function solution = optimizeCardinality(problem, params)
% DC programming for solving the cardinality optimization problem
% The `l0` norm is approximated by capped-`l1` function.
% :math:`min c'(x, y, z) + lambda_0*||k.*x||_0 - delta_0*||d.*y||_0 
%            + lambda_1*||x||_1 + delta_1*||y||_1` 
% s.t. :math:`A*(x, y, z) <= b`
% :math:`l <= (x,y,z) <= u`
% :math:`x in R^p, y in R^q, z in R^r`
%
% USAGE:
%
%    solution = optimizeCardinality(problem, params)
%
% INPUT:
%    problem:     Structure containing the following fields describing the problem:
%
%                   * .p - size of vector `x`
%                   * .q - size of vector `y`
%                   * .r - size of vector `z`
%                   * .c - `(p+q+r) x 1` linear objective function vector
%                   * .lambda_0 - trade-off parameter of `||x||_0`
%                   * .delta_0 - trade-off parameter of `||y||_0`
%                   * .lambda_1 - trade-off parameter of `||x||_1`
%                   * .delta_1 - trade-off parameter of `||y||_1`
%                   * .k - `p x 1` strictly possitive weight vector of `x`
%                   * .d - `q x 1` strictly possitive weight vector of `y`
%                   * .A - `s x (p+q+r)` LHS matrix
%                   * .b - `s x 1` RHS vector
%                   * .csense - `s x 1` Constraint senses, a string containting the constraint sense for
%                     each row in `A` ('E', equality, 'G' greater than, 'L' less than).
%                   * .lb - `(p+q+r) x 1` Lower bound vector
%                   * .ub - ``(p+q+r) x 1` Upper bound vector
%
% OPTIONAL INPUTS:
%    params:      Parameters structure:
%
%                   * .nbMaxIteration - stopping criteria - number maximal of iteration (Default value = 1000)
%                   * .epsilon - stopping criteria - (Defautl value = 10e-6)
%                   * .theta - parameter of the approximation (Default value = 2)
%
% OUTPUT:
%    solution:    Structure containing the following fields:
%
%                   * .x - `p x 1` solution vector
%                   * .y - `q x 1` solution vector
%                   * .z - `r x 1` solution vector
%                   * .stat - status
%
%                     * 1 =  Solution found
%                     * 2 =  Unbounded
%                     * 0 =  Infeasible
%                     * -1=  Invalid input
%
% .. Author: - Hoai Minh Le, 07/03/2016

stop = false;
solution.x = [];
solution.y = [];
solution.z = [];
solution.stat = 1;

%% Check inputs
if ~exist('params','var') || isempty(params)
    params.nbMaxIteration = 1000;
    params.epsilon = getCobraSolverParams('LP', 'feasTol');
    params.theta   = 2;
end
if ~isfield(params,'nbMaxIteration')
    params.nbMaxIteration = 1000;
end
if ~isfield(params,'epsilon')
    params.epsilon = getCobraSolverParams('LP', 'feasTol');
end
if ~isfield(params,'theta')
    params.theta   = 2;
end
if ~isfield(params,'nbMaxIteration')
    params.nbMaxIteration = 1000;
end

if ~isfield(problem,'p')
    warning('Error: the size of vector x is not defined');
    solution.stat = -1;
    return;
else
    if problem.p < 0
        warning('Error: p should be a non-negative number');
        solution.stat = -1;
        return;
    end
end

if ~isfield(problem,'q')
    warning('Error: the size of vector y is not defined');
    solution.stat = -1;
    return;
else
    if problem.q < 0
        warning('Error: q should be a non-negative number');
        solution.stat = -1;
        return;
    end
end

if ~isfield(problem,'r')
    warning('Error: the size of vector z is not defined');
    solution.stat = -1;
    return;
else
    if problem.r < 0
        warning('Error: r should be a non-negative number');
        solution.stat = -1;
        return;
    end
end

if ~isfield(problem,'lambda0')
    problem.lambda0 = 1;
end

if ~isfield(problem,'lambda1')
    problem.lambda1 = 1;
end

if ~isfield(problem,'delta0')
    problem.delta0 = 1;
end

if ~isfield(problem,'delta1')
    problem.delta1 = 1;
end

if ~isfield(problem,'k')
    %warning('Error: Weight vector of x is not defined. Default value will be used');
    problem.k = ones(problem.p,1);
else
    if length(problem.k) ~= problem.p 
        warning('Error: the size of weight vector k is not correct');
        solution.stat = -1;
        return;
    else
        if any(problem.k <=0)
            warning('Error: the weight vector k should be stritly possitive');
            solution.stat = -1;
            return;
        end
    end
end

if ~isfield(problem,'d')
    %warning('Error: Weight vector of y is not defined. Default value will be used');
    problem.d = ones(problem.q,1);
else
    if length(problem.d) ~= problem.q 
        warning('Error: the size of weight vector d is not correct');
        solution.stat = -1;
        return;
        else
        if any(problem.d <=0)
            warning('Error: the weight vector d should be stritly possitive');
            solution.stat = -1;
            return;
        end
    end
end

if ~isfield(problem,'A')
    warning('Error: LHS matrix is not defined');
    solution.stat = -1;
    return;
else
    if size(problem.A,2) ~= (problem.p + problem.q + problem.r)
        warning('Error: the number of columns of A is not correct');
        solution.stat = -1;
        return;
    end
end

if ~isfield(problem,'b')
    warning('Error: RHS vector is not defined');
    solution.stat = -1;
    return;
else
    if size(problem.A,1) ~= length(problem.b)
        warning('Error: the number of rows of A is not correct');
        solution.stat = -1;
        return;
    end
end

if ~isfield(problem,'lb')
    warning('Error: lower bound vector is not defined');
    solution.stat = -1;
    return;
else
    if length(problem.lb) ~= (problem.p + problem.q + problem.r)
        warning('Error: the size of vector lb is not correct');
        solution.stat = -1;
        return;
    end
end

if ~isfield(problem,'ub')
    warning('Error: upper bound vector is not defined');
    solution.stat = -1;
    return;
else
    if length(problem.ub) ~= (problem.p + problem.q + problem.r)
        warning('Error: the size of vector lb is not correct');
        solution.stat = -1;
        return;
    end
end

if any(problem.lb > problem.ub)
    warning('Error: lb is greater than ub');
    solution.stat = -1;
    return;
end

if ~isfield(problem,'csense')
    warning('Error: constraint sense vector is not defined');
    solution.stat = -1;
    return;
else
    if length(problem.csense) ~= length(problem.b)
        warning('Error: the size of vector csense is not correct');
        solution.stat = -1;
        return;
    end
end

[nbMaxIteration,epsilon,theta] = deal(params.nbMaxIteration,params.epsilon,params.theta);
[p,q,r] = deal(problem.p,problem.q,problem.r);
[c,lambda0,lambda1,delta0,delta1] = deal(problem.c,problem.lambda0,problem.lambda1,problem.delta0,problem.delta1);
[k,d] = deal(problem.k,problem.d);
[A,b,lb,ub,csense] = deal(problem.A,problem.b,problem.lb,problem.ub,problem.csense);
s = length(problem.b);


%% Initialisation
nbIteration = 0;
x       = -100 + 200*rand(p,1);
y       = -100 + 200*rand(q,1);
z       = zeros(r,1);
x_bar   = zeros(p,1);
y_bar   = zeros(q,1);

% Solve the l1 approximation for starting point
% min       c'(x,y,z) + lambda_0*||x||_1
% s.t.      A*(x,y,z) <= b
%           l <= (x,y,z) <=u
%           x in R^p, y in R^q, z in R^r

obj = [c(1:p);c(p+1:p+q);c(p+q+1:p+q+r);lambda0*ones(p,1)];
% Constraints
% A*[x;y;z] <=b
% w >= x
% w >= -x
A1 = [A                                             sparse(s,p);
      speye(p)      sparse(p,q)      sparse(p,r)    -speye(p);
      -speye(p)     sparse(p,q)      sparse(p,r)    -speye(p);];
b1 = [b; zeros(2*p,1)];
csense1 = [csense;repmat('L',2*p, 1)];

% Bound;
% lb <= [x;y;z] <= ub
% 0  <= w <= max(|lb_x|,|ub_x|)
lb1 = [lb;zeros(p,1)];
ub1 = [ub;max(abs(lb(1:p)),abs(ub(1:p)))];

%Define the linear sub-problem
LPproblem = struct('c',obj,'osense',1,'A',A1,'csense',csense1,'b',b1,'lb',lb1,'ub',ub1);

%Solve the linear problem
LPsolution = solveCobraLP(LPproblem);

switch LPsolution.stat
    case 1
        x = LPsolution.full(1:p);
        y = LPsolution.full(p+1:p+q);
        z = LPsolution.full(p+q+1:p+q+r);
    case 0
        % solution                  Structure containing the following fields
        %       x                   p x 1 solution vector
        %       y                   q x 1 solution vector
        %       z                   r x 1 solution vector
        %       stat                status
        solution.stat=LPsolution.stat;
        return
    otherwise
        error('L1 problem is neither solved nor infeasible')
end


% Create the linear sub-programme that one needs to solve at each iteration, only its
% objective function changes, the constraints set remains.
% Define objective - variable (x,y,z,w,t)
obj = [c(1:p)-x_bar;c(p+1:p+q)-y_bar;c(p+q+1:p+q+r);lambda0*theta*ones(p,1);delta0*ones(q,1)];

% Constraints - variable (x,y,z,w,t)
% A*[x;y;z] <=b
% w >= k.*x             -> k.*x - w <= 0
% w >= -k.*x            -> -k.*x - w <= 0
% t >= theta*d.*y       -> theta*d.*y - t <= 0
% t >= -theta*d.*y      -> -theta*d.*y - t <= 0
A2 = [A                                                        sparse(s,p)      sparse(s,q);
      sparse(diag(k))   sparse(p,q)             sparse(p,r)    -speye(p)        sparse(p,q);
      -sparse(diag(k))  sparse(p,q)             sparse(p,r)    -speye(p)        sparse(p,q);
      sparse(q,p)       theta*sparse(diag(d))   sparse(q,r)    sparse(q,p)      -speye(q);
      sparse(q,p)       -theta*sparse(diag(d))  sparse(q,r)    sparse(q,p)      -speye(q)];
b2 = [b; zeros(2*p+2*q,1)];
csense2 = [csense;repmat('L',2*p+2*q, 1)];

% Bound;
% lb <= [x;y;z] <= ub
% 0  <= w <= max(|k.*lb_x|,|k.*ub_x|)
% 1  <= t <= theta*max(|d.*lb_y|,|d.*ub_y|)
lb2 = [lb;zeros(p,1);ones(q,1)];
ub2 = [ub;k.*max(abs(lb(1:p)),abs(ub(1:p)));theta*d.*max(abs(lb(p+1:p+q)),abs(ub(p+1:p+q)))];

%Define the linear sub-problem
subLPproblem = struct('c',obj,'osense',1,'A',A2,'csense',csense2,'b',b2,'lb',lb2,'ub',ub2);

obj_old = optimizeCardinality_cappedL1_obj(x,y,z,c,k,d,theta,lambda0,lambda1,delta0,delta1);

%% DCA loop
while nbIteration < nbMaxIteration && stop ~= true,

    x_old = x;
    y_old = y;
    z_old = z;

    %Compute (x_bar,y_bar,z_bar) in subgradient of second DC component (z_bar = 0)
    x(abs(x) < 1/theta) = 0;
    x_bar = -lambda1*sign(x) +  theta*lambda0*k.*sign(x);
    y_bar = -delta1*sign(y) + theta*delta0*d.*sign(y);

    %Solve the linear sub-program to obtain new x
    [x,y,z,LPsolution] = optimizeCardinality_cappedL1_solveSubProblem(subLPproblem,x_bar,y_bar,p,q,r,c,k,d,lb,ub,theta,lambda0,lambda1,delta0,delta1);

    switch LPsolution.stat
        case 0
            solution.x = [];
            solution.y = [];
            solution.z = [];
            solution.stat = 0;
            disp(solution)
            warning('Problem infeasible !');
            return;
        case 2
            solution.x = [];
            solution.y = [];
            solution.z = [];
            solution.stat = 2;
            warning('Problem unbounded !');
            return;
        case 1
            %Check stopping criterion
            error_x = norm([x;y;z] - [x_old;y_old;z_old]);
            obj_new = optimizeCardinality_cappedL1_obj(x,y,z,c,k,d,theta,lambda0,lambda1,delta0,delta1);
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
            disp(strcat('DCA - Iteration: ',num2str(nbIteration)));
            disp(strcat('Obj:',num2str(obj_new)));
            disp(strcat('Stopping criteria error: ',num2str(min(error_x,error_obj))));
            disp('=================================');
    end
end
if solution.stat == 1
    solution.obj=obj_new;
    solution.x = x;
    solution.y = y;
    solution.z = z;
end

end

%Solve the linear sub-program to obtain new (x,y,z)
function [x,y,z,LPsolution] = optimizeCardinality_cappedL1_solveSubProblem(subLPproblem,x_bar,y_bar,p,q,r,c,k,d,lb,ub,theta,lambda0,lambda1,delta0,delta1);
    % Change the objective - variable (x,y,z,w,t)
    subLPproblem.obj = [c(1:p)-x_bar;c(p+1:p+q)-y_bar;c(p+q+1:p+q+r);lambda0*theta*ones(p,1);delta0*ones(q,1)];
    subLPproblem.ub  = [ub;k.*max(abs(lb(1:p)),abs(ub(1:p)));theta*d.*max(abs(lb(p+1:p+q)),abs(ub(p+1:p+q)))];

    %Solve the linear problem
    LPsolution = solveCobraLP(subLPproblem);

    if LPsolution.stat == 1
        x = LPsolution.full(1:p);
        y = LPsolution.full(p+1:p+q);
        z = LPsolution.full(p+q+1:p+q+r);
    else
        x = [];
        y = [];
        z = [];
    end

end

%returns the objective function for the outer problem
function obj = optimizeCardinality_cappedL1_obj(x,y,z,c,k,d,theta,lambda0,lambda1,delta0,delta1)
    p = length(x);
    q = length(y);
    obj = c'*[x;y;z]
        + lambda0*ones(p,1)'*min(ones(p,1),theta*abs(k.*x)) 
        - delta0*ones(q,1)'*min(ones(q,1),theta*abs(d.*y))
        + lambda1*norm(x,1) + delta1* norm(y,1);
end
