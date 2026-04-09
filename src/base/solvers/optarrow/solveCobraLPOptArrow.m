function result = solveCobraLPOptArrow(LPproblem, problemTypeParams, solverParams)
% Solve a COBRA LP problem through the OptArrow backend
%
% USAGE:
%
%    result = solveCobraLPOptArrow(LPproblem, problemTypeParams, solverParams)
%
% INPUTS:
%    LPproblem:           COBRA LP problem structure
%    problemTypeParams:   structure of problem-type parameters
%    solverParams:        structure of solver parameters
%
% OUTPUT:
%    result:              structure with fields compatible with the
%                         `solveCobraLP` solver dispatch
%
% This helper keeps the OptArrow integration downstream from the generic
% COBRA solver interface. It supports:
%  - a CLI-backed local Python path
%  - an HTTP path through the generic OptArrow MATLAB client

if nargin < 1 || ~isstruct(LPproblem)
    error('solveCobraLPOptArrow requires LPproblem as a struct.');
end
if nargin < 2 || ~isstruct(problemTypeParams)
    problemTypeParams = struct();
end
if nargin < 3 || ~isstruct(solverParams)
    solverParams = struct();
end

request = struct();
request.lp_problem = localNormalizeLPProblem(LPproblem);
request.solver_params = localSanitizeSolverParams(solverParams);

if isfield(solverParams, 'endpoint') && ~isempty(solverParams.endpoint)
    result = localSolveViaOptArrowHttp(LPproblem, problemTypeParams, solverParams);
    return;
end

inputFile = [tempname '.json'];
outputFile = [tempname '.json'];
cleanupObj = onCleanup(@() localCleanupFiles({inputFile, outputFile}));

fid = fopen(inputFile, 'w');
if fid == -1
    error('Unable to create temporary OptArrow input file.');
end
fwrite(fid, jsonencode(request), 'char');
fclose(fid);

pythonExe = localResolvePythonExecutable(solverParams);
cliPath = fullfile(fileparts(mfilename('fullpath')), 'solve_cobra_lp_cli.py');

cmd = sprintf('"%s" "%s" --input "%s" --output "%s"', ...
    pythonExe, cliPath, inputFile, outputFile);
[status, cmdout] = system(cmd);
if status ~= 0
    error('OptArrow CLI call failed.\nCommand: %s\nOutput:\n%s', cmd, cmdout);
end

if ~exist(outputFile, 'file')
    error('OptArrow CLI did not create an output file.');
end

response = jsondecode(fileread(outputFile));
cobraSolution = response.cobra_solution;

result = struct();
result.x = localEnsureColumn(cobraSolution.full);
result.f = cobraSolution.obj;
result.w = localEnsureColumn(cobraSolution.rcost);
result.y = localEnsureColumn(cobraSolution.dual);
result.stat = cobraSolution.stat;
result.origStat = cobraSolution.origStat;
result.origStatText = cobraSolution.origStatText;
result.lpmethod = cobraSolution.lpmethod;
result.basis = [];
result.raw = response.raw_result;

if isfield(problemTypeParams, 'printLevel') && problemTypeParams.printLevel > 1
    fprintf('OptArrow status: %s\n', result.origStatText);
end
end

function result = localSolveViaOptArrowHttp(LPproblem, problemTypeParams, solverParams)
localMaybeConfigurePyenv(solverParams);
localEnsureOptArrowMatlabPath(solverParams);

opts = struct();
opts.endpoint = char(string(solverParams.endpoint));
if isfield(solverParams, 'timeoutSec') && ~isempty(solverParams.timeoutSec)
    opts.timeoutSec = double(solverParams.timeoutSec);
else
    opts.timeoutSec = 120;
end
opts.modelName = 'cobra_lp_http';
opts.solver = struct('solver_name', 'HiGHS', 'solver_type', 'LP', 'solver_params', struct());

response = optarrow.solveLP(LPproblem, opts);

result = struct();
result.x = localEnsureColumn(localGetFieldOrDefault(response, 'solution', []));
result.f = localGetFieldOrDefault(response, 'obj_val', NaN);
result.w = [];
result.y = [];
result.stat = localMapOptArrowStatus(localGetFieldOrDefault(response, 'status', ''));
result.origStat = localGetFieldOrDefault(response, 'status', '');
result.origStatText = localGetFieldOrDefault(response, 'status', '');
result.lpmethod = 'arrow-http';
result.basis = [];
result.raw = response;

if isfield(problemTypeParams, 'printLevel') && problemTypeParams.printLevel > 1
    fprintf('OptArrow HTTP status: %s\n', result.origStatText);
end
end

function normalized = localNormalizeLPProblem(LPproblem)
normalized = struct();

if isfield(LPproblem, 'A')
    A = LPproblem.A;
elseif isfield(LPproblem, 'S')
    A = LPproblem.S;
else
    error('LPproblem must contain A or S.');
end

if ~issparse(A)
    A = sparse(A);
end
[row, col, val] = find(A);
normalized.A = struct( ...
    'row', row(:)' - 1, ...
    'col', col(:)' - 1, ...
    'val', val(:)', ...
    'shape', [size(A, 1), size(A, 2)]);

if isfield(LPproblem, 'b') && ~isempty(LPproblem.b)
    normalized.b = LPproblem.b(:)';
else
    normalized.b = zeros(1, size(A, 1));
end

if ~isfield(LPproblem, 'c') || isempty(LPproblem.c)
    error('LPproblem must include c.');
end
normalized.c = LPproblem.c(:)';

if isfield(LPproblem, 'lb') && ~isempty(LPproblem.lb)
    normalized.lb = LPproblem.lb(:)';
else
    normalized.lb = zeros(1, size(A, 2));
end

if isfield(LPproblem, 'ub') && ~isempty(LPproblem.ub)
    normalized.ub = LPproblem.ub(:)';
else
    normalized.ub = repmat(1e6, 1, size(A, 2));
end

if isfield(LPproblem, 'csense') && ~isempty(LPproblem.csense)
    normalized.csense = cellstr(upper(char(LPproblem.csense(:))));
else
    normalized.csense = repmat({'E'}, size(A, 1), 1);
end

if isfield(LPproblem, 'osense') && ~isempty(LPproblem.osense)
    if isnumeric(LPproblem.osense) && LPproblem.osense == -1
        normalized.osense = -1;
    elseif ischar(LPproblem.osense) || isstring(LPproblem.osense)
        if strcmpi(string(LPproblem.osense), "max")
            normalized.osense = -1;
        else
            normalized.osense = 1;
        end
    else
        normalized.osense = 1;
    end
else
    normalized.osense = -1;
end
end

function solverParamsOut = localSanitizeSolverParams(solverParams)
solverParamsOut = solverParams;
blockedFields = {'pythonExecutable', 'python_executable', 'optarrowPython', 'endpoint', 'timeoutSec', 'optArrowMatlabRoot'};
for i = 1:numel(blockedFields)
    if isfield(solverParamsOut, blockedFields{i})
        solverParamsOut = rmfield(solverParamsOut, blockedFields{i});
    end
end
end

function pythonExe = localResolvePythonExecutable(solverParams)
candidateFields = {'pythonExecutable', 'python_executable', 'optarrowPython'};
for i = 1:numel(candidateFields)
    if isfield(solverParams, candidateFields{i}) && ~isempty(solverParams.(candidateFields{i}))
        pythonExe = char(string(solverParams.(candidateFields{i})));
        return;
    end
end

envPython = getenv('COBRA_OPTARROW_PYTHON');
if ~isempty(envPython)
    pythonExe = envPython;
    return;
end

repoRoot = localRepoRoot();
localVenvPython = fullfile(repoRoot, '.venv_optarrow_poc', 'bin', 'python');
if exist(localVenvPython, 'file')
    pythonExe = localVenvPython;
    return;
end

pythonExe = 'python3';
end

function repoRoot = localRepoRoot()
thisFile = mfilename('fullpath');
repoRoot = fileparts(fileparts(fileparts(fileparts(fileparts(thisFile)))));
end

function value = localEnsureColumn(inputValue)
if isempty(inputValue)
    value = [];
else
    value = inputValue(:);
end
end

function localCleanupFiles(files)
for i = 1:numel(files)
    if exist(files{i}, 'file')
        delete(files{i});
    end
end
end

function localEnsureOptArrowMatlabPath(solverParams)
if isfield(solverParams, 'optArrowMatlabRoot') && ~isempty(solverParams.optArrowMatlabRoot)
    matlabRoot = char(string(solverParams.optArrowMatlabRoot));
else
    repoRoot = localRepoRoot();
    matlabRoot = fullfile(fileparts(repoRoot), 'optArrow_mat', 'src', 'matlab');
end

if ~exist(fullfile(matlabRoot, '+optarrow', 'solveLP.m'), 'file')
    error('OptArrow MATLAB interface not found at %s', matlabRoot);
end

addpath(genpath(matlabRoot));
end

function localMaybeConfigurePyenv(solverParams)
candidateFields = {'pythonExecutable', 'python_executable', 'optarrowPython'};
pythonExe = '';
for i = 1:numel(candidateFields)
    if isfield(solverParams, candidateFields{i}) && ~isempty(solverParams.(candidateFields{i}))
        pythonExe = char(string(solverParams.(candidateFields{i})));
        break;
    end
end

if isempty(pythonExe)
    return;
end

try
    pe = pyenv;
    if strcmp(pe.Status, 'NotLoaded')
        pyenv('Version', pythonExe);
    elseif ~strcmp(string(pe.Executable), string(pythonExe))
        warning('OptArrow HTTP path is using Python executable %s instead of requested %s.', ...
            string(pe.Executable), string(pythonExe));
    end
catch ME
    warning('Unable to configure MATLAB Python environment for OptArrow HTTP path: %s', ME.message);
end
end

function value = localGetFieldOrDefault(s, fieldName, defaultValue)
if isstruct(s) && isfield(s, fieldName)
    value = s.(fieldName);
else
    value = defaultValue;
end
end

function stat = localMapOptArrowStatus(status)
normalized = lower(strtrim(string(status)));
if normalized == "optimal" || normalized == "locallyoptimal"
    stat = 1;
elseif normalized == "infeasible"
    stat = 0;
elseif normalized == "unbounded"
    stat = 2;
else
    stat = -1;
end
end
