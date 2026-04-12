function result = solveCobraOptArrow(problemType, problem, problemTypeParams, solverParams)
% solveCobraOptArrow  Generic OptArrow solver for any COBRA problem type.
%
% Sends the problem as a flat Apache Arrow IPC stream to the OptArrow
% Gateway and maps the response back to a COBRA-compatible result struct.
% No Python interpreter is involved on the client side.
%
% Requires MATLAB R2023b or later (native Arrow list-array support).
% The OptArrow Gateway must be running (locally or remotely).
%
% USAGE:
%
%   result = solveCobraOptArrow('LP', LPproblem, problemTypeParams, solverParams)
%   result = solveCobraOptArrow('QP', QPproblem, problemTypeParams, solverParams)
%
% Called automatically by solveCobraLPOptArrow / solveCobraQPOptArrow via
% COBRA's solver dispatch. Configure with changeCobraOptArrowSolver.
%
% .. Author: - Farid Zare 12/04/2026

problemType = upper(char(string(problemType)));

if nargin < 3 || ~isstruct(problemTypeParams), problemTypeParams = struct(); end
if nargin < 4 || ~isstruct(solverParams),      solverParams      = struct(); end

% Merge stored config with per-call overrides
storedConfig = getCobraOptArrowConfig(problemType);
solverParams = localMerge(storedConfig, solverParams);

[cfg, requestOpts] = resolveCobraOptArrowConfig(problemType, solverParams);

if isempty(cfg.backendSolver)
    error(['OptArrow: no solver configured for %s problems.\n' ...
           'Call changeCobraOptArrowSolver(''<solver>'', ''%s'') first.'], ...
          problemType, problemType);
end

if ~isfield(cfg, 'endpoint') || isempty(cfg.endpoint)
    error(['OptArrow: no endpoint configured.\n' ...
           'Call changeCobraOptArrowSolver(''<solver>'', ''%s'', ' ...
           '''endpoint'', ''http://127.0.0.1:8000/cobra/compute'') first.'], ...
          problemType);
end

% Ensure the optArrow MATLAB client is on the path
localEnsureOptArrowPath(solverParams);

% Set global optarrow config so optarrow.compute picks up endpoint/timeout
optarrow.setOptArrowConfig(struct( ...
    'engine',            cfg.engine, ...
    'backendSolver',     cfg.backendSolver, ...
    'backendSolverType', problemType, ...
    'backendOptions',    cfg.backendOptions, ...
    'endpoint',          cfg.endpoint, ...
    'timeoutSec',        cfg.timeoutSec, ...
    'transport',         'arrow'));

% Build payload struct for optarrow.compute
payload = struct();
payload.problem_type  = problemType;
payload.engine        = cfg.engine;
payload.solver_name   = cfg.backendSolver;
payload.model_name    = requestOpts.modelName;
payload.time_limit    = localTimeLimit(cfg, requestOpts);
payload.solver_params = cfg.backendOptions;
payload.model         = localSerializeProblem(problemType, problem);

computeOpts = struct('endpoint', cfg.endpoint, 'timeoutSec', cfg.timeoutSec);
response = optarrow.compute(payload, computeOpts);

result = localBuildResult(problemType, response, cfg);

if isfield(problemTypeParams, 'printLevel') && problemTypeParams.printLevel > 1
    fprintf('OptArrow [%s]: %s\n', problemType, result.origStatText);
end
end


% =========================================================================
% Result builder
% =========================================================================
function result = localBuildResult(problemType, response, cfg)
result = struct();
result.x            = localCol(localGet(response, 'solution', []));
result.w            = localCol(localGet(response, 'rcost', []));
result.y            = localCol(localGet(response, 'dual', []));
result.s            = localCol(localGet(response, 'slack', []));
result.stat         = localGet(response, 'stat', -1);
result.origStat     = localGet(response, 'status', '');
result.origStatText = localGet(response, 'status', '');
result.raw          = response;
result.optarrowConfig = cfg;

if strcmpi(problemType, 'LP')
    result.full     = result.x;
    result.obj      = localGet(response, 'obj_val', NaN);
    result.f        = result.obj;
    result.lpmethod = localGet(response, 'method', 'optarrow');
    result.basis    = [];
elseif strcmpi(problemType, 'QP')
    result.full     = result.x;
    result.qpmethod = localGet(response, 'method', 'optarrow');
end
end


% =========================================================================
% Problem serialisation (MATLAB sparse → COO struct)
% =========================================================================
function model = localSerializeProblem(problemType, problem)
model = struct();

if strcmpi(problemType, 'LP')
    A = localGetField(problem, {'A','S'});
    if isempty(A), error('LP problem must have field ''A'' or ''S''.'); end
    model.A      = localCOO(A);
    model.b      = double(problem.b(:)');
    model.c      = double(problem.c(:)');
    if isfield(problem,'lb') && ~isempty(problem.lb), model.lb = double(problem.lb(:)'); end
    if isfield(problem,'ub') && ~isempty(problem.ub), model.ub = double(problem.ub(:)'); end
    if isfield(problem,'csense') && ~isempty(problem.csense)
        model.csense = cellstr(upper(char(problem.csense(:))));
    end
    if isfield(problem,'osense'), model.osense = problem.osense; end

elseif strcmpi(problemType, 'QP')
    F = localGetField(problem, {'F','Q'});
    if isempty(F), error('QP problem must have field ''F'' or ''Q''.'); end
    model.Q = localCOO(F);
    model.c = double(problem.c(:)');
    if isfield(problem,'lb') && ~isempty(problem.lb), model.lb = double(problem.lb(:)'); end
    if isfield(problem,'ub') && ~isempty(problem.ub), model.ub = double(problem.ub(:)'); end
    if isfield(problem,'osense'), model.osense = problem.osense; end
    if isfield(problem,'A') && ~isempty(problem.A)
        model.A = localCOO(problem.A);
        model.b = double(problem.b(:)');
        if isfield(problem,'csense') && ~isempty(problem.csense)
            model.csense = cellstr(upper(char(problem.csense(:))));
        end
    end
else
    error('OptArrow: unsupported problem type ''%s''.', problemType);
end
end

function coo = localCOO(M)
if ~issparse(M), M = sparse(M); end
[r, c, v] = find(M);
coo = struct('row', r(:)' - 1, 'col', c(:)' - 1, 'val', v(:)', ...
             'shape', [size(M,1), size(M,2)]);
end

function val = localGetField(s, candidates)
val = [];
for i = 1:numel(candidates)
    if isfield(s, candidates{i}) && ~isempty(s.(candidates{i}))
        val = s.(candidates{i});
        return;
    end
end
end


% =========================================================================
% Path / config helpers
% =========================================================================
function localEnsureOptArrowPath(solverParams)
if isfield(solverParams,'optArrowMatlabRoot') && ~isempty(solverParams.optArrowMatlabRoot)
    root = char(string(solverParams.optArrowMatlabRoot));
else
    root = localFindOptArrowRoot();
end
if ~exist(fullfile(root, '+optarrow', 'compute.m'), 'file')
    error('OptArrow MATLAB client not found at:\n  %s\nSet opts.optArrowMatlabRoot or place optArrow_mat next to the COBRA Toolbox.', root);
end
addpath(genpath(root));
end

function root = localFindOptArrowRoot()
repoRoot   = localRepoRoot();
candidates = { ...
    fullfile(repoRoot, 'external', 'base', 'solvers', 'optArrow', 'src', 'matlab'), ...
    fullfile(fileparts(repoRoot), 'optArrow_mat', 'src', 'matlab')};
for i = 1:numel(candidates)
    if exist(fullfile(candidates{i}, '+optarrow', 'compute.m'), 'file')
        root = candidates{i};
        return;
    end
end
root = candidates{1};
end

function repoRoot = localRepoRoot()
thisFile = mfilename('fullpath');
repoRoot = fileparts(fileparts(fileparts(fileparts(fileparts(thisFile)))));
end

function tl = localTimeLimit(cfg, requestOpts)
if ~isempty(requestOpts.timeLimit)
    tl = double(requestOpts.timeLimit);
elseif isfield(cfg, 'timeLimit') && ~isempty(cfg.timeLimit)
    tl = double(cfg.timeLimit);
else
    tl = 300;
end
end


% =========================================================================
% Misc helpers
% =========================================================================
function v = localCol(x)
if isempty(x), v = []; else, v = double(x(:)); end
end

function val = localGet(s, field, default)
if isstruct(s) && isfield(s, field), val = s.(field); else, val = default; end
end

function merged = localMerge(base, override)
merged = struct();
if isstruct(base)
    merged = base;
end
if isstruct(override)
    for fn = fieldnames(override)'
        merged.(fn{1}) = override.(fn{1});
    end
end
end
