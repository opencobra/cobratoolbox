% The COBRAToolbox: testPerformSampling.m
%
% Purpose:
%     - performSampling creates warmup points with createHRWarmup (an LP solver), starts the
%       ACHR sampler at the first warmup point and saves nFiles files of pointsPerFile points
%       named <path>/<fileName>_<fileBaseNo + k>.mat. The walk is random, so this test fixes
%       the seed and checks invariants, not particular points: on a two-dimensional toy flux
%       space built with createModel (v = (a + b, a, b, a, b), 0 <= a, b <= 10, a + b <= 15)
%       the saved points satisfy S*v = 0 and the bounds, the files are written to the given
%       folder with the documented names, numbers and sizes, and a time limit that is
%       exceeded stops the sampler after its first point. Expected values follow from the
%       documentation and the construction of the model, not from a first run.
%
% Function under test:
%     src/dataIntegration/metabotools/performSampling.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - createHRWarmup solves LPs; a hand-built five-reaction model (createModel); every
%     available LP solver among gurobi and glpk.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found. createHRWarmup is quarantined for its bias input; performSampling always
%     calls it without a bias, and this test passes none.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPerformSampling'));
cd(fileDir);

% prepareTest, CobraSolverState and showprogress (called by ACHRSampler) create globals (solver
% parameters, WAITBAR_TYPE, WAITBAR_HANDLE): note the existing ones to remove the new ones at the
% end
globalsBefore = who('global');

% declare the requirements of this test: createHRWarmup needs an LP solver
solvers = prepareTest('needsLP', true, 'useSolversIfAvailable', {'gurobi', 'glpk'});
initialSolverState = CobraSolverState.get();

% ACHRSampler changes the warning state (warning off MATLAB:divideByZero): note it to restore it
% at the end
warningState = warning;

% the open files, to close the log that ACHRSampler leaves open when its time limit is exceeded
% (a cosmetic defect documented in testACHRSampler)
if exist('openedFiles') %#ok<EXIST> openedFiles replaces fopen('all') from R2024a
    getOpenFiles = @openedFiles;
else
    getOpenFiles = @() fopen('all');
end

% ACHRSampler writes ACHRerror.txt and ACHR_last_point.mat into the current folder: work in a
% temporary folder, and save the points into a sub-folder of it to see that path is used
workDir = tempname;
mkdir(workDir);
outDir = fullfile(workDir, 'points');
mkdir(outDir);
cd(workDir);

%% toy flux space: v = (a + b, a, b, a, b) with 0 <= a, b <= 10 and a + b <= 15

model = createModel({'R1'; 'R2'; 'R3'; 'R4'; 'R5'}, {'uptake'; 'A to B'; 'A to C'; 'B out'; 'C out'}, ...
    {' -> A'; 'A -> B'; 'A -> C'; 'B -> '; 'C -> '}, 'lowerBoundList', zeros(1, 5), ...
    'upperBoundList', [15 10 10 10 10], 'printLevel', 0);
nRxns = numel(model.rxns);

% S*v of a saved point: the steps stay in the null space up to rounding, and ACHRSampler
% re-projects a point every ten steps when |S*v| exceeds 1e-9, so 1e-8 is a safe bound; the
% bounds are compared with the same margin (LP warmup points may lie 1e-9 outside a bound)
tolNull = 1e-8;

for k = 1:length(solvers.LP)
    solverOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);
    if ~solverOK
        continue
    end
    fprintf('   Testing performSampling using %s ... \n', solvers.LP{k});

    %% three files of four points, numbered from fileBaseNo + 1 = 3, written to path

    % 10 warmup points = 2 * nRxns, the minimum createHRWarmup accepts without a warning
    rng(20261125);
    performSampling(model, 2 * nRxns, 'sampleTest', 3, 4, 5, 2, 3600, outDir);
    for fileNo = 3:5
        fileName = fullfile(outDir, ['sampleTest_' num2str(fileNo) '.mat']);
        assert(exist(fileName, 'file') == 2);
        saved = load(fileName, 'points');
        % pointsPerFile points of nRxns fluxes each
        assert(isequal(size(saved.points), [nRxns 4]));
        % every point is a steady state within the bounds
        assert(full(max(max(abs(model.S * saved.points)))) < tolNull);
        assert(all(all(saved.points >= model.lb - tolNull & saved.points <= model.ub + tolNull)));
    end
    % no file below fileBaseNo + 1 or above fileBaseNo + nFiles, none in the current folder
    assert(exist(fullfile(outDir, 'sampleTest_2.mat'), 'file') == 0);
    assert(exist(fullfile(outDir, 'sampleTest_6.mat'), 'file') == 0);
    assert(exist(fullfile(workDir, 'sampleTest_3.mat'), 'file') == 0);
    % the walk moves: the four points of the last file are not all the same
    assert(any(std(full(saved.points), 0, 2) > 1e-3));
    % the sampler's restart file and log are written to the current folder
    restart = load('ACHR_last_point.mat', 'curPoint');
    assert(isequal(restart.curPoint, saved.points(:, end)));
    assert(exist('ACHRerror.txt', 'file') == 2);
    delete('ACHRerror.txt', 'ACHR_last_point.mat', fullfile(outDir, 'sampleTest_*.mat'));

    %% maxTime exceeded: the sampler saves its first point and stops

    % a negative time limit is exceeded after the first step: one file whose first column is a
    % feasible point and whose other columns are the zeros the sampler allocated
    rng(20261125);
    openFilesBefore = getOpenFiles();
    performSampling(model, 2 * nRxns, 'sampleTimed', 2, 3, 2, 0, -1, outDir);
    leftOpen = setdiff(getOpenFiles(), openFilesBefore);
    for f = 1:numel(leftOpen)
        fclose(leftOpen(f));
    end
    assert(exist(fullfile(outDir, 'sampleTimed_1.mat'), 'file') == 2);
    assert(exist(fullfile(outDir, 'sampleTimed_2.mat'), 'file') == 0);
    saved = load(fullfile(outDir, 'sampleTimed_1.mat'), 'points');
    assert(isequal(size(saved.points), [nRxns 3]));
    assert(full(max(abs(model.S * saved.points(:, 1)))) < tolNull);
    assert(all(saved.points(:, 1) >= model.lb - tolNull & saved.points(:, 1) <= model.ub + tolNull));
    assert(isequal(full(saved.points(:, 2:3)), zeros(nRxns, 2)));
    delete('ACHRerror.txt', 'ACHR_last_point.mat', fullfile(outDir, 'sampleTimed_*.mat'));
end

% remove the temporary folder, restore the solver, the warning state and the globals, change
% the directory
cd(currentDir);
rmdir(workDir, 's');
CobraSolverState.restore(initialSolverState);
warning(warningState);
newGlobals = setdiff(who('global'), globalsBefore);
for k = 1:numel(newGlobals)
    clear('global', newGlobals{k});
end
