% extractBondSubgraphsPeelingCheck.m
%
% Non-CI reproducibility check and benchmark for feature
% 20260928-100409-extract-bond-subgraphs-local-peeling (tasks.md T012, T022-T024, T029;
% spec FR-002, FR-009, FR-012, SC-001 to SC-005; research R7, R10).
%
% For each captured fixture (inputs and pre-change golden outputs written by
% captureLocalPeelingFixtures.m to the local results tree), it:
%   1. runs the current extractBondSubgraphs and compares all three outputs with the
%      pre-change outputs: first by the SHA-256 fingerprints saved at capture (research R8),
%      and, if any fingerprint differs, live against extractBondSubgraphsBaseline by the
%      FR-002 rule (same cell sizes, graph class, isequaln Nodes/Edges, isequaln
%      bmgEdgeIndex), which then decides;
%   2. counts, under the profiler, the rmedge and subgraph calls made from the source file
%      of extractBondSubgraphs (every local function included), and records the pass count
%      (the rmedge count of the pre-change function, one call per pass);
%   3. records whether FR-009 held on the pre-change function (k never advanced), as
%      measured by extractBondSubgraphsBaselineAssertK when the fixture was captured;
% and appends one row per fixture to extractBondSubgraphsPeelingResults.md. Unless
% CBT_EBS_NO_TIMING=1, it then times the pre-change and current functions back to back
% (alternating, CBT_EBS_TIMING_RUNS runs each, default 3), reports medians, the output
% size, SC-004 on n1960 and the SC-005 log-log exponents across the nested subsets.
% With CBT_EBS_END_TO_END=1 it also runs identifyConservedReactingMoieties on the
% 1,960-reaction model and compares all its outputs with the golden run (SC-002).
%
% USAGE (headless, after initCobraToolbox):
%   setenv('CBT_EBS_FIXTURES', 'tyr,n332');   % optional subset; default: all six
%   setenv('CBT_EBS_NO_TIMING', '1');         % optional: equality and call counts only
%   setenv('CBT_EBS_END_TO_END', '1');        % optional: SC-002 end-to-end check
%   run('specs/20260928-100409-extract-bond-subgraphs-local-peeling/extractBondSubgraphsPeelingCheck.m')

featureDir = fileparts(mfilename('fullpath'));
repoRoot = fileparts(fileparts(featureDir));
addpath(featureDir);   % baseline copies, fingerprints, model builder
srcPath = which('extractBondSubgraphs');
baselinePath = fullfile(featureDir, 'extractBondSubgraphsBaseline.m');
homeDir = char(java.lang.System.getProperty('user.home'));
extDir = fullfile(homeDir, 'repos', 'reconXmoieties', 'experiments', 'moietySizing', ...
    'results', 'outputs', 'extractBondSubgraphsPeeling');
resultsPath = fullfile(featureDir, 'extractBondSubgraphsPeelingResults.md');

fixtureList = {'tyr', 'n332', 'n531', 'n1067', 'n1604', 'n1960'};
if ~isempty(getenv('CBT_EBS_FIXTURES'))
    fixtureList = strtrim(strsplit(getenv('CBT_EBS_FIXTURES'), ','));
end
[~, gitCommit] = system(sprintf('git -C "%s" rev-parse --short HEAD', repoRoot));
[~, gitDirty] = system(sprintf('git -C "%s" status --porcelain -- %s', repoRoot, ...
    'src/analysis/topology/reactingMoieties/extractBondSubgraphs.m'));
srcState = strtrim(gitCommit);
if ~isempty(strtrim(gitDirty))
    srcState = [srcState '+modified'];
end
runTime = char(datetime('now', 'TimeZone', 'UTC', 'Format', 'yyyy-MM-dd HH:mm'));

fid = fopen(resultsPath, 'a');
fprintf(fid, ['\n### Equality and call counts, %s UTC, source %s\n\n' ...
    '| Fixture | Reactions | Outputs | Identical | rmedge calls | subgraph calls | Passes | k always first | Notes |\n' ...
    '|---|---|---|---|---|---|---|---|---|\n'], runTime, srcState);
fclose(fid);

anyMismatch = false;
for f = 1:numel(fixtureList)
    name = fixtureList{f};
    fprintf('\n=== fixture %s ===\n', name);
    inputs = load(fullfile(extDir, [name '-inputs.mat']));
    golden = load(fullfile(extDir, [name '-golden.mat']));

    [bondSubgraphs, BMG, bmgEdgeIndex] = extractBondSubgraphs(inputs.BIG, inputs.ATG);
    if isequal(fingerprintBondSubgraphOutputs(bondSubgraphs, BMG, bmgEdgeIndex), golden.fingerprint)
        isIdentical = true;
        note = 'fingerprints equal';
    else
        baseline = struct();
        [baseline.bondSubgraphs, baseline.BMG, baseline.bmgEdgeIndex] = ...
            extractBondSubgraphsBaseline(inputs.BIG, inputs.ATG);
        [isIdentical, note] = compareWithGolden(bondSubgraphs, BMG, bmgEdgeIndex, baseline);
        note = ['fingerprints differ; live isequaln vs pre-change: ' ternary(isIdentical, ...
            'equal', 'DIFFERENT') ' ' note];
        clear baseline
    end
    anyMismatch = anyMismatch || ~isIdentical;
    clear bondSubgraphs BMG bmgEdgeIndex

    counts = profileGraphCalls(@() extractBondSubgraphs(inputs.BIG, inputs.ATG), srcPath);
    passFile = fullfile(extDir, [name '-passcount.mat']);
    if ~isfile(passFile) && ~contains(srcState, '+modified')
        % the source is the pre-change function: its rmedge count is the pass count
        passCount = counts.rmedge;
        save(passFile, 'passCount');
    end
    passCount = loadPassCount(extDir, name, inputs, baselinePath);

    fid = fopen(resultsPath, 'a');
    fprintf(fid, '| %s | %d | %d | %s | %d | %d | %d | %s | %s |\n', name, golden.provenance.nRxns, ...
        golden.nOutputs, yesNo(isIdentical), counts.rmedge, counts.subgraph, ...
        passCount, yesNo(golden.kAlwaysFirst), note);
    fclose(fid);
    fprintf('fixture %s: identical %d, rmedge %d, subgraph %d, passes %d %s\n', name, ...
        isIdentical, counts.rmedge, counts.subgraph, passCount, note);
    clear inputs golden
end

%% Timing (SC-004) and scaling (SC-005)
sc004Failed = false;
if ~strcmp(getenv('CBT_EBS_NO_TIMING'), '1')
    nRuns = 3;
    if ~isempty(getenv('CBT_EBS_TIMING_RUNS'))
        nRuns = str2double(getenv('CBT_EBS_TIMING_RUNS'));
    end
    fid = fopen(resultsPath, 'a');
    fprintf(fid, ['\n### Timing, %s UTC, source %s, %d alternating runs each\n\n' ...
        '| Fixture | Reactions | Baseline median s | New median s | Ratio | Output size | Passes |\n' ...
        '|---|---|---|---|---|---|---|\n'], runTime, srcState, nRuns);
    fclose(fid);
    timing = struct('name', {}, 'nRxns', {}, 'baseline', {}, 'new', {}, 'outputSize', {});
    for f = 1:numel(fixtureList)
        name = fixtureList{f};
        inputs = load(fullfile(extDir, [name '-inputs.mat']));
        golden = load(fullfile(extDir, [name '-golden.mat']), 'fingerprint', 'provenance');
        baselineSeconds = zeros(nRuns, 1);
        newSeconds = zeros(nRuns, 1);
        for run = 1:nRuns
            tStart = tic;
            extractBondSubgraphsBaseline(inputs.BIG, inputs.ATG);
            baselineSeconds(run) = toc(tStart);
            tStart = tic;
            extractBondSubgraphs(inputs.BIG, inputs.ATG);
            newSeconds(run) = toc(tStart);
        end
        outputSize = golden.fingerprint.outputSize;
        timing(end + 1) = struct('name', name, 'nRxns', golden.provenance.nRxns, ...
            'baseline', median(baselineSeconds), 'new', median(newSeconds), ...
            'outputSize', outputSize); %#ok<SAGROW>
        passCount = loadPassCount(extDir, name, inputs, baselinePath);
        fid = fopen(resultsPath, 'a');
        fprintf(fid, '| %s | %d | %.2f | %.2f | %.3f | %d | %d |\n', name, timing(end).nRxns, ...
            timing(end).baseline, timing(end).new, timing(end).new / timing(end).baseline, ...
            outputSize, passCount);
        fclose(fid);
        fprintf('timing %s: baseline %.2f s, new %.2f s (ratio %.3f)\n', name, ...
            timing(end).baseline, timing(end).new, timing(end).new / timing(end).baseline);
        clear inputs golden
    end

    fid = fopen(resultsPath, 'a');
    isN1960 = strcmp({timing.name}, 'n1960');
    if any(isN1960)
        ratio = timing(isN1960).new / timing(isN1960).baseline;
        sc004Failed = ratio > 0.15;
        fprintf(fid, '\n- **SC-004 (gate)**: n1960 new/baseline median = %.3f (limit 0.15): %s\n', ...
            ratio, ternary(sc004Failed, 'FAIL', 'PASS'));
    end
    isNested = ismember({timing.name}, {'n332', 'n531', 'n1067', 'n1604', 'n1960'});
    if nnz(isNested) >= 3
        nRxns = [timing(isNested).nRxns]';
        exponent = @(y) subsref(polyfit(log(nRxns), log(y(:)), 1), struct('type', '()', 'subs', {{1}}));
        baselineExponent = exponent([timing(isNested).baseline]);
        newExponent = exponent([timing(isNested).new]);
        sizeExponent = exponent([timing(isNested).outputSize]);
        perSizeExponent = exponent([timing(isNested).new] ./ [timing(isNested).outputSize]);
        if newExponent <= 1.3
            sc005 = 'PASS';
        elseif sizeExponent > 1.1 && perSizeExponent <= 0.3
            sc005 = 'scope-explained';
        else
            sc005 = 'above target (reported, not a gate)';
        end
        fprintf(fid, ['- **SC-005 (reported)**: log-log exponents over %d nested subsets: ' ...
            'baseline %.2f, new %.2f, output size %.2f, new time per output size %.2f: %s\n'], ...
            nnz(isNested), baselineExponent, newExponent, sizeExponent, perSizeExponent, sc005);
    end
    fclose(fid);
end

%% End-to-end check (SC-002)
if strcmp(getenv('CBT_EBS_END_TO_END'), '1')
    corpusDir = '/media/JACK/repos/ctf/rxns/atomMapped_std';
    models = buildLowSymmetrySubsetModels(corpusDir, homeDir);
    [dATM, ~, ~, ~, ~, ~, BG] = buildAtomAndBondTransitionMultigraph(models.n1960, corpusDir, ...
        struct('directed', 0, 'sanityChecks', 0));
    tStart = tic;
    [arm, moietyFormulae, reacting] = identifyConservedReactingMoieties(models.n1960, BG, dATM, ...
        struct('directed', 0, 'sanityChecks', 0, 'conservedMoietiesOnly', true));
    endToEndSeconds = toc(tStart);
    goldenEndToEnd = load(fullfile(extDir, 'n1960-endToEnd-golden.mat'));
    sameArm = isequaln(arm, goldenEndToEnd.arm);
    sameFormulae = isequaln(moietyFormulae, goldenEndToEnd.moietyFormulae);
    sameReacting = isequaln(reacting, goldenEndToEnd.reacting);
    fid = fopen(resultsPath, 'a');
    fprintf(fid, ['\n- **SC-002 (end-to-end, n1960, conservedOnly)**: arm %s, moietyFormulae %s, ' ...
        'reacting %s; identifyConservedReactingMoieties %.0f s (golden run %.0f s)\n'], ...
        yesNo(sameArm), yesNo(sameFormulae), yesNo(sameReacting), endToEndSeconds, ...
        goldenEndToEnd.endToEndSeconds);
    fclose(fid);
    anyMismatch = anyMismatch || ~(sameArm && sameFormulae && sameReacting);
end

if anyMismatch
    error('extractBondSubgraphsPeelingCheck:mismatch', ...
        'At least one fixture differs from its pre-change golden outputs; see %s.', resultsPath);
end
if sc004Failed
    error('extractBondSubgraphsPeelingCheck:sc004', ...
        'SC-004 failed: n1960 new median is above 15%% of the baseline median; see %s.', resultsPath);
end

%% Local functions
function [isIdentical, note] = compareWithGolden(bondSubgraphs, BMG, bmgEdgeIndex, golden)
% FR-002 equality with the pre-change outputs in golden: cell sizes, graph class, isequaln
% Nodes/Edges, isequaln bmgEdgeIndex
note = '';
[okSub, noteSub] = compareGraphCells(bondSubgraphs, golden.bondSubgraphs, 'bondSubgraphs');
[okBMG, noteBMG] = compareGraphCells(BMG, golden.BMG, 'BMG');
okIdx = isequaln(bmgEdgeIndex, golden.bmgEdgeIndex);
isIdentical = okSub && okBMG && okIdx;
if ~isIdentical
    note = strjoin({noteSub, noteBMG, ternary(okIdx, '', 'bmgEdgeIndex differs')}, ' ');
end
end

function [ok, note] = compareGraphCells(A, B, label)
ok = isequal(size(A), size(B));
note = '';
if ~ok
    note = sprintf('%s: size %s vs %s.', label, mat2str(size(A)), mat2str(size(B)));
    return
end
for q = 1:numel(A)
    if ~strcmp(class(A{q}), class(B{q}))
        ok = false;
        note = sprintf('%s{%d}: class differs.', label, q);
        return
    elseif ~isequaln(A{q}.Nodes, B{q}.Nodes)
        ok = false;
        note = sprintf('%s{%d}: Nodes differ.', label, q);
        return
    elseif ~isequaln(A{q}.Edges, B{q}.Edges)
        ok = false;
        note = sprintf('%s{%d}: Edges differ.', label, q);
        return
    end
end
end

function counts = profileGraphCalls(runFunction, filePath)
% rmedge and subgraph calls made from any function defined in filePath (research R10)
profile clear
profile on
runFunction();
profile off
info = profile('info');
functionTable = info.FunctionTable;
counts = struct('rmedge', 0, 'subgraph', 0);
for r = 1:numel(functionTable)
    if ~strcmp(functionTable(r).FileName, filePath)
        continue
    end
    for c = 1:numel(functionTable(r).Children)
        childName = functionTable(functionTable(r).Children(c).Index).FunctionName;
        if contains(childName, 'rmedge')
            counts.rmedge = counts.rmedge + functionTable(r).Children(c).NumCalls;
        elseif contains(childName, 'subgraph')
            counts.subgraph = counts.subgraph + functionTable(r).Children(c).NumCalls;
        end
    end
end
end

function passCount = loadPassCount(extDir, name, inputs, baselinePath)
% Pass count = rmedge calls of the pre-change function (one per pass); computed once
passFile = fullfile(extDir, [name '-passcount.mat']);
if isfile(passFile)
    loaded = load(passFile, 'passCount');
    passCount = loaded.passCount;
    return
end
counts = profileGraphCalls(@() extractBondSubgraphsBaseline(inputs.BIG, inputs.ATG), baselinePath);
passCount = counts.rmedge;
save(passFile, 'passCount');
end

function s = yesNo(tf)
s = ternary(tf, 'yes', 'NO');
end

function out = ternary(condition, a, b)
if condition
    out = a;
else
    out = b;
end
end
