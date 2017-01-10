function solution = sparseLP(approximation,constraint,params)
% DC programming for solving the sparse LP
% min   ||x||_0 subject to linear constraints
% See "Le Thi et al., DC approximation approaches for sparse optimization,
% European Journal of Operational Research, 2014"
% http://dx.doi.org/10.1016/j.ejor.2014.11.031
%
% solution = sparseLP(approximation,constraint,params)
%
% INPUT
%  approximation            appoximation type of zero-norm. Available approximations
%                           'cappedL1' : Capped-L1 norm
%                           'exp'      : Exponential function
%                           'log'      : Logarithmic function
%                           'SCAD'     : SCAD function
%                           'lp-'      : L_p norm with p<0
%                           'lp+'      : L_p norm with 0<p<1
%                           'l1'       : l_1 norm
%                           'all'      : try all approximations and return the best result
%
%  constraint               Structure containing the following fields describing the linear constraints
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
%       optTol              optimality tolerance
%       feasTol             feasibilty tolerance
% 
%OUTPUT
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
availableApprox = {'cappedL1','exp','log','SCAD','lp-','lp+','l1','all'};

% Check inputs
if nargin < 3
    params.nbMaxIteration = 1000;
    params.epsilon = 1e-6;
    params.theta   = 0.5;
    if strcmp(approximation,'lp-') == 1
        params.p = -1;
    end
    if strcmp(approximation,'lp+') == 1
        params.p = 0.5;
    end
else
    if isfield(params,'nbMaxIteration') == 0
        params.nbMaxIteration = 1000;
    end

    if isfield(params,'epsilon') == 0
        params.epsilon = 1e-6;
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
    
    if isfield(params,'p') == 0
        if strcmp(approximation,'lp-') == 1
            params.p = -1;
        end
        if strcmp(approximation,'lp+') == 1
        params.p = 0.5;
    end

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

if ~ismember(approximation,availableApprox)
    error('Approximation is not valid');
    solution.stat = -1;
    return;
end

switch approximation
    case 'cappedL1'
        solution = sparseLP_cappedL1(constraint,params);
    case 'exp'
        solution = sparseLP_exp(constraint,params);
    case 'log'
        solution = sparseLP_log(constraint,params);
    case 'SCAD'
        solution = sparseLP_SCAD(constraint,params);
    case 'lp-'
        solution = sparseLP_lpNegative(constraint,params);
    case 'lp+'
        solution = sparseLP_lpPositive(constraint,params);
    case 'l1'
        solution = sparseLP_l1(constraint);
    case 'all'
        approximations = {'cappedL1','exp','log','SCAD','lp+','lp-'};
        bestResult = size(constraint.A,2);
        bestAprox = '';
        for i=1:length(approximations)
            %disp(approximations(i))
            solutionL0 = sparseLP(char(approximations(i)),constraint,params);
            if solutionL0.stat == 1
                if bestResult > nnz(solutionL0.x)
                    bestResult = nnz(solutionL0.x);
                    bestAprox = char(approximations(i));
                    bestSolutionL0 = solutionL0;
                end
            end
        end
        solution = bestSolutionL0;
        solution.bestAprox = bestAprox;
end
