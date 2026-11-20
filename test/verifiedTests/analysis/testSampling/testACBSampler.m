% The COBRAToolbox: testACBSampler.m
%
% Purpose:
%     - ACBSampler (artificial centering boundary sampler) draws two warmup points, follows
%       the line through them to both ends of the flux space, saves one of the two boundary
%       points once the mixing steps are over and adds (or, with a bias, replaces) a warmup
%       point by the midpoint of the two boundary points. The sampler is stochastic, so this
%       test fixes the seed and checks invariants on a two-dimensional toy flux space built
%       with createModel (v = (a + b, a, b, a, b), 0 <= a, b <= 10, a + b <= 15): every
%       saved point satisfies S*v = 0 within the sampler's own threshold, respects the bounds
%       and lies on a bound; the files hold the documented numbers of points; the .fls text
%       format holds one point per line; the .err log holds the bias record of the first step,
%       whose statistics are derived by hand from the warmup points. Further calls reach a
%       warmup point off the null space (its lines are rejected), a bias on one and on two
%       reactions, the replacement of warmup points once nWarmupNeeded is reached and the
%       text output format.
%
% Function under test:
%     src/analysis/sampling/ACHR/ACBSampler.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a hand-built model (createModel) and hand-built warmup points, no solver; the
%     seed is fixed and only invariants are asserted (the walk is random).
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testACBSampler'));
cd(fileDir);

% declare the requirements of this test: a Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system
prepareTest();

% the sampler changes the warning state (warning off MATLAB:divideByZero): restore it at the end
warningState = warning;

% all files are written under the base file name: use a temporary folder removed at the end
workDir = tempname;
mkdir(workDir);

%% toy flux space: v = (a + b, a, b, a, b) with 0 <= a, b <= 10 and a + b <= 15

model = createModel({'R1'; 'R2'; 'R3'; 'R4'; 'R5'}, {'uptake'; 'A to B'; 'A to C'; 'B out'; 'C out'}, ...
    {' -> A'; 'A -> B'; 'A -> C'; 'B -> '; 'C -> '}, 'lowerBoundList', zeros(1, 5), ...
    'upperBoundList', [15 10 10 10 10], 'printLevel', 0);
assert(isequal(size(model.S), [3 5]) && numel(model.rxns) == 5 && numel(model.mets) == 3);
fluxOf = @(a, b) [a + b; a; b; a; b];
% interior warmup points (the sampler needs a direction that is valid at the first point)
warmupClean = [fluxOf(2, 3), fluxOf(7, 2), fluxOf(3, 8), fluxOf(5, 5)];
assert(isequal(model.S * warmupClean, zeros(3, 4)));

% tolerances: a saved point passed the sampler's own null-space check |S*v| <= 1e-7 (line
% 142); directions with |u| <= 1e-9 (uTol, line 55) are not step-limited, so a bound can be
% crossed by at most 1e-9 times the step length (below 25 here): 1e-7 covers it
tolNull = 1e-7;
tolBound = 1e-7;

%% unbiased sampling to .mat files with the default nWarmupNeeded and saveMatFlag

% the fifth warmup point is off the null space by 1e-5: the lines through it leave the null
% space and are rejected (lines 142-145), the other lines are accepted
rng(20261115);
warmupPoints = [warmupClean, fluxOf(4, 4) + [1e-5; 0; 0; 0; 0]];
baseName = fullfile(workDir, 'acbTest');
ACBSampler(model, warmupPoints, baseName, 2, 4, 3);
for fileNo = 1:2
    saved = load([baseName '_' num2str(fileNo) '.mat'], 'points');
    assert(isequal(size(saved.points), [5 4]));
    assert(full(max(max(abs(model.S * saved.points)))) < tolNull);
    assert(all(all(saved.points >= model.lb - tolBound & saved.points <= model.ub + tolBound)));
    % every saved point is a boundary point: some bound is active within the tolerance
    slack = min(model.ub - saved.points, saved.points - model.lb);
    assert(all(min(slack, [], 1) < tolBound));
end
% the two files hold different points
assert(~isequal(load([baseName '_1.mat'], 'points'), saved));
% without a bias nothing is written to the error log, which is still created
errLog = dir([baseName '.err']);
assert(numel(errLog) == 1 && errLog.bytes == 0);

%% bias on one reaction, text output, warmup points replaced once nWarmupNeeded is reached

% target a = 8 (R2) with standard deviation 1: the bias distances of the four warmup points
% are (2-8)^2 = 36, (7-8)^2 = 1, (3-8)^2 = 25 and (5-8)^2 = 9, so the first record of the
% log reads step 0, <distance of the first midpoint>, min 1, max 36, mean 17.75, 4 points
rng(20261115);
biasOne = struct('rxns', {{'R2'}}, 'values', 8, 'stds', 1, 'percThr', 0.5);
baseName = fullfile(workDir, 'acbBiasOne');
ACBSampler(model, warmupClean, baseName, 1, 3, 2, 5, false, biasOne);
% one point per line of the .fls file, written with %g (six significant digits, so the
% null-space and bound checks allow 1e-3)
flsRows = strsplit(strtrim(fileread([baseName '_1.fls'])), newline);
flsPoints = cell2mat(cellfun(@(row) sscanf(row, '%g')', flsRows(:), 'UniformOutput', false));
assert(isequal(size(flsPoints), [3 5]));
assert(full(max(max(abs(model.S * flsPoints')))) < 1e-3);
assert(all(all(flsPoints' >= model.lb - 1e-3 & flsPoints' <= model.ub + 1e-3)));
assert(exist([baseName '_1.mat'], 'file') == 0);
errRows = strsplit(strtrim(fileread([baseName '.err'])), newline);
firstRecord = sscanf(errRows{1}, '%g');
assert(numel(firstRecord) == 6);
assert(isequal(firstRecord([1 3 4 5 6]), [0; 1; 36; 17.75; 4]));

%% bias on two reactions, .mat output, every midpoint added to the warmup points

% target (a, b) = (8, 1) with standard deviations (1, 2): the distances of the warmup points
% are 36 + 1 = 37, 1 + 0.25 = 1.25, 25 + 12.25 = 37.25 and 9 + 4 = 13
rng(20261115);
biasTwo = struct('rxns', {{'R2'; 'R3'}}, 'values', [8; 1], 'stds', [1; 2], 'percThr', 1);
baseName = fullfile(workDir, 'acbBiasTwo');
ACBSampler(model, warmupClean, baseName, 1, 6, 2, 20000, true, biasTwo);
saved = load([baseName '_1.mat'], 'points');
assert(isequal(size(saved.points), [5 6]));
assert(full(max(max(abs(model.S * saved.points)))) < tolNull);
assert(all(all(saved.points >= model.lb - tolBound & saved.points <= model.ub + tolBound)));
slack = min(model.ub - saved.points, saved.points - model.lb);
assert(all(min(slack, [], 1) < tolBound));
firstRecord = sscanf(strtok(fileread([baseName '.err']), newline), '%g');
assert(isequal(firstRecord([1 3 4 5 6]), [0; 1.25; 37.25; 22.125; 4]));

% remove the temporary folder, restore the warning state and change the directory
rmdir(workDir, 's');
warning(warningState);
cd(currentDir)
