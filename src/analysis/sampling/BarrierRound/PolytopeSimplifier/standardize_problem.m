function P = standardize_problem(P)
if isfield(P, 'A')
    error('Polytope:standardize', 'Use Aeq or Aineq instead of A in the model structure.');
end
    
if isfield(P, 'Aeq')
    n = size(P.Aeq, 2);
elseif isfield(P, 'Aineq')
    n = size(P.Aineq, 2);
elseif isfield(P, 'lb')
    n = length(P.lb);
elseif isfield(P, 'ub')
    n = length(P.ub);
else
    error('Polytope:standardize', 'For unconstrained problems, an initial point "center" is required.');
end

%% Set all non-existence fields
if ~isfield(P, 'Aeq')
    P.Aeq = sparse(zeros(0, n));
end

if ~isfield(P, 'beq')
    P.beq = zeros(size(P.Aeq, 1), 1);
end

if ~isfield(P, 'Aineq')
    P.Aineq = sparse(zeros(0, n));
end

if ~isfield(P, 'bineq')
    P.bineq = zeros(size(P.Aineq, 1), 1);
end

if ~isfield(P, 'lb')
    P.lb = -Inf * ones(n, 1);
end

if ~isfield(P,'ub')
    P.ub = Inf * ones(n,1);
end

%% Store f, df, ddf, dddf
randVec = randn(n, 1);
hasf = isfield(P, 'f') && ~isempty(P.f);
hasdf = isfield(P, 'df') && ~isempty(P.df);
hasddf = isfield(P, 'ddf') && ~isempty(P.ddf);

if (hasdf && isfloat(P.df) && norm(P.df) == 0)
    hasdf = false;
end

% Case 1: df is empty
if ~hasdf
    assert(~hasf && ~hasddf);% && ~hasdddf);
    P.f = [];
    P.df = [];
    P.ddf = [];
elseif isfloat(P.df) % Case 2: df is a vector
    assert(all(size(P.df) == [n 1]));
    P.f = [];
    P.df = P.df;
    P.ddf = [];
elseif isa(P.df, 'function_handle') % Case 3: df is handle
    assert(hasf);
    assert(isa(P.f,'function_handle'));
    assert(all(size(P.f(randVec)) == [1 1]));
    assert(all(size(P.df(randVec)) == [n 1]));
    P.f = P.f;
    P.df = P.df;
    if hasddf
        if isa(P.ddf, 'function_handle')
            assert(all(size(P.ddf(randVec)) == [n 1]));
        else
            assert(all(size(P.ddf) == [n 1]));
        end
        P.ddf = P.ddf;
    else
        P.ddf = [];
    end
    
    %% Verify f, df, ddf, dddf
    % TODO
end

%% Check the input dimensions
assert(all(size(P.Aineq) == [length(P.bineq) n]));
assert(all(size(P.Aeq) == [length(P.beq) n]));
assert(all(size(P.lb) == [n 1]));
assert(all(size(P.ub) == [n 1]));
assert(all(P.lb <= P.ub));
end