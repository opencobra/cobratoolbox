function [v,p,q,dv,obj] = fitExperimentalFlux(model, vExp, weightLower, weightUpper, weightExpFlux, param)
% fit a vector of change in concentration, over a time interval, to the
% range of a stoichiometric matrix, minimising the weighed norm
% of the perturbations to the given lower and upper bounds on the
% corresponding exchange reactions of a model, to ensure that a steady
% state solution exists.
%
% INPUT
%    model:             (the following fields are required - others can be supplied)
%
%                         * .S  - `m x 1` Stoichiometric matrix
%                         * .c  - `n x 1` Linear objective coefficients
%                         * .osense - objective sense
%                         * .lb - `n x 1` Lower bounds
%                         * .ub - `n x 1` Upper bounds
%
%          vExp:          `n x 1` experimental flux vector (NaN if no info)         
%   weightLower:          `n x 1` positive weight penalty on relaxation of lower bounds
%   weightUpper:          `n x 1` positive weight penalty on relaxation of lower bounds
% weightExpFlux:          `n x 1` positive weight penalty on deviation from experimental flux

%
% OPTIONAL INPUTS:
%    model:             (the following fields are optional)
%                         * dxdt - `m x 1` change in concentration with time
%                         * C - `k x n` Left hand side of C*v <= d
%                         * d - `k x n` Right hand side of C*v <= d
%                         * csense - `m + k x 1` character array with entries in {L,E,G}
%  param:               Parameters structure with the following optional fields
%  * printLevel         {(1),(0)}
%
%  * method             String indicating flux fitting method
%                       'zero'   minimise zero norm of relaxations
%                       'zeroOne'   minimise zero norm of relaxations with one norm regularisation
%                       'oneTwo'   minimise a combination of one and two norm of relaxations
%                       'two' (default) minimise the two norm of relaxations
%  param.lambda0:       scalar non-negative weight on zero norm
%  param.lambda1:       scalar non-negative weight on one norm
%  param.lambda2:       scalar non-negative weight on two norm
%
% OUTPUT
%  v:          * `n x 1` steady state flux vector
%  p:          * `n x 1` relaxation of lower bounds
%  q:          * `n x 1` relaxation of upper bounds
% dv:          * `n x 1` difference between experimental and predicted steady state flux
% obj:         * Flux fitting used

% Ronan Fleming, March 2018, first version.

[nMet, nRxn]=size(model.S);

vExp=columnVector(vExp);
if length(vExp) ~= nRxn
    error('vExp must have the same dimensions as the number of reactions in S');
end

if ~exist('param', 'var')
    param = struct();
end
if ~isfield(param,'printLevel')
    param.printLevel = 0;
end
if ~isfield(param, 'method')
    param.method = 'two';
end

%function solution = solveCobraQP(QPproblem, varargin)
% Solves constraint-based QP problems
%
% The solver is defined in the CBT_MILP_SOLVER global variable
% (set using changeCobraSolver). Solvers currently available are
% 'tomlab_cplex', 'mosek' and 'qpng' (limited support for small problems)
%
% Solves problems of the type
% :math:`min  0.5 x' * F * x + osense * c' * x`
% s/t :math:`lb <= x <= ub`
% :math:`A * x  <=/=/>= b`
%
% USAGE:
%
%    solution = solveCobraQP(QPproblem, varargin)
%
% INPUT:
%    QPproblem:       Structure containing the following fields describing the QP
%
%                       * .A - LHS matrix
%                       * .b - RHS vector
%                       * .F - F matrix for quadratic objective (see above)
%                       * .c - Objective coeff vector
%                       * .lb - Lower bound vector
%                       * .ub - Upper bound vector
%                       * .osense - Objective sense (-1 max, +1 min)
%                       * .csense - Constraint senses, a string containing the constraint sense for
%                         each row in A ('E', equality, 'G' greater than, 'L' less than).



% Assume constraint S*v = b if csense not provided
if ~isfield(model, 'csense')
    % If csense is not declared in the model, assume that all
    % constraints are equalities.
    model.csense(1:length(model.mets), 1) = 'E';
end

if ~isfield(model, 'b')
    model.b = zeros(size(model.S,1),1);
end

%test that the original model is feasible.
FBAsolution = optimizeCbModel(model);
if FBAsolution.stat ~= 1
    FBAsolution
    warning('Original model is not feasible for FBA. Check numerical issues.')
end

Omn = sparse(nMet, nRxn);
On = sparse(nRxn, nRxn);
In = eye(nRxn);

%no y = v_exp - v constraints for vExp that are nan
finiteExpBool =~ isnan(vExp);
vExpFinite = vExp(finiteExpBool);
nVexp = length(vExpFinite);

Ivv = eye(nVexp);
Ivn = eye(nRxn);
Ivn = Ivn(finiteExpBool, :);
Onv = sparse(nRxn, nVexp);
Ovn = sparse(nVexp, nRxn);
Omv = sparse(nMet, nVexp);

%remove infinite entries or the solver runs into trouble. The non relaxable bounds
%prevent relaxation of the corresponding variables anyway
weights = [weightLower; weightUpper; weightExpFlux(finiteExpBool)];
weights(~isfinite(weights)) = 0;
        
if isfield(model, 'C')
    [nConst,nRxn2] = size(model.C);
    if nRxn ~= nRxn2
        error('number of columns of S should match number of columns of C');
    end
    Okn = sparse(nConst, nRxn);
    Okv = sparse(nConst, nVexp);
    
    %          v    p    q    y
    A = [model.S, Omn, Omn, Omv;
        In,  In,  On, Onv;
        In,  On, -In, Onv;
        Ivn, Ovn, Ovn, Ivv;  % v + y = v_exp
        model.C, Okn, Okn, Okv;];
    
    b = [model.b;
        model.lb;
        model.ub;
        vExpFinite;
        model.d;];
    
    csense1(1:nMet, 1) = model.csense(1:nMet, 1);
    csense2(1:nRxn, 1) = 'G';
    csense3(1:nRxn, 1) = 'L';
    csense4(1:nVexp, 1) = 'E';
    csense5(1:nConst, 1) = model.dsense;%will error unless dsense properly provided for coupling constraints
    csense=[csense1; csense2; csense3; csense4; csense5];
else
    %          v    p    q    y
    A = [model.S, Omn, Omn, Omv;
        In,  In,  On, Onv;
        In,  On, -In, Onv;
        Ivn, Ovn, Ovn, Ivv;]; % v + y = v_exp
    
    b = [model.b;
        model.lb;
        model.ub;
        vExpFinite];
    
    csense1(1:nMet, 1) = model.csense(1:nMet, 1);
    csense2(1:nRxn, 1) = 'G';
    csense3(1:nRxn, 1) = 'L';
    csense4(1:nVexp, 1) = 'E';
    csense=[csense1; csense2; csense3; csense4];
end

switch param.method
    case 'zero'
        %cardinalities
        prob.p = [false(nRxn, 1); weights ~= 0];%min
        prob.q = false(3 * nRxn+nVexp, 1); %max
        prob.r = [true(nRxn, 1); weights == 0];%not optimised
        
        prob.k = zeros(3 * nRxn + nVexp, 1);
        prob.k(prob.p) = weights(weights ~= 0);
        prob.d = zeros(3 * nRxn + nVexp, 1);
        prob.o = zeros(3 * nRxn + nVexp, 1);
        
        if isfield(param, 'lambda0')
            prob.lambda0 = param.lambda0;
        else
            prob.lambda0 = 1;    
        end
        prob.lambda1 = 0;
        
        %linear objective
        c = [model.c; zeros(2 * nRxn + nVexp, 1)];
        
    case 'zeroOne'
        %cardinalities
        prob.p = [false(nRxn, 1); weights ~= 0];%min
        prob.q = false(3 * nRxn + nVexp, 1);%max
        prob.r = [true(nRxn, 1); weights == 0];%not optimised
        
        prob.k = zeros(3 * nRxn + nVexp, 1);
        prob.k(prob.p) = weights(weights ~= 0);
        prob.d = zeros(3 * nRxn + nVexp, 1);
        prob.o = ones(3 * nRxn + nVexp, 1);
        prob.o(prob.p) = weights(weights ~= 0);
        
        if isfield(param,'lambda0')
            prob.lambda0 = param.lambda0;
        else
            prob.lambda0 = 1;
        end
        if isfield(param,'lambda1')
            prob.lambda1 = param.lambda1;
        else
            prob.lambda1 = 1;
        end
        
        %linear objective
        c = [model.c; zeros(2 * nRxn + nVexp, 1)];
        
    case 'oneTwo'

        %positive semi-definite matrix
        if 0
            %small bit of regularisation becasue most solvers do not like zero F
            F = diag(sparse([zeros(nRxn, 1) + 1e-12; weights]));
        else
            F = diag(sparse([zeros(nRxn, 1); weights]));
        end
        
        if isfield(param, 'lambda1')
            lambda1 = param.lambda1;
        else
            lambda1 = 1;
        end
        if isfield(param, 'lambda2')
            lambda2 = param.lambda2;
        else
            lambda2 = 1;
        end
        
        F = lambda2 * F;
        
        %linear objective
        c = [model.c; lambda1 * ones(2 * nRxn, 1); zeros(nVexp, 1)];
        
    case 'two'
        %positive semi-definite matrix
        f = sparse([zeros(nRxn,1); weights]);
        if 1
            %small bit of regularisation becasue most solvers do not like zero F
            f(f==0)=1e-7;
        end
        F = diag(f);
        
        if isfield(param,'lambda2')
            lambda2 = param.lambda2;
        else
            lambda2 = 1;
        end
        
        F = lambda2 * F;
        
        %linear objective
        c = [model.c; zeros(2 * nRxn + nVexp, 1)];
end

%
lb = [ -Inf * ones(nRxn, 1); zeros(2 * nRxn, 1); -Inf * ones(nVexp, 1)];

%do not allow to relax the lower bounds on any reaction with an infinite weight
p_ub = Inf * ones(nRxn, 1);
p_ub(~isfinite(weightLower)) = 0;

%do not allow to relax the upper bounds on any reaction with an infinite weight
q_ub = Inf * ones(nRxn, 1);
q_ub(~isfinite(weightUpper)) = 0;

ub = [Inf * ones(nRxn, 1); p_ub; q_ub; Inf * ones(nVexp, 1)];

if isfield(model, 'osense')
    osense = model.osense;
else
    osense = 1;
end

if exist('F', 'var')
    if any(any(~isfinite(F)))
        error('F cannot have non finite entries')
    end
else
    F = [];
end

[prob.A, prob.b, prob.csense, prob.F, prob.c, prob.lb, prob.ub, prob.osense] = deal(A, b, csense, F, c, lb, ub, osense);

param.printLevel = param.printLevel - 1;

feasTol = getCobraSolverParams('LP', 'feasTol');
if isempty(prob.F)
    solCard = optimizeCardinality(prob, param);
    sol.stat = solCard.stat;
    sol.full = solCard.xyz;
else
    paramQP=param;
    %remove certain parameters that interfere with some solvers
    paramQP = rmfield(paramQP, 'method');
    paramQP.feasTol = feasTol / 10;
    paramQP.optTol = feasTol / 10;
    sol = solveCobraQP(prob, paramQP);
end

%zero out relaxations smaller than feasibility tolerance
bool = abs(sol.full) < feasTol & sol.full ~= 0;
sol.full(bool) = 0;

if sol.stat ~= 1
    sol
    if sol.stat == 3
        warning('fitExperimentalFlux sol.stat == 3.')
    else
        warning('Model does not seem relaxable to fit experimental data. Check numerical issues.')
    end
end

v = sol.full(1:nRxn, 1);
p = sol.full(nRxn + 1:2 * nRxn, 1);
q = sol.full(2 * nRxn + 1:3 * nRxn, 1);
dv = NaN * ones(nRxn, 1);
dv(finiteExpBool) = sol.full(3 * nRxn + 1:3 * nRxn + nVexp, 1);

switch param.method
    case 'zero'
        obj = nnz(sol.full(prob.p));
    case 'zeroOne'
        obj = nnz(sol.full(prob.p)) + norm(dv, 1) + norm(p, 1) + norm(q, 1);
    case 'oneTwo'
        obj = norm(dv, 1) + norm(p, 1) + norm(q, 1) + sol.full' * prob.F * sol.full;
    case 'two'
        disp(sol.obj - sol.full' * prob.F * sol.full)
        obj = + sol.full' * prob.F * sol.full;
end

