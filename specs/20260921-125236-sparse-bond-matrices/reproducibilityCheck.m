% reproducibilityCheck.m
%
% Non-CI golden-snapshot reproducibility check for feature
% 20260921-125236-sparse-bond-matrices (Constitution Principle III's
% documented-reproducibility-check fallback: the tyrosine fixture depends on an
% external model and RXN corpus; see spec FR-012, FR-013, SC-001, SC-003,
% SC-004, SC-005 and research R7, R8). Structural template: feature
% 20260902-150020-eliminate-bond-transition-ismember-scans'
% tyrosineReproducibilityCheck.m (capture-vs-compare mode chosen by snapshot
% presence, append-only results file). Unlike that script, this one captures
% all twelve outputs of buildAtomAndBondTransitionMultigraph itself, over
% several fixtures, and compares them in both output modes.
%
% USAGE:
%   run('specs/20260921-125236-sparse-bond-matrices/reproducibilityCheck.m')
%
% Mode is selected automatically by whether golden-snapshot.mat exists next
% to this script:
%   - snapshot absent  -> CAPTURE mode. MUST be run against the UNMODIFIED
%     buildAtomAndBondTransitionMultigraph.m. Saves every fixture's outputs,
%     their original classes, residuals, inconsistency warnings, provenance,
%     and (tyrosine only) the median fill-step time of the original loops.
%   - snapshot present -> COMPARE mode. Re-runs every fixture with default
%     options and with options.denseBondMatrices = 1, compares against the
%     snapshot, appends a section to reproducibility-results.md, then asserts
%     every gate (so a FAIL errors only after the results are written).
%
% ADJUST BEFORE RUNNING: the tyrosine model and RXN corpus are external
% (spec Assumptions). If they have moved, change tyrModelPath / tyrRxnDir
% below without changing the rest of this script's intent.
%
% Authors:
%     - COBRA Toolbox, feature 20260921-125236-sparse-bond-matrices

global CBTDIR

tyrModelPath = fullfile(getenv('HOME'), 'repos', 'ReconXKG-cidev', 'ReconXKGtoCobra', ...
    'models', 'subsystemSubModels', 'subsystemSubModels.mat');
tyrRxnDir = '/media/JACK/repos/ctf/rxns/old/atomMapped_standardised'; % research R7
tyrVarNameHint = 'tyr';
nTimedRuns = 5;              % median of 5 runs (spec FR-013, SC-005)
storageRatioMax = 0.10;      % SC-004
snapshotSizeWarnBytes = 10e6;

thisDir = fileparts(mfilename('fullpath'));
repoRoot = fileparts(fileparts(thisDir));
snapshotPath = fullfile(thisDir, 'golden-snapshot.mat');
resultsPath = fullfile(thisDir, 'reproducibility-results.md');
srcPath = fullfile(repoRoot, 'src', 'analysis', 'topology', 'reactingMoieties', ...
    'buildAtomAndBondTransitionMultigraph.m');
testDataDir = fullfile(repoRoot, 'test', 'verifiedTests', 'analysis', 'testReactingMoieties', 'data');
localRxnDir = fullfile(testDataDir, 'rxnFiles');

if ~exist('buildAtomAndBondTransitionMultigraph', 'file')
    initCobraToolbox(false);
end
assert(isfile(tyrModelPath), 'reproducibilityCheck:ModelNotFound', ...
    'Tyrosine subsystem model not found at %s. Adjust tyrModelPath.', tyrModelPath);
assert(isfolder(tyrRxnDir), 'reproducibilityCheck:RxnFilesNotFound', ...
    'Atom-mapped RXN corpus not found at %s. Adjust tyrRxnDir.', tyrRxnDir);

%% Fixtures (tasks.md T004; required fixtures are tyr and ci -- research R7)
recon3DPath = fullfile(CBTDIR, 'test', 'models', 'mat', 'Recon3D_301.mat');
recon3D = readCbModel(recon3DPath);
ciModel = extractSubNetwork(recon3D, {'r0317'; 'ACONTm'; 'r0426'});
clear recon3D

fixtures = struct('name', {}, 'model', {}, 'rxnDir', {}, 'modelPath', {}, ...
    'required', {}, 'nOut', {}, 'bondTransitionMultigraph', {}, 'allowError', {}, 'expectConsistent', {});
fixtures(end + 1) = makeFixture('ci', ciModel, localRxnDir, recon3DPath, true, 12, 1, false);
subModelFiles = {'crn', 'crnBondKeySubmodel.mat'; 'coaM', 'coaMBondKeySubmodel.mat'; ...
    'coaX', 'coaXBondKeySubmodel.mat'; 'coaR', 'coaRBondKeySubmodel.mat'; ...
    'crnM', 'crnMBondKeySubmodel.mat'};
for k = 1:size(subModelFiles, 1)
    subModelPath = fullfile(testDataDir, subModelFiles{k, 2});
    loadedSubModel = load(subModelPath);
    fixtures(end + 1) = makeFixture(subModelFiles{k, 1}, loadedSubModel.subModel, localRxnDir, ...
        subModelPath, false, 12, 1, false); %#ok<SAGROW>
end
% hand-built MACACI/rh_14817 model, exactly as in testConservedReactingMoieties.m
macaciModel = struct();
macaciModel.mets = {'maleacac[c]'; '4fumacac[c]'; 'CHEBI_17105[c]'; 'CHEBI_18034[c]'};
macaciModel.rxns = {'MACACI'; 'rh_14817'};
macaciModel.S = sparse([-1 0; 1 0; 0 -1; 0 1]);
macaciModel.lb = [-1000; -1000];
macaciModel.ub = [1000; 1000];
fixtures(end + 1) = makeFixture('macaci', macaciModel, localRxnDir, 'hand-built', false, 12, 1, false);
% US1 acceptance scenario 4: only the first five outputs are assigned in this mode
fixtures(end + 1) = makeFixture('ci_noBond', ciModel, localRxnDir, recon3DPath, false, 5, 0, false);
% degenerate input: no reaction has an RXN file (spec Edge Case "Empty or degenerate inputs")
noRxnFilesModel = ciModel;
noRxnFilesModel.rxns = strcat(ciModel.rxns, '_none');
fixtures(end + 1) = makeFixture('noRxnFiles', noRxnFilesModel, localRxnDir, recon3DPath, false, 12, 1, true);
fixtures(end + 1) = makeFixture('tyr', loadTyrosineModel(tyrModelPath, tyrVarNameHint), tyrRxnDir, ...
    tyrModelPath, true, 12, 1, false);

[~, gitHead] = system(sprintf('git -C "%s" rev-parse HEAD', repoRoot));
gitHead = strtrim(gitHead);

if ~isfile(snapshotPath)
    %% ================= CAPTURE mode (unmodified source) =================
    snapshot = struct();
    for f = 1:numel(fixtures)
        fx = fixtures(f);
        fprintf('[reproducibilityCheck] CAPTURE %s ...\n', fx.name);
        [outputs, consoleText, errorInfo] = runCaptured(fx, []);
        entry = struct();
        entry.outputs = outputs;
        entry.errorInfo = errorInfo;
        entry.originalClasses = describeClasses(outputs);
        if isempty(errorInfo) && fx.nOut == 12
            % three matrices stored sparse to keep the snapshot small (spec Assumptions)
            entry.outputs{9} = sparse(outputs{9});
            entry.outputs{10} = sparse(outputs{10});
            entry.outputs{11} = sparse(outputs{11});
        end
        entry.residuals = computeResiduals(fx, outputs, errorInfo);
        entry.warningsSeen = inconsistencyWarnings(consoleText);
        entry.bondReport = bondMismatchReport(consoleText);
        entry.provenance = provenanceOf(fx, gitHead);
        if strcmp(fx.name, 'tyr')
            % research R8: time the verbatim original fill code on the function's own data,
            % after checking that the copy reproduces the function's M2BiE/M2BiW exactly
            [copyM2BiE, copyM2BiW] = fillBondMatricesOriginal(fx.model, outputs{8}, height(outputs{8}.Nodes));
            assert(isequaln(copyM2BiE, outputs{9}) && isequaln(copyM2BiW, outputs{10}), ...
                'reproducibilityCheck:OriginalCopyFidelity', ...
                'fillBondMatricesOriginal does not reproduce the unmodified function''s M2BiE/M2BiW.');
            entry.fillMedianSecondsBefore = timeFill(@fillBondMatricesOriginal, fx.model, outputs{8}, nTimedRuns);
            fprintf('[reproducibilityCheck] tyr original fill-step median of %d runs: %.4f s\n', ...
                nTimedRuns, entry.fillMedianSecondsBefore);
        end
        printCaptureSummary(fx, entry);
        snapshot.(fx.name) = entry;
    end
    save(snapshotPath, 'snapshot', '-v7');
    reloaded = load(snapshotPath);
    assert(isequaln(reloaded.snapshot, snapshot), 'reproducibilityCheck:SnapshotSelfCompare', ...
        'The saved golden snapshot does not compare equal to itself after reload.');
    snapshotInfo = dir(snapshotPath);
    fprintf('[reproducibilityCheck] Snapshot saved: %s (%d bytes)\n', snapshotPath, snapshotInfo.bytes);
    if snapshotInfo.bytes > snapshotSizeWarnBytes
        warning('reproducibilityCheck:LargeSnapshot', ...
            'Golden snapshot is %d bytes (> %d). Ask before committing it (tasks.md T005).', ...
            snapshotInfo.bytes, snapshotSizeWarnBytes);
    end
else
    %% ================= COMPARE mode (modified source) =================
    loadedSnapshot = load(snapshotPath);
    snapshot = loadedSnapshot.snapshot;
    reportLines = {sprintf('## Run %s', datestr(now, 'yyyy-mm-dd HH:MM:SS')), '', ...
        sprintf('- Source commit (HEAD): `%s` (working tree may contain the uncommitted change)', gitHead), ...
        '- Not covered: reconXmoieties pilot fixtures (need that repository''s staged data and the unmerged feature 029 harness; research R7).', ''}; %#ok<TNOW1,DATST>
    gates = struct('label', {}, 'pass', {});

    for f = 1:numel(fixtures)
        fx = fixtures(f);
        snap = snapshot.(fx.name);
        currentProvenance = provenanceOf(fx, gitHead);
        if ~strcmp(currentProvenance.rxnDirHash, snap.provenance.rxnDirHash) || ...
                currentProvenance.rxnFileCount ~= snap.provenance.rxnFileCount || ...
                ~strcmp(currentProvenance.modelFileStamp, snap.provenance.modelFileStamp)
            error('reproducibilityCheck:CorpusChanged', ...
                ['Input data for fixture %s changed since the golden snapshot was captured ' ...
                 '(RXN files %d -> %d, hash %s -> %s, model %s -> %s). A data change must not be ' ...
                 'reported as a code regression; recapture against the unmodified source.'], ...
                fx.name, snap.provenance.rxnFileCount, currentProvenance.rxnFileCount, ...
                snap.provenance.rxnDirHash, currentProvenance.rxnDirHash, ...
                snap.provenance.modelFileStamp, currentProvenance.modelFileStamp);
        end
        reportLines{end + 1} = sprintf('### Fixture `%s` (%s; %d mets, %d rxns; RXN dir `%s`, %d files, hash `%s`)', ...
            fx.name, tern(fx.required, 'required', 'optional'), numel(fx.model.mets), numel(fx.model.rxns), ...
            fx.rxnDir, currentProvenance.rxnFileCount, currentProvenance.rxnDirHash(1:16)); %#ok<SAGROW>
        reportLines{end + 1} = ''; %#ok<SAGROW>

        for denseMode = [0 1]
            modeLabel = tern(denseMode, 'dense', 'default');
            fprintf('[reproducibilityCheck] COMPARE %s (%s mode) ...\n', fx.name, modeLabel);
            extraOptions = struct();
            if denseMode
                extraOptions.denseBondMatrices = 1;
            end
            [outputs, consoleText, errorInfo] = runCaptured(fx, extraOptions);
            prefix = sprintf('%s/%s', fx.name, modeLabel);

            % ---- error outcome (degenerate fixture) ----
            if ~isempty(snap.errorInfo) || ~isempty(errorInfo)
                samePass = ~isempty(snap.errorInfo) && ~isempty(errorInfo) && ...
                    strcmp(snap.errorInfo.identifier, errorInfo.identifier) && ...
                    strcmp(snap.errorInfo.message, errorInfo.message);
                gates(end + 1) = gate(sprintf('%s SC-001 same error outcome', prefix), samePass); %#ok<SAGROW>
                reportLines{end + 1} = sprintf('- %s: error outcome identical to original (`%s`): %s', ...
                    modeLabel, strrep(describeError(errorInfo), newline, ' '), tern(samePass, 'PASS', 'FAIL')); %#ok<SAGROW>
                continue
            end

            % ---- SC-001: values and classes of every output ----
            valuePass = true;
            classPass = true;
            newClasses = describeClasses(outputs);
            for k = 1:fx.nOut
                if ismember(k, 9:11)
                    valuePass = valuePass && isequal(size(outputs{k}), size(snap.outputs{k})) && ...
                        isequaln(full(outputs{k}), full(snap.outputs{k}));
                else
                    valuePass = valuePass && isequaln(outputs{k}, snap.outputs{k});
                end
                expectedClass = snap.originalClasses(k);
                if ~denseMode && ismember(k, 9:11)
                    expectedClass.issparse = true; % the one approved difference (FR-001)
                end
                classPass = classPass && strcmp(newClasses(k).class, expectedClass.class) && ...
                    newClasses(k).issparse == expectedClass.issparse;
            end
            gates(end + 1) = gate(sprintf('%s SC-001 values', prefix), valuePass); %#ok<SAGROW>
            gates(end + 1) = gate(sprintf('%s SC-001 class/issparse of all %d outputs', prefix, fx.nOut), classPass); %#ok<SAGROW>
            reportLines{end + 1} = sprintf('- %s: SC-001 values of all %d outputs `isequaln` to snapshot: %s; class/issparse as expected: %s', ...
                modeLabel, fx.nOut, tern(valuePass, 'PASS', 'FAIL'), tern(classPass, 'PASS', 'FAIL')); %#ok<SAGROW>

            % ---- SC-003: residuals and inconsistency warnings ----
            residuals = computeResiduals(fx, outputs, errorInfo);
            warningsSeen = inconsistencyWarnings(consoleText);
            bondReport = bondMismatchReport(consoleText);
            if fx.expectConsistent
                sc003Pass = residuals.atom == 0 && (isnan(residuals.bond) || residuals.bond == 0) && ...
                    ~warningsSeen.atom && ~warningsSeen.bond;
                sc003Rule = 'zero residuals, no inconsistency warning';
            else
                sc003Pass = isequaln(residuals, snap.residuals) && isequal(warningsSeen, snap.warningsSeen);
                sc003Rule = 'residuals and warnings identical to original';
            end
            % FR-007/FR-008: the bond mismatch report (empty when consistent) must be
            % printed exactly as the original function printed it, in both modes.
            reportPass = strcmp(bondReport, snap.bondReport);
            gates(end + 1) = gate(sprintf('%s FR-007 mismatch report identical', prefix), reportPass); %#ok<SAGROW>
            reportLines{end + 1} = sprintf('- %s: FR-007 bond mismatch report (%d lines) identical to original: %s', ...
                modeLabel, numel(splitlines(bondReport)) * ~isempty(bondReport), tern(reportPass, 'PASS', 'FAIL')); %#ok<SAGROW>
            gates(end + 1) = gate(sprintf('%s SC-003', prefix), sc003Pass); %#ok<SAGROW>
            reportLines{end + 1} = sprintf('- %s: SC-003 (%s): atom residual %g, bond residual %g, atom warning %d, bond warning %d: %s', ...
                modeLabel, sc003Rule, residuals.atom, residuals.bond, warningsSeen.atom, warningsSeen.bond, ...
                tern(sc003Pass, 'PASS', 'FAIL')); %#ok<SAGROW>

            if fx.nOut < 12
                continue
            end
            dBTM = outputs{8};

            % ---- edge checks: energy pseudo-node columns and bond-less rows are empty ----
            nonModelBondCols = ~ismember(dBTM.Nodes.mets, fx.model.mets);
            bondlessRows = ~ismember(fx.model.mets, dBTM.Nodes.mets);
            edgePass = nnz(outputs{9}(:, nonModelBondCols)) == 0 && nnz(outputs{10}(:, nonModelBondCols)) == 0 && ...
                nnz(outputs{9}(bondlessRows, :)) == 0 && nnz(outputs{10}(bondlessRows, :)) == 0;
            gates(end + 1) = gate(sprintf('%s edge checks', prefix), edgePass); %#ok<SAGROW>
            reportLines{end + 1} = sprintf('- %s: %d non-metabolite (energy) bond columns and %d bond-less metabolite rows all empty: %s', ...
                modeLabel, nnz(nonModelBondCols), nnz(bondlessRows), tern(edgePass, 'PASS', 'FAIL')); %#ok<SAGROW>

            if denseMode
                continue
            end

            % ---- SC-004: storage (default mode) ----
            sparseBytes = bytesOf(outputs{9}) + bytesOf(outputs{10}) + bytesOf(outputs{11});
            denseBytes = bytesOf(full(outputs{9})) + bytesOf(full(outputs{10})) + bytesOf(full(outputs{11}));
            storageRatio = sparseBytes / denseBytes;
            isLargeFixture = numel(fx.model.mets) >= 50 && numel(fx.model.rxns) >= 50;
            if isLargeFixture
                sc004Pass = storageRatio <= storageRatioMax;
                gates(end + 1) = gate(sprintf('%s SC-004', prefix), sc004Pass); %#ok<SAGROW>
                sc004Verdict = tern(sc004Pass, 'PASS', 'FAIL');
            else
                sc004Verdict = 'reported only (fixture < 50 mets or < 50 rxns)';
            end
            reportLines{end + 1} = sprintf('- SC-004 storage of M2BiE+M2BiW+BTi2R: %d bytes sparse vs %d bytes dense (ratio %.4f; gate <= %.2f): %s', ...
                sparseBytes, denseBytes, storageRatio, storageRatioMax, sc004Verdict); %#ok<SAGROW>

            % ---- SC-005 and modified-copy fidelity (tyrosine only; research R8) ----
            if strcmp(fx.name, 'tyr')
                [copyM2BiE, copyM2BiW] = fillBondMatricesModified(fx.model, dBTM, height(dBTM.Nodes));
                fidelityPass = isequaln(full(copyM2BiE), full(outputs{9})) && isequaln(full(copyM2BiW), full(outputs{10}));
                sourceMatchPass = modifiedCopyMatchesSource(mfilename('fullpath'), srcPath);
                gates(end + 1) = gate('tyr modified-copy fidelity', fidelityPass); %#ok<SAGROW>
                gates(end + 1) = gate('tyr modified-copy source match', sourceMatchPass); %#ok<SAGROW>
                fillMedianAfter = timeFill(@fillBondMatricesModified, fx.model, dBTM, nTimedRuns);
                sc005Pass = fillMedianAfter <= snap.fillMedianSecondsBefore;
                gates(end + 1) = gate('tyr SC-005', sc005Pass); %#ok<SAGROW>
                reportLines{end + 1} = sprintf('- Modified fill copy reproduces the function''s M2BiE/M2BiW: %s; its code appears verbatim in the source: %s', ...
                    tern(fidelityPass, 'PASS', 'FAIL'), tern(sourceMatchPass, 'PASS', 'FAIL')); %#ok<SAGROW>
                reportLines{end + 1} = sprintf('- SC-005 M2BiE/M2BiW fill step, median of %d runs: before %.6f s, after %.6f s (%.1fx): %s', ...
                    nTimedRuns, snap.fillMedianSecondsBefore, fillMedianAfter, ...
                    snap.fillMedianSecondsBefore / fillMedianAfter, tern(sc005Pass, 'PASS', 'FAIL')); %#ok<SAGROW>
            end
        end
        reportLines{end + 1} = ''; %#ok<SAGROW>
    end

    nFail = nnz(~[gates.pass]);
    reportLines{end + 1} = sprintf('**Overall: %d gates, %d failed.**', numel(gates), nFail);
    reportLines{end + 1} = '';
    fid = fopen(resultsPath, 'a');
    fprintf(fid, '%s\n', reportLines{:});
    fclose(fid);
    fprintf('[reproducibilityCheck] %d gates, %d failed. Results appended to %s\n', numel(gates), nFail, resultsPath);
    for g = 1:numel(gates)
        assert(gates(g).pass, 'reproducibilityCheck:GateFailed', 'Gate failed: %s', gates(g).label);
    end
end

%% ======================= local functions =======================

function fx = makeFixture(name, model, rxnDir, modelPath, required, nOut, bondTransitionMultigraph, allowError)
% expectConsistent: SC-003 requires zero residuals only for the CI fixture. The
% tyrosine fixture is already inconsistent in the original function (tym[c] and
% 34hpp[c] bond-count mismatch in the corpus, found at capture on 2026-09-21), so
% like every other fixture it must reproduce the original residuals, warnings and
% mismatch report exactly (user decision, spec SC-003).
fx = struct('name', name, 'model', model, 'rxnDir', rxnDir, 'modelPath', modelPath, ...
    'required', required, 'nOut', nOut, 'bondTransitionMultigraph', bondTransitionMultigraph, ...
    'allowError', allowError, 'expectConsistent', strcmp(name, 'ci'));
end

function model = loadTyrosineModel(modelPath, varNameHint)
% model-loading block from the feature 021/022/20260902 template
loaded = load(modelPath);
loadedFieldNames = fieldnames(loaded);
matchIdx = find(strcmpi(loadedFieldNames, varNameHint), 1);
model = [];
if ~isempty(matchIdx)
    model = loaded.(loadedFieldNames{matchIdx});
else
    for topIdx = 1:numel(loadedFieldNames)
        candidate = loaded.(loadedFieldNames{topIdx});
        if isstruct(candidate) && isfield(candidate, varNameHint)
            model = candidate.(varNameHint);
            break
        end
    end
end
assert(~isempty(model), 'reproducibilityCheck:ModelVariableNotFound', ...
    'No field "%s" found in %s (top-level fields: %s).', varNameHint, modelPath, strjoin(loadedFieldNames, ', '));
end

function [outputs, consoleText, errorInfo] = runCaptured(fx, extraOptions)
% Calls the function with console output recorded by diary (not evalc), so
% every warning still reaches the console (Principle VII-B, research R6).
options = struct('directed', 0, 'sanityChecks', 1, 'bondTransitionMultigraph', fx.bondTransitionMultigraph);
if ~isempty(extraOptions)
    extraNames = fieldnames(extraOptions);
    for n = 1:numel(extraNames)
        options.(extraNames{n}) = extraOptions.(extraNames{n});
    end
end
diaryFile = [tempname '.txt'];
previousDiaryState = get(0, 'Diary');
previousDiaryFile = get(0, 'DiaryFile');
restoreDiary = onCleanup(@() restoreDiaryState(previousDiaryState, previousDiaryFile, diaryFile));
diary(diaryFile);
outputs = cell(1, fx.nOut);
errorInfo = [];
if fx.allowError
    try
        [outputs{:}] = buildAtomAndBondTransitionMultigraph(fx.model, fx.rxnDir, options);
    catch ME
        % Expected for the degenerate fixture: the error itself is the outcome being
        % compared. Recorded with its stack (Principle VII-C), not swallowed.
        errorInfo = struct('identifier', ME.identifier, 'message', ME.message, ...
            'stackFile', ME.stack(1).file, 'stackLine', ME.stack(1).line);
        fprintf('[reproducibilityCheck] %s raised (expected for this fixture): %s\n  at %s:%d\n', ...
            fx.name, ME.message, ME.stack(1).file, ME.stack(1).line);
    end
else
    [outputs{:}] = buildAtomAndBondTransitionMultigraph(fx.model, fx.rxnDir, options);
end
diary('off');
consoleText = fileread(diaryFile);
end

function restoreDiaryState(previousDiaryState, previousDiaryFile, diaryFile)
diary('off');
set(0, 'DiaryFile', previousDiaryFile);
if strcmp(previousDiaryState, 'on')
    diary('on');
end
if isfile(diaryFile)
    delete(diaryFile);
end
end

function classes = describeClasses(outputs)
classes = struct('class', {}, 'issparse', {});
for k = 1:numel(outputs)
    classes(k).class = class(outputs{k});
    classes(k).issparse = issparse(outputs{k});
end
end

function residuals = computeResiduals(fx, outputs, errorInfo)
% Recomputes both decompositions from the outputs, mirroring the function's own
% derivation of N (atom side) and of the bond-mapped subsets. Exact comparison
% with zero is valid: the arithmetic is on integers and exact binary fractions
% (research R4). NaN marks a decomposition that is not applicable.
residuals = struct('atom', NaN, 'bond', NaN);
if ~isempty(errorInfo)
    return
end
[dATM, metAtomMappedBool, rxnAtomMappedBool, M2Ai, Ti2R] = outputs{1:5};
atomN = sparse(fx.model.S(metAtomMappedBool, rxnAtomMappedBool));
atomRes = (M2Ai * M2Ai') * atomN - M2Ai * incidence(dATM) * Ti2R;
residuals.atom = full(max([0; abs(atomRes(:))]));
if fx.nOut < 12
    return
end
[dBTM, M2BiE, M2BiW, BTi2R, BTiE] = outputs{8:12};
rxnBondMappedBool = ismember(fx.model.rxns, dBTM.Edges.rxns);
metBondMappedBool = ismember(fx.model.mets, dBTM.Nodes.mets(~ismember(dBTM.Nodes.Bond, {'E'})));
bondN = sparse(fx.model.S(metBondMappedBool, rxnBondMappedBool));
bondRes = (M2BiW(metBondMappedBool, :) * M2BiE(metBondMappedBool, :)') * bondN - ...
    M2BiE(metBondMappedBool, :) * BTiE * BTi2R;
residuals.bond = full(max([0; abs(bondRes(:))]));
end

function warningsSeen = inconsistencyWarnings(consoleText)
warningsSeen = struct( ...
    'atom', contains(consoleText, 'Inconsistent directed atom transition multigraph'), ...
    'bond', contains(consoleText, 'Inconsistent directed bond transition multigraph'));
end

function report = bondMismatchReport(consoleText)
% The text the function prints between its bond mismatch header and its
% bond inconsistency warning ('' when the bond decomposition is consistent).
startIdx = strfind(consoleText, 'Inconsistency between reaction stoichiometry and bond mapped reactions');
endIdx = strfind(consoleText, 'Inconsistent directed bond transition multigraph');
if isempty(startIdx) || isempty(endIdx)
    report = '';
else
    report = consoleText(startIdx(1):endIdx(end) - 1);
end
end

function provenance = provenanceOf(fx, gitHead)
rxnListing = dir(fullfile(fx.rxnDir, '*.rxn'));
names = sort({rxnListing.name});
[~, order] = ismember(names, {rxnListing.name});
rxnListing = rxnListing(order);
listingLines = arrayfun(@(d) sprintf('%s\t%d\t%.10f', d.name, d.bytes, d.datenum), rxnListing, 'UniformOutput', false);
digest = java.security.MessageDigest.getInstance('SHA-256');
digest.update(unicode2native(strjoin(listingLines, newline), 'UTF-8'));
hashBytes = typecast(digest.digest(), 'uint8');
provenance = struct();
provenance.rxnDir = fx.rxnDir;
provenance.rxnFileCount = numel(rxnListing);
provenance.rxnDirHash = lower(reshape(dec2hex(hashBytes)', 1, []));
if isfile(fx.modelPath)
    modelInfo = dir(fx.modelPath);
    provenance.modelFileStamp = sprintf('%s|%d|%.10f', fx.modelPath, modelInfo.bytes, modelInfo.datenum);
else
    provenance.modelFileStamp = fx.modelPath;
end
provenance.gitHead = gitHead;
end

function printCaptureSummary(fx, entry)
if ~isempty(entry.errorInfo)
    fprintf('[reproducibilityCheck]   %s: original raised "%s"\n', fx.name, entry.errorInfo.message);
    return
end
if fx.nOut == 12
    fprintf('[reproducibilityCheck]   %s: original M2BiE %s sparse=%d, M2BiW %s sparse=%d, BTi2R %s sparse=%d\n', ...
        fx.name, entry.originalClasses(9).class, entry.originalClasses(9).issparse, ...
        entry.originalClasses(10).class, entry.originalClasses(10).issparse, ...
        entry.originalClasses(11).class, entry.originalClasses(11).issparse);
end
fprintf('[reproducibilityCheck]   %s: residuals atom %g bond %g; warnings atom %d bond %d; RXN files %d\n', ...
    fx.name, entry.residuals.atom, entry.residuals.bond, entry.warningsSeen.atom, ...
    entry.warningsSeen.bond, entry.provenance.rxnFileCount);
end

function medianSeconds = timeFill(fillFunction, model, dBTM, nRuns)
nBonds = height(dBTM.Nodes);
runSeconds = zeros(nRuns, 1);
for runIdx = 1:nRuns
    runTimer = tic;
    [~, ~] = fillFunction(model, dBTM, nBonds);
    runSeconds(runIdx) = toc(runTimer);
end
medianSeconds = median(runSeconds);
end

function [M2BiE, M2BiW] = fillBondMatricesOriginal(model, dBTM, nBonds)
% Verbatim copy of buildAtomAndBondTransitionMultigraph.m lines 883-893 at
% develop commit 97ecfc596 (research R8), taking the same variables.
M2BiE=zeros(length(model.mets),nBonds);
for i=1:length(model.mets)
    M2BiE(i,:)=(ismember(dBTM.Nodes.mets,model.mets(i)))';
end

%Matrix that specifies the type of chemical bonds in M2Bi
M2BiW=zeros(length(model.mets),nBonds);
for i=1:length(model.mets)
    bondId=find(ismember(dBTM.Nodes.mets,model.mets(i)));
    M2BiW(i,bondId)=dBTM.Nodes.BondType(bondId);
end
end

function [M2BiE, M2BiW] = fillBondMatricesModified(model, dBTM, nBonds)
% Verbatim copy of the new construction in buildAtomAndBondTransitionMultigraph.m
% (research R1); modifiedCopyMatchesSource checks the lines between the markers.
% BEGIN-MODIFIED-FILL
nModelMets = length(model.mets);
[isModelMetBond, bondMetRow] = ismember(dBTM.Nodes.mets, model.mets);
bondCols = find(isModelMetBond);
M2BiE = sparse(bondMetRow(isModelMetBond), bondCols, 1, nModelMets, nBonds);
M2BiW = sparse(bondMetRow(isModelMetBond), bondCols, ...
    double(full(dBTM.Nodes.BondType(isModelMetBond))), nModelMets, nBonds);
% END-MODIFIED-FILL
end

function isMatch = modifiedCopyMatchesSource(harnessPath, srcPath)
% True when every non-blank line between the markers in this file appears,
% in order, among the lines of the source file (trimmed comparison).
harnessLines = strtrim(splitlines(fileread([harnessPath '.m'])));
beginIdx = find(strcmp(harnessLines, '% BEGIN-MODIFIED-FILL'), 1, 'last');
endIdx = find(strcmp(harnessLines, '% END-MODIFIED-FILL'), 1, 'last');
copyLines = harnessLines(beginIdx + 1:endIdx - 1);
copyLines = copyLines(~cellfun(@isempty, copyLines));
srcLines = strtrim(splitlines(fileread(srcPath)));
searchFrom = 1;
isMatch = ~isempty(copyLines);
for k = 1:numel(copyLines)
    hit = find(strcmp(srcLines(searchFrom:end), copyLines{k}), 1);
    if isempty(hit)
        isMatch = false;
        return
    end
    searchFrom = searchFrom + hit;
end
end

function b = bytesOf(x) %#ok<INUSD>
info = whos('x');
b = info.bytes;
end

function g = gate(label, pass)
g = struct('label', label, 'pass', logical(pass));
end

function text = describeError(errorInfo)
if isempty(errorInfo)
    text = 'no error';
else
    text = sprintf('%s: %s', errorInfo.identifier, errorInfo.message);
end
end

function out = tern(cond, ifTrue, ifFalse)
if cond
    out = ifTrue;
else
    out = ifFalse;
end
end
