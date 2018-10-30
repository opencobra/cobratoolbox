function V1 = cycleFreeFlux(V0, C, model, isInternalRxn, relaxBounds, parallelize)
% Removes stoichiometrically balanced cycles from FBA solutions when
% possible.
%
% A Matlab implementation of the CycleFreeFlux algorithm from Desouki et
% al., 2015. Minimises the one norm of fluxes subject to bounds determined
% by input flux.
%
% USAGE:
%
%    V1 = cycleFreeFlux(V0, C, model, isInternalRxn, relaxBounds);
%
% INPUTS:
%    V0:       `n x k` matrix of `k` FBA solutions
%    C:        `n x k` matrix of `k` FBA objectives
%    model:    COBRA model structure with required fields:
%
%                * .S  - `m x n` stoichiometric matrix
%                * .b  - `m x 1` RHS vector
%                * .lb - `n x 1` lower bound vector
%                * .ub - `n x 1` lower bound vector
%
% OPTIONAL INPUTS:
%    isInternalRxn:    `n x 1` logical array. True for internal reactions.
%    relaxBounds:      Relax bounds that don't include zero. Default is false.
%    parallelize:      Turn parfor use on or off. Default is true if k > 12.
%
% OUTPUT:
%    V1:    `n x k` matrix of cycle free flux vectors
%
% EXAMPLE:
%    % Remove cycles from a single flux vector
%    solution = optimizeCbModel(model);
%    v1 = cycleFreeFlux(solution.v, model.c, model);
% 
%    % Remove cycles from multiple flux vectors
%    [minFlux, maxFlux, Vmin, Vmax] = fluxVariability(model, 0, 'max', model.rxns, 0, 1, 'FBA');
%    V0 = [Vmin, Vmax];
%    n = size(model.S, 2);
%    C = [eye(n), eye(n)];
%    V1 = cycleFreeFlux(V0, C, model);
%
% .. Author: - Hulda S. Haraldsdottir, 25/5/2018

if ~exist('isInternalRxn', 'var') || isempty(isInternalRxn) % Set defaults
    if isfield(model, 'SIntRxnBool')
        isInternalRxn = model.SIntRxnBool;
    else
        tmp = model;
        tmp.c(:) = 0;
        
        if isfield(tmp, 'biomassRxnAbbr')
            tmp = rmfield(tmp, 'biomassRxnAbbr');
        end
        
        [~, isInternalRxn] = findStoichConsistentSubset(tmp, 0, 0);
        
        clear tmp
    end
end

if ~exist('relaxBounds', 'var') || isempty(relaxBounds)
    relaxBounds = false;
end

% Check for parallel computing toolbox
try
    gcp('nocreate');
    hasPCT = true;
catch
    hasPCT = false;
end

k = size(V0, 2);

if ~exist('parallelize', 'var') || isempty(parallelize)
    if hasPCT && k > 12
        parallelize = true;
    else
        parallelize = false;
    end
end

% parameters
[model_S, model_b, model_lb, model_ub] = deal(model.S, model.b, model.lb, model.ub);

% loop through input flux vectors
V1 = zeros(size(V0));

if parallelize
    environment = getEnvironment();
    parfor i = 1:k
        restoreEnvironment(environment,0);
        
        v0 = V0(:, i);
        c0 = C(:, i);
        
        v1 = computeCycleFreeFluxVector(v0, c0, model_S, model_b, model_lb, model_ub, isInternalRxn, relaxBounds); % see subfunction below
        
        V1(:, i) = v1;
    end
    
else
    for i = 1:k
        v0 = V0(:, i);
        c0 = C(:, i);
        
        v1 = computeCycleFreeFluxVector(v0, c0, model_S, model_b, model_lb, model_ub, isInternalRxn, relaxBounds); % see subfunction below
        
        V1(:, i) = v1;
        
    end
end

end

function v1 = computeCycleFreeFluxVector(v0, c0, model_S, model_b, model_lb, model_ub, isInternalRxn, relaxBounds)

[m,n] = size(model_S);
p = sum(isInternalRxn);

D = sparse(p, n);
D(:, isInternalRxn) = speye(p);

isF = isInternalRxn & v0 >= 0; % net forward flux
isR = isInternalRxn & v0 < 0; % net reverse flux

% objective: minimize one-norm
osense = 1;
c = [zeros(n, 1); ones(p, 1)]; % variables: [v; x]

% constraints
%       v            x
A = [model_S   sparse(m, p); % Sv = b (steady state)
     c0'       sparse(1, p); % c0'v = c0'v0
     D        -speye(p)    ; % z - x <= 0
    -D        -speye(p)   ]; % -z - x <= 0

csense = repmat('E', size(A, 1), 1);
csense(m+2:end) = 'L';

b = [model_b; c0' * v0; zeros(2*p, 1)];

% bounds
lb = [v0; zeros(p, 1)]; % fixed exchange fluxes
if relaxBounds
    lb(isF) = 0; % internal reaction directionality same as in input flux
else
    lb(isF) = max(0,model_lb(isF)); % Keep lower bound if it is > 0 (forced positive flux)
end

ub = [v0; abs(v0(isInternalRxn))];
if relaxBounds
    ub(isR) = 0;
else
    ub(isR) = min(0,model_ub(isR)); % Keep upper bound if it is < 0 (forced negative flux)
end

lp = struct('osense', osense, 'c', c, 'A', A, ...
    'csense', csense, 'b', b, 'lb', lb, 'ub', ub);

% solve LP
solution = solveCobraLP(lp);

if solution.stat == 1
    v1 = solution.full(1:n);
else
    error('No solution found for a problem that by definition has a solution.\nTry using a different solver');
end

end

