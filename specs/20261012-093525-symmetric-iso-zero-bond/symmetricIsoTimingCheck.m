% symmetricIsoTimingCheck.m
%
% Non-CI reproducibility check and benchmark for feature 20261012-093525-symmetric-iso-zero-bond
% (tasks.md T003, T011; spec FR-008, SC-001, SC-005; research R8). Adapted from
% specs/20260930-102230-isomorphism-label-only-copies/isomorphismLabelOnlyCheck.m.
%
% The pre-change helper is FEATURE/baseline/classifySubgraphIsomorphism.m (a verbatim copy of
% develop f1581781c). It is put in front of the source on the path only for baseline runs, and
% the active file is asserted before every run.
%
% Modes (environment variable CBT_SIZ_MODE):
%   'baseline' (T003): time the unlabelled classification of the 1,960-reaction bond-mapping
%                      components with the baseline helper only, N runs; save baseline_timing.mat
%   'compare'  (T011): SC-001, the stored near-symmetric pair with the source helper, N runs,
%                      maximum; SC-005, alternating baseline/source runs on the 1,960-reaction
%                      components, median ratio; classification outputs compared for equality;
%                      save after_timing.mat
% CBT_SIZ_RUNS overrides N (default 3).
%
% The bond-mapping components are built with extractBondSubgraphs from the BIG and ATG of the
% same 1,960-reaction model (the capture of feature 20260928-100409, n1960-inputs.mat, sibling of
% conservedMoietyHotspots/n1960-identifyInputs.mat), exactly as identifyConservedReactingMoieties
% builds them before calling findAndExtractMolecularGraphs, whose unlabelled
% classifySubgraphIsomorphism(bondSubgraphs) call is timed.
%
% USAGE (headless):
%   setenv('CBT_SIZ_MODE', 'baseline');
%   run('/home/jackmcgoldrick/cobratoolbox/specs/20261012-093525-symmetric-iso-zero-bond/symmetricIsoTimingCheck.m')

featureDir = fileparts(mfilename('fullpath'));
repoRoot = fileparts(fileparts(featureDir));
baselineDir = fullfile(featureDir, 'baseline');
srcPath = fullfile(repoRoot, 'src', 'analysis', 'topology', 'reactingMoieties', ...
    'classifySubgraphIsomorphism.m');
baselinePath = fullfile(baselineDir, 'classifySubgraphIsomorphism.m');
resultsDir = fullfile(repoRoot, 'results', '20261012-093525-symmetric-iso-zero-bond');
if ~isfolder(resultsDir)
    mkdir(resultsDir);
end
homeDir = char(java.lang.System.getProperty('user.home'));
outputsDir = fullfile(homeDir, 'repos', 'reconXmoieties', 'results', 'moietySizing', 'outputs');
inputsPath = fullfile(outputsDir, 'extractBondSubgraphsPeeling', 'n1960-inputs.mat');
pairPath = fullfile(repoRoot, 'test', 'verifiedTests', 'analysis', 'testReactingMoieties', ...
    'data', 'nearSymmetricBondComponentPair.mat');

mode = getenv('CBT_SIZ_MODE');
if isempty(mode)
    mode = 'baseline';
end
nRuns = 3;
if ~isempty(getenv('CBT_SIZ_RUNS'))
    nRuns = str2double(getenv('CBT_SIZ_RUNS'));
end
if ~isfile(inputsPath)
    error('symmetricIsoTimingCheck:missingCapture', ...
        'The 1,960-reaction capture %s is missing; stop and report (tasks.md T003).', inputsPath);
end

[~, gitCommit] = system(sprintf('git -C "%s" rev-parse --short HEAD', repoRoot));
[~, gitDirty] = system(sprintf('git -C "%s" status --porcelain -- src', repoRoot));
srcState = strtrim(gitCommit);
if ~isempty(strtrim(gitDirty))
    srcState = [srcState '+modified'];
end
runTime = char(datetime('now', 'TimeZone', 'UTC', 'Format', 'yyyy-MM-dd HH:mm'));
[~, loadBefore] = system('uptime');

S = load(inputsPath, 'BIG', 'ATG');
tStart = tic;
bondSubgraphs = extractBondSubgraphs(S.BIG, S.ATG);
extractSeconds = toc(tStart);
clear S
fprintf('%d bond-mapping components extracted in %.1f s\n', numel(bondSubgraphs), extractSeconds);

switch mode
    case 'baseline'
        useHelper(baselineDir, baselinePath, true);
        baselineRuns = zeros(nRuns, 1);
        for run = 1:nRuns
            [baselineCallCount, baselineOut, baselineRuns(run)] = classifyOnce(bondSubgraphs);
            fprintf('baseline run %d: %.2f s, %d candidate pairs\n', run, baselineRuns(run), ...
                baselineCallCount);
        end
        useHelper(baselineDir, srcPath, false);
        [~, loadAfter] = system('uptime');
        save(fullfile(resultsDir, 'baseline_timing.mat'), 'baselineRuns', 'baselineCallCount', ...
            'baselineOut', 'srcState', 'runTime', 'loadBefore', 'loadAfter', 'nRuns');
        fprintf('SC-005 baseline: median %.2f s over %d runs (%s)\n', median(baselineRuns), nRuns, ...
            mat2str(baselineRuns', 4));

    case 'compare'
        % SC-001: the stored near-symmetric pair, source helper
        useHelper(baselineDir, srcPath, false);
        P = load(pairPath, 'g1', 'g2');
        pairRuns = zeros(nRuns, 1);
        for run = 1:nRuns
            tStart = tic;
            pairClasses = classifySubgraphIsomorphism({P.g1; P.g2});
            pairRuns(run) = toc(tStart);
            assert(isequal(pairClasses, {[1, 2]}), 'The stored pair is not one isomorphism class.');
        end
        fprintf('SC-001: stored pair one class; maximum %.3f s over %d runs (%s)\n', max(pairRuns), ...
            nRuns, mat2str(pairRuns', 4));

        % SC-005: alternating baseline and source runs on the 1,960-reaction components
        baselineRuns = zeros(nRuns, 1);
        sourceRuns = zeros(nRuns, 1);
        for run = 1:nRuns
            useHelper(baselineDir, baselinePath, true);
            [baselineCallCount, baselineOut, baselineRuns(run)] = classifyOnce(bondSubgraphs);
            useHelper(baselineDir, srcPath, false);
            [sourceCallCount, sourceOut, sourceRuns(run)] = classifyOnce(bondSubgraphs);
            fallbackCount = classifySubgraphIsomorphism('getFallbackCount');
            fprintf('run %d: baseline %.2f s, source %.2f s, fallbacks %d\n', run, ...
                baselineRuns(run), sourceRuns(run), fallbackCount);
        end
        [~, loadAfter] = system('uptime');
        sameClassification = isequal(baselineOut, sourceOut);
        sameCallCount = baselineCallCount == sourceCallCount;
        ratio = median(sourceRuns) / median(baselineRuns);
        earlier = load(fullfile(resultsDir, 'baseline_timing.mat'), 'baselineRuns', 'baselineOut');
        sameAsT003 = isequal(earlier.baselineOut, sourceOut);
        ratioT003 = median(sourceRuns) / median(earlier.baselineRuns);
        save(fullfile(resultsDir, 'after_timing.mat'), 'pairRuns', 'baselineRuns', 'sourceRuns', ...
            'ratio', 'ratioT003', 'sameClassification', 'sameAsT003', 'sameCallCount', ...
            'baselineCallCount', 'sourceCallCount', 'fallbackCount', 'srcState', 'runTime', ...
            'loadBefore', 'loadAfter', 'nRuns');
        fprintf(['SC-005: median source/baseline %.2f / %.2f = %.3f (limit 1.10); against T003 ' ...
            'baseline %.3f; classification identical %d (T003 %d); candidate pairs %d/%d; ' ...
            'fallbacks %d\n'], median(sourceRuns), median(baselineRuns), ratio, ratioT003, ...
            sameClassification, sameAsT003, baselineCallCount, sourceCallCount, fallbackCount);
        if ~(sameClassification && sameAsT003 && sameCallCount)
            error('symmetricIsoTimingCheck:mismatch', ...
                'The classification or candidate-pair count differs from the pre-change helper.');
        end

    otherwise
        error('symmetricIsoTimingCheck:unknownMode', 'Unknown CBT_SIZ_MODE "%s".', mode);
end
fprintf('Load before: %s\nLoad after: %s\n', strtrim(loadBefore), strtrim(loadAfter));

%% Local functions
function useHelper(baselineDir, expectedPath, useBaseline)
% Put the baseline helper in front of the source (or remove it) and assert which is active
if useBaseline
    addpath(baselineDir, '-begin');
elseif contains(path, baselineDir)
    rmpath(baselineDir);
end
activePath = which('classifySubgraphIsomorphism');
if ~strcmp(activePath, expectedPath)
    error('symmetricIsoTimingCheck:wrongHelper', ...
        'Active classifySubgraphIsomorphism is %s, expected %s.', activePath, expectedPath);
end
end

function [callCount, outputs, seconds] = classifyOnce(subgraphs)
% Unlabelled classification, as in findAndExtractMolecularGraphs
classifySubgraphIsomorphism('resetCallCount');
tStart = tic;
[classes, firsts, subsequent] = classifySubgraphIsomorphism(subgraphs);
seconds = toc(tStart);
callCount = classifySubgraphIsomorphism('getCallCount');
outputs = {classes, firsts, subsequent};
end
