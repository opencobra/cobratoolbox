function buildRuntimeReproducibilityCheck(mode, fixtureNames, runVersion)
% Non-CI golden-snapshot reproducibility check for feature
% 20260921-160105-build-function-runtime (spec FR-011, FR-012, FR-013; research R5-R8).
%
% USAGE:
%
%    buildRuntimeReproducibilityCheck(mode)
%    buildRuntimeReproducibilityCheck(mode, fixtureNames)
%    buildRuntimeReproducibilityCheck('peakmem', {fixtureName}, runVersion)
%
% INPUT:
%    mode:            one of
%
%                       * 'capture' - run the UNMODIFIED source on every fixture and save
%                         snapshots/<fixture>-golden-snapshot.mat (outputs in default and
%                         dense mode, checkABRXNFiles outputs, bondMappings per RXN file,
%                         console text, readABRXNFile message set, profiler counts, timing,
%                         peak memory, provenance). Refuses to run if the three edited
%                         source files differ from the baseline revision.
%                       * 'captureCI' - write the expected-value files used by
%                         testAddBondMappingsRXNFile.m and testCheckABRXNFiles.m
%                         (same refusal rule).
%                       * 'compare' - run the current source on every fixture, compare with
%                         the snapshots, time the original (baseline copies extracted with
%                         git show) and the modified function alternately, count parses and
%                         energy-table constructions of both, measure peak memory of both,
%                         and append the results to reproducibility-results.md.
%                       * 'selfcheck' - as 'compare' but equality and console items only
%                         (no timing, counts or memory); run on the unmodified source to
%                         validate the harness itself (tasks T010).
%                       * 'peakmem' - internal: one default-mode call in this (fresh)
%                         process, then print VMHWM_KB=<peak resident memory in kB>.
%
% OPTIONAL INPUTS:
%    fixtureNames:    cell array of fixture names. Default: the seven subsystem fixtures,
%                     'ci', 'ci_missing' and 'ci_unparsable'. 'pufa' only when named.
%    runVersion:      'peakmem' mode only: 'original' or 'modified'.
%
% NOTE:
%    Depends on external data (the subsystem submodels and the atom-mapped RXN corpus),
%    so it is a documented reproducibility check (Constitution Principle III), not a CI
%    test. Console text is captured with diary, never evalc, so warnings stay visible.
%
% .. Authors: - COBRA Toolbox, feature 20260921-160105-build-function-runtime

if ~exist('fixtureNames', 'var') || isempty(fixtureNames)
    fixtureNames = {'nglycan', 'phe', 'andest', 'chol', 'urea', 'tyr', 'bileacid', ...
        'ci', 'ci_missing', 'ci_unparsable'};
end
if ~exist('runVersion', 'var') || isempty(runVersion)
    runVersion = 'modified';
end

cfg = harnessConfig();

switch mode
    case 'capture'
        assertBaselineSource(cfg);
        runCapture(cfg, fixtureNames);
    case 'captureCI'
        assertBaselineSource(cfg);
        runCaptureCI(cfg);
    case 'compare'
        runCompare(cfg, fixtureNames, true);
    case 'selfcheck'
        runCompare(cfg, fixtureNames, false);
    case 'peakmem'
        runPeakMem(cfg, fixtureNames{1}, runVersion);
    otherwise
        error('buildRuntimeReproducibilityCheck:badMode', 'Unknown mode "%s".', mode);
end
end

%% ------------------------------------------------------------------ configuration

function cfg = harnessConfig()
cfg.thisDir = fileparts(mfilename('fullpath'));
cfg.repoRoot = fileparts(fileparts(cfg.thisDir));
cfg.srcDir = fullfile(cfg.repoRoot, 'src', 'analysis', 'topology', 'reactingMoieties');
cfg.srcFiles = {'addBondMappingsRXNFile.m', 'checkABRXNFiles.m', ...
    'buildAtomAndBondTransitionMultigraph.m'};
cfg.testDir = fullfile(cfg.repoRoot, 'test', 'verifiedTests', 'analysis', 'testReactingMoieties');
cfg.ciRxnDir = fullfile(cfg.testDir, 'data', 'rxnFiles');
cfg.snapshotDir = fullfile(cfg.thisDir, 'snapshots');
cfg.resultsPath = fullfile(cfg.thisDir, 'reproducibility-results.md');
cfg.subModelMatPath = fullfile(getenv('HOME'), 'repos', 'ReconXKG-cidev', 'ReconXKGtoCobra', ...
    'models', 'subsystemSubModels', 'subsystemSubModels.mat');
cfg.corpusDir = '/media/JACK/repos/ctf/rxns/moiety_rxns/atomMapped_std';
cfg.baseRev = '64efe1dc8';
cfg.nTimedRuns = 5;
cfg.memRelTol = 0.05;       % spec Edge Cases: 5% or 50 MB, whichever is larger
cfg.memAbsTolKB = 50 * 1024;
cfg.nMemRuns = 3;           % fresh processes per version; the minimum is compared (VmHWM noise)
end

function assertBaselineSource(cfg)
% capture modes must run on the unmodified source (research R7, 029 R9)
cmd = sprintf('git -C "%s" diff --quiet %s -- %s', cfg.repoRoot, cfg.baseRev, ...
    strjoin(fullfile('src', 'analysis', 'topology', 'reactingMoieties', cfg.srcFiles), ' '));
status = system(cmd);
if status ~= 0
    error('buildRuntimeReproducibilityCheck:sourceModified', ...
        'Capture refused: the edited source files differ from %s.', cfg.baseRev);
end
end

%% ------------------------------------------------------------------ baseline copies

function [baselineDir, cleanupObj] = makeBaselineDir(cfg)
baselineDir = tempname;
mkdir(baselineDir);
for k = 1:numel(cfg.srcFiles)
    cmd = sprintf('git -C "%s" show %s:src/analysis/topology/reactingMoieties/%s > "%s"', ...
        cfg.repoRoot, cfg.baseRev, cfg.srcFiles{k}, fullfile(baselineDir, cfg.srcFiles{k}));
    [status, cmdOut] = system(cmd);
    if status ~= 0
        error('buildRuntimeReproducibilityCheck:gitShow', 'git show failed for %s: %s', ...
            cfg.srcFiles{k}, cmdOut);
    end
end
cleanupObj = onCleanup(@() removeBaselineDir(baselineDir));
end

function removeBaselineDir(baselineDir)
if any(strcmp(strsplit(path, pathsep), baselineDir))
    rmpath(baselineDir);
end
if isfolder(baselineDir)
    rmdir(baselineDir, 's');
end
end

function useBaseline(flag, baselineDir, cfg)
onPath = any(strcmp(strsplit(path, pathsep), baselineDir));
if flag && ~onPath
    addpath(baselineDir, '-begin');
elseif ~flag && onPath
    rmpath(baselineDir);
end
clear('functions'); %#ok<CLFUNC>
rehash;
if flag
    expectedDir = baselineDir;
else
    expectedDir = cfg.srcDir;
end
for k = 1:numel(cfg.srcFiles)
    [~, fn] = fileparts(cfg.srcFiles{k});
    resolved = which(fn);
    assert(strcmp(fileparts(resolved), expectedDir), ...
        'buildRuntimeReproducibilityCheck:pathSwitch', '%s resolves to %s, expected %s.', ...
        fn, resolved, expectedDir);
end
end

%% ------------------------------------------------------------------ fixtures

function [model, rxnDir, prov, cleanupObj] = loadFixture(cfg, name)
cleanupObj = [];
derivedKind = '';
alteredRxn = '';
switch name
    case {'ci', 'ci_missing', 'ci_unparsable'}
        model = ciSubModel();
        rxnDir = cfg.ciRxnDir;
        modelFile = fullfile(getCBTDIR(), 'test', 'models', 'mat', 'Recon3D_301.mat');
        if ~strcmp(name, 'ci')
            derivedKind = regexprep(name, '^ci_', '');
            [rxnDir, alteredRxn] = makeDerivedRxnDir(derivedKind, model, cfg.ciRxnDir);
            cleanupObj = onCleanup(@() rmdir(rxnDir, 's'));
        end
    otherwise
        assert(isfile(cfg.subModelMatPath), 'buildRuntimeReproducibilityCheck:noSubModels', ...
            'Subsystem submodels not found at %s.', cfg.subModelMatPath);
        assert(isfolder(cfg.corpusDir), 'buildRuntimeReproducibilityCheck:noCorpus', ...
            'Atom-mapped RXN corpus not found at %s.', cfg.corpusDir);
        loaded = load(cfg.subModelMatPath, 'subModels');
        model = loaded.subModels.(name);
        rxnDir = cfg.corpusDir;
        modelFile = cfg.subModelMatPath;
end
prov = provenance(name, model, rxnDir, modelFile, derivedKind, alteredRxn, cfg);
end

function model = ciSubModel()
persistent cachedModel
if isempty(cachedModel)
    recon3D = readCbModel(fullfile(getCBTDIR(), 'test', 'models', 'mat', 'Recon3D_301.mat'));
    cachedModel = extractSubNetwork(recon3D, {'r0317'; 'ACONTm'; 'r0426'});
end
model = cachedModel;
end

function cbtDir = getCBTDIR()
global CBTDIR
cbtDir = CBTDIR;
end

function [derivedDir, alteredRxn] = makeDerivedRxnDir(kind, subModel, rxnFilesDir)
% Derived fixture (tasks T004): a copy of the RXN directory with one reaction's file
% deleted ('missing') or cut to its first 4 header lines ('unparsable' for the last
% mapped reaction, 'firstBroken' for the first). The caller removes derivedDir.
% The body of this function is copied verbatim into testCheckABRXNFiles.m.
derivedDir = tempname;
mkdir(derivedDir);
copyfile(fullfile(rxnFilesDir, '*.rxn'), derivedDir);
mappedBool = cellfun(@(r) isfile(fullfile(rxnFilesDir, [r '.rxn'])), subModel.rxns);
mappedRxns = subModel.rxns(mappedBool);
switch kind
    case 'missing'
        alteredRxn = mappedRxns{end};
        delete(fullfile(derivedDir, [alteredRxn '.rxn']));
    case {'unparsable', 'firstBroken'}
        if strcmp(kind, 'unparsable')
            alteredRxn = mappedRxns{end};
        else
            alteredRxn = mappedRxns{1};
        end
        alteredPath = fullfile(derivedDir, [alteredRxn '.rxn']);
        fileLines = regexp(fileread(alteredPath), '\r?\n', 'split');
        fid = fopen(alteredPath, 'w');
        fprintf(fid, '%s\n', fileLines{1:4});
        fclose(fid);
    otherwise
        error('makeDerivedRxnDir:badKind', 'Unknown derived fixture kind "%s".', kind);
end
end

function prov = provenance(name, model, rxnDir, modelFile, derivedKind, alteredRxn, cfg)
prov.fixture = name;
prov.rxnDir = rxnDir;
prov.derivedKind = derivedKind;
prov.alteredRxn = alteredRxn;
if isempty(derivedKind) && ~strcmp(name, 'ci')
    prov.corpusRxnCount = numel(dir(fullfile(rxnDir, '*.rxn')));
    flaggedDir = fullfile(rxnDir, 'flagged_for_review');
    if isfolder(flaggedDir)
        flagged = dir(fullfile(flaggedDir, '*.rxn'));
        prov.flagged = sort({flagged.name})';
    else
        prov.flagged = {};
    end
else
    prov.corpusRxnCount = numel(dir(fullfile(rxnDir, '*.rxn')));
    prov.flagged = {};
end
prov.modelFile = modelFile;
modelInfo = dir(modelFile);
prov.modelDatenum = modelInfo.datenum;
prov.nRxns = numel(model.rxns);
prov.nMets = numel(model.mets);
prov.matlabVersion = version;
[~, head] = system(sprintf('git -C "%s" rev-parse --short HEAD', cfg.repoRoot));
prov.gitHead = strtrim(head);
prov.baseRev = cfg.baseRev;
end

function [same, reason] = sameProvenance(a, b)
same = true;
reason = '';
if ~strcmp(a.derivedKind, b.derivedKind) || ~strcmp(a.alteredRxn, b.alteredRxn)
    same = false;
    reason = 'derived fixture definition differs';
elseif a.corpusRxnCount ~= b.corpusRxnCount
    same = false;
    reason = sprintf('corpus .rxn count %d -> %d', a.corpusRxnCount, b.corpusRxnCount);
elseif ~isequal(a.flagged, b.flagged)
    same = false;
    reason = 'flagged_for_review list differs';
elseif a.modelDatenum ~= b.modelDatenum
    same = false;
    reason = 'fixture model file modified';
elseif a.nRxns ~= b.nRxns || a.nMets ~= b.nMets
    same = false;
    reason = 'fixture model size differs';
end
end

%% ------------------------------------------------------------------ one fixture's record

function out = callBuild(model, rxnDir, options)
out = cell(1, 12);
[out{:}] = buildAtomAndBondTransitionMultigraph(model, rxnDir, options);
end

function rec = errorRecord(ME)
rec.identifier = ME.identifier;
rec.message = ME.message;
if ~isempty(ME.stack)
    rec.file = ME.stack(1).file;
    rec.line = ME.stack(1).line;
else
    rec.file = '';
    rec.line = NaN;
end
end

function rec = captureOutputs(model, rxnDir)
% default mode with console capture (one call), dense mode, checkABRXNFiles,
% bondMappings per RXN file, readABRXNFile message set, decompartmentalisation branch
options = struct('sanityChecks', 1);
diaryFile = [tempname '.txt'];
diary(diaryFile);
try
    rec.outDefault = callBuild(model, rxnDir, options);
    rec.errDefault = [];
catch ME
    rec.outDefault = {};
    rec.errDefault = errorRecord(ME);
    fprintf('Build (default) raised: %s (%s line %d)\n', ME.message, rec.errDefault.file, rec.errDefault.line);
end
diary('off');
rec.consoleText = strrep(fileread(diaryFile), rxnDir, '<RXNDIR>');
delete(diaryFile);

denseOptions = options;
denseOptions.denseBondMatrices = 1;
try
    rec.outDense = callBuild(model, rxnDir, denseOptions);
    rec.errDense = [];
catch ME
    rec.outDense = {};
    rec.errDense = errorRecord(ME);
end
rec.classInfo = struct('default', {classInfoOf(rec.outDefault)}, 'dense', {classInfoOf(rec.outDense)});

try
    [modelOut, nA, nB] = checkABRXNFiles(model, rxnDir);
    rec.checkOut = checkFields(modelOut, nA, nB);
    rec.errCheck = [];
catch ME
    rec.checkOut = [];
    rec.errCheck = errorRecord(ME);
end

mappedBool = cellfun(@(r) isfile(fullfile(rxnDir, [r '.rxn'])), model.rxns);
rec.bondMappingsByRxn.rxnIds = model.rxns(mappedBool);
rec.bondMappingsByRxn.tables = cell(size(rec.bondMappingsByRxn.rxnIds));
for k = 1:numel(rec.bondMappingsByRxn.rxnIds)
    try
        rec.bondMappingsByRxn.tables{k} = addBondMappingsRXNFile(rec.bondMappingsByRxn.rxnIds{k}, rxnDir);
    catch ME
        rec.bondMappingsByRxn.tables{k} = errorRecord(ME);
    end
end

rec.readMessages = readABRXNFileMessages(rec.bondMappingsByRxn.rxnIds, rxnDir);
rec.decompBranch = decompBranchOf(model, rec.bondMappingsByRxn.rxnIds, rxnDir);
end

function info = classInfoOf(out)
info = cell(numel(out), 2);
for k = 1:numel(out)
    info{k, 1} = class(out{k});
    info{k, 2} = issparse(out{k});
end
end

function checkOut = checkFields(modelOut, nA, nB)
fieldList = {'metRXNBool', 'RXNBool', 'RXNParsedBool', 'RXNAtomsConservedBool', ...
    'RXNStoichiometryMatchBool', 'RXNStoichiometryMatchUptoProtonsBool', ...
    'RXNSubstrateTransitionNumbersOrdered', 'RXNProductTransitionNumbersOrdered', ...
    'RXNTransitionNumbersMatching', 'RXNMatchingElementBool'};
for k = 1:numel(fieldList)
    checkOut.(fieldList{k}) = modelOut.(fieldList{k});
end
checkOut.nTotalAtomTransitions = nA;
checkOut.nTotalBondTransitions = nB;
end

function msgSet = readABRXNFileMessages(rxnIds, rxnDir)
% the non-blank, non-stack-frame lines readABRXNFile itself prints for these files,
% used to classify console lines under the FR-009 rule (research R5)
diaryFile = [tempname '.txt'];
diary(diaryFile);
for k = 1:numel(rxnIds)
    try
        readABRXNFile(rxnIds{k}, rxnDir);
    catch
        % an unreadable file's error text is printed by the callers' catch blocks, whose
        % output FR-009 keeps exact, so it is deliberately NOT added to this set
    end
end
diary('off');
textLines = splitConsole(strrep(fileread(diaryFile), rxnDir, '<RXNDIR>'));
delete(diaryFile);
[messageLines, ~] = dropStackFrames(textLines);
messageLines = messageLines(~cellfun(@(l) isempty(strtrim(l)), messageLines));
msgSet = unique(messageLines);
end

function branch = decompBranchOf(model, mappedRxns, rxnDir)
branch = 'none';
if isempty(mappedRxns)
    return
end
try
    atoms = readABRXNFile(mappedRxns{1}, rxnDir);
catch
    branch = 'firstUnreadable';
    return
end
atomMetAbbr = atoms.mets{1};
metAbbr = model.mets{1};
if strcmp(atomMetAbbr(end), metAbbr(end))
    branch = 'match';
elseif strcmp(atomMetAbbr(end), ']')
    branch = 'rxnFileCompartmented';
elseif strcmp(metAbbr(end), ']')
    branch = 'modelCompartmented';
else
    branch = 'mismatchNoBracket';
end
end

%% ------------------------------------------------------------------ counts, timing, memory

function counts = captureCounts(model, rxnDir)
% profiler-based counts (research R7); nothing is added to src/
options = struct('sanityChecks', 1);
profile('clear');
profile('on');
try
    callBuild(model, rxnDir, options);
catch ME
    fprintf('Profiled build raised: %s\n', ME.message);
end
p = profile('info');
profile('off');
fnNames = {p.FunctionTable.FunctionName};
counts.readABRXNFileCalls = sum([p.FunctionTable(strcmp(fnNames, 'readABRXNFile')).NumCalls]);
addIdx = find(strcmp(fnNames, 'addBondMappingsRXNFile'));
counts.addBondMappingsCalls = sum([p.FunctionTable(addIdx).NumCalls]);
counts.energyConstructions = 0;
counts.energyAppends = 0;
for k = addIdx
    fileLines = regexp(fileread(p.FunctionTable(k).FileName), '\r?\n', 'split');
    constructLines = find(~cellfun('isempty', regexp(fileLines, '^\s*energy\s*=\s*table\(', 'once')));
    appendLines = find(~cellfun('isempty', regexp(fileLines, '^\s*bondMappings\s*=\s*\[bondMappings;\s*energy\];', 'once')));
    executed = p.FunctionTable(k).ExecutedLines;
    if ~isempty(executed)
        counts.energyConstructions = counts.energyConstructions + sum(executed(ismember(executed(:, 1), constructLines), 2));
        counts.energyAppends = counts.energyAppends + sum(executed(ismember(executed(:, 1), appendLines), 2));
    end
end
end

function t = timeRuns(model, rxnDir, baselineDir, cfg)
% alternating original/modified whole-function timing (research R7)
options = struct('sanityChecks', 1);
useBaseline(true, baselineDir, cfg);
runQuiet(model, rxnDir, options); % warm-up
useBaseline(false, baselineDir, cfg);
runQuiet(model, rxnDir, options); % warm-up
t.original = zeros(cfg.nTimedRuns, 1);
t.modified = zeros(cfg.nTimedRuns, 1);
for r = 1:cfg.nTimedRuns
    useBaseline(true, baselineDir, cfg);
    tStart = tic;
    runQuiet(model, rxnDir, options);
    t.original(r) = toc(tStart);
    useBaseline(false, baselineDir, cfg);
    tStart = tic;
    runQuiet(model, rxnDir, options);
    t.modified(r) = toc(tStart);
end
t = summariseTiming(t);
end

function t = summariseTiming(t)
t.medianOriginal = median(t.original);
t.medianModified = median(t.modified);
t.ratio = t.medianOriginal / t.medianModified;
t.noise = (max(t.original) - min(t.original)) / 2;
t.pass = t.medianModified <= t.medianOriginal + t.noise;
end

function runQuiet(model, rxnDir, options)
% the function's own console output is left visible (no evalc, Principle VII-A)
try
    callBuild(model, rxnDir, options);
catch ME
    fprintf('Timed build raised: %s\n', ME.message);
end
end

function kB = peakMemory(cfg, name, whichVersion)
% minimum VmHWM over cfg.nMemRuns fresh processes: a single run of identical code varied
% by about 7% (116 MB) on the CI fixture, more than the spec's tolerance
runs = zeros(cfg.nMemRuns, 1);
for r = 1:cfg.nMemRuns
    runs(r) = peakMemoryOnce(cfg, name, whichVersion);
end
kB = min(runs);
fprintf('peakMemory(%s, %s): %s kB, min %g kB\n', name, whichVersion, mat2str(runs'), kB);
end

function kB = peakMemoryOnce(cfg, name, whichVersion)
cmd = sprintf(['matlab -batch "initCobraToolbox(false); cd(''%s''); ' ...
    'buildRuntimeReproducibilityCheck(''peakmem'', {''%s''}, ''%s'')"'], ...
    cfg.thisDir, name, whichVersion);
[status, cmdOut] = system(cmd);
tok = regexp(cmdOut, 'VMHWM_KB=(\d+)', 'tokens', 'once');
if status ~= 0 || isempty(tok)
    fprintf('peakMemory(%s, %s) failed (status %d); tail of output:\n%s\n', name, whichVersion, ...
        status, cmdOut(max(1, end - 2000):end));
    kB = NaN;
else
    kB = str2double(tok{1});
end
end

function runPeakMem(cfg, name, whichVersion)
baselineDir = '';
cleanupBaseline = []; %#ok<NASGU>
if strcmp(whichVersion, 'original')
    [baselineDir, cleanupBaseline] = makeBaselineDir(cfg); %#ok<ASGLU>
    useBaseline(true, baselineDir, cfg);
end
[model, rxnDir, ~, cleanupFixture] = loadFixture(cfg, name); %#ok<ASGLU>
runQuiet(model, rxnDir, struct('sanityChecks', 1));
statusText = fileread('/proc/self/status');
tok = regexp(statusText, 'VmHWM:\s*(\d+)\s*kB', 'tokens', 'once');
fprintf('VMHWM_KB=%s\n', tok{1});
end

%% ------------------------------------------------------------------ console rule (research R5)

function textLines = splitConsole(text)
% MATLAB -batch wraps warnings as [<BS>Warning: ...]<BS>; drop the backspaces, and drop the
% environment's path warnings ("Name is nonexistent or not a directory", raised by path
% changes, not by the functions under test) together with the path line that follows
textLines = regexp(strrep(text, char(8), ''), '\r?\n', 'split');
isNoise = false(size(textLines));
for k = 1:numel(textLines)
    if ~isempty(regexp(textLines{k}, '^\[?Warning: Name is nonexistent or not a directory:', 'once'))
        isNoise(k) = true;
        if k < numel(textLines)
            isNoise(k + 1) = true;
        end
    end
end
textLines = textLines(~isNoise);
end

function [kept, frames] = dropStackFrames(textLines)
isFrame = false(size(textLines));
k = 1;
while k <= numel(textLines)
    ln = textLines{k};
    if ~isempty(regexp(ln, '^\[?\s*>?\s*In \S.*\(line \d+\)\]?\s*$', 'once'))
        isFrame(k) = true; % warning backtrace frame
    elseif ~isempty(regexp(ln, '^Error in \S.*\(line \d+\)\s*$', 'once'))
        isFrame(k) = true; % getReport frame, then its echoed source line and caret line
        if k + 1 <= numel(textLines)
            isFrame(k + 1) = true;
            k = k + 1;
        end
        if k + 1 <= numel(textLines) && ~isempty(regexp(textLines{k + 1}, '^\s*\^+\s*$', 'once'))
            isFrame(k + 1) = true;
            k = k + 1;
        end
    end
    k = k + 1;
end
kept = textLines(~isFrame);
frames = textLines(isFrame);
end

function [nonRead, readLines] = classifyLines(textLines, msgSet)
isRead = ismember(textLines, msgSet);
% a blank line right after a readABRXNFile message belongs to that message
for k = 2:numel(textLines)
    if isempty(strtrim(textLines{k})) && isRead(k - 1)
        isRead(k) = true;
    end
end
readLines = textLines(isRead & ~cellfun(@(l) isempty(strtrim(l)), textLines));
nonRead = textLines(~isRead);
end

function res = compareConsole(origText, modText, msgSet)
[origKept, origFrames] = dropStackFrames(splitConsole(origText));
[modKept, modFrames] = dropStackFrames(splitConsole(modText));
[origNonRead, origRead] = classifyLines(origKept, msgSet);
[modNonRead, modRead] = classifyLines(modKept, msgSet);
res.sequencePass = isequal(origNonRead, modNonRead);
res.firstSequenceDiff = '';
if ~res.sequencePass
    n = min(numel(origNonRead), numel(modNonRead));
    d = find(~strcmp(origNonRead(1:n), modNonRead(1:n)), 1);
    if isempty(d)
        d = n + 1;
    end
    res.firstSequenceDiff = sprintf('line %d: original "%s" vs modified "%s" (lengths %d vs %d)', d, ...
        safeLine(origNonRead, d), safeLine(modNonRead, d), numel(origNonRead), numel(modNonRead));
end
distinctRead = unique([origRead(:); modRead(:)]);
res.readPass = true;
res.readCounts = cell(numel(distinctRead), 3);
for k = 1:numel(distinctRead)
    nOrig = nnz(strcmp(origRead, distinctRead{k}));
    nMod = nnz(strcmp(modRead, distinctRead{k}));
    res.readCounts(k, :) = {distinctRead{k}, nOrig, nMod};
    if ~(nOrig >= 1 && nMod >= 1 && nMod <= nOrig)
        res.readPass = false;
    end
end
res.pass = res.sequencePass && res.readPass;
res.framesOnlyInOriginal = setdiff(reportableFrames(origFrames), reportableFrames(modFrames));
res.framesOnlyInModified = setdiff(reportableFrames(modFrames), reportableFrames(origFrames));
end

function frames = reportableFrames(frames)
% frame headers only (not echoed source lines), excluding this harness's own frames
isHeader = ~cellfun('isempty', regexp(frames, '^(\[?\s*>?\s*In |Error in )', 'once'));
isHarness = contains(frames, 'buildRuntimeReproducibilityCheck');
frames = unique(strtrim(frames(isHeader & ~isHarness)));
end

function s = safeLine(textLines, k)
if k <= numel(textLines)
    s = textLines{k};
else
    s = '<end>';
end
end

%% ------------------------------------------------------------------ modes

function runCapture(cfg, fixtureNames)
if ~isfolder(cfg.snapshotDir)
    mkdir(cfg.snapshotDir);
end
[baselineDir, cleanupBaseline] = makeBaselineDir(cfg); %#ok<ASGLU>
appendResults(cfg, sprintf('\n## Capture run %s (source at %s)\n\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'), cfg.baseRev));
appendResults(cfg, sprintf('| Fixture | Rxns | Mets | Corpus .rxn | decompBranch | readABRXNFile calls | addBondMappings calls | energy constructions | energy appends | median s (5 runs) | VmHWM kB | Build error |\n|---|---|---|---|---|---|---|---|---|---|---|---|\n'));
for f = 1:numel(fixtureNames)
    name = fixtureNames{f};
    fprintf('\n=== CAPTURE %s ===\n', name);
    [model, rxnDir, prov, cleanupFixture] = loadFixture(cfg, name); %#ok<ASGLU>
    snapshot = captureOutputs(model, rxnDir);
    snapshot.provenance = prov;
    snapshot.countsBefore = captureCounts(model, rxnDir);
    useBaseline(true, baselineDir, cfg); % identical code; keeps the timing path identical to compare mode
    times = zeros(cfg.nTimedRuns, 1);
    runQuiet(model, rxnDir, struct('sanityChecks', 1));
    for r = 1:cfg.nTimedRuns
        tStart = tic;
        runQuiet(model, rxnDir, struct('sanityChecks', 1));
        times(r) = toc(tStart);
    end
    useBaseline(false, baselineDir, cfg);
    snapshot.timingBefore = times;
    if isempty(prov.derivedKind)
        snapshot.peakMemBefore = peakMemory(cfg, name, 'original');
    else
        snapshot.peakMemBefore = NaN; % CI-size derived fixtures: not measured
    end
    save(fullfile(cfg.snapshotDir, [name '-golden-snapshot.mat']), '-struct', 'snapshot', '-v7');
    appendResults(cfg, sprintf('| %s | %d | %d | %d | %s | %d | %d | %d | %d | %.3f | %g | %s |\n', ...
        name, prov.nRxns, prov.nMets, prov.corpusRxnCount, snapshot.decompBranch, ...
        snapshot.countsBefore.readABRXNFileCalls, snapshot.countsBefore.addBondMappingsCalls, ...
        snapshot.countsBefore.energyConstructions, snapshot.countsBefore.energyAppends, ...
        median(times), snapshot.peakMemBefore, errText(snapshot.errDefault)));
end
end

function s = errText(err)
if isempty(err)
    s = 'none';
else
    s = sprintf('%s: %s', err.identifier, strrep(err.message, newline, ' '));
end
end

function runCaptureCI(cfg)
model = ciSubModel();
% addBondMappingsRXNFile expected values for every shipped RXN file
rxnFiles = dir(fullfile(cfg.ciRxnDir, '*.rxn'));
rxnIds = regexprep(sort({rxnFiles.name})', '\.rxn$', '');
bondMappings = cell(size(rxnIds));
for k = 1:numel(rxnIds)
    bondMappings{k} = addBondMappingsRXNFile(rxnIds{k}, cfg.ciRxnDir);
end
save(fullfile(cfg.testDir, 'data', 'addBondMappingsRXNFileExpected.mat'), 'rxnIds', 'bondMappings', '-v7');

% checkABRXNFiles expected values: base, missing, unparsable
[modelOut, nA, nB] = checkABRXNFiles(model, cfg.ciRxnDir);
base = checkFields(modelOut, nA, nB); %#ok<NASGU>
[missingDir, missingRxn] = makeDerivedRxnDir('missing', model, cfg.ciRxnDir);
cleanupMissing = onCleanup(@() rmdir(missingDir, 's')); %#ok<NASGU>
[modelOut, nA, nB] = checkABRXNFiles(model, missingDir);
missing = checkFields(modelOut, nA, nB);
missing.alteredRxn = missingRxn; %#ok<STRNU>
[unparsableDir, unparsableRxn] = makeDerivedRxnDir('unparsable', model, cfg.ciRxnDir);
cleanupUnparsable = onCleanup(@() rmdir(unparsableDir, 's')); %#ok<NASGU>
readThrew = false;
try
    readABRXNFile(unparsableRxn, unparsableDir);
catch
    readThrew = true;
end
assert(readThrew, 'buildRuntimeReproducibilityCheck:unparsableParsed', ...
    'The derived unparsable file %s.rxn did not make readABRXNFile throw (tasks T009 STOP).', unparsableRxn);
[modelOut, nA, nB] = checkABRXNFiles(model, unparsableDir);
unparsable = checkFields(modelOut, nA, nB);
unparsable.alteredRxn = unparsableRxn; %#ok<STRNU>
[firstBrokenDir, ~] = makeDerivedRxnDir('firstBroken', model, cfg.ciRxnDir);
cleanupFirstBroken = onCleanup(@() rmdir(firstBrokenDir, 's')); %#ok<NASGU>
checkThrew = false;
try
    checkABRXNFiles(model, firstBrokenDir);
catch
    checkThrew = true;
end
assert(checkThrew, 'buildRuntimeReproducibilityCheck:firstBrokenPassed', ...
    'checkABRXNFiles did not throw on the firstBroken fixture (tasks T009 STOP).');
save(fullfile(cfg.testDir, 'data', 'checkABRXNFilesExpected.mat'), 'base', 'missing', 'unparsable', '-v7');
appendResults(cfg, sprintf(['\n## CI expected-value capture %s (source at %s)\n\n' ...
    '- addBondMappingsRXNFileExpected.mat: %d RXN files\n' ...
    '- checkABRXNFilesExpected.mat: base, missing (%s.rxn deleted), unparsable (%s.rxn cut to 4 header lines)\n' ...
    '- readABRXNFile throws on the unparsable file: yes; checkABRXNFiles throws on firstBroken: yes\n'], ...
    datestr(now, 'yyyy-mm-dd HH:MM:SS'), cfg.baseRev, numel(rxnIds), missingRxn, unparsableRxn));
end

function runCompare(cfg, fixtureNames, measure)
[baselineDir, cleanupBaseline] = makeBaselineDir(cfg); %#ok<ASGLU>
[~, head] = system(sprintf('git -C "%s" rev-parse --short HEAD', cfg.repoRoot));
if measure
    runKind = 'Compare';
else
    runKind = 'Self-check (equality and console only)';
end
appendResults(cfg, sprintf('\n## %s run %s (HEAD %s, working tree; original = %s copies)\n\n', ...
    runKind, datestr(now, 'yyyy-mm-dd HH:MM:SS'), strtrim(head), cfg.baseRev));
for f = 1:numel(fixtureNames)
    name = fixtureNames{f};
    fprintf('\n=== COMPARE %s ===\n', name);
    snapFile = fullfile(cfg.snapshotDir, [name '-golden-snapshot.mat']);
    if ~isfile(snapFile)
        appendResults(cfg, sprintf('### %s\n\n- no snapshot: SKIPPED\n\n', name));
        continue
    end
    snapshot = load(snapFile);
    [model, rxnDir, prov, cleanupFixture] = loadFixture(cfg, name); %#ok<ASGLU>
    [sameProv, provReason] = sameProvenance(snapshot.provenance, prov);
    textLines = {sprintf('### %s (%d rxns, %d mets, decompBranch %s)\n', name, prov.nRxns, prov.nMets, snapshot.decompBranch)};
    if ~sameProv
        textLines{end + 1} = sprintf('- corpus changed since capture (%s): equality not assessed\n', provReason);
    else
        now_ = captureOutputs(model, rxnDir);
        textLines = [textLines, compareRecords(snapshot, now_)]; %#ok<AGROW>
    end
    if measure && strcmp(name, 'ci')
        textLines{end + 1} = invalidIndexCheck(model, rxnDir);
    end
    if ~measure
        appendResults(cfg, [strjoin(textLines, ''), newline]);
        continue
    end
    % timing, counts and memory are measured against the baseline copies in this session
    timing = timeRuns(model, rxnDir, baselineDir, cfg);
    if ~timing.pass
        fprintf('Timing shortfall on %s; repeating once (research R7).\n', name);
        timing = timeRuns(model, rxnDir, baselineDir, cfg);
    end
    textLines{end + 1} = sprintf(['- timing (5 alternating runs): original median %.3f s, modified median %.3f s, ' ...
        'speed-up %.2fx, noise %.3f s: %s\n'], timing.medianOriginal, timing.medianModified, ...
        timing.ratio, timing.noise, passText(timing.pass));
    textLines{end + 1} = sprintf('  - original runs: %s; modified runs: %s\n', mat2str(timing.original', 4), mat2str(timing.modified', 4));
    useBaseline(true, baselineDir, cfg);
    countsOrig = captureCounts(model, rxnDir);
    useBaseline(false, baselineDir, cfg);
    countsMod = captureCounts(model, rxnDir);
    nMapped = numel(snapshot.bondMappingsByRxn.rxnIds);
    textLines{end + 1} = sprintf(['- readABRXNFile calls: original %d, modified %d (3r+1 = %d for r = %d): %s\n' ...
        '- addBondMappingsRXNFile calls: original %d, modified %d: %s\n' ...
        '- energy table constructions: original %d, modified %d; energy rows appended: modified %d: %s\n'], ...
        countsOrig.readABRXNFileCalls, countsMod.readABRXNFileCalls, 3 * nMapped + 1, nMapped, ...
        passText(countsMod.readABRXNFileCalls <= 3 * nMapped + 2), ...
        countsOrig.addBondMappingsCalls, countsMod.addBondMappingsCalls, ...
        passText(countsOrig.addBondMappingsCalls == countsMod.addBondMappingsCalls), ...
        countsOrig.energyConstructions, countsMod.energyConstructions, countsMod.energyAppends, ...
        passText(countsMod.energyConstructions == countsMod.energyAppends && ...
        countsOrig.energyAppends == countsMod.energyAppends));
    if isempty(prov.derivedKind)
        memOrig = peakMemory(cfg, name, 'original');
        memMod = peakMemory(cfg, name, 'modified');
        memPass = memMod <= memOrig + max(cfg.memRelTol * memOrig, cfg.memAbsTolKB);
        textLines{end + 1} = sprintf('- peak memory VmHWM: original %g kB, modified %g kB (capture %g kB): %s\n', ...
            memOrig, memMod, snapshot.peakMemBefore, passText(memPass));
    else
        textLines{end + 1} = sprintf('- peak memory: not measured (derived CI-size fixture)\n');
    end
    appendResults(cfg, [strjoin(textLines, ''), newline]);
end
end

function textLines = compareRecords(snap, now_)
textLines = {};
textLines{end + 1} = sprintf('- build error (default): original %s, modified %s: %s\n', errText(snap.errDefault), ...
    errText(now_.errDefault), passText(sameError(snap.errDefault, now_.errDefault)));
textLines{end + 1} = outputsLine('default', snap.outDefault, now_.outDefault);
textLines{end + 1} = outputsLine('dense', snap.outDense, now_.outDense);
textLines{end + 1} = sprintf('- class/sparsity of outputs: %s\n', passText(isequal(snap.classInfo, now_.classInfo)));
if isempty(snap.errCheck) && isempty(now_.errCheck)
    textLines{end + 1} = sprintf('- checkABRXNFiles fields and counts: %s\n', passText(isequaln(snap.checkOut, now_.checkOut)));
else
    textLines{end + 1} = sprintf('- checkABRXNFiles error: original %s, modified %s: %s\n', errText(snap.errCheck), ...
        errText(now_.errCheck), passText(sameError(snap.errCheck, now_.errCheck)));
end
bmPass = isequal(snap.bondMappingsByRxn.rxnIds, now_.bondMappingsByRxn.rxnIds);
nBad = 0;
if bmPass
    for k = 1:numel(snap.bondMappingsByRxn.tables)
        a = snap.bondMappingsByRxn.tables{k};
        b = now_.bondMappingsByRxn.tables{k};
        if istable(a) && istable(b)
            ok = isequaln(a, b) && isequal(a.Properties.VariableNames, b.Properties.VariableNames);
        elseif isstruct(a) && isstruct(b)
            ok = sameError(a, b);
        else
            ok = false;
        end
        nBad = nBad + ~ok;
    end
end
textLines{end + 1} = sprintf('- bondMappings for %d RXN files: %d mismatches: %s\n', ...
    numel(snap.bondMappingsByRxn.tables), nBad, passText(bmPass && nBad == 0));
res = compareConsole(snap.consoleText, now_.consoleText, snap.readMessages);
textLines{end + 1} = sprintf('- console rule (FR-009/R5): non-readABRXNFile sequence %s, readABRXNFile counts %s: %s\n', ...
    passText(res.sequencePass), passText(res.readPass), passText(res.pass));
if ~res.sequencePass
    textLines{end + 1} = sprintf('  - first difference: %s\n', res.firstSequenceDiff);
end
for k = 1:size(res.readCounts, 1)
    if res.readCounts{k, 2} ~= res.readCounts{k, 3}
        textLines{end + 1} = sprintf('  - readABRXNFile line x%d -> x%d: `%s`\n', res.readCounts{k, 2}, ...
            res.readCounts{k, 3}, res.readCounts{k, 1}); %#ok<AGROW>
    end
end
for k = 1:numel(res.framesOnlyInOriginal)
    textLines{end + 1} = sprintf('  - stack frame only in original: `%s`\n', strtrim(res.framesOnlyInOriginal{k})); %#ok<AGROW>
end
for k = 1:numel(res.framesOnlyInModified)
    textLines{end + 1} = sprintf('  - stack frame only in modified: `%s`\n', strtrim(res.framesOnlyInModified{k})); %#ok<AGROW>
end
end

function line = invalidIndexCheck(model, rxnDir)
% tasks T022 (FR-004 edge case): the BondElmts block below is a character-for-character
% copy of the one in buildAtomAndBondTransitionMultigraph.m (checked in T024). Applied to
% the returned dBTM/dATME it must reproduce the returned BondElmts column, and it must
% raise an error when a bond atom index is NaN, zero or out of range.
out = callBuild(model, rxnDir, struct('sanityChecks', 1));
dATME = out{6};
dBTM = out{8};
recomputed = vectorisedBondElmts(dBTM, dATME);
reproduces = isequal(recomputed.Nodes.BondElmts, dBTM.Nodes.BondElmts);
badValues = [NaN, 0, height(dATME.Nodes) + 1];
nErrors = 0;
for v = badValues
    dBTMBad = dBTM;
    dBTMBad.Nodes.BondHeadAtomIndex(1) = v;
    try
        vectorisedBondElmts(dBTMBad, dATME);
    catch
        nErrors = nErrors + 1;
    end
end
line = sprintf(['- BondElmts block (T022): reproduces the returned column %s; raises an error for ' ...
    'index NaN, 0 and out of range: %d of 3: %s\n'], passText(reproduces), nErrors, ...
    passText(reproduces && nErrors == numel(badValues)));
end

function dBTM = vectorisedBondElmts(dBTM, dATME)
if height(dBTM.Nodes) > 0
    bondElementList = dATME.Nodes.Element;
    bondHeadElmts = bondElementList(full(dBTM.Nodes.BondHeadAtomIndex(:)));
    bondTailElmts = bondElementList(full(dBTM.Nodes.BondTailAtomIndex(:)));
    dBTM.Nodes.BondElmts = cellfun(@(a, b) [a '-' b], bondHeadElmts, bondTailElmts, 'UniformOutput', false);
end
end

function line = outputsLine(modeName, a, b)
names = {'dATM', 'metAtomMappedBool', 'rxnAtomMappedBool', 'M2Ai', 'Ti2R', 'dATME', 'BG', ...
    'dBTM', 'M2BiE', 'M2BiW', 'BTi2R', 'BTiE'};
if isempty(a) && isempty(b)
    line = sprintf('- outputs (%s): none produced by either version: PASS\n', modeName);
    return
end
if numel(a) ~= numel(b)
    line = sprintf('- outputs (%s): output count differs: FAIL\n', modeName);
    return
end
bad = {};
for k = 1:numel(a)
    if ~isequaln(a{k}, b{k})
        bad{end + 1} = names{k}; %#ok<AGROW>
    end
end
if isempty(bad)
    line = sprintf('- outputs (%s): all 12 isequaln: PASS\n', modeName);
else
    line = sprintf('- outputs (%s): mismatch in %s: FAIL\n', modeName, strjoin(bad, ', '));
end
end

function same = sameError(a, b)
if isempty(a) && isempty(b)
    same = true;
elseif isempty(a) || isempty(b)
    same = false;
else
    same = strcmp(a.identifier, b.identifier) && strcmp(a.message, b.message);
end
end

function s = passText(ok)
if ok
    s = 'PASS';
else
    s = 'FAIL';
end
end

function appendResults(cfg, text)
fid = fopen(cfg.resultsPath, 'a');
fprintf(fid, '%s', text);
fclose(fid);
end
