function result = solveCobraQPOptArrow(QPproblem, problemTypeParams, solverParams)
% Solve a COBRA QP problem through the OptArrow backend
%
% USAGE:
%
%    result = solveCobraQPOptArrow(QPproblem, problemTypeParams, solverParams)
%
% INPUTS:
%    QPproblem:           COBRA QP problem structure
%    problemTypeParams:   structure of problem-type parameters
%    solverParams:        structure of solver parameters
%
% OUTPUT:
%    result:              structure with fields compatible with the
%                         `solveCobraQP` solver dispatch

if nargin < 1 || ~isstruct(QPproblem)
    error('solveCobraQPOptArrow requires QPproblem as a struct.');
end
if nargin < 2 || ~isstruct(problemTypeParams)
    problemTypeParams = struct();
end
if nargin < 3 || ~isstruct(solverParams)
    solverParams = struct();
end

request = struct();
request.qp_problem = localNormalizeQPProblem(QPproblem);
request.solver_params = localSanitizeSolverParams(solverParams);

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
cliPath = fullfile(fileparts(mfilename('fullpath')), 'solve_cobra_qp_cli.py');
cmd = sprintf('"%s" "%s" --input "%s" --output "%s"', ...
    pythonExe, cliPath, inputFile, outputFile);

[status, cmdout] = system(cmd);
if status ~= 0
    error('OptArrow QP CLI call failed.\nCommand: %s\nOutput:\n%s', cmd, cmdout);
end

response = jsondecode(fileread(outputFile));
cobraSolution = response.cobra_solution;

result = struct();
result.x = localEnsureColumn(cobraSolution.full);
result.w = localEnsureColumn(cobraSolution.rcost);
result.y = localEnsureColumn(cobraSolution.dual);
result.s = localEnsureColumn(cobraSolution.slack);
result.stat = cobraSolution.stat;
result.origStat = cobraSolution.origStat;
result.origStatText = cobraSolution.origStatText;
result.qpmethod = cobraSolution.qpmethod;
result.raw = response.raw_result;
end

function normalized = localNormalizeQPProblem(QPproblem)
normalized = struct();

if ~isfield(QPproblem, 'F') || isempty(QPproblem.F)
    error('QPproblem must include F.');
end
F = QPproblem.F;
if ~issparse(F)
    F = sparse(F);
end
[row, col, val] = find(F);
normalized.F = struct('row', row(:)' - 1, 'col', col(:)' - 1, 'val', val(:)', 'shape', [size(F,1), size(F,2)]);
normalized.c = QPproblem.c(:)';
normalized.lb = QPproblem.lb(:)';
normalized.ub = QPproblem.ub(:)';

if isfield(QPproblem, 'A') && ~isempty(QPproblem.A)
    A = QPproblem.A;
    if ~issparse(A)
        A = sparse(A);
    end
    [rowA, colA, valA] = find(A);
    normalized.A = struct('row', rowA(:)' - 1, 'col', colA(:)' - 1, 'val', valA(:)', 'shape', [size(A,1), size(A,2)]);
    normalized.b = QPproblem.b(:)';
    if isfield(QPproblem, 'csense') && ~isempty(QPproblem.csense)
        normalized.csense = cellstr(upper(char(QPproblem.csense(:))));
    else
        normalized.csense = repmat({'E'}, size(A,1), 1);
    end
else
    normalized.A = struct('row', [], 'col', [], 'val', [], 'shape', [0, numel(QPproblem.c)]);
    normalized.b = [];
    normalized.csense = {};
end

if isfield(QPproblem, 'osense') && ~isempty(QPproblem.osense)
    normalized.osense = QPproblem.osense;
else
    normalized.osense = 1;
end
end

function solverParamsOut = localSanitizeSolverParams(solverParams)
solverParamsOut = solverParams;
blockedFields = {'pythonExecutable', 'python_executable', 'optarrowPython'};
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
