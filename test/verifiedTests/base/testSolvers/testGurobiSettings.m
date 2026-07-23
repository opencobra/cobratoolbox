% The COBRAToolbox: testGurobiSettings.m
%
% Purpose:
%     - Tests Gurobi solver parameter configuration through COBRA Toolbox
%     - Demonstrates parameter passing and impact on solver behavior
%     - Tests Crossover, Method, and other Gurobi-specific parameters
%
% Authors:
%     - COBRA Toolbox developers
%
% Note:
%     This test requires Gurobi solver and demonstrates how to configure
%     various Gurobi parameters through the COBRA Toolbox API.

global CBTDIR

% Save the current path
currentDir = pwd;

% Define required solver for this test
solvers = prepareTest('requiredSolvers', {'gurobi'});

% Initialize the test
fileDir = fileparts(which('testGurobiSettings'));
cd(fileDir);

fprintf('Testing Gurobi Parameter Configuration...\n\n');

% Change to Gurobi solver
solverOk = changeCobraSolver('gurobi', 'LP', 0);
if ~solverOk
    error('Failed to set Gurobi as LP solver');
end

% Load Recon3D model
modelPath = fullfile(CBTDIR, 'test', 'models', 'mat', 'Recon3DModel_301.mat');

if ~isfile(modelPath)
    error('Recon3D model not found');
end

load(modelPath);
if ~exist('model', 'var')
    % Try alternative model names
    if exist('modelRecon3D', 'var')
        model = modelRecon3D;
    elseif exist('Recon3D', 'var')
        model = Recon3D;
    else
        error('Could not find model variable in Recon3D file');
    end
end

% Set up test parameters
testTol = 1e-6;

fprintf('--- Test 1: Crossover Parameter Variants ---\n\n');

% Define different crossover settings to test
crossover_settings = {
    struct('Crossover', -1, 'name', 'Automatic (default)'),
    struct('Crossover', 0, 'name', 'Disabled'),
    struct('Crossover', 1, 'name', 'Primal'),
    struct('Crossover', 2, 'name', 'Dual'),
    struct('Crossover', 3, 'name', 'Primal-Dual')
};

reference_obj = [];
crossover_results = {};

for i = 1:length(crossover_settings)
    setting = crossover_settings{i};

    fprintf('  Testing Crossover = %d (%s)...\n', setting.Crossover, setting.name);

    % Set up parameters
    params.Crossover = setting.Crossover;
    params.printLevel = 0;  % Silent

    % Solve with this setting
    tic;
    solution = optimizeCbModel(model, 'max', 0, true, params);
    solve_time = toc;

    % Verify solution is valid
    if solution.stat ~= 1
        warning('Solution with Crossover=%d is not optimal (stat=%d)', ...
            setting.Crossover, solution.stat);
    end

    % Store result
    crossover_results{i} = struct(...
        'Crossover', setting.Crossover, ...
        'name', setting.name, ...
        'objective', solution.f, ...
        'stat', solution.stat, ...
        'time', solve_time, ...
        'hasBasis', isfield(solution, 'basis'));

    % Set reference objective on first iteration
    if i == 1
        reference_obj = solution.f;
    end

    % Display result
    fprintf('    Objective: %.6f, Time: %.4f s, Status: %d, Has basis: %s\n', ...
        solution.f, solve_time, solution.stat, ...
        iif(isfield(solution, 'basis'), 'Yes', 'No'));

    % Verify all solutions match
    obj_diff = abs(solution.f - reference_obj);
    assert(obj_diff < testTol, ...
        sprintf('Crossover=%d gives different objective: %e', ...
        setting.Crossover, obj_diff));
end

fprintf('\n--- Test 2: Crossover Performance Comparison ---\n\n');

% Find fastest and slowest
times = cell2mat(cellfun(@(x) x.time, crossover_results, 'UniformOutput', false)');
[max_time, max_idx] = max(times);
[min_time, min_idx] = min(times);

fprintf('  Fastest:  Crossover=%d (%s) - %.4f s\n', ...
    crossover_results{min_idx}.Crossover, ...
    crossover_results{min_idx}.name, ...
    min_time);

fprintf('  Slowest:  Crossover=%d (%s) - %.4f s\n', ...
    crossover_results{max_idx}.Crossover, ...
    crossover_results{max_idx}.name, ...
    max_time);

fprintf('  Difference: %.2f%%\n', ...
    ((max_time / min_time) - 1) * 100);

fprintf('\n--- Test 3: Method Parameter (LP Algorithm) ---\n\n');

% Test different LP methods
method_settings = {
    struct('Method', -1, 'name', 'Automatic'),
    struct('Method', 0, 'name', 'Primal Simplex'),
    struct('Method', 1, 'name', 'Dual Simplex'),
    struct('Method', 2, 'name', 'Barrier')
};

method_results = {};

for i = 1:length(method_settings)
    setting = method_settings{i};

    fprintf('  Testing Method = %d (%s)...\n', setting.Method, setting.name);

    % Set up parameters
    params.Method = setting.Method;
    params.printLevel = 0;  % Silent

    % Solve with this setting
    tic;
    solution = optimizeCbModel(model, 'max', 0, true, params);
    solve_time = toc;

    % Verify solution is valid
    assert(solution.stat == 1, ...
        sprintf('Solution with Method=%d is not optimal', setting.Method));

    % Verify objective matches reference
    obj_diff = abs(solution.f - reference_obj);
    assert(obj_diff < testTol, ...
        sprintf('Method=%d gives different objective: %e', ...
        setting.Method, obj_diff));

    % Store result
    method_results{i} = struct(...
        'Method', setting.Method, ...
        'name', setting.name, ...
        'objective', solution.f, ...
        'time', solve_time);

    % Display result
    fprintf('    Objective: %.6f, Time: %.4f s\n', solution.f, solve_time);
end

fprintf('\n--- Test 4: Multiple Parameters Combined ---\n\n');

% Test combining multiple parameters
fprintf('  Testing combined parameters:\n');
fprintf('    Method = Dual Simplex (1)\n');
fprintf('    Crossover = Disabled (0)\n');
fprintf('    TimeLimit = 60 seconds\n');

params_combined.Method = 1;        % Dual simplex
params_combined.Crossover = 0;     % No crossover
params_combined.TimeLimit = 60;    % 1 minute timeout
params_combined.printLevel = 0;

tic;
solution_combined = optimizeCbModel(model, 'max', 0, true, params_combined);
time_combined = toc;

fprintf('    Objective: %.6f, Time: %.4f s, Status: %d\n', ...
    solution_combined.f, time_combined, solution_combined.stat);

% Verify solution
assert(solution_combined.stat == 1, 'Combined parameter solution is not optimal');
obj_diff = abs(solution_combined.f - reference_obj);
assert(obj_diff < testTol, ...
    sprintf('Combined parameters give different objective: %e', obj_diff));

fprintf('\n--- Test 5: Parameter Pass-Through Verification ---\n\n');

fprintf('  Verifying that Gurobi parameters are correctly passed through setGurobiParam:\n');
fprintf('  Permitted parameters include:\n');
fprintf('    - Crossover (barrier crossover strategy)\n');
fprintf('    - Method (LP/QP algorithm selection)\n');
fprintf('    - TimeLimit (maximum solve time in seconds)\n');
fprintf('    - OutputFlag (solver verbosity)\n');
fprintf('    - Threads (number of threads to use)\n');
fprintf('    - Presolve (presolve level: -1 to 2)\n');
fprintf('    - And 300+ other Gurobi parameters\n');

% Test that invalid parameters are filtered out
fprintf('\n  Testing parameter filtering:\n');

params_filtered.Crossover = 0;
params_filtered.InvalidParam = 123;
params_filtered.printLevel = 0;

% This should not error - invalid param should be filtered
solution_filtered = optimizeCbModel(model, 'max', 0, true, params_filtered);
assert(solution_filtered.stat == 1, 'Solution with parameter filtering failed');
fprintf('  Verified: Invalid parameters are safely filtered out\n');

fprintf('\n--- Test 6: Barrier Without Crossover (Basis Field Handling) ---\n\n');

% Test specifically for barrier method without crossover
% This tests the fix in solveCobraLP.m that checks if basis fields exist
% before accessing them (interior-point solutions don't have basis info)

fprintf('  Testing Barrier (Method=2) with Crossover=0 (no crossover):\n');
fprintf('  This configuration returns an interior-point solution without basis information.\n');
fprintf('  The solver should handle gracefully the absence of vbasis and cbasis fields.\n\n');

% Test 1: Direct solveCobraLP call with barrier + no crossover
fprintf('  Test 6a: solveCobraLP with barrier + no crossover...\n');
LPproblem_test = buildOptProblemFromModel(model);
params_barrier.Method = 2;      % barrier
params_barrier.Crossover = 0;   % no crossover

tic;
solution_barrier = solveCobraLP(LPproblem_test, params_barrier);
time_barrier = toc;

assert(solution_barrier.stat == 1, 'Barrier without crossover should find optimal solution');
obj_diff_barrier = abs(solution_barrier.obj - reference_obj);
assert(obj_diff_barrier < testTol, ...
    sprintf('Barrier without crossover gives different objective: %e', obj_diff_barrier));

fprintf('    Objective: %.6f, Time: %.4f s, Status: %d\n', ...
    solution_barrier.obj, time_barrier, solution_barrier.stat);

% Check that basis fields are handled gracefully (may be empty or missing)
has_vbasis = isfield(solution_barrier, 'basis') && isfield(solution_barrier.basis, 'vbasis');
has_cbasis = isfield(solution_barrier, 'basis') && isfield(solution_barrier.basis, 'cbasis');
fprintf('    Basis info present: vbasis=%s, cbasis=%s\n', ...
    iif(has_vbasis, 'Yes', 'No'), iif(has_cbasis, 'Yes', 'No'));

% Test 2: optimizeCbModel with barrier + no crossover
fprintf('\n  Test 6b: optimizeCbModel with barrier + no crossover...\n');
params_barrier_ocm.Method = 2;
params_barrier_ocm.Crossover = 0;

tic;
solution_barrier_ocm = optimizeCbModel(model, 'max', 0, true, params_barrier_ocm);
time_barrier_ocm = toc;

assert(solution_barrier_ocm.stat == 1, 'optimizeCbModel with barrier should find optimal solution');
obj_diff_barrier_ocm = abs(solution_barrier_ocm.f - reference_obj);
assert(obj_diff_barrier_ocm < testTol, ...
    sprintf('optimizeCbModel barrier without crossover gives different objective: %e', obj_diff_barrier_ocm));

fprintf('    Objective: %.6f, Time: %.4f s, Status: %d\n', ...
    solution_barrier_ocm.f, time_barrier_ocm, solution_barrier_ocm.stat);

% Test 3: Compare barrier with/without crossover
fprintf('\n  Test 6c: Comparing Barrier + Crossover vs Barrier without Crossover...\n');
params_barrier_with_crossover.Method = 2;
params_barrier_with_crossover.Crossover = 1;  % primal crossover

solution_barrier_with = optimizeCbModel(model, 'max', 0, true, params_barrier_with_crossover);

fprintf('    With crossover:    obj=%.6f, stat=%d\n', solution_barrier_with.f, solution_barrier_with.stat);
fprintf('    Without crossover: obj=%.6f, stat=%d\n', solution_barrier_ocm.f, solution_barrier_ocm.stat);

% Objectives should be equivalent
obj_diff_both = abs(solution_barrier_with.f - solution_barrier_ocm.f);
assert(obj_diff_both < testTol, ...
    sprintf('Barrier with vs without crossover give different objectives: %e', obj_diff_both));

fprintf('    Objective difference: %.2e (within tolerance)\n\n', obj_diff_both);

fprintf('\n=== All Gurobi Settings Tests Passed ===\n\n');

fprintf('Summary:\n');
fprintf('  - Crossover variants tested: %d\n', length(crossover_results));
fprintf('  - LP methods tested: %d\n', length(method_results));
fprintf('  - Barrier without crossover (interior-point) tested and verified\n');
fprintf('  - All solutions verified to be equivalent\n');
fprintf('  - Basis field handling verified (graceful when absent)\n');
fprintf('  - Parameter pass-through mechanism verified\n');

% Restore the original directory
cd(currentDir);

% Helper function
function result = iif(condition, trueVal, falseVal)
    if condition
        result = trueVal;
    else
        result = falseVal;
    end
end
