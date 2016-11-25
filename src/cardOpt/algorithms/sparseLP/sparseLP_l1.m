function solution = sparseLP_l1(constraint)
% DC programming for solving the sparse LP
% min   ||x||_1 subject to linear constraints
%
% solution = sparseLP_l1(constraint)
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
% OUTPUT
% solution                  Structure containing the following fields
%       x                   n x 1 solution vector
%       stat                status
%                           1 =  Solution found
%                           2 =  Unbounded
%                           0 =  Infeasible
%                           -1=  Invalid input
% Hoai Minh Le	20/10/2015

[A,b,lb,ub,csense] = deal(constraint.A,constraint.b,constraint.lb,constraint.ub,constraint.csense);

stop = false;
solution.x = [];
solution.stat = 1;

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

[m,n] = size(constraint.A);

    % Define objective - variable (x,t)
    obj = [zeros(n,1);ones(n,1)];
    
    %Constraints
    A2 = [A         sparse(m,n);
          speye(n)  -speye(n);
          -speye(n) -speye(n)];
    b2 = [b; zeros(2*n,1)];
    csense2 = [csense;repmat('L',2*n, 1)];
    
    %Bound;
    lb2 = [lb;zeros(n,1)];
    ub2 = [ub;inf*ones(n,1)];
    
    %Solve the linear problem  
    LPproblem = struct('c',obj,'osense',1,'A',A2,'csense',csense2,'b',b2,'lb',lb2,'ub',ub2);  
    CobraParams = struct('FeasibilityTol',1e-6);
    LPsolution = solveCobraLP(LPproblem,CobraParams);
        
    
    if LPsolution.stat == 1
        solution.x = LPsolution.full(1:n);        
    else
        x = [];
    end
    solution.stat = LPsolution.stat;
end

