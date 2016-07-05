function  [solution]=maxCardinalityConservationVector(SInt, params)
% Maximise the cardinality of the conservation vector:
% max   ||l||_0
% st.   S'l = 0
%       0 <= l <= 1/epsilon
% [solution]=maxCardinalityConservationVector(SInt, params)
%
% The l0 norm is approximated by capped l1 norm. The resulting problem is a DC program
%INPUT
% SInt                     mxn Stoichiometric matrix
%
%OPTIONAL INPUTS
% params.nbMaxIteration    Stopping criteria - maximal number of iteration (Default value 1000)
% params.epsilon           1/epsilon is the largest molecular mass considered (Default value 1e-4)
% params.zeta              Stopping criteria - threshold (Default value 1e-6)
% params.theta             Parameter of capped l1 approximation (Default value 2)
%
%OUTPUT
% solution                  Structure containing the following fields
%       l                   m x 1 molecular mass vector
%       stat                status
%                           1 =  Solution found
%                           2 =  Unbounded
%                           0 =  Infeasible
%                           -1=  Invalid input
%
% Hoai Minh Le	18/02/2016


% Format inputs
if nargin < 2
    params.nbMaxIteration = 1000;
    params.zeta = 1e-6;
    params.theta   = 0.5;    %parameter of capped l1 approximation
else
    if isfield(params,'nbMaxIteration') == 0
        params.nbMaxIteration = 1000;
    end
    
    if isfield(params,'epsilon') == 0
        params.epsilon = 1e-4;
    end
    
    if isfield(params,'zeta') == 0
        params.zeta = 1e-6;
    end
    
    if isfield(params,'theta') == 0
        params.theta   = 0.5;    %parameter of capped l1 approximation
    end
end


% Get data from the model
[m,n] = size(SInt);
[nbMaxIteration,zeta,theta,epsilon] = deal(params.nbMaxIteration,params.zeta,params.theta,params.epsilon);

method='quasiConcave';
%method='specific';
%method='cardOptGeneral';
switch method
    case 'quasiConcave'
        [nMet,nInt]=size(SInt);
        % Solve the linear problem
        %   max sum(z_i)
        %       s.t S'*m = 0
        %           z <= m
        %           0 <= m <= 1/epsilon
        %           0 <= z <= epsilon
        LPproblem.A=[SInt'      , sparse(nInt,nMet);
                     speye(nMet),-speye(nMet)];
        
        LPproblem.b=zeros(nInt+nMet,1);
        LPproblem.lb=[zeros(nMet,1);zeros(nMet,1)];
        LPproblem.ub=[ones(nMet,1)*(1/epsilon);ones(nMet,1)*epsilon];
        LPproblem.c=zeros(nMet+nMet,1);
        LPproblem.c(nMet+1:2*nMet,1)=1;
        LPproblem.osense=-1;
        LPproblem.csense(1:nInt,1)='E';
        LPproblem.csense(nInt+1:nInt+nMet,1)='G';
        
        printLevel=0;
        sol = solveCobraLP(LPproblem,'printLevel',printLevel);
        
        if sol.stat==1
            solution.l=sol.full(1:nMet,1);
            %z=solution.full(nMet+1:end,1);
            solution.stat=sol.stat;
        else
            disp(solution)
            error('solve for maximal conservation vector failed')
        end
    case 'cardOptGeneral'
        % min       c'(x,y,z) + lambda*||x||_0 - delta*||y||_0
        % s.t.      A*(x,y,z) <= b
        %           l <= (x,y,z) <=u
        %           x in R^p, y in R^q, z in R^r
        [mlt,nlt]=size(SInt');
        cardProblem.p=0;
        cardProblem.q=nlt;
        cardProblem.r=0;
        cardProblem.c=zeros(nlt,1);
        cardProblem.A=SInt';
        cardProblem.b=zeros(mlt,1);
        cardProblem.lb=zeros(nlt,1);
        cardProblem.ub=(1/epsilon)*ones(nlt,1);
        cardProblem.csense(1:mlt,1)='E';
        params.lambda=0;
        params.delta=1;
        solution = optimizeCardinality(cardProblem,params);
        %  problem                  Structure containing the following fields describing the problem
        %       p                   size of vector x
        %       q                   size of vector y
        %       r                   size of vector z
        %       c                   (p+q+r) x 1 linear objective function vector
        %       lambda              trade-off parameter of ||x||_0
        %       delta               trade-off parameter of ||y||_0
        %       A                   s x (p+q+r) LHS matrix
        %       b                   s x 1 RHS vector
        %       csense              s x 1 Constraint senses, a string containting the constraint sense for
        %                           each row in A ('E', equality, 'G' greater than, 'L' less than).
        %       lb                  (p+q+r) x 1 Lower bound vector
        %       ub                  (p+q+r) x 1 Upper bound vector
        %
        % OPTIONAL INPUTS
        % params                    parameters structure
        %       nbMaxIteration      stopping criteria - number maximal of iteration (Defaut value = 1000)
        %       epsilon             stopping criteria - (Defaut value = 10e-6)
        %       theta               parameter of the approximation (Defaut value = 2)
        %
        % OUTPUT
        % solution                  Structure containing the following fields
        %       x                   p x 1 solution vector
        %       y                   q x 1 solution vector
        %       z                   r x 1 solution vector
        %       stat                status
        %                           1 =  Solution found
        %                           2 =  Unbounded
        %                           0 =  Infeasible
        %                           -1=  Invalid input
        if solution.stat == 1
            solution.l = solution.y;
        end
    case 'specific'
        %Parameters
        nbIteration = 1;
        stop = false;
        solution.l = [];
        solution.stat = 1;
        
        % Variable
        l   = zeros(m,1);
        z   = zeros(m,1);
        
        %Create the linear sub-programme that one needs to solve at each iteration, only its
        %objective function changes, the constraints set remains.
        
        % Define objective - variable (l,z)
        obj = [-theta*ones(m,1);ones(m,1)];
        
        % Constraints
        % S'*l = 0
        % z >= theta*l
        A2 = [SInt'             sparse(n,m);
            theta*speye(m)    -speye(m)];
        b2 = [zeros(n+m,1)];
        csense2 = [repmat('E',n, 1);repmat('L',m, 1)];
        
        % Bound;
        % 0 <= l <= 1/epsilon
        % 0 <= z <=   epsilon
        lb2 = [zeros(m,1);zeros(m,1)];
        ub2 = [(1/epsilon)*ones(m,1);epsilon*ones(m,1)];
        
        %Basis
        basis = [];
        
        %Define the linear sub-problem
        subLPproblem = struct('c',obj,'osense',1,'A',A2,'csense',csense2,'b',b2,'lb',lb2,'ub',ub2,'basis',basis);
        
        obj_old = maximiseConservationVector_obj(l,theta);
        
        %DCA
        while nbIteration < nbMaxIteration && stop ~= true,
            
            l_old = l;
            
            %Solve the sub-linear program to obtain new l
            [l,LPsolution] = maximiseConservationVector_solveSubProblem(subLPproblem,SInt,theta);
            switch LPsolution.stat
                case 0
                    warning('Problem infeasible !!!!!');
                    solution.l = [];
                    solution.stat = 0;
                    stop = true;
                case 2
                    warning('Problem unbounded !!!!!');
                    solution.l = [];
                    solution.stat = 2;
                    stop = true;
                case 1
                    %Reuse basis
                    if isfield(LPsolution,'basis')
                        subLPproblem.basis=LPsolution.basis;
                    end
                    %Check stopping criterion
                    error_l = norm(l - l_old);
                    obj_new = maximiseConservationVector_obj(l,theta);
                    error_obj = abs(obj_new - obj_old);
                    if (error_l < zeta) || (error_obj < zeta)
                        stop = true;
                    else
                        obj_old = obj_new;
                    end
                    % Automatically update the approximation parameter theta
                    if theta < 1000
                        theta = theta * 1.5;
                    end
                    %             disp(strcat('DCA - Iteration: ',num2str(nbIteration)));
                    %             disp(strcat('Obj:',num2str(obj_new)));
                    %             disp(strcat('Stopping criteria error: ',num2str(min(error_l,error_obj))));
                    %             disp('=================================');
                    
            end
            
            nbIteration = nbIteration + 1;
            
        end
        
        %find rows that are not all zero when a subset of reactions omitted
        zeroRowBool = ~any(SInt,2);
        if any(zeroRowBool)
            %any zero row of S is automatically inconsistent
            l(zeroRowBool)=0;
        end
        
        if solution.stat == 1
            solution.l = l;
        end
        
end

end


%Solve the linear sub-program to obtain new l
function [l,LPsolution] = maximiseConservationVector_solveSubProblem(subLPproblem,SInt,theta)

[m,n] = size(SInt);

% Change the objective - variable (l,z)
subLPproblem.obj = [-theta*ones(m,1);ones(m,1)];

%Solve the linear problem
LPsolution = solveCobraLP(subLPproblem);

if LPsolution.stat == 1
    l = LPsolution.full(1:m);
else
    l = [];
end
end

%Compute the objective function
function obj = maximiseConservationVector_obj(l,theta)
m = length(l);
obj = ones(m,1)'*min(ones(m,1),theta*l);
end
