% The COBRAToolbox: testACHRSampler.m
%
% Purpose:
%     - ACHRSampler walks through the flux space of a model by artificial centering hit-and-run
%       (directions from the moving centre of the warmup points to a random warmup point,
%       steps limited by the bounds) and saves pointsPerFile points per file, the error log
%       ACHRerror.txt and the last point for a restart. The sampler is stochastic, so this test
%       fixes the seed and checks invariants, not particular points: on a two-dimensional toy
%       flux space built with createModel (v = (a + b, a, b, a, b), 0 <= a, b <= 10,
%       a + b <= 15) the saved points satisfy S*v = 0 and the bounds, the files hold the
%       documented numbers of points, and the restart file holds the last point. Further
%       calls reach the optional inputs (initPoint, fileBaseNo, maxTime, printLevel, FVA
%       bounds), the re-projection of a point that left the null space, the clamping of a
%       point that crossed a bound, the re-draw when both step limits are below 1e-9 and the
%       early exit when the time limit is exceeded.
%
% Function under test:
%     src/analysis/sampling/ACHR/ACHRSampler.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a hand-built model (createModel) and hand-built warmup points, no solver; the
%     seed is fixed and only invariants are asserted (the walk is random).
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The time-limit exit leaves the error log open
%       SEVERITY: cosmetic
%       TRIGGER: any call whose time limit is exceeded before the last point, for example
%         ACHRSampler(model, warmupPoints, 'achr', 1, 3, 2, [], [], -1)
%       OBSERVED: the function returns at line 200 after saving the points without closing
%         the file ACHRerror.txt opened at line 72; its identifier is still listed by
%         openedFiles after the call (MATLAB R2025a; this test closes it)
%       EXPECTED: the log closed on every exit, as at line 221
%       LINES: 200
%     - DEFECT: printLevel 0 does not silence the header and the step warnings
%       SEVERITY: cosmetic
%       TRIGGER: ACHRSampler(model, warmupPoints, 'achr', 1, 4, 5, initPoint, 3, 36000, 0,
%         minFlux, maxFlux) (printLevel 0, documented as silent)
%       OBSERVED: the line 'File #  Point #  Step #  Time  #Time left' (line 80), the progress
%         bar title (line 76) and 'Warning <minStep> <maxStep>' (line 132) are printed
%         whatever printLevel is (MATLAB R2025a)
%       EXPECTED: no console output with printLevel 0
%       LINES: 76, 80, 132
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testACHRSampler'));
cd(fileDir);

% declare the requirements of this test: a Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system
prepareTest();

% showprogress creates the globals WAITBAR_TYPE and WAITBAR_HANDLE and the sampler changes
% the warning state (warning off MATLAB:divideByZero): note both to restore them at the end
globalsBefore = who('global');
warningState = warning;

% the open files, to close the log that the time-limit exit leaves open (defect above)
if exist('openedFiles') %#ok<EXIST> openedFiles replaces fopen('all') from R2024a
    getOpenFiles = @openedFiles;
else
    getOpenFiles = @() fopen('all');
end

% the sampler writes ACHRerror.txt, ACHR_last_point.mat and the point files into the current
% folder: work in a temporary folder that is removed at the end
workDir = tempname;
mkdir(workDir);
cd(workDir);

%% toy flux space: v = (a + b, a, b, a, b) with 0 <= a, b <= 10 and a + b <= 15

model = createModel({'R1'; 'R2'; 'R3'; 'R4'; 'R5'}, {'uptake'; 'A to B'; 'A to C'; 'B out'; 'C out'}, ...
    {' -> A'; 'A -> B'; 'A -> C'; 'B -> '; 'C -> '}, 'lowerBoundList', zeros(1, 5), ...
    'upperBoundList', [15 10 10 10 10], 'printLevel', 0);
assert(isequal(size(model.S), [3 5]) && numel(model.rxns) == 5 && numel(model.mets) == 3);
% every flux vector of the space is an exact null-space vector of S
fluxOf = @(a, b) [a + b; a; b; a; b];
assert(isequal(model.S * fluxOf(2, 3), zeros(3, 1)));

% S*v of a saved point: the steps stay in the null space up to rounding, and the point is
% re-projected every ten steps when |S*v| exceeds 1e-9 (line 145), so 1e-8 is a safe bound
tolNull = 1e-8;

%% defaults: two files of five points, every point feasible, the last point saved for restart

rng(20261115);
warmupPoints = [fluxOf(2, 3), fluxOf(7, 2), fluxOf(3, 8), fluxOf(5, 5), fluxOf(1, 9)];
ACHRSampler(model, warmupPoints, 'achrTest', 2, 5, 3);
for fileNo = 1:2
    assert(exist(['achrTest_' num2str(fileNo) '.mat'], 'file') == 2);
    saved = load(['achrTest_' num2str(fileNo) '.mat'], 'points');
    assert(isequal(size(saved.points), [5 5]));
    assert(full(max(max(abs(model.S * saved.points)))) < tolNull);
    % a point beyond a bound is set onto the bound (lines 165-173), so the bounds hold exactly
    assert(all(all(saved.points >= model.lb & saved.points <= model.ub)));
end
% the walk moves: the five points of a file are not all the same
assert(any(std(saved.points, 0, 2) > 1e-3));
% the restart file holds the last point, the log exists
restart = load('ACHR_last_point.mat', 'curPoint');
assert(isequal(restart.curPoint, saved.points(:, end)));
assert(exist('ACHRerror.txt', 'file') == 2);
delete('ACHRerror.txt', 'ACHR_last_point.mat', 'achrTest_1.mat', 'achrTest_2.mat');

%% optional inputs: start point off the null space, FVA bounds, silent, numbered from 3

% three warmup points with centre fluxOf(5, 7): the first differs from the centre only in b,
% the other two also in a; the FVA range of R2 and R4 (= a) is a point up to 1e-10, so a
% direction with a component in a has both step limits below 1e-9 and is re-drawn (lines
% 131-134); the start point is off the null space by 1e-6, so the first step is re-projected
% (lines 145-147); the start point sits on the FVA upper bound of R3 (= b), so a step towards
% the first warmup point crosses it and is clamped (lines 165-173)
rng(20261115);
warmupNarrow = [fluxOf(5, 8), fluxOf(6, 6.5), fluxOf(4, 6.5)];
initPoint = fluxOf(5, 7) + [1e-6; 0; 0; 0; 0];
minFlux = model.lb;
maxFlux = model.ub;
minFlux([2 4]) = 5 - 1e-10;
maxFlux([2 4]) = 5 + 1e-10;
maxFlux(3) = 7;
ACHRSampler(model, warmupNarrow, 'achrNarrow', 1, 4, 5, initPoint, 3, 36000, 0, minFlux, maxFlux);
% the file number is fileBaseNo + 1
assert(exist('achrNarrow_4.mat', 'file') == 2 && exist('achrNarrow_1.mat', 'file') == 0);
saved = load('achrNarrow_4.mat', 'points');
assert(isequal(size(saved.points), [5 4]));
% the FVA bounds, not the model bounds, limit the walk: a (R2, R4) stays in its range of
% width 2e-10 around 5, which the model bounds 0..10 would not enforce, and b (R3) never
% exceeds 7 (clamping breaks S*v = 0 by design, so the null space is not asserted here)
assert(all(all(saved.points >= minFlux & saved.points <= maxFlux)));
assert(all(saved.points(3, :) <= 7) && all(all(abs(saved.points([2 4], :) - 5) <= maxFlux(2) - 5)));
delete('ACHRerror.txt', 'ACHR_last_point.mat', 'achrNarrow_4.mat');

%% time limit exceeded: the first point is saved and the sampler returns

% a negative limit is exceeded after the first step: the points file holds that point in its
% first column and zeros elsewhere (allocated at line 84), and the restart file holds it too
rng(20261115);
openFilesBefore = getOpenFiles();
ACHRSampler(model, warmupPoints, 'achrTimed', 1, 3, 2, [], [], -1);
% the early return skips fclose (defect above): close the log the call left open
leftOpen = setdiff(getOpenFiles(), openFilesBefore);
for k = 1:numel(leftOpen)
    fclose(leftOpen(k));
end
saved = load('achrTimed_1.mat', 'points');
assert(isequal(size(saved.points), [5 3]));
assert(full(max(abs(model.S * saved.points(:, 1)))) < tolNull);
assert(all(saved.points(:, 1) >= model.lb & saved.points(:, 1) <= model.ub));
assert(isequal(saved.points(:, 2:3), zeros(5, 2)));
restart = load('ACHR_last_point.mat', 'curPoint');
assert(isequal(restart.curPoint, saved.points(:, 1)));

% remove the temporary folder, restore the warning state and the globals, change the directory
cd(currentDir);
rmdir(workDir, 's');
warning(warningState);
newGlobals = setdiff(who('global'), globalsBefore);
for k = 1:numel(newGlobals)
    clear('global', newGlobals{k});
end
