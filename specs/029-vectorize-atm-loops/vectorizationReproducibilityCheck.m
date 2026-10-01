% vectorizationReproducibilityCheck.m
%
% Non-CI reproducibility check for feature 029-vectorize-atm-loops (Constitution
% Principle III's documented-reproducibility-check substitute; spec FR-010, FR-011,
% SC-002, SC-003, SC-004). Structural template: feature 022's
% tyrosineReproducibilityCheck.m (snapshot-presence mode selection, append-only
% results file), extended to all 8 reconXmoieties fixtures, per-fixture resumable.
%
% What it compares, per fixture:
%   - ATM.Edges immediately after stage02 (User Story 1). ATM is internal to
%     identifyConservedReactingMoieties and never returned, so it is read through a
%     TEMPORARY capture hook in src/ (tasks.md T007, research.md R10) which saves it
%     to the file named by CBT029_CAPTURE_FILE. With CBT029_STOP_AFTER_CAPTURE=1 the
%     hook ends the call right after saving: nothing after stage02 is needed here,
%     and stopping turns a multi-hour pufa run into roughly its graph-build time.
%   - BIG.Nodes / BIG.Edges (User Story 2), from calling createBIGraph directly on
%     the build output BG, which is identical to the in-function input at line 566.
%   - Corpus provenance (research.md R11): a mismatch is reported as a corpus
%     change, never as a code regression.
%
% USAGE (headless, after initCobraToolbox):
%   setenv('CBT029_FIXTURES', 'tyr,phe');  % optional subset; default: all 8
%   setenv('CBT029_SANITY', '1');          % optional: options.sanityChecks = 1 pass
%   setenv('CBT029_MODE', 'synthetic');    % optional: synthetic stage02 section only
%   run('specs/029-vectorize-atm-loops/vectorizationReproducibilityCheck.m')
%
% Mode per fixture: CAPTURE if its snapshot is absent, otherwise COMPARE.

thisDir = fileparts(mfilename('fullpath'));
repoRoot = fileparts(fileparts(thisDir));
homeDir = getenv('HOME');

corpusDir = '/media/JACK/repos/ctf/rxns/moiety_rxns/atomMapped_std';   % NOT atomMapped_standardised (research.md R8)
subModelMatPath = fullfile(homeDir, 'repos', 'ReconXKG-cidev', 'ReconXKGtoCobra', 'models', ...
    'subsystemSubModels', 'subsystemSubModels.mat');
externalDir = fullfile(homeDir, 'repos', 'reconXmoieties', 'experiments', 'moietySizing', ...
    'results', 'outputs', 'vectorization029');
snapshotDir = fullfile(thisDir, 'snapshots');
resultsPath = fullfile(thisDir, 'vectorization-reproducibility-results.md');
snapshotSizeLimitBytes = 10 * 1024^2;   % research.md R7

allFixtures = {'nglycan', 'phe', 'andest', 'chol', 'urea', 'tyr', 'bileacid', 'pufa'};

if strcmp(getenv('CBT029_MODE'), 'synthetic')
    runSyntheticStage02Section(resultsPath);
    return
end

%% Environment
assert(isfolder(corpusDir), 'Atom-mapped corpus not found: %s', corpusDir)
assert(isfile(subModelMatPath), 'Subsystem submodels not found: %s', subModelMatPath)
assert(exist('identifyConservedReactingMoieties', 'file') == 2, 'COBRA Toolbox not on path.')
if ~isfolder(snapshotDir)
    mkdir(snapshotDir);
end
if ~isfolder(externalDir)
    mkdir(externalDir);
end

fixtureList = allFixtures;
if ~isempty(getenv('CBT029_FIXTURES'))
    fixtureList = strtrim(strsplit(getenv('CBT029_FIXTURES'), ','));
    assert(all(ismember(fixtureList, allFixtures)), 'Unknown fixture in CBT029_FIXTURES.')
end
sanityMode = strcmp(getenv('CBT029_SANITY'), '1');
if sanityMode
    snapshotSuffix = '-sanity';
else
    snapshotSuffix = '';
end

loaded = load(subModelMatPath, 'subModels');
subModels = loaded.subModels;
provenance = corpusProvenance(corpusDir);
gitCommit = currentGitCommit(repoRoot);

if ~isfile(resultsPath)
    fid = fopen(resultsPath, 'w');
    fprintf(fid, ['# Vectorization reproducibility results (feature 029)\n\n' ...
        'Append-only. One row per fixture per run. Speedup = before / after.\n\n' ...
        '| Run (UTC) | Fixture | sanityChecks | Mode | Status | Rxns | Mets | ATM.Edges eq | BIG.Nodes eq | BIG.Edges eq | BIG guard | stage02 s (before -> after, speedup) | createBIGraph s (before -> after, speedup) | Corpus (.rxn, flagged) | Snapshot | Commit | Notes |\n' ...
        '|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|\n']);
    fclose(fid);
end

anyFailure = false;
for f = 1:numel(fixtureList)
    name = fixtureList{f};
    snapFile = fullfile(snapshotDir, sprintf('%s%s-golden-snapshot.mat', name, snapshotSuffix));
    pointerFile = strrep(snapFile, '.mat', '.external.txt');
    captureMode = ~isfile(snapFile) && ~isfile(pointerFile);
    fprintf('\n=== 029 %s: %s (sanityChecks=%d) ===\n', upper(ternary(captureMode, 'capture', 'compare')), name, sanityMode);

    row = struct('fixture', name, 'mode', ternary(captureMode, 'capture', 'compare'), ...
        'status', 'ERROR', 'nRxns', NaN, 'nMets', NaN, 'atmEq', '-', 'bigNodesEq', '-', ...
        'bigEdgesEq', '-', 'bigGuard', '-', 'stage02', '-', 'createBIGraph', '-', ...
        'snapshot', '-', 'notes', '');
    try
        rec = runFixturePipeline(subModels.(name), corpusDir, sanityMode);
        row.nRxns = rec.nRxns;
        row.nMets = rec.nMets;
        row.bigGuard = yesNo(rec.bigGuardPass);
        if ~rec.bigGuardPass
            row.notes = 'BIG.Nodes ~= dATM.Nodes (the line-567 guard condition)';
        end

        if captureMode
            snapshot = struct();
            snapshot.fixtureName = name;
            snapshot.sanityChecks = sanityMode;
            snapshot.nReactions = rec.nRxns;
            snapshot.nMetabolites = rec.nMets;
            snapshot.atmEdges = rec.atmEdges;
            snapshot.bigNodes = rec.bigNodes;
            snapshot.bigEdges = rec.bigEdges;
            snapshot.corpusProvenance = provenance;
            snapshot.stage02Seconds = rec.stage02Seconds;
            snapshot.createBIGraphSeconds = rec.createBIGraphSeconds;
            snapshot.capturedAt = char(datetime('now', 'TimeZone', 'UTC', 'Format', 'yyyy-MM-dd''T''HH:mm:ss''Z'''));
            snapshot.gitCommit = gitCommit;
            save(snapFile, '-struct', 'snapshot', '-v7');
            row.snapshot = placeSnapshot(snapFile, pointerFile, externalDir, snapshotSizeLimitBytes);
            row.status = ternary(rec.bigGuardPass, 'CAPTURED', 'CAPTURED (guard fail)');
            row.stage02 = sprintf('%.4f', rec.stage02Seconds);
            row.createBIGraph = sprintf('%.4f', rec.createBIGraphSeconds);
        else
            [baseline, row.snapshot] = loadSnapshot(snapFile, pointerFile);
            row.stage02 = speedupText(baseline.stage02Seconds, rec.stage02Seconds);
            row.createBIGraph = speedupText(baseline.createBIGraphSeconds, rec.createBIGraphSeconds);
            if ~isequal(baseline.corpusProvenance, provenance)
                row.status = 'CORPUS CHANGED SINCE CAPTURE';
                row.notes = 'Not a code comparison: re-capture this fixture against the current corpus (research.md R11).';
            else
                atmEq = isequal(baseline.atmEdges, rec.atmEdges);
                nodesEq = isequal(baseline.bigNodes, rec.bigNodes);
                edgesEq = isequal(baseline.bigEdges, rec.bigEdges);
                row.atmEq = yesNo(atmEq);
                row.bigNodesEq = yesNo(nodesEq);
                row.bigEdgesEq = yesNo(edgesEq);
                if atmEq && nodesEq && edgesEq && rec.bigGuardPass
                    row.status = 'PASS';
                else
                    row.status = 'FAIL';
                    anyFailure = true;
                end
            end
        end
    catch ME
        anyFailure = true;
        row.status = 'ERROR';
        row.notes = describeError(ME);
        fprintf(2, '  %s\n', row.notes);
    end

    appendResultRow(resultsPath, row, sanityMode, provenance, gitCommit);
    fprintf('  status: %s\n', row.status);
end

if anyFailure
    error('CBT029:reproducibilityFailure', ...
        'At least one fixture failed or errored; see %s', resultsPath);
end

%% ---------------------------------------------------------------------------
%% Local functions
%% ---------------------------------------------------------------------------

function rec = runFixturePipeline(model, corpusDir, sanityMode)
% Build the graphs, read ATM.Edges through the temporary hook, and run createBIGraph.
options = struct('directed', 0, 'sanityChecks', double(sanityMode), 'conservedMoietiesOnly', true);
rec.nRxns = numel(model.rxns);
rec.nMets = numel(model.mets);

[dATM, ~, ~, ~, ~, ~, BG] = buildAtomAndBondTransitionMultigraph(model, corpusDir, options);

captureFile = [tempname '.mat'];
setenv('CBT029_CAPTURE_FILE', captureFile);
setenv('CBT029_STOP_AFTER_CAPTURE', '1');
restoreEnv = onCleanup(@() clearCaptureEnvironment());
try
    identifyConservedReactingMoieties(model, BG, dATM, options);
catch ME
    if ~strcmp(ME.identifier, 'CBT029:captureDone')
        rethrow(ME);
    end
end
clear restoreEnv
% Without sanityChecks this proves stage02 ran; with sanityChecks = 1 it also proves
% the stage02 sanityChecks block passed, because the hook sits after it (FR-006).
assert(isfile(captureFile), 'CBT029:hookDidNotFire', ...
    'Capture hook did not write %s: is the T007 hook present in src/?', captureFile);
captured = load(captureFile);
delete(captureFile);
rec.atmEdges = captured.stage02AtmEdges;
rec.stage02Seconds = captured.stage02Seconds;

tBig = tic;
BIG = createBIGraph(BG);
rec.createBIGraphSeconds = toc(tBig);
rec.bigNodes = BIG.Nodes;
rec.bigEdges = BIG.Edges;
rec.bigGuardPass = isequal(BIG.Nodes, dATM.Nodes);
end

function clearCaptureEnvironment()
setenv('CBT029_CAPTURE_FILE', '');
setenv('CBT029_STOP_AFTER_CAPTURE', '');
end

function prov = corpusProvenance(corpusDir)
% Corpus path, top-level .rxn count, and sorted contents of flagged_for_review/ (R11).
topLevel = dir(fullfile(corpusDir, '*.rxn'));
flaggedDir = fullfile(corpusDir, 'flagged_for_review');
flaggedNames = {};
if isfolder(flaggedDir)
    listing = dir(flaggedDir);
    listing = listing(~[listing.isdir]);
    flaggedNames = sort({listing.name})';
end
prov = struct();
prov.corpusDir = corpusDir;
prov.nTopLevelRxn = numel(topLevel);
prov.flaggedForReview = flaggedNames;
end

function commit = currentGitCommit(repoRoot)
[status, out] = system(sprintf('git -C "%s" rev-parse HEAD', repoRoot));
if status ~= 0
    commit = 'UNKNOWN';
    return
end
commit = strtrim(out);
[~, dirty] = system(sprintf('git -C "%s" status --porcelain -- src', repoRoot));
if ~isempty(strtrim(dirty))
    commit = [commit '+src-uncommitted'];
end
end

function location = placeSnapshot(snapFile, pointerFile, externalDir, sizeLimitBytes)
% Keep small snapshots in the repo; move large ones out, leaving a pointer (R7).
info = dir(snapFile);
if info.bytes <= sizeLimitBytes
    location = sprintf('in repo (%.1f MB)', info.bytes / 1024^2);
    return
end
[~, base, ext] = fileparts(snapFile);
externalFile = fullfile(externalDir, [base ext]);
movefile(snapFile, externalFile);
hash = sha256OfFile(externalFile);
fid = fopen(pointerFile, 'w');
fprintf(fid, 'path: %s\nsha256: %s\nbytes: %d\n', externalFile, hash, info.bytes);
fclose(fid);
location = sprintf('external (%.1f MB, sha256 %s)', info.bytes / 1024^2, hash(1:12));
end

function [baseline, location] = loadSnapshot(snapFile, pointerFile)
if isfile(snapFile)
    baseline = load(snapFile);
    location = 'in repo';
    return
end
pointer = fileread(pointerFile);
externalFile = strtrim(regexp(pointer, '(?<=path: )[^\n]+', 'match', 'once'));
expectedHash = strtrim(regexp(pointer, '(?<=sha256: )[0-9a-f]+', 'match', 'once'));
assert(isfile(externalFile), 'External snapshot missing: %s', externalFile);
actualHash = sha256OfFile(externalFile);
assert(strcmp(actualHash, expectedHash), ...
    'External snapshot hash mismatch for %s (expected %s, got %s).', externalFile, expectedHash, actualHash);
baseline = load(externalFile);
location = sprintf('external (sha256 verified %s)', expectedHash(1:12));
end

function hash = sha256OfFile(filePath)
[status, out] = system(sprintf('sha256sum "%s"', filePath));
assert(status == 0, 'sha256sum failed for %s', filePath);
hash = strtok(strtrim(out));
end

function text = speedupText(beforeSeconds, afterSeconds)
text = sprintf('%.4f -> %.4f (%.1fx)', beforeSeconds, afterSeconds, beforeSeconds / afterSeconds);
end

function appendResultRow(resultsPath, row, sanityMode, provenance, gitCommit)
runTime = char(datetime('now', 'TimeZone', 'UTC', 'Format', 'yyyy-MM-dd HH:mm'));
corpusText = sprintf('%d, %d flagged', provenance.nTopLevelRxn, numel(provenance.flaggedForReview));
fid = fopen(resultsPath, 'a');
fprintf(fid, '| %s | %s | %d | %s | %s | %g | %g | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s |\n', ...
    runTime, row.fixture, sanityMode, row.mode, row.status, row.nRxns, row.nMets, ...
    row.atmEq, row.bigNodesEq, row.bigEdgesEq, row.bigGuard, row.stage02, row.createBIGraph, ...
    corpusText, row.snapshot, shortCommit(gitCommit), strrep(row.notes, '|', '/'));
fclose(fid);
end

function text = shortCommit(gitCommit)
% Short hash, keeping the uncommitted-src marker visible.
[hash, marker] = strtok(gitCommit, '+');
text = [hash(1:min(12, end)) marker];
end

function text = describeError(ME)
% Full ME information, including the failing frame (Constitution VII-C).
if isempty(ME.stack)
    text = sprintf('%s: %s', ME.identifier, ME.message);
else
    text = sprintf('%s: %s (%s:%d)', ME.identifier, ME.message, ME.stack(1).file, ME.stack(1).line);
end
end

function text = yesNo(flag)
text = ternary(flag, 'yes', 'NO');
end

function out = ternary(condition, a, b)
if condition
    out = a;
else
    out = b;
end
end

%% ---------------------------------------------------------------------------
%% Synthetic stage02 edge-case section (research.md R12; tasks.md T006a, T011a)
%% ---------------------------------------------------------------------------

function runSyntheticStage02Section(resultsPath)
% Runs the verbatim copy of the ORIGINAL stage02 loop on hand-built inputs covering the
% cases the fixtures may not contain. T011a adds the copy of the NEW block and compares.
% These copies check semantics only; the fixture runs are the proof of the shipped code.
cases = syntheticStage02Cases();
fid = fopen(resultsPath, 'a');
fprintf(fid, '\n### Synthetic stage02 section — %s UTC\n\n| Case | Rows | Original copy ran | Original vs new |\n|---|---|---|---|\n', ...
    char(datetime('now', 'TimeZone', 'UTC', 'Format', 'yyyy-MM-dd HH:mm')));
allEqual = true;
for c = 1:numel(cases)
    ATM = struct('Edges', cases(c).edges);
    ATMorig = stage02OriginalLoop(ATM, cases(c).orientation, height(cases(c).edges));
    ATMnew = stage02VectorizedBlock(ATM, cases(c).orientation);
    isSame = isequal(ATMorig.Edges, ATMnew.Edges);
    allEqual = allEqual && isSame;
    fprintf(fid, '| %s | %d | yes | %s |\n', cases(c).name, height(cases(c).edges), ternary(isSame, 'identical (isequal)', 'DIFFERENT'));
    fprintf('  synthetic %-15s rows=%d  original vs new: %s\n', cases(c).name, height(ATMorig.Edges), ternary(isSame, 'identical', 'DIFFERENT'));
end
fclose(fid);
assert(allEqual, 'CBT029:syntheticMismatch', ...
    'The vectorized stage02 block differs from the original loop on at least one synthetic case.');
end

function cases = syntheticStage02Cases()
% Hand-built ATM.Edges tables. The mixed case deliberately includes orientation-0 rows
% (research.md R1: the loop routes them to the reverse branch), a Trans with no '#',
% and a Trans with several '#' (R2).
mk = @(endNodes, trans, headIdx, tailIdx, headAtom, tailAtom) table( ...
    endNodes, trans, headIdx, tailIdx, headAtom, tailAtom, ...
    'VariableNames', {'EndNodes', 'Trans', 'HeadAtomIndex', 'TailAtomIndex', 'HeadAtom', 'TailAtom'});

mixed = mk([1 2; 3 4; 5 6; 7 8; 9 10; 11 12], ...
    {'R1#A1#B1'; 'R2#A2#B2'; 'R3#A3#B3'; 'noHash'; 'R5#a#b#c'; 'R6#x#y'}, ...
    [1; 4; 6; 7; 9; 12], [2; 3; 5; 8; 10; 11], ...
    {'A1'; 'A2'; 'A3'; 'A4'; 'A5'; 'A6'}, {'B1'; 'B2'; 'B3'; 'B4'; 'B5'; 'B6'});
cases(1) = struct('name', 'mixed', 'edges', mixed, 'orientation', [1; -1; 0; 1; 1; -1]);

empty = mk(zeros(0, 2), cell(0, 1), zeros(0, 1), zeros(0, 1), cell(0, 1), cell(0, 1));
cases(2) = struct('name', 'empty', 'edges', empty, 'orientation', zeros(0, 1));

forward = mk([1 2; 3 4; 5 6], {'R1#A#B'; 'R2#C#D'; 'R3#E#F'}, [1; 3; 5], [2; 4; 6], ...
    {'A'; 'C'; 'E'}, {'B'; 'D'; 'F'});
cases(3) = struct('name', 'allForward', 'edges', forward, 'orientation', ones(3, 1));

reverse = mk([1 2; 3 4; 5 6], {'R1#A#B'; 'R2#C#D'; 'R3#E#F'}, [2; 4; 6], [1; 3; 5], ...
    {'A'; 'C'; 'E'}, {'B'; 'D'; 'F'});
cases(4) = struct('name', 'allReverse', 'edges', reverse, 'orientation', -ones(3, 1));

zeroOnly = mk([1 2; 3 4], {'R1#A#B'; 'R2#C#D'}, [1; 3], [2; 4], {'A'; 'C'}, {'B'; 'D'});
cases(5) = struct('name', 'orientationZero', 'edges', zeroOnly, 'orientation', zeros(2, 1));
end

function ATM = stage02VectorizedBlock(ATM, orientationATM2dATM)
% TEST COPY of the vectorized stage02 block shipped in
% src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m by feature 029
% (tasks.md T011). Verbatim; T021 confirms it matches the shipped lines (research.md R12).
% Any row that is not forward-oriented takes the reverse branch, including
% orientation 0 rows when sanityChecks is off, exactly as the per-row loop did.
forwardOriented = orientationATM2dATM == 1;
reverseOriented = ~forwardOriented;

%remove the reaction prefix from the Transition name
[~, transRemainder] = cellfun(@(transName) strtok(transName, '#'), ...
    ATM.Edges.Trans(forwardOriented), 'UniformOutput', false);
ATM.Edges.Trans(forwardOriented) = cellfun(@(remainder) remainder(2:end), ...
    transRemainder, 'UniformOutput', false);

ATM.Edges.HeadAtomIndex(reverseOriented) = ATM.Edges.EndNodes(reverseOriented, 2);
ATM.Edges.TailAtomIndex(reverseOriented) = ATM.Edges.EndNodes(reverseOriented, 1);
reorientedHeadAtom = ATM.Edges.TailAtom(reverseOriented);
reorientedTailAtom = ATM.Edges.HeadAtom(reverseOriented);
ATM.Edges.HeadAtom(reverseOriented) = reorientedHeadAtom;
ATM.Edges.TailAtom(reverseOriented) = reorientedTailAtom;
ATM.Edges.Trans(reverseOriented) = cellfun(@(headAtom, tailAtom) [headAtom '#' tailAtom], ...
    reorientedHeadAtom, reorientedTailAtom, 'UniformOutput', false);
end

function ATM = stage02OriginalLoop(ATM, orientationATM2dATM, nTransInstances)
% TEST COPY of src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m
% lines 321-335 as of commit 4b8409d5c (pre-change). Verbatim; do not edit (research.md R12).
for i=1:nTransInstances
    if orientationATM2dATM(i)==1
        %remove the reaction prefix from the Transition name
        [~,rem]=strtok(ATM.Edges.Trans{i},'#');
        ATM.Edges.Trans{i}=rem(2:end);
    else
        ATM.Edges.HeadAtomIndex(i) = ATM.Edges.EndNodes(i,2);
        ATM.Edges.TailAtomIndex(i) = ATM.Edges.EndNodes(i,1);
        HeadAtom = ATM.Edges.TailAtom{i};
        TailAtom = ATM.Edges.HeadAtom{i};
        ATM.Edges.HeadAtom{i} = HeadAtom;
        ATM.Edges.TailAtom{i} = TailAtom;
        ATM.Edges.Trans{i} = [HeadAtom '#' TailAtom];
    end
end
end
