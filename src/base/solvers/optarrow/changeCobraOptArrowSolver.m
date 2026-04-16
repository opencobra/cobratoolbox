function cfg = changeCobraOptArrowSolver(solverName, problemType, varargin)
% changeCobraOptArrowSolver  Configure OptArrow as the active COBRA solver.
%
% Every OptArrow solve goes through the Gateway via Apache Arrow IPC —
% the same code path whether the Gateway is on the same machine or remote.
% For local use, start the Gateway first:
%
%   python src/run_server.py       % from the optArrow_mat directory
%
% USAGE:
%
%   % Minimal — solver + problem type (defaults to local Gateway)
%   changeCobraOptArrowSolver('HiGHS', 'LP')
%
%   % Multiple problem types at once
%   changeCobraOptArrowSolver('HiGHS', {'LP', 'QP'})
%
%   % Explicit endpoint (local or remote, identical syntax)
%   changeCobraOptArrowSolver('HiGHS', 'LP', ...
%       'endpoint', 'http://127.0.0.1:8000/cobra/compute')
%
%   changeCobraOptArrowSolver('Gurobi', 'QP', ...
%       'endpoint', 'http://compute-node-01:8000/cobra/compute')
%
%   % With solver options
%   changeCobraOptArrowSolver('HiGHS', 'LP', ...
%       'backendOptions', struct('time_limit', 300, 'presolve', 'on'))
%
%   % Query current configuration
%   cfg = changeCobraOptArrowSolver('query', 'LP')
%
%   % List all configured problem types
%   changeCobraOptArrowSolver('list')
%
% INPUTS:
%   solverName    char/string  Backend solver: 'HiGHS', 'Gurobi', 'CPLEX', ...
%                              Special: 'query' or 'list'
%   problemType   char/string or cell  'LP', 'QP', {'LP','QP'}, ...
%
% NAME-VALUE PAIRS:
%   'engine'         char/string  'python' (default) | 'julia' | ...
%   'endpoint'       char/string  Gateway URL.
%                                 Default: 'http://127.0.0.1:8000/cobra/compute'
%   'timeoutSec'     numeric      HTTP timeout in seconds (default: 120)
%   'backendOptions' struct       Solver-specific options (passed to backend)
%   'timeLimit'      numeric      Solve time limit in seconds
%   'verbosity'      numeric      0=silent, 1=normal (default: 1)
%
% OUTPUT:
%   cfg   struct  Stored configuration (only returned when querying).
%
% .. Author: - Farid Zare 12/04/2026

% ------------------------------------------------------------------
% Special commands
% ------------------------------------------------------------------
if strcmpi(solverName, 'query')
    if nargin < 2 || isempty(problemType)
        error('changeCobraOptArrowSolver: ''query'' requires a problem type.');
    end
    cfg = getCobraOptArrowConfig(upper(char(string(problemType))));
    return;
end

if strcmpi(solverName, 'list')
    localPrintList();
    cfg = [];
    return;
end

% ------------------------------------------------------------------
% Name-value parsing
% ------------------------------------------------------------------
p = inputParser();
p.CaseSensitive = false;
addParameter(p, 'engine',         'python');
addParameter(p, 'endpoint',       'http://127.0.0.1:8000/cobra/compute');
addParameter(p, 'timeoutSec',     120);
addParameter(p, 'backendOptions', struct());
addParameter(p, 'timeLimit',      []);
addParameter(p, 'verbosity',      1);
parse(p, varargin{:});
opts = p.Results;

% ------------------------------------------------------------------
% Build config
% ------------------------------------------------------------------
cfg = struct();
cfg.backendSolver  = char(string(solverName));
cfg.engine         = char(string(opts.engine));
cfg.endpoint       = char(string(opts.endpoint));
cfg.timeoutSec     = opts.timeoutSec;
cfg.backendOptions = opts.backendOptions;
if ~isempty(opts.timeLimit)
    cfg.timeLimit = opts.timeLimit;
end

% ------------------------------------------------------------------
% Normalise problem types to cell array
% ------------------------------------------------------------------
if ischar(problemType) || isstring(problemType)
    types = {upper(char(string(problemType)))};
elseif iscell(problemType)
    types = cellfun(@(t) upper(char(string(t))), problemType, 'UniformOutput', false);
else
    error('changeCobraOptArrowSolver: problemType must be a string or cell array.');
end

% ------------------------------------------------------------------
% Store and register for each problem type
% ------------------------------------------------------------------
for i = 1:numel(types)
    pt = types{i};
    cfgPT = cfg;
    cfgPT.backendSolverType = pt;
    setCobraOptArrowConfig(pt, cfgPT);
    changeCobraSolver('optarrow', pt, 0, -1);
    if opts.verbosity > 0
        fprintf('OptArrow: %s (%s) → %s [%s]\n', ...
            cfgPT.backendSolver, cfgPT.engine, pt, cfgPT.endpoint);
    end
end
end


% ------------------------------------------------------------------
function localPrintList()
global CBT_OPTARROW_SOLVER_CONFIGS;
if isempty(CBT_OPTARROW_SOLVER_CONFIGS) || ~isstruct(CBT_OPTARROW_SOLVER_CONFIGS)
    fprintf('No OptArrow solver configurations set.\n');
    return;
end
types = fieldnames(CBT_OPTARROW_SOLVER_CONFIGS);
if isempty(types)
    fprintf('No OptArrow solver configurations set.\n');
    return;
end
fprintf('OptArrow configured problem types:\n');
for i = 1:numel(types)
    pt  = types{i};
    c   = CBT_OPTARROW_SOLVER_CONFIGS.(pt);
    fprintf('  %-6s  solver=%-10s  engine=%-8s  endpoint=%s\n', ...
        pt, c.backendSolver, c.engine, c.endpoint);
end
end
