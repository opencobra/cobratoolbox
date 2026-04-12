function [cfg, requestOpts] = resolveCobraOptArrowConfig(problemType, solverParams)
% resolveCobraOptArrowConfig  Build an OptArrow runtime config from solver params.
%
% Extracts OptArrow-specific fields from solverParams and applies defaults.
% No solver or problem type is hardcoded; both must be provided either via
% changeCobraOptArrowSolver or passed explicitly in solverParams.
%
% USAGE:
%
%   [cfg, requestOpts] = resolveCobraOptArrowConfig(problemType, solverParams)
%
% INPUTS:
%   problemType   char/string  e.g. 'LP' or 'QP'
%   solverParams  struct       merged solver parameters
%
% OUTPUTS:
%   cfg           struct  Runtime configuration for OptArrow
%   requestOpts   struct  Per-request options (modelName, timeLimit)
%
% .. Author: - Farid Zare 07/04/2026

if nargin < 1 || isempty(problemType)
    problemType = '';
end
if nargin < 2 || ~isstruct(solverParams)
    solverParams = struct();
end

problemType = upper(char(string(problemType)));

cfg = struct();
cfg.engine           = localFirst(solverParams, {'engine', 'optarrowEngine'}, 'python');
cfg.backendSolver    = localFirst(solverParams, {'backendSolver', 'solverName', 'solver_name'}, '');
cfg.backendSolverType = upper(char(string(localFirst(solverParams, ...
    {'backendSolverType', 'solverType', 'solver_type'}, problemType))));
cfg.backendOptions   = localFirstStruct(solverParams, {'backendOptions', 'solverParams', 'solver_params'});
cfg.timeoutSec       = localFirst(solverParams, {'timeoutSec'}, 120);
cfg.transport        = localFirst(solverParams, {'transport'}, 'arrow');

% Endpoint is optional; its presence switches to HTTP path.
endpoint = localFirst(solverParams, {'endpoint'}, '');
if ~isempty(endpoint)
    cfg.endpoint = char(string(endpoint));
end

requestOpts = struct();
requestOpts.modelName = char(string(localFirst(solverParams, {'modelName', 'model_name'}, 'cobra_model')));
requestOpts.timeLimit = localFirst(solverParams, {'timeLimit', 'time_limit'}, []);
end


function value = localFirst(s, fieldNames, defaultValue)
for i = 1:numel(fieldNames)
    if isfield(s, fieldNames{i}) && ~isempty(s.(fieldNames{i}))
        value = s.(fieldNames{i});
        return;
    end
end
value = defaultValue;
end

function value = localFirstStruct(s, fieldNames)
for i = 1:numel(fieldNames)
    if isfield(s, fieldNames{i}) && isstruct(s.(fieldNames{i}))
        value = s.(fieldNames{i});
        return;
    end
end
value = struct();
end
