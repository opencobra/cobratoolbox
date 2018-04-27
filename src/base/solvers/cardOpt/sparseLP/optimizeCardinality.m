function solution = optimizeCardinality(problem, param)
% DC programming for solving the cardinality optimization problem
% The `l0` norm is approximated by capped-`l1` function.
% :math:`min c'(x, y, z) + lambda_0*||k.*x||_0 - delta_0*||d.*y||_0 
%                        + lambda_1*||x||_1    + delta_1*||y||_1` 
% s.t. :math:`A*(x, y, z) <= b`
% :math:`l <= (x,y,z) <= u`
% :math:`x in R^p, y in R^q, z in R^r`
%
% USAGE:
%
%    solution = optimizeCardinality(problem, param)
%
% INPUT:
%    problem:     Structure containing the following fields describing the problem:
%
%                   * .p - size of vector `x`
%                   * .q - size of vector `y`
%                   * .r - size of vector `z`
%                   * .A - `s x (p+q+r)` LHS matrix
%                   * .b - `s x 1` RHS vector
%                   * .csense - `s x 1` Constraint senses, a string containing the constraint sense for
%                     each row in `A` ('E', equality, 'G' greater than, 'L' less than).
%                   * .lb - `(p+q+r) x 1` Lower bound vector
%                   * .ub - `(p+q+r) x 1` Upper bound vector
%                   * .c - `(p+q+r) x 1` linear objective function vector
%
% OPTIONAL INPUTS:
%    problem:     Structure containing the following fields describing the problem:
%                   * .osense - Objective sense  for problem.c only (1 means minimise (default), -1 means maximise)
%                   * .lambda0 - trade-off parameter on minimise `||x||_0`
%                   * .lambda1 - trade-off parameter on minimise `||x||_1`
%                   * .k - `p x 1` strictly positive weight vector on minimise `||x||_0`
%                   * .delta0 - trade-off parameter on maximise `||y||_0`
%                   * .delta1 - trade-off parameter on maximise `||y||_1
%                   * .d - `q x 1` strictly positive weight vector on maximise `||y||_0`
%
%    param:      Parameters structure:
%
%                   * .nbMaxIteration - stopping criteria - number maximal of iteration (Default value = 100)
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

% .. Author: - Hoai Minh Le &  Ronan Fleming

stop = false;
solution.x = [];
solution.y = [];
solution.z = [];
solution.stat = 1;

%% Check inputs
if ~exist('param','var') || isempty(param)
    param.nbMaxIteration = 100;
    param.epsilon = getCobraSolverParams('LP', 'feasTol');
    param.theta   = 2;
end
if ~isfield(param,'nbMaxIteration')
    param.nbMaxIteration = 100;
end
if ~isfield(param,'epsilon')
    param.epsilon = getCobraSolverParams('LP', 'feasTol');
end
if ~isfield(param,'theta')
    param.theta   = 2;
end
if ~isfield(param,'nbMaxIteration')
    param.nbMaxIteration = 100;
end
if ~isfield(param,'printLevel')
    param.printLevel = 0;
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

%set global parameters on zero norm if they do not exist
if ~isfield(problem,'lambda') && ~isfield(problem,'lambda0')
    problem.lambda = 10;  %weight on relaxation of steady state constraints
end
if ~isfield(problem,'delta') && ~isfield(problem,'delta0')
    %default should not be to aim for zero norm flux vector if the problem is infeasible at the begining 
    problem.delta = 0;  %weight on zero norm of reaction rate  
end

%set local paramters on zero norm for capped L1
if ~isfield(problem,'lambda0')
    problem.lambda0 = problem.lambda;    
end
if ~isfield(problem,'delta0')
    problem.delta0 = problem.delta;       
end

%set local paramters on one norm for capped L1
if ~isfield(problem,'lambda1')
    problem.lambda1 = problem.lambda0/10;    
end
if ~isfield(problem,'delta1')
    %always include some regularisation on the flux rates to keep it well
    %behaved
    %problem.delta1 = 0*1e-6 + problem.delta0/10;  
    problem.delta1 = problem.delta0/10;   
end

if ~isfield(problem,'k')
    if problem.lambda0==0
        problem.k = zeros(problem.p,1);
    else
        problem.k = ones(problem.p,1);
    end
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
    if problem.delta0==0
        problem.d = zeros(problem.q,1);
    else
        problem.d = ones(problem.q,1);
    end
else
    if length(problem.d) ~= problem.q 
        warning('Error: the size of weight vector d is not correct');
        solution.stat = -1;
        return;
        else
        if any(problem.d <=0)
            warning('Error: the weight vector d should be stritly positive');
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

[nbMaxIteration,epsilon,theta] = deal(param.nbMaxIteration,param.epsilon,param.theta);
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
obj = [c(1:p)-x_bar;c(p+1:p+q)-y_bar;c(p+q+1:p+q+r);lambda0*theta*ones(p,1);-delta0*ones(q,1)];

% Constraints - variable (x,y,z,w,t)
% A*[x;y;z] <=b
% w >= k.*x             -> k.*x - w <= 0
% w >= -k.*x            -> -k.*x - w <= 0
% t >= theta*d.*y       -> theta*d.*y - t <= 0
% t >= -theta*d.*y      -> -theta*d.*y - t <= 0
A2 = [A                                                        sparse(s,p)      sparse(s,q);
      sparse(diag(k))   sparse(p,q)             sparse(p,r)    -speye(p)        sparse(p,q);
      -sparse(diag(k))  sparse(p,q)             sparse(p,r)    -speye(p)        sparse(p,q);
      sparse(q,p)       theta*spdiags(d,0,q,q)   sparse(q,r)    sparse(q,p)      -speye(q);
      sparse(q,p)       -theta*spdiags(d,0,q,q)  sparse(q,r)    sparse(q,p)      -speye(q)];
b2 = [b; zeros(2*p+2*q,1)];
csense2 = [csense;repmat('L',2*p+2*q, 1)];

% Bounds for unweighted problem
% lb <= [x;y;z] <= ub
% 0  <= w <= max(|lb_x|,|ub_x|)
% 1  <= t <= theta*max(|lb_y|,|ub_y|)
%lb2 = [lb;zeros(p,1);ones(q,1)];
%ub2 = [ub;max(abs(lb(1:p)),abs(ub(1:p)));theta*max(abs(lb(p+1:p+q)),abs(ub(p+1:p+q)))];

% Bounds for weighted problem
% lb <= [x;y;z] <= ub
% 0  <= w <= max(|k.*lb_x|,|k.*ub_x|)
% 1  <= t <= theta*max(|d.*lb_y|,|d.*ub_y|)
lb2 = [lb;zeros(p,1);ones(q,1)];

%ub2 = [ub;    k.*max(abs(lb(1:p)),abs(ub(1:p)));    theta*d.*max(abs(lb(p+1:p+q)),abs(ub(p+1:p+q)))];%Minh
 ub2 = [ub;(k+1).*max(abs(lb(1:p)),abs(ub(1:p)));theta*(d+1).*max(abs(lb(p+1:p+q)),abs(ub(p+1:p+q)))];%each weight greater than unity

if any(lb2>ub2)
    error('lower must be less than upper bounds')
end

%Define the linear sub-problem
subLPproblem = struct('c',obj,'osense',1,'A',A2,'csense',csense2,'b',b2,'lb',lb2,'ub',ub2);

if 1
    %Solve the linear problem
    LPsolution = solveCobraLP(subLPproblem);

    if ~LPsolution.stat
        if param.printLevel>2
            disp(theta)
            %relaxing the problem usually makes it feasible
            subLPproblemRelaxed=subLPproblem;
            subLPproblemRelaxed.lb(:)=-1000;
            subLPproblemRelaxed.ub(:)=1000;
            LPsolutionRelaxed = solveCobraLP(subLPproblemRelaxed);
            disp(LPsolutionRelaxed);
            error('Infeasible before the iterations begin')
        end
    end
end

obj_old = optimizeCardinality_cappedL1_obj(x,y,z,c,k,d,theta,lambda0,lambda1,delta0,delta1);

%% DCA loop
while nbIteration < nbMaxIteration && stop ~= true

    x_old = x;
    y_old = y;
    z_old = z;

    %Compute (x_bar,y_bar,z_bar), i.e. subgradient of second DC component  (z_bar = 0)
    x(abs(x) < 1/theta) = 0;
    %x_bar = -lambda1*sign(x) +  theta*lambda0*k.*sign(x); %Minh - negative on the lambda1 reversed below
     x_bar = -lambda1*sign(x) +  theta*lambda0*k.*sign(x); %Ronan
    %y_bar =  delta1*sign(y)  +  theta*delta0*d.*sign(y); % Minh
     y_bar = -delta1*sign(y)  +  theta*delta0*d.*sign(y); % Ronan

    %Solve the linear sub-program to obtain new x
    [x,y,z,LPsolution] = optimizeCardinality_cappedL1_solveSubProblem(subLPproblem,x_bar,y_bar,p,q,r,c,k,d,lb,ub,theta,lambda0,lambda1,delta0,delta1,param.printLevel);

    switch LPsolution.stat
        case -1
            solution.x = [];
            solution.y = [];
            solution.z = [];
            solution.stat = -1;
            error(['No solution reported (timelimit, numerical problem etc). Solver original status is: ' LPsolution.origStat]);
        case 0
            solution.x = [];
            solution.y = [];
            solution.z = [];
            solution.stat = 0;
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
            if param.printLevel>0
                if nbIteration==1
                    fprintf('%20s%12.3s%12.4s\n','itn','obj','err');
                end
                fprintf('%20u%12.3g%12.4g\n',nbIteration,obj_new,min(error_x,error_obj));
            end
            %                 disp(strcat('DCA - Iteration: ',num2str(nbIteration)));
            %                 disp(strcat('Obj:',num2str(obj_new)));
            %                 disp(strcat('Stopping criteria error: ',num2str()));
            %                 disp('=================================');
        otherwise
            solution.x = [];
            solution.y = [];
            solution.z = [];
            solution.stat = -1;
            error(['No solution reported (timelimit, numerical problem etc). Solver original status is: ' LPsolution.origStat]);
    end
end
if solution.stat == 1
    if param.printLevel>0
        fprintf('%s\n','     Optimise cardinality reached the stopping criterion. Finished.')
    end
    solution.obj=obj_new;
    solution.x = x;
    solution.y = y;
    solution.z = z;
end

end

%Solve the linear sub-program to obtain new (x,y,z)
function [x,y,z,LPsolution] = optimizeCardinality_cappedL1_solveSubProblem(subLPproblem,x_bar,y_bar,p,q,r,c,k,d,lb,ub,theta,lambda0,lambda1,delta0,delta1,printLevel)
    % Change the objective - variable (x,y,z,w,t)

    %subLPproblem.obj  = [c(1:p)-x_bar;c(p+1:p+q)-y_bar;c(p+q+1:p+q+r);lambda0*theta*ones(p,1);delta0*ones(q,1)]; %Minh
    %Ronan. It must be subLPproblem.c for solveCobraLP
    subLPproblem.c     = [c(1:p)     - x_bar;...      % x 
                          c(p+1:p+q) - y_bar;...      % y
                          c(p+q+1:p+q+r);...          % z
                          lambda0*theta*ones(p,1);... % w = max(x,-x)
                                 delta0*ones(q,1)];   % t = max(1,theta*abs(y))
   
    %subLPproblem.ub  = [ub;    k.*max(abs(lb(1:p)),abs(ub(1:p)));    theta*d.*max(abs(lb(p+1:p+q)),abs(ub(p+1:p+q)))];%Minh
     subLPproblem.ub  = [ub;(k+1).*max(abs(lb(1:p)),abs(ub(1:p)));theta*(d+1).*max(abs(lb(p+1:p+q)),abs(ub(p+1:p+q)))];%Ronan - each weight must be greater than unity to stay feasible
    
    %debugging problematic example
    if 0
        A=subLPproblem.A;
        [mlt,nlt]=size(A);
        % determine the vector with all singular values (including zeros)
        svVectAll = svds(A, min(mlt, nlt));
        The singular values and their cut-off can be illustrated as follows:
        % plot the singular values
        figure;
        
        % plot the singular values up to rankS
        semilogy(linspace(1, length(svVect), length(svVect)), svVect, '*');
        
        % plot all singular values
        hold on;
        semilogy(linspace(1, length(svVectAll), length(svVectAll)), svVectAll, 'ro');
        
        % set the font size of the current figure axes, show a legend and minor grid axes
        set(gca, 'fontsize', 14);
        legend('svds (up to rankS)', 'svds (all)')
        grid minor;
        
        % set the label
        xlabel('Number of the singular value');
        ylabel('Magnitude of the singular value');
        
        hold off;
    end
    
    %Solve the linear problem
    LPsolution = solveCobraLP(subLPproblem);

    if LPsolution.stat == 1
        x = LPsolution.full(1:p);
        y = LPsolution.full(p+1:p+q);
        z = LPsolution.full(p+q+1:p+q+r);
    else
        if printLevel>2
            disp(theta)
            %relaxing the problem usually makes it feasible
            subLPproblemRelaxed=subLPproblem;
            subLPproblemRelaxed.lb(:)=-1000;
            subLPproblemRelaxed.ub(:)=1000;
            LPsolutionRelaxed = solveCobraLP(subLPproblemRelaxed);
            disp(LPsolutionRelaxed)
        end
        x = [];
        y = [];
        z = [];
    end

end

%returns the objective function for the outer problem
function obj = optimizeCardinality_cappedL1_obj(x,y,z,c,k,d,theta,lambda0,lambda1,delta0,delta1)
    p = length(x);
    q = length(y);
    %obj = c'*[x;y;z] + lambda0*ones(p,1)'*min(ones(p,1),theta*abs(k.*x)) - delta0*ones(q,1)'*min(ones(q,1),theta*abs(d.*y)) + lambda1*norm(x,1) + delta1*norm(y,1);%Minh
     obj = c'*[x;y;z]...
         + lambda0*ones(p,1)'*min(ones(p,1),theta*abs(k.*x))...
         - delta0*ones(q,1)'*min(ones(q,1),theta*abs(d.*y))...
         + lambda1*norm(x,1) + delta1*norm(y,1);
end