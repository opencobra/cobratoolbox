function  [solution]=maxCardinalityConservationVector(SInt, params)

% Maximise the cardinality of the conservation vector:
% max   ||l||_0   
% st.   S'l = 0
%       l >= 0 
% [solution]=maxCardinalityConservationVector(SInt, params)
% 
% The l0 norm is approximated by capped l1 norm. The resulting problem is a DC program
%INPUT
% SInt                     mxn Stoichiometric matrix
% 
%OPTIONAL INPUTS
% params.nbMaxIteration    Stopping criteria - maximal number of iteration (Default value 1000)
% params.epsilon           Stopping criteria - threshold (Default value 10e-6)
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
    params.epsilon = 10e-6;
    params.theta   = 0.5;    %parameter of capped l1 approximation  
else
    if isfield(params,'nbMaxIteration') == 0
        params.nbMaxIteration = 1000;
    end
    
    if isfield(params,'epsilon') == 0
        params.epsilon = 10e-6;
    end
    
    if isfield(params,'theta') == 0
        params.theta   = 0.5;    %parameter of capped l1 approximation
    end
end


% Get data from the model
[m,n] = size(SInt);
[nbMaxIteration,epsilon,theta] = deal(params.nbMaxIteration,params.epsilon,params.theta);

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
% l >= 0
% z >= 1
lb2 = [zeros(m,1);ones(m,1)];
ub2 = [inf*ones(m,1);inf*ones(m,1)];

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
            if (error_l < epsilon) || (error_obj < epsilon)
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
if solution.stat == 1
    solution.l = l;
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

