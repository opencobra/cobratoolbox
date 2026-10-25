% reactingOptimisationReproducibilityCheck.m
%
% Non-CI reproducibility check for feature 20260921-154310-reacting-moiety-optimisation
% (Constitution Principle III's documented-reproducibility-check substitute; spec FR-002,
% FR-011, FR-012, SC-001, SC-004, SC-006; research.md R10; tasks.md T004). Structural
% template: specs/029-vectorize-atm-loops/vectorizationReproducibilityCheck.m.
%
% For every fixture and mode it calls identifyConservedReactingMoieties and either
% CAPTURES a golden snapshot (unmodified src/ only) or COMPARES against one:
%   - arm, moietyFormulae and every field of reacting, on value AND class, sparsity and
%     size, recursively (isequaln alone ignores class and sparsity; FR-008);
%   - or, when the call raises an error, the error identifier and message;
%   - the console text of the call (SC-006), recorded with diary (not evalc). Warning
%     backtrace lines ("> In ...") and "(line N)" references are removed before comparing,
%     because they carry source line numbers that legitimately move when src/ is edited;
%     the raw text is kept in the snapshot;
%   - default mode: median of 3 whole-function runs, before (snapshot) vs after (FR-012);
%   - bileacid, default mode: profiler line-time sums over the stage-09 and stage-14..17
%     blocks, found by searching the source for marker comments (reported, not gated).
%
% USAGE (headless, after initCobraToolbox and changeCobraSolver('gurobi', 'all', 0)):
%   setenv('CBT_RMO_FIXTURES', 'ci,tyr');     % optional subset; default: 7 subsystems + ci
%   setenv('CBT_RMO_SANITY', '1');            % optional: sanityChecks = 1 mode only
%   setenv('CBT_RMO_NO_TIMING_GATE', '1');    % optional: report SLOWER without failing
%   setenv('CBT_RMO_TIMING_ONLY', '1');       % optional: timing only (pufa, re-measures)
%   setenv('CBT_RMO_TIMING_RUNS', '1');       % optional: runs for CBT_RMO_TIMING_ONLY (default 3)
%   setenv('CBT_RMO_MODE', 'synthetic');      % optional: synthetic re-indexing section only
%   run('specs/20260921-154310-reacting-moiety-optimisation/reactingOptimisationReproducibilityCheck.m')
%
% Mode per fixture: CAPTURE if its snapshot is absent, otherwise COMPARE. Snapshots are
% never overwritten.

global CBT_MILP_SOLVER

thisDir = fileparts(mfilename('fullpath'));
repoRoot = fileparts(fileparts(thisDir));
homeDir = getenv('HOME');

corpusDir = '/media/JACK/repos/ctf/rxns/moiety_rxns/atomMapped_std';
subModelMatPath = fullfile(homeDir, 'repos', 'ReconXKG-cidev', 'ReconXKGtoCobra', 'models', ...
    'subsystemSubModels', 'subsystemSubModels.mat');
ciRxnDir = fullfile(repoRoot, 'test', 'verifiedTests', 'analysis', 'testReactingMoieties', ...
    'data', 'rxnFiles');
externalDir = fullfile(homeDir, 'repos', 'reconXmoieties', 'experiments', 'moietySizing', ...
    'results', 'outputs', 'reactingOptimisation');
snapshotDir = fullfile(thisDir, 'snapshots');
resultsPath = fullfile(thisDir, 'reacting-optimisation-reproducibility-results.md');
icrmFile = fullfile(repoRoot, 'src', 'analysis', 'topology', 'reactingMoieties', ...
    'identifyConservedReactingMoieties.m');
snapshotSizeLimitBytes = 10 * 1024^2;
nTimingRuns = 3;

subsystemFixtures = {'nglycan', 'phe', 'andest', 'chol', 'urea', 'tyr', 'bileacid'};
allFixtures = [subsystemFixtures, {'ci', 'pufa'}];

if strcmp(getenv('CBT_RMO_MODE'), 'synthetic')
    runSyntheticReindexingSection(resultsPath, icrmFile, repoRoot);
    return
end

%% Environment
assert(exist('identifyConservedReactingMoieties', 'file') == 2, 'COBRA Toolbox not on path.')
if ~isfolder(snapshotDir)
    mkdir(snapshotDir);
end

timingOnly = strcmp(getenv('CBT_RMO_TIMING_ONLY'), '1');
sanityMode = strcmp(getenv('CBT_RMO_SANITY'), '1');
timingGateOn = ~strcmp(getenv('CBT_RMO_NO_TIMING_GATE'), '1');
fixtureList = [subsystemFixtures, {'ci'}];
if ~isempty(getenv('CBT_RMO_FIXTURES'))
    fixtureList = strtrim(strsplit(getenv('CBT_RMO_FIXTURES'), ','));
    assert(all(ismember(fixtureList, allFixtures)), 'Unknown fixture in CBT_RMO_FIXTURES.')
end
assert(timingOnly || ~any(strcmp(fixtureList, 'pufa')), ...
    'pufa has no golden snapshot; run it only with CBT_RMO_TIMING_ONLY=1.')
if timingOnly
    modeList = {'default'};
    if ~isempty(getenv('CBT_RMO_TIMING_RUNS'))
        nTimingRuns = str2double(getenv('CBT_RMO_TIMING_RUNS'));
    end
elseif sanityMode
    modeList = {'sanity'};
else
    modeList = {'default', 'conservedOnly'};
end

gitCommit = currentGitCommit(repoRoot);
subModels = [];
runTime = char(datetime('now', 'TimeZone', 'UTC', 'Format', 'yyyy-MM-dd HH:mm'));
fid = fopen(resultsPath, 'a');
fprintf(fid, ['\n### Run %s UTC — fixtures: %s; modes: %s%s%s\n\n' ...
    '| Fixture | Mode | Run | Status | arm eq | moietyFormulae eq | reacting eq (differing fields) | console eq | median s before -> after (ratio) | targeted stages s before -> after | Solver | Corpus (.rxn) | Snapshot | Commit | Notes |\n' ...
    '|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|\n'], ...
    runTime, strjoin(fixtureList, ','), strjoin(modeList, ','), ...
    ternary(timingOnly, ' (timing only)', ''), ternary(timingGateOn, '', ' (timing gate off)'));
fclose(fid);

anyFailure = false;
failureKinds = {};
for f = 1:numel(fixtureList)
    name = fixtureList{f};
    fprintf('\n=== fixture %s ===\n', name);
    try
        if strcmp(name, 'ci')
            model = buildCiFixtureModel();
            rxnDir = ciRxnDir;
            buildSanity = 1;
            provenance = rxnDirProvenance(ciRxnDir, 'Recon3D_301 r0317/ACONTm/r0426');
        else
            if isempty(subModels)
                assert(isfolder(corpusDir), 'Atom-mapped corpus not found: %s', corpusDir)
                assert(isfile(subModelMatPath), 'Subsystem submodels not found: %s', subModelMatPath)
                loaded = load(subModelMatPath, 'subModels');
                subModels = loaded.subModels;
            end
            model = subModels.(name);
            rxnDir = corpusDir;
            buildSanity = double(sanityMode);
            provenance = rxnDirProvenance(corpusDir, subModelMatPath);
        end
        [dATM, ~, ~, ~, ~, ~, BG] = buildAtomAndBondTransitionMultigraph(model, rxnDir, ...
            struct('directed', 0, 'sanityChecks', buildSanity));
    catch ME
        anyFailure = true;
        failureKinds{end + 1} = 'ERROR'; %#ok<SAGROW>
        appendRow(resultsPath, struct('fixture', name, 'mode', '-', 'run', 'build', ...
            'status', 'ERROR', 'notes', describeError(ME)), gitCommit);
        fprintf(2, '  build failed: %s\n', describeError(ME));
        continue
    end

    for m = 1:numel(modeList)
        mode = modeList{m};
        row = emptyRow(name, mode);
        row.corpus = sprintf('%d', provenance.nRxnFiles);
        row.solver = CBT_MILP_SOLVER;
        snapFile = fullfile(snapshotDir, sprintf('%s-%s-golden-snapshot.mat', name, mode));
        pointerFile = strrep(snapFile, '.mat', '.external.txt');
        haveSnapshot = isfile(snapFile) || isfile(pointerFile);
        options = modeOptions(mode);
        isGatedFixture = any(strcmp(name, subsystemFixtures));
        fprintf('--- %s / %s (%s) ---\n', name, mode, ...
            ternary(timingOnly, 'TIMING', ternary(haveSnapshot, 'COMPARE', 'CAPTURE')));
        try
            if timingOnly
                row.run = 'TIMING';
                rec = timeIdentification(model, BG, dATM, options, nTimingRuns);
                beforeMedian = NaN;
                if haveSnapshot
                    baseline = loadSnapshot(snapFile, pointerFile);
                    beforeMedian = baseline.wholeFunctionMedianSeconds;
                end
                row.timing = timingText(beforeMedian, rec.medianSeconds);
                row.status = timingStatus(beforeMedian, rec.medianSeconds, isGatedFixture, timingGateOn);
                row.notes = sprintf('runs: %s s', strjoin(compose('%.2f', rec.seconds), ', '));
            elseif ~haveSnapshot
                row.run = 'CAPTURE';
                srcStatus = system(sprintf('git -C "%s" diff --quiet develop -- src/', repoRoot));
                assert(srcStatus == 0, 'reactingOptimisationCheck:srcModified', ...
                    'Refusing to CAPTURE: src/ differs from develop.');
                rec = runIdentification(model, BG, dATM, options, mode, name, icrmFile, nTimingRuns);
                snapshot = rec;
                snapshot.fixtureName = name;
                snapshot.mode = mode;
                snapshot.options = options;
                snapshot.milpSolver = CBT_MILP_SOLVER;
                snapshot.corpusProvenance = provenance;
                snapshot.gitCommit = gitCommit;
                snapshot.capturedAt = char(datetime('now', 'TimeZone', 'UTC', ...
                    'Format', 'yyyy-MM-dd''T''HH:mm:ss''Z'''));
                snapshot.nReactions = numel(model.rxns);
                snapshot.nMetabolites = numel(model.mets);
                save(snapFile, '-struct', 'snapshot', '-v7');
                row.snapshot = placeSnapshot(snapFile, pointerFile, externalDir, snapshotSizeLimitBytes);
                row.status = ternary(strcmp(rec.outcome, 'ok'), 'CAPTURED', 'CAPTURED (error outcome)');
                row.timing = timingText(rec.wholeFunctionMedianSeconds, NaN);
                row.stages = stageText(rec.targetedStageSeconds, []);
                if strcmp(rec.outcome, 'error')
                    row.notes = sprintf('%s: %s (%s)', rec.errorIdentifier, rec.errorMessage, rec.errorTopFrame);
                end
            else
                row.run = 'COMPARE';
                [baseline, row.snapshot] = loadSnapshot(snapFile, pointerFile);
                rec = runIdentification(model, BG, dATM, options, mode, name, icrmFile, nTimingRuns);
                row = compareToSnapshot(row, baseline, rec, provenance, CBT_MILP_SOLVER, ...
                    isGatedFixture, timingGateOn);
            end
        catch ME
            row.status = 'ERROR';
            row.notes = describeError(ME);
            fprintf(2, '  %s\n', row.notes);
        end
        if ismember(row.status, {'DIFF', 'CLASS DIFF', 'CONSOLE DIFF', 'ERROR', 'SLOWER', ...
                'SOLVER MISMATCH', 'CORPUS CHANGED SINCE CAPTURE'})
            anyFailure = true;
            failureKinds{end + 1} = row.status; %#ok<SAGROW>
        end
        appendRow(resultsPath, row, gitCommit);
        fprintf('  status: %s\n', row.status);
    end
end

if anyFailure
    kinds = unique(failureKinds);
    if isequal(kinds, {'SOLVER MISMATCH'})
        error('reactingOptimisationCheck:solverMismatch', ...
            'The MILP solver differs from the one used at capture; re-run with it. See %s', resultsPath);
    end
    error('reactingOptimisationCheck:failure', ...
        'At least one fixture reported %s; see %s', strjoin(kinds, ', '), resultsPath);
end

%% ---------------------------------------------------------------------------
%% Local functions
%% ---------------------------------------------------------------------------

function model = buildCiFixtureModel()
% The CI fixture of testConservedReactingMoieties.m (self-contained, in-repo data).
global CBTDIR
fullModel = readCbModel(fullfile(CBTDIR, 'test', 'models', 'mat', 'Recon3D_301.mat'));
model = extractSubNetwork(fullModel, {'r0317'; 'ACONTm'; 'r0426'});
end

function options = modeOptions(mode)
switch mode
    case 'default'
        options = struct('directed', 0, 'sanityChecks', 0);
    case 'conservedOnly'
        options = struct('directed', 0, 'sanityChecks', 0, 'conservedMoietiesOnly', 1);
    case 'sanity'
        options = struct('directed', 0, 'sanityChecks', 1);
    otherwise
        error('reactingOptimisationCheck:unknownMode', 'Unknown mode %s.', mode);
end
end

function rec = runIdentification(model, BG, dATM, options, mode, name, icrmFile, nTimingRuns)
% Outcome + console text in one diary-recorded call, then timing and profiling.
rec = struct('outcome', '', 'arm', [], 'moietyFormulae', [], 'reacting', [], ...
    'errorIdentifier', '', 'errorMessage', '', 'errorTopFrame', '', 'consoleText', '', ...
    'wholeFunctionSeconds', [], 'wholeFunctionMedianSeconds', NaN, 'targetedStageSeconds', []);
diaryFile = [tempname '.txt'];
diary(diaryFile);
try
    [arm, moietyFormulae, reacting] = identifyConservedReactingMoieties(model, BG, dATM, options);
    diary off
    rec.outcome = 'ok';
    rec.arm = arm;
    rec.moietyFormulae = moietyFormulae;
    rec.reacting = reacting;
catch ME
    diary off
    rec.outcome = 'error';
    rec.errorIdentifier = ME.identifier;
    rec.errorMessage = ME.message;
    if isempty(ME.stack)
        rec.errorTopFrame = '';
    else
        rec.errorTopFrame = sprintf('%s:%d', ME.stack(1).name, ME.stack(1).line);
    end
    fprintf('  outcome: error %s\n', describeError(ME));
end
rec.consoleText = fileread(diaryFile);
delete(diaryFile);

if strcmp(rec.outcome, 'ok') && strcmp(mode, 'default')
    timing = timeIdentification(model, BG, dATM, options, nTimingRuns);
    rec.wholeFunctionSeconds = timing.seconds;
    rec.wholeFunctionMedianSeconds = timing.medianSeconds;
    fprintf('  median of %d runs: %.2f s\n', nTimingRuns, timing.medianSeconds);
    if strcmp(name, 'bileacid')
        rec.targetedStageSeconds = profileTargetedStages(model, BG, dATM, options, icrmFile);
    end
end
end

function timing = timeIdentification(model, BG, dATM, options, nRuns)
timing.seconds = zeros(1, nRuns);
for r = 1:nRuns
    tRun = tic;
    identifyConservedReactingMoieties(model, BG, dATM, options);
    timing.seconds(r) = toc(tRun);
end
timing.medianSeconds = median(timing.seconds);
end

function stageSeconds = profileTargetedStages(model, BG, dATM, options, icrmFile)
% Profiler line times (which include time spent in called functions) summed over the
% stage-09 and stage-14..17 blocks of identifyConservedReactingMoieties.m.
icrmLines = strtrim(splitlines(fileread(icrmFile)));
stage09Start = findMarker(icrmLines, '% STEP B1', 1);
stage09End = findMarker(icrmLines, '%map BIG to connected component', stage09Start) - 1;
stage14Start = findMarker(icrmLines, '%Reacting bond graph', stage09End);
stage14End = findMarker(icrmLines, '%% STEP 4', stage14Start) - 1;

profile clear
profile on
identifyConservedReactingMoieties(model, BG, dATM, options);
profile off
profileInfo = profile('info');
functionTable = profileInfo.FunctionTable;
isIcrm = strcmp({functionTable.FunctionName}, 'identifyConservedReactingMoieties');
assert(nnz(isIcrm) == 1, 'Expected one profiler entry for identifyConservedReactingMoieties.');
executedLines = functionTable(isIcrm).ExecutedLines;
lineNumbers = executedLines(:, 1);
lineSeconds = executedLines(:, 3);
stageSeconds = struct();
stageSeconds.stage09 = sum(lineSeconds(lineNumbers >= stage09Start & lineNumbers <= stage09End));
stageSeconds.stage14to17 = sum(lineSeconds(lineNumbers >= stage14Start & lineNumbers <= stage14End));
stageSeconds.wholeFunctionProfiled = functionTable(isIcrm).TotalTime;
stageSeconds.blockLines = [stage09Start stage09End; stage14Start stage14End];
fprintf('  profiled: stage09 %.2f s, stage14to17 %.2f s (lines %d-%d, %d-%d)\n', ...
    stageSeconds.stage09, stageSeconds.stage14to17, stage09Start, stage09End, stage14Start, stage14End);
profile clear
end

function lineNumber = findMarker(lines, prefix, fromLine)
hits = find(startsWith(lines, prefix));
hits = hits(hits >= fromLine);
assert(~isempty(hits), 'Marker "%s" not found after line %d.', prefix, fromLine);
lineNumber = hits(1);
end

function row = compareToSnapshot(row, baseline, rec, provenance, solverNow, isGatedFixture, timingGateOn)
row.timing = timingText(baseline.wholeFunctionMedianSeconds, rec.wholeFunctionMedianSeconds);
row.stages = stageText(baseline.targetedStageSeconds, rec.targetedStageSeconds);
notes = {};
if ~strcmp(baseline.milpSolver, solverNow)
    row.status = 'SOLVER MISMATCH';
    row.notes = sprintf('captured with %s, now %s: not a code comparison', baseline.milpSolver, solverNow);
    return
end
if baseline.corpusProvenance.nRxnFiles ~= provenance.nRxnFiles
    row.status = 'CORPUS CHANGED SINCE CAPTURE';
    row.notes = 'Not a code comparison: the reaction-file corpus changed.';
    return
end

status = 'EQUAL';
if ~strcmp(baseline.outcome, rec.outcome)
    status = 'DIFF';
    notes{end + 1} = sprintf('outcome %s -> %s', baseline.outcome, rec.outcome);
elseif strcmp(rec.outcome, 'error')
    sameError = strcmp(baseline.errorIdentifier, rec.errorIdentifier) && ...
        strcmp(baseline.errorMessage, rec.errorMessage);
    row.armEq = '-';
    row.formulaeEq = '-';
    row.reactingEq = ternary(sameError, 'same error', 'DIFFERENT ERROR');
    notes{end + 1} = sprintf('error outcome: %s', rec.errorIdentifier);
    if ~sameError
        status = 'DIFF';
        notes{end + 1} = sprintf('was %s: %s; now %s: %s', baseline.errorIdentifier, ...
            baseline.errorMessage, rec.errorIdentifier, rec.errorMessage);
    end
else
    [armSame, armPaths, armClass] = compareStrictly(baseline.arm, rec.arm, 'arm');
    [formulaeSame, formulaePaths, formulaeClass] = compareStrictly(baseline.moietyFormulae, ...
        rec.moietyFormulae, 'moietyFormulae');
    [reactingSame, reactingPaths, reactingClass] = compareStrictly(baseline.reacting, ...
        rec.reacting, 'reacting');
    row.armEq = yesNo(armSame);
    row.formulaeEq = yesNo(formulaeSame);
    row.reactingEq = ternary(reactingSame, 'yes', strjoin(reactingPaths(1:min(8, end)), '; '));
    allPaths = [armPaths, formulaePaths, reactingPaths];
    if ~(armSame && formulaeSame && reactingSame)
        if ~isempty(allPaths) && all([armClass, formulaeClass, reactingClass] | ...
                [armSame, formulaeSame, reactingSame])
            status = 'CLASS DIFF';
        else
            status = 'DIFF';
        end
        notes{end + 1} = ['differs: ' strjoin(allPaths(1:min(12, end)), '; ')];
    end
    % FR-008: CRB2R must stay a sparse double (default and sanity modes)
    if isfield(rec.reacting, 'CRB2R')
        crb2rOK = issparse(rec.reacting.CRB2R) && strcmp(class(rec.reacting.CRB2R), 'double');
        if ~crb2rOK
            status = 'CLASS DIFF';
            notes{end + 1} = 'reacting.CRB2R is not a sparse double';
        end
    end
end

consoleSame = strcmp(normaliseConsole(baseline.consoleText), normaliseConsole(rec.consoleText));
row.consoleEq = yesNo(consoleSame);
if ~consoleSame && strcmp(status, 'EQUAL')
    status = 'CONSOLE DIFF';
end

if strcmp(status, 'EQUAL') && ~isnan(rec.wholeFunctionMedianSeconds)
    timeStatus = timingStatus(baseline.wholeFunctionMedianSeconds, ...
        rec.wholeFunctionMedianSeconds, isGatedFixture, timingGateOn);
    if ~strcmp(timeStatus, 'EQUAL')
        status = timeStatus;
    end
end
if strcmp(status, 'SLOWER')
    notes{end + 1} = 're-measure before treating as failure (timing noise)';
end
row.status = status;
row.notes = strjoin(notes, ' / ');
end

function status = timingStatus(beforeSeconds, afterSeconds, isGatedFixture, timingGateOn)
if isnan(beforeSeconds) || isnan(afterSeconds)
    status = 'EQUAL';
elseif ~isGatedFixture
    status = 'TIMING (not gated)';
elseif afterSeconds <= beforeSeconds
    status = 'EQUAL';
elseif timingGateOn
    status = 'SLOWER';
else
    status = 'SLOWER (not gated)';
end
end

function text = normaliseConsole(text)
% Drop warning backtrace lines and "(line N)" references: they carry source line numbers.
lines = splitlines(text);
lines = lines(~startsWith(strtrim(lines), '> In ') & ~startsWith(strtrim(lines), '[> In '));
lines = regexprep(lines, '\(line \d+\)', '(line N)');
text = strjoin(lines, newline);
end

function [isSame, diffPaths, isClassOnly] = compareStrictly(a, b, path)
% Recursive comparison on class, sparsity, size and value (isequaln ignores the first two).
% isClassOnly is true when every difference found is a class/sparsity/size difference.
diffPaths = {};
classDiffs = 0;
[diffPaths, classDiffs] = compareNode(a, b, path, diffPaths, classDiffs);
isSame = isempty(diffPaths);
isClassOnly = ~isSame && classDiffs == numel(diffPaths);
end

function [diffPaths, classDiffs] = compareNode(a, b, path, diffPaths, classDiffs)
if ~strcmp(class(a), class(b)) || issparse(a) ~= issparse(b) || ~isequal(size(a), size(b))
    diffPaths{end + 1} = sprintf('%s [class/sparsity/size: %s%s %s vs %s%s %s]', path, ...
        class(a), ternary(issparse(a), ' sparse', ''), mat2str(size(a)), ...
        class(b), ternary(issparse(b), ' sparse', ''), mat2str(size(b)));
    classDiffs = classDiffs + 1;
    return
end
if isa(a, 'graph') || isa(a, 'digraph')
    [diffPaths, classDiffs] = compareNode(a.Nodes, b.Nodes, [path '.Nodes'], diffPaths, classDiffs);
    [diffPaths, classDiffs] = compareNode(a.Edges, b.Edges, [path '.Edges'], diffPaths, classDiffs);
elseif istable(a)
    if ~isequal(a.Properties.VariableNames, b.Properties.VariableNames)
        diffPaths{end + 1} = [path ' [variable names]'];
        return
    end
    for v = 1:width(a)
        name = a.Properties.VariableNames{v};
        [diffPaths, classDiffs] = compareNode(a.(name), b.(name), [path '.' name], diffPaths, classDiffs);
    end
elseif isstruct(a)
    if ~isequal(sort(fieldnames(a)), sort(fieldnames(b)))
        diffPaths{end + 1} = [path ' [field names]'];
        return
    end
    names = fieldnames(a);
    for k = 1:numel(a)
        for n = 1:numel(names)
            if numel(a) == 1
                childPath = [path '.' names{n}];
            else
                childPath = sprintf('%s(%d).%s', path, k, names{n});
            end
            [diffPaths, classDiffs] = compareNode(a(k).(names{n}), b(k).(names{n}), childPath, ...
                diffPaths, classDiffs);
        end
    end
elseif iscell(a)
    for k = 1:numel(a)
        [diffPaths, classDiffs] = compareNode(a{k}, b{k}, sprintf('%s{%d}', path, k), ...
            diffPaths, classDiffs);
    end
elseif ~isequaln(a, b)
    diffPaths{end + 1} = [path ' [values]'];
end
end

function prov = rxnDirProvenance(rxnDir, modelSource)
listing = dir(fullfile(rxnDir, '*.rxn'));
prov = struct('rxnDir', rxnDir, 'nRxnFiles', numel(listing), 'modelSource', modelSource);
if isfile(modelSource)
    info = dir(modelSource);
    prov.modelSourceDate = info.date;
end
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
% Keep small snapshots in the repo; move large ones out, leaving a pointer (029 R7).
info = dir(snapFile);
if info.bytes <= sizeLimitBytes
    location = sprintf('in repo (%.1f MB)', info.bytes / 1024^2);
    return
end
if ~isfolder(externalDir)
    mkdir(externalDir);
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

function row = emptyRow(name, mode)
row = struct('fixture', name, 'mode', mode, 'run', '-', 'status', 'ERROR', 'armEq', '-', ...
    'formulaeEq', '-', 'reactingEq', '-', 'consoleEq', '-', 'timing', '-', 'stages', '-', ...
    'solver', '-', 'corpus', '-', 'snapshot', '-', 'notes', '');
end

function appendRow(resultsPath, row, gitCommit)
full = emptyRow(row.fixture, row.mode);
names = fieldnames(row);
for n = 1:numel(names)
    full.(names{n}) = row.(names{n});
end
fid = fopen(resultsPath, 'a');
fprintf(fid, '| %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s |\n', ...
    full.fixture, full.mode, full.run, full.status, full.armEq, full.formulaeEq, ...
    strrep(full.reactingEq, '|', '/'), full.consoleEq, full.timing, full.stages, full.solver, ...
    full.corpus, full.snapshot, shortCommit(gitCommit), strrep(full.notes, '|', '/'));
fclose(fid);
end

function text = timingText(beforeSeconds, afterSeconds)
if isnan(afterSeconds)
    text = ternary(isnan(beforeSeconds), '-', sprintf('%.2f -> -', beforeSeconds));
elseif isnan(beforeSeconds)
    text = sprintf('- -> %.2f', afterSeconds);
else
    text = sprintf('%.2f -> %.2f (%.2fx)', beforeSeconds, afterSeconds, beforeSeconds / afterSeconds);
end
end

function text = stageText(before, after)
if isempty(before) && isempty(after)
    text = '-';
elseif isempty(after)
    text = sprintf('09: %.2f; 14-17: %.2f (profiled, relative)', before.stage09, before.stage14to17);
else
    text = sprintf('09: %.2f -> %.2f; 14-17: %.2f -> %.2f (profiled, relative)', before.stage09, ...
        after.stage09, before.stage14to17, after.stage14to17);
end
end

function text = shortCommit(gitCommit)
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
%% Synthetic re-indexing section (tasks.md T022; research.md R4-R6, R8)
%% ---------------------------------------------------------------------------

function runSyntheticReindexingSection(resultsPath, icrmFile, repoRoot) %#ok<INUSD>
% Runs verbatim copies of the ORIGINAL and OPTIMISED stage-14a, stage-14b and STEP-3 blocks
% of identifyConservedReactingMoieties.m on hand-built inputs covering the cases the
% fixtures do not contain: zero rows, exactly one row, a missing BondIndex, an untouched
% bond, and inputs that force each optimised block onto its fallback (tasks.md T022).
% The copies check semantics only; the fixture runs are the proof of the shipped code.

% Guard: the optimised copies below must still match the shipped source, line for line.
icrmText = fileread(icrmFile);
keyLines = { ...
    '[~, newEndNodes] = ismember(full(edgeTable.EndNodes), full(nodeTable.AtomIndex));', ...
    'endpointComponents = reshape(RBG.Nodes.Component(rbgEndNodes), size(rbgEndNodes));', ...
    '[~, endNodesModified] = ismember(full(endpointComponents), full(uniqueComponents));', ...
    'atomToRxn = spones(sparse([headATM(validTr); tailATM(validTr)], ...', ...
    'CRB2R = sparse(foundIdx(touchRow), touchCol, 1, nCRB, nRxns);'};
for k = 1:numel(keyLines)
    assert(contains(icrmText, keyLines{k}), 'reactingOptimisationCheck:syntheticCopyDrift', ...
        'Optimised block line not found verbatim in %s: %s', icrmFile, keyLines{k});
end

cases = syntheticReindexingCases();
fid = fopen(resultsPath, 'a');
fprintf(fid, ['\n### Synthetic re-indexing section — %s UTC\n\n' ...
    '| Case | Block | Original outcome | Optimised outcome | Result |\n|---|---|---|---|---|\n'], ...
    char(datetime('now', 'TimeZone', 'UTC', 'Format', 'yyyy-MM-dd HH:mm')));
allEqual = true;
for c = 1:numel(cases)
    original = runSyntheticBlock(cases(c), true);
    optimised = runSyntheticBlock(cases(c), false);
    if strcmp(original.outcome, 'ok') && strcmp(optimised.outcome, 'ok')
        isSame = compareStrictly(original.value, optimised.value, 'value') ...
            && strcmp(original.warningText, optimised.warningText);
    else
        isSame = strcmp(original.outcome, optimised.outcome) ...
            && strcmp(original.errorIdentifier, optimised.errorIdentifier) ...
            && strcmp(original.errorMessage, optimised.errorMessage);
    end
    allEqual = allEqual && isSame;
    fprintf(fid, '| %d. %s | %s | %s | %s | %s |\n', c, cases(c).name, cases(c).block, ...
        describeSyntheticOutcome(original), describeSyntheticOutcome(optimised), ...
        ternary(isSame, 'EQUAL', 'DIFF'));
    fprintf('  synthetic %2d %-34s %s\n', c, cases(c).name, ternary(isSame, 'EQUAL', 'DIFF'));
end
fclose(fid);
assert(allEqual, 'reactingOptimisationCheck:syntheticMismatch', ...
    'An optimised block differs from the original on at least one synthetic case; see %s', resultsPath);
end

function text = describeSyntheticOutcome(result)
if strcmp(result.outcome, 'ok')
    text = sprintf('ok, %s %s%s', class(result.value), mat2str(size(result.value)), ...
        ternary(isempty(result.warningText), '', [', warning: ' result.warningText]));
else
    text = sprintf('error %s', result.errorIdentifier);
end
end

function result = runSyntheticBlock(syntheticCase, useOriginal)
result = struct('outcome', 'ok', 'value', [], 'warningText', '', 'errorIdentifier', '', ...
    'errorMessage', '');
lastwarn('');
try
    in = syntheticCase.inputs;
    switch syntheticCase.block
        case '14a'
            if useOriginal
                result.value = rbgEndNodesOriginal(in.edgeTable, in.nodeTable);
            else
                result.value = rbgEndNodesOptimised(in.edgeTable, in.nodeTable);
            end
        case '14b'
            if useOriginal
                result.value = condensedEndNodesOriginal(in.RBG, in.uniqueComponents, in.componentTable);
            else
                result.value = condensedEndNodesOptimised(in.RBG, in.uniqueComponents, in.componentTable);
            end
        case 'STEP3'
            if useOriginal
                result.value = crb2rOriginal(in.bondIdx, in.bondRowMap, in.atom1_all, in.atom2_all, ...
                    in.headATM, in.tailATM, in.rxnCols, in.nCRB, in.nRxns, in.maxBondIndex);
            else
                result.value = crb2rOptimised(in.bondIdx, in.bondRowMap, in.atom1_all, in.atom2_all, ...
                    in.headATM, in.tailATM, in.rxnCols, in.nCRB, in.nRxns, in.maxBondIndex);
            end
    end
    result.warningText = lastwarn();
catch ME
    result.outcome = 'error';
    result.errorIdentifier = ME.identifier;
    result.errorMessage = ME.message;
    fprintf('    (%s copy raised %s: %s at %s:%d)\n', ternary(useOriginal, 'original', 'optimised'), ...
        ME.identifier, ME.message, ME.stack(1).name, ME.stack(1).line);
end
end

function cases = syntheticReindexingCases()
cases = struct('name', {}, 'block', {}, 'inputs', {});

% stage 14b: RBG on atoms, with NewId = 1:n, and its component table
cases(end + 1) = struct('name', 'condensed RBG, one edge', 'block', '14b', ...
    'inputs', condensedInputs([5; 9], [1 2]));
cases(end + 1) = struct('name', 'condensed RBG, three edges', 'block', '14b', ...
    'inputs', condensedInputs([3; 7; 7; 11], [1 2; 2 3; 3 4]));
cases(end + 1) = struct('name', 'condensed RBG, zero edges', 'block', '14b', ...
    'inputs', condensedInputs([3; 7], zeros(0, 2)));

% stage 14a: reacting-bond edge table on atom indices, and the node table of its end atoms
cases(end + 1) = struct('name', 'RBG re-index, zero edges', 'block', '14a', 'inputs', ...
    struct('edgeTable', table(zeros(0, 2), 'VariableNames', {'EndNodes'}), ...
    'nodeTable', table(zeros(0, 1), 'VariableNames', {'AtomIndex'})));
cases(end + 1) = struct('name', 'RBG re-index, one edge', 'block', '14a', 'inputs', ...
    struct('edgeTable', table([20 10], 'VariableNames', {'EndNodes'}), ...
    'nodeTable', table([10; 20], 'VariableNames', {'AtomIndex'})));

% STEP 3: bonds 1 and 3 exist in BG (atoms 1-2 and 7-8); bond 2 does not
bgBondIndex = [1; 3];
bgEndNodes = [1 2; 7 8];
cases(end + 1) = struct('name', 'CRB2R, zero condensed bonds', 'block', 'STEP3', ...
    'inputs', crb2rInputs(zeros(0, 1), bgBondIndex, bgEndNodes, [1; 5], [2; 6], [1; 2], 2));
cases(end + 1) = struct('name', 'CRB2R, BondIndex not found', 'block', 'STEP3', ...
    'inputs', crb2rInputs([1; 2; 3], bgBondIndex, bgEndNodes, [1; 5; 2], [2; 6; 9], [1; 2; 0], 3));
cases(end + 1) = struct('name', 'CRB2R, untouched bond (zero row)', 'block', 'STEP3', ...
    'inputs', crb2rInputs([1; 3], bgBondIndex, bgEndNodes, [1; 5], [2; 6], [1; 2], 2));

% fallback triggers
cases(end + 1) = struct('name', 'condensed RBG, NaN component', 'block', '14b', ...
    'inputs', condensedInputs([NaN; 4], [1 2]));
cellInputs = crb2rInputs([1; 3], bgBondIndex, bgEndNodes, [1; 5], [2; 6], [1; 2], 2);
cellInputs.headATM = num2cell(cellInputs.headATM);
cases(end + 1) = struct('name', 'CRB2R, headATM as a cell array', 'block', 'STEP3', ...
    'inputs', cellInputs);
end

function in = condensedInputs(components, endNodes)
% Builds RBG, uniqueComponents and componentTable exactly as the source does.
nodeTable = table((101:100 + numel(components))', components, ...
    'VariableNames', {'AtomIndex', 'Component'});
edgeTable = table(endNodes, 'VariableNames', {'EndNodes'});
RBG = graph(edgeTable, nodeTable);
RBG.Nodes.NewId = (1:size(RBG.Nodes, 1))';
uniqueComponents = unique(RBG.Nodes.Component);
newIds = (1:length(uniqueComponents))';
componentTable = table(uniqueComponents, newIds, 'VariableNames', {'Component', 'NewId'});
in = struct('RBG', RBG, 'uniqueComponents', uniqueComponents, 'componentTable', componentTable);
end

function in = crb2rInputs(bondIdx, allBondIndex, bgEndNodes, headATM, tailATM, rxnCols, nRxns)
% Builds the STEP-2 lookup (bondRowMap) exactly as the source does.
atom1_all = bgEndNodes(:, 1);
atom2_all = bgEndNodes(:, 2);
maxBondIndex = max(allBondIndex);
bondRowMap = zeros(maxBondIndex, 1);
for r = 1:numel(allBondIndex)
    bIdx = allBondIndex(r);
    if bondRowMap(bIdx) == 0
        bondRowMap(bIdx) = r;
    end
end
in = struct('bondIdx', bondIdx, 'bondRowMap', bondRowMap, 'atom1_all', atom1_all, ...
    'atom2_all', atom2_all, 'headATM', headATM, 'tailATM', tailATM, 'rxnCols', rxnCols, ...
    'nCRB', length(bondIdx), 'nRxns', nRxns, 'maxBondIndex', maxBondIndex);
end

% ----- verbatim copies of the pre-change blocks (git show develop:<ICRM>) -----

function newEndNodes = rbgEndNodesOriginal(edgeTable, nodeTable)
newEndNodes = zeros(size(edgeTable, 1), 2);
% Update the EndNodes by finding the new positions in the nodeTable
for i = 1:size(edgeTable, 1)
    % Find the new position for the first node (EndNodes1) in the edgeTable
    newEndNodes(i, 1) = find(nodeTable.AtomIndex == edgeTable.EndNodes(i,1));

    % Find the new position for the second node (EndNodes2) in the edgeTable
    newEndNodes(i, 2) = find(nodeTable.AtomIndex == edgeTable.EndNodes(i,2));
end
end

function endNodesModified = condensedEndNodesOriginal(RBG, uniqueComponents, componentTable) %#ok<INUSL>
 % Initialize the new EndNodes vector
endNodesModified = zeros(size(RBG.Edges.EndNodes));

% Loop over all edges in RBG to replace the EndNodes with the Component values
for i = 1:size(RBG.Edges.EndNodes, 1)
    % Get the current edge's EndNode(s)
    currentEndNode = RBG.Edges.EndNodes(i, :);

    % Replace each EndNode with the corresponding Component value from ATG
    for j = 1:2
        % Find the index of the node in ATG whose AtomIndex matches the EndNode
        idx = find(RBG.Nodes.NewId == currentEndNode(j));

        % If the index is found, replace the EndNode with the Component value
        if ~isempty(idx)
            component=RBG.Nodes.Component(idx);
            endNodesModified(i, j) = componentTable.NewId(componentTable.Component==component);
        end
    end
end
end

function CRB2R = crb2rOriginal(bondIdx, bondRowMap, atom1_all, atom2_all, headATM, tailATM, ...
    rxnCols, nCRB, nRxns, maxBondIndex) %#ok<INUSD>
CRB2R = sparse(nCRB, nRxns);
for i = 1:nCRB
    b = bondIdx(i);

    % Lookup BG edge row
    row = bondRowMap(b);
    if row == 0
        warning('BondIndex %d not found.', b);
        continue;
    end

    a1 = atom1_all(row);
    a2 = atom2_all(row);

    % Find transitions involving either atom
    involved = (headATM == a1 | tailATM == a1 | ...
                headATM == a2 | tailATM == a2);

    cols = unique(rxnCols(involved));
    CRB2R(i, cols(cols>0)) = 1;
end
end

% ----- verbatim copies of the optimised blocks shipped in <ICRM> (T019, T020, T021) -----

function newEndNodes = rbgEndNodesOptimised(edgeTable, nodeTable)
% Update the EndNodes to their positions in the nodeTable. nodeTable.AtomIndex is
% unique, so the first-match location from ismember is the position find() returns.
[~, newEndNodes] = ismember(full(edgeTable.EndNodes), full(nodeTable.AtomIndex));
if numel(unique(nodeTable.AtomIndex)) ~= height(nodeTable) || any(newEndNodes(:) == 0)
    % Duplicated or missing atom indices: use the original per-edge search, which
    % reports such inputs exactly as it always has
    newEndNodes = zeros(size(edgeTable, 1), 2);
    % Update the EndNodes by finding the new positions in the nodeTable
    for i = 1:size(edgeTable, 1)
        % Find the new position for the first node (EndNodes1) in the edgeTable
        newEndNodes(i, 1) = find(nodeTable.AtomIndex == edgeTable.EndNodes(i,1));
    
        % Find the new position for the second node (EndNodes2) in the edgeTable
        newEndNodes(i, 2) = find(nodeTable.AtomIndex == edgeTable.EndNodes(i,2));
    end
end
end

function endNodesModified = condensedEndNodesOptimised(RBG, uniqueComponents, componentTable) %#ok<INUSD>
% Replace each EndNode with the NewId of its node's Component. RBG.Nodes.NewId is
% 1:numnodes, so an EndNode is already its node's row, and componentTable.NewId is the
% position of the Component in the sorted uniqueComponents. The reshape keeps the
% EndNodes shape when there is exactly one edge (indexing a column vector with a 1-by-2
% index would otherwise return a 2-by-1 result).
rbgEndNodes = RBG.Edges.EndNodes;
if isnumeric(rbgEndNodes)
    endpointComponents = reshape(RBG.Nodes.Component(rbgEndNodes), size(rbgEndNodes));
    [~, endNodesModified] = ismember(full(endpointComponents), full(uniqueComponents));
else
    endNodesModified = [];
end
if ~isnumeric(rbgEndNodes) || any(endNodesModified(:) == 0)
    % Non-numeric end nodes or unmatched components: use the original per-edge search
    % Initialize the new EndNodes vector
    endNodesModified = zeros(size(RBG.Edges.EndNodes));

    % Loop over all edges in RBG to replace the EndNodes with the Component values
    for i = 1:size(RBG.Edges.EndNodes, 1)
        % Get the current edge's EndNode(s)
        currentEndNode = RBG.Edges.EndNodes(i, :);
    
        % Replace each EndNode with the corresponding Component value from ATG
        for j = 1:2
            % Find the index of the node in ATG whose AtomIndex matches the EndNode
            idx = find(RBG.Nodes.NewId == currentEndNode(j));
        
            % If the index is found, replace the EndNode with the Component value
            if ~isempty(idx)
                component=RBG.Nodes.Component(idx);
                endNodesModified(i, j) = componentTable.NewId(componentTable.Component==component);
            end
        end
    end
end
end

function CRB2R = crb2rOptimised(bondIdx, bondRowMap, atom1_all, atom2_all, headATM, tailATM, ...
    rxnCols, nCRB, nRxns, maxBondIndex)
CRB2R = sparse(nCRB, nRxns);
% Build CRB2R from a sparse atom -> reaction incidence: row i holds the reactions with
% an atom transition that touches either end atom of condensed reacting bond i. This
% replaces a scan of every atom transition for every bond. The original per-bond loop
% is kept for inputs whose indices are not positive whole numbers.
isPositiveWholeNumeric = @(v) isnumeric(v) && all(v(:) >= 1) && all(v(:) == fix(v(:)));
if isPositiveWholeNumeric(atom1_all) && isPositiveWholeNumeric(atom2_all) ...
        && isPositiveWholeNumeric(headATM) && isPositiveWholeNumeric(tailATM) ...
        && isPositiveWholeNumeric(bondIdx) && all(bondIdx <= maxBondIndex)
    rowsInBG = bondRowMap(bondIdx);
    foundInBG = rowsInBG > 0;
    for iMissing = find(~foundInBG)'
        warning('BondIndex %d not found.', bondIdx(iMissing));
    end
    validTr = rxnCols > 0;
    nAtomsMax = max([0; atom1_all(:); atom2_all(:); headATM(:); tailATM(:)]);
    atomToRxn = spones(sparse([headATM(validTr); tailATM(validTr)], ...
        [rxnCols(validTr); rxnCols(validTr)], 1, nAtomsMax, nRxns));
    foundIdx = find(foundInBG);
    touch = atomToRxn(atom1_all(rowsInBG(foundIdx)), :) + atomToRxn(atom2_all(rowsInBG(foundIdx)), :);
    [touchRow, touchCol] = find(touch);
    CRB2R = sparse(foundIdx(touchRow), touchCol, 1, nCRB, nRxns);
else
    for i = 1:nCRB
        b = bondIdx(i);

        % Lookup BG edge row
        row = bondRowMap(b);
        if row == 0
            warning('BondIndex %d not found.', b);
            continue;
        end

        a1 = atom1_all(row);
        a2 = atom2_all(row);

        % Find transitions involving either atom
        involved = (headATM == a1 | tailATM == a1 | ...
                    headATM == a2 | tailATM == a2);

        cols = unique(rxnCols(involved));
        CRB2R(i, cols(cols>0)) = 1;
    end
end

end
