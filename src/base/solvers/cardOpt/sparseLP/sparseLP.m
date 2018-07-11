function solution = sparseLP(model, approximation, params)
% DC programming for solving the sparse LP
% :math:`min ||x||_0` subject to linear constraints
% See `Le Thi et al., DC approximation approaches for sparse optimization,
% European Journal of Operational Research, 2014`;
% http://dx.doi.org/10.1016/j.ejor.2014.11.031
%
% USAGE:
%
%    solution = sparseLP(model, approximation, params);
%
% INPUTS:
%    model:       Structure containing the following fields describing the linear constraints:
%
%                        * .A - `m x n` LHS matrix
%                        * .b - `m x 1` RHS vector
%                        * .lb - `n x 1` Lower bound vector
%                        * .ub - `n x 1` Upper bound vector
%                        * .csense - `m x 1` Constraint senses, a string containting the model sense for
%                          each row in `A` ('E', equality, 'G' greater than, 'L' less than).
%
% OPTIONAL INPUTS
%    approximation:    appoximation type of zero-norm. Available approximations:
%
%                        * 'cappedL1' : Capped-L1 norm
%                        * 'exp'      : Exponential function
%                        * 'log'      : Logarithmic function
%                        * 'SCAD'     : SCAD function
%                        * 'lp-'      : `L_p` norm with `p < 0`
%                        * 'lp+'      : `L_p` norm with `0 < p < 1`
%                        * 'all'      : try all approximations and return the best result
%
%
% OPTIONAL INPUTS:
%    params:           Parameters structure:
%
%                        * .nbMaxIteration - stopping criteria - number maximal of iteration (Defaut value = 1000)
%                        * .epsilon - stopping criteria - (Defaut value = 10e-6)
%                        * .theta - parameter of the approximation (Defaut value = 0.5)
%
% OUTPUT:
%    solution:         Structure containing the following fields:
%
%                        * .x - `n x 1` solution vector
%                        * .stat - status:
%
%                          * 1 =  Solution found
%                          * 2 =  Unbounded
%                          * 0 =  Infeasible
%                          * -1=  Invalid input
%
% .. Author: - Hoai Minh Le,	20/10/2015
%              Ronan Fleming,    2017

stop = false;
solution.x = [];
solution.stat = 1;
availableApprox = {'cappedL1','exp','log','SCAD','lp-','lp+','all'};

if ~exist('approximation','var')
    approximation='cappedL1';
end

% Check inputs
if nargin < 3
    params.nbMaxIteration = 1000;
    params.epsilon = 1e-6;
    params.theta   = 0.5;
    params.p = -1;
    if strcmp(approximation,'lp+')
        params.p = 0.5;
    end
else
    if ~isfield(params,'nbMaxIteration')
        params.nbMaxIteration = 1000;
    end

    if ~isfield(params,'epsilon')
        params.epsilon = 1e-6;
    end

    if ~isfield(params,'theta')
        params.theta   = 0.5;
    end

    if ~isfield(params,'p')
        params.p = -1;
        if strcmp(approximation,'lp+')
            params.p = 0.5;
        end
    end

end

if ~isfield(model,'A')
    error('Error:LHS matrix is not defined');
    solution.stat = -1;
    return;
end
if ~isfield(model,'b')
    error('RHS vector is not defined');
    solution.stat = -1;
    return;
end
if ~isfield(model,'lb')
    error('Lower bound vector is not defined');
    solution.stat = -1;
    return;
end
if ~isfield(model,'ub')
    error('Upper bound vector is not defined');
    solution.stat = -1;
    return;
end
if ~isfield(model,'csense')
    error('Constraint sense vector is not defined');
    solution.stat = -1;
    return;
end

if ~ismember(approximation,availableApprox)
    error('Approximation is not valid');
    solution.stat = -1;
    return;
end

switch approximation
    case 'all'
        approximations = setdiff(availableApprox,'all','stable');
        bestResult = size(model.A,2);
        bestAprox = '';
        for i=1:length(approximations)
            %disp(approximations(i))
            %try
                solutionL0 = sparseLP(model,approximations{i},params);
            %catch
                %fail gracefully
                %solutionL0.stat = 0;
            %end
            if solutionL0.stat == 1
                if bestResult > nnz(solutionL0.x)
                    bestResult = nnz(solutionL0.x);
                    bestAprox = approximations{i};
                    bestSolutionL0 = solutionL0;
                end
            end
        end
        solution = bestSolutionL0;
        solution.bestAprox = bestAprox;
        
    otherwise
        [nbMaxIteration,epsilon,theta,p] = deal(params.nbMaxIteration,params.epsilon,params.theta,params.p);
        [A,b,lb,ub,csense] = deal(constraint.A,constraint.b,constraint.lb,constraint.ub,constraint.csense);
        
        %Parameters
        nbIteration = 0;
        epsilonP = 10e-2;
        alpha = 3;
        [m,n] = size(A);
        
        %Create the linear sub-programme that one needs to solve at each iteration, only its
        %objective function changes, the constraints set remains.
        
        % Constraints
        % Ax <=b
        % t >= x
        % t >= -x
        A2 = [A         sparse(m,n);
              speye(n) -speye(n);
             -speye(n) -speye(n)];
        b2 = [b; zeros(2*n,1)];
        csense2 = [csense;repmat('L',2*n, 1)];
        
        % Bound;
        % lb <= x <= ub
        % 0  <= t <= max(|lb|,|ub|)
        lb2 = [lb;zeros(n,1)];
        ub2 = [ub;max(abs(lb),abs(ub))];
        
        %Define the linear sub-problem
        subLPproblem = struct('osense',1,'A',A2,'csense',csense2,'b',b2,'lb',lb2,'ub',ub2);
        
        %Initialisation
        x = zeros(n,1);
        obj_old = evalObj(x,theta,p,epsilonP,alpha,approximation);
        
        %DCA
        tic
        while nbIteration < nbMaxIteration && stop ~= true
            
            x_old = x;
            x_bar = updateSubgrad(x,theta,p,epsilonP,alpha,approximation);
            
            subLPproblem.c = updateObj(x_bar,theta,p,epsilonP,alpha,approximation);
            
            %Solve the linear problem
            LPsolution = solveCobraLP(subLPproblem);
            
            if LPsolution.stat == 1
                x = LPsolution.full(1:n);
            else
                x = [];
            end
            
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
                    obj_new = evalObj(x,theta,p,epsilonP,alpha,approximation);
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
        time = toc;
        if solution.stat == 1
            solution.x = x;
            solution.time = time;
            solution.nIterations = nbIteration;
        end
        
end
