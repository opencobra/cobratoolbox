function [solution,sparseRxnBool] = findSparsePathway(model,rxnPenalty,param)
%input a cobra model and find a sparse pathway given penalties on certain
%reactions being active rxnPenalty(j)>0 and incentives on certain reactions
%being active rxnPenalty(j)<0 and indifferent to the activity of other
%reactions rxnPenalty(j)==0


%build LP problem
problem = buildLPproblemFromModel(model);
[m,n]=size(problem.A);

if ~exist('rxnPenalty','var')
    rxnPenalty = ones(n,1);
end

if ~exist('param','var')
    param = struct();
end
if ~isfield(param,'printLevel')
    param.printLevel =1;
end

if n~=length(rxnPenalty)
    error('rxnPenalty must be the same as size(problem.A,2)')
end

rxnPenaltySign = sign(rxnPenalty);

%     * .p - size of vector `x` OR a `size(A,2) x 1` boolean indicating columns of A corresponding to x (min zero norm).
problem.p = rxnPenaltySign>0;
%     * .q - size of vector `y` OR a `size(A,2) x 1` boolean indicating columns of A corresponding to y (max zero norm).
problem.q = rxnPenaltySign<0;
%     * .r - size of vector `z` OR a `size(A,2) x 1`boolean indicating columns of A corresponding to z .
problem.r = rxnPenaltySign==0;

%     * .k - `p x 1` OR a `size(A,2) x 1` strictly positive weight vector on minimise `||x||_0`
problem.k = rxnPenaltySign;
problem.k(problem.q | problem.r) = 0;
%     * .d - `q x 1` OR a `size(A,2) x 1` strictly positive weight vector on maximise `||y||_0`
problem.d = -rxnPenaltySign;
problem.d(problem.p | problem.r) = 0;

%                   * .lambda0 - trade-off parameter on minimise `||x||_0`
problem.lambda0 = 1;
%                   * .lambda1 - trade-off parameter on minimise `||x||_1`
problem.lambda1 = 0.1;
%                   * .delta0 - trade-off parameter on maximise `||y||_0`
problem.delta0 = 1;
%                   * .delta1 - trade-off parameter on minimise `||y||_1
problem.delta1 = 0.1;

param.theta=0.1;
%param.theta=0.5; %this is the default, but it tends to give volatile
%solutions

% :math:`min c'(x, y, z) + lambda_0*k.||*x||_0 + lambda_1*o.*||x||_1
% .                      -  delta_0*d.||*y||_0 +  delta_1*o.*||y||_1` 
% .                                            +  alpha_1*o.*||z||_1` 
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
%     * .p - size of vector `x` OR a `size(A,2) x 1` boolean indicating columns of A corresponding to x (min zero norm).
%     * .q - size of vector `y` OR a `size(A,2) x 1` boolean indicating columns of A corresponding to y (max zero norm).
%     * .r - size of vector `z` OR a `size(A,2) x 1`boolean indicating columns of A corresponding to z .
%     * .A - `s x size(A,2)` LHS matrix
%     * .b - `s x 1` RHS vector
%     * .csense - `s x 1` Constraint senses, a string containing the constraint sense for
%                  each row in `A` ('E', equality, 'G' greater than, 'L' less than).
%     * .lb - `size(A,2) x 1` Lower bound vector
%     * .ub - `size(A,2) x 1` Upper bound vector
%     * .c -  `size(A,2) x 1` linear objective function vector
% OPTIONAL INPUTS:
%    problem:     Structure containing the following fields describing the problem:
%                   * .osense - Objective sense  for problem.c only (1 means minimise (default), -1 means maximise)
%                   * .k - `p x 1` OR a `size(A,2) x 1` strictly positive weight vector on minimise `||x||_0`
%                   * .d - `q x 1` OR a `size(A,2) x 1` strictly positive weight vector on maximise `||y||_0`
%                   * .o `size(A,2) x 1` strictly positive weight vector on minimise `||[x;y;z]||_1`
%                   * .lambda0 - trade-off parameter on minimise `||x||_0`
%                   * .lambda1 - trade-off parameter on minimise `||x||_1`
%                   * .delta0 - trade-off parameter on maximise `||y||_0`
%                   * .delta1 - trade-off parameter on minimise `||y||_1
%
%    param:      Parameters structure:
%                   * .printLevel - greater than zero to recieve more output
%                   * .nbMaxIteration - stopping criteria - number maximal of iteration (Default value = 100)
%                   * .epsilon - stopping criteria - (Default value = 1e-6)
%                   * .theta - starting parameter of the approximation (Default value = 0.5) 
%                              For a sufficiently large parameter , the Capped-L1 approximate problem
%                              and the original cardinality optimisation problem are have the same set of optimal solutions
%                   * .thetaMultiplier - at each iteration: theta = theta*thetaMultiplier
%                   * .eta - Smallest value considered non-zero (Default value feasTol)
cardSol = optimizeCardinality(problem, param);

%    solution:    Structure may also contain the following field:
%                   * .xyz - 'size(A,2) x 1` solution vector, where model.p,q,r are 'size(A,2) x 1` boolean vectors and 
%                     x=solution.xyz(problem.p);
%                     y=solution.xyz(problem.q);
%                     z=solution.xyz(problem.r);
%                   * .stat - status
solution.v = cardSol.xyz;
solution.stat = cardSol.stat;
sparseRxnBool = abs(solution.v)>=getCobraSolverParams('LP', 'feasTol');
solution.v(~sparseRxnBool)=0;
