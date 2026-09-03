% tyrosineReproducibilityCheck.m
%
% Non-CI reproducibility check for feature
% 20260902-150020-eliminate-bond-transition-ismember-scans (Constitution
% Principle III's documented-reproducibility-check fallback for a
% multi-minute, externally-dependent benchmark; see FR-007, FR-008, SC-001,
% SC-002, SC-003, SC-005). Reuses feature 021's/022's tyrosineReproducibilityCheck.m
% as a structural template (model-loading block, capture-vs-compare mode
% selection by golden-snapshot presence, append-only results file) but
% captures arm.L/moietyFormulae/reacting.selectedReactionNames -- the same
% layer feature 021's script captured, per FR-007 -- rather than feature
% 022's dATM/dBTM-node-level capture, and profiles cell.ismember/
% tabular.dotReference (dropping tabular.dotAssign -- out of scope per
% spec.md's Assumptions) around the buildAtomAndBondTransitionMultigraph call
% only, matching feature 022's own measurement scope (research.md R3).
%
% USAGE:
%   run('specs/20260902-150020-eliminate-bond-transition-ismember-scans/tyrosineReproducibilityCheck.m')
%
% Mode is selected automatically by whether the golden snapshot already
% exists next to this script:
%   - snapshot absent  -> CAPTURE mode: run the pipeline on the current
%     working tree (post-feature-022, pre-this-feature) and save arm.L /
%     moietyFormulae / reacting.selectedReactionNames, the current
%     cell.ismember/tabular.dotReference call counts, and wall-clock time as
%     the correctness baseline (FR-007(a)). This capture is NOT itself
%     expected to satisfy SC-001/SC-002 -- those gate the POST-this-feature
%     run against the fixed historical pre-feature-022 baseline constants
%     below, not against whatever this capture happens to record.
%   - snapshot present -> COMPARE mode: re-run the pipeline on the current
%     (post-this-feature) code, assert structural equality against the
%     snapshot (SC-003), and append before/after call counts, their
%     percentage reduction from the historical pre-feature-022 baseline, and
%     wall-clock time (SC-001, SC-002, SC-005) to
%     tyrosine-reproducibility-results.md.
%
% ADJUST BEFORE RUNNING: per spec.md's Assumptions section, the Tyrosine
% metabolism subsystem model and its atom-mapped RXN files are expected at
% the paths below (from the original profiling session, same as features
% 021/022). If unavailable, change modelPath/rxnFilesDir/modelVarNameHint to
% the correct location without changing the rest of this script's intent.
modelPath = fullfile(getenv('HOME'), 'repos', 'ReconXKG-cidev', 'ReconXKGtoCobra', ...
    'models', 'subsystemSubModels', 'subsystemSubModels.mat');
rxnFilesDir = '/media/JACK/repos/ctf/rxns/atomMapped_standardised';
modelVarNameHint = 'tyr'; % matches subModels.tyr (the Tyrosine metabolism subsystem abbreviation; 139 reactions)
nTimedRuns = 2; % wall-clock time averaged over at least 2 runs (SC-005; consistent with features 021/022's own ±10% run-to-run noise allowance)

% Historical baselines this feature's success criteria are defined against
% (spec.md SC-001, SC-002, SC-005) -- fixed constants, not re-derived from
% this script's own capture. The cell.ismember/tabular.dotReference values
% are feature 022's own directly-measured "before" result (its
% tyrosine-reproducibility-results.md, captured against buildAtomAndBondTransitionMultigraph
% + readABRXNFile with the identical profiling scope used below); the
% wall-clock value is feature 022's own final measured "after" result (its
% post-fix baseline, which this feature must not regress against).
PRE_FEATURE_022_ISMEMBER_BASELINE = 508534;
PRE_FEATURE_022_DOTREFERENCE_BASELINE = 1863426;
POST_FEATURE_022_WALLCLOCK_BASELINE_SECONDS = 55.0;
SC001_ISMEMBER_MAX = 50853;   % <=10% of PRE_FEATURE_022_ISMEMBER_BASELINE
SC002_DOTREFERENCE_MAX = 559028; % <=30% of PRE_FEATURE_022_DOTREFERENCE_BASELINE
WALLCLOCK_REGRESSION_TOLERANCE = 1.10; % 10% run-to-run noise allowance, matching feature 022's own precedent

thisDir = fileparts(mfilename('fullpath'));
snapshotPath = fullfile(thisDir, 'tyrosine-golden-snapshot.mat');
resultsPath = fullfile(thisDir, 'tyrosine-reproducibility-results.md');

assert(isfile(modelPath), 'tyrosineReproducibilityCheck:ModelNotFound', ...
    ['Tyrosine subsystem model not found at %s. Per spec.md''s Assumptions ' ...
     'section, adjust modelPath in this script to the correct location before running.'], modelPath);
assert(isfolder(rxnFilesDir), 'tyrosineReproducibilityCheck:RxnFilesNotFound', ...
    ['Atom-mapped RXN files not found at %s. Per spec.md''s Assumptions ' ...
     'section, adjust rxnFilesDir in this script to the correct location before running.'], rxnFilesDir);

% Ensure the toolbox is on the MATLAB path.
if ~exist('buildAtomAndBondTransitionMultigraph', 'file')
    initCobraToolbox(false, 'agent');
end

% modelPath's actual layout (feature 021/022 precedent): a top-level
% `subModels` struct whose field names are subsystem abbreviations, rather
% than a single top-level model variable. Search top-level fields first,
% then one level into any top-level struct field, for modelVarNameHint.
loaded = load(modelPath);
loadedFieldNames = fieldnames(loaded);
matchIdx = find(strcmpi(loadedFieldNames, modelVarNameHint) | contains(lower(loadedFieldNames), lower(modelVarNameHint)), 1);
if ~isempty(matchIdx)
    model = loaded.(loadedFieldNames{matchIdx});
else
    model = [];
    for topIdx = 1:numel(loadedFieldNames)
        candidate = loaded.(loadedFieldNames{topIdx});
        if isstruct(candidate)
            nestedFieldNames = fieldnames(candidate);
            nestedMatchIdx = find(strcmpi(nestedFieldNames, modelVarNameHint) | contains(lower(nestedFieldNames), lower(modelVarNameHint)), 1);
            if ~isempty(nestedMatchIdx)
                model = candidate.(nestedFieldNames{nestedMatchIdx});
                break;
            end
        end
    end
    assert(~isempty(model), 'tyrosineReproducibilityCheck:ModelVariableNotFound', ...
        ['No top-level or one-level-nested field matching "%s" found in %s ' ...
         '(top-level fields: %s). Adjust modelVarNameHint in this script to match ' ...
         'the Tyrosine subsystem model''s actual field/variable name.'], ...
        modelVarNameHint, modelPath, strjoin(loadedFieldNames, ', '));
end

options.directed = 0;
options.sanityChecks = 1; % matches testConservedReactingMoieties.m's buildAtomAndBondTransitionMultigraph call

% --- Wall-clock measurement (SC-005: averaged over at least nTimedRuns runs) ---
% Profiling instrumentation adds overhead that would distort wall-clock, so
% timing runs are unprofiled; call counts are captured separately below from
% one additional profiled run (deterministic per input -- one capture suffices).
timedSeconds = zeros(nTimedRuns, 1);
for runIdx = 1:nTimedRuns
    tRun = tic;
    buildAtomAndBondTransitionMultigraph(model, rxnFilesDir, options); %#ok<NASGU>
    timedSeconds(runIdx) = toc(tRun);
end
elapsedSeconds = mean(timedSeconds);

% --- Profiled run (exact cell.ismember / tabular.dotReference call counts, FR-008) ---
profile('on');
[dATM, ~, ~, ~, ~, ~, BG, ~, ~, ~, ~, ~] = ...
    buildAtomAndBondTransitionMultigraph(model, rxnFilesDir, options);
profile('off');
profInfo = profile('info');

callCounts = struct('ismember', 0, 'dotReference', 0);
for f = 1:numel(profInfo.FunctionTable)
    switch profInfo.FunctionTable(f).FunctionName
        case 'cell.ismember'
            callCounts.ismember = callCounts.ismember + profInfo.FunctionTable(f).NumCalls;
        case 'tabular.dotReference'
            callCounts.dotReference = callCounts.dotReference + profInfo.FunctionTable(f).NumCalls;
    end
end
profile('clear');

% --- Downstream conserved/reacting-moiety classification (FR-007's captured layer) ---
% Unprofiled: this feature does not touch identifyConservedReactingMoieties, and
% profiling only the graph-building call above matches features 021/022's own
% measurement scope (research.md R3).
optionsIdentify = options;
optionsIdentify.sanityChecks = 0; % matches testConservedReactingMoieties.m / feature 021's script
[arm, moietyFormulae, reacting] = identifyConservedReactingMoieties(model, BG, dATM, optionsIdentify); %#ok<ASGLU>

armL = arm.L; %#ok<NASGU>
selectedReactionNames = sort(reacting.selectedReactionNames); %#ok<NASGU>

if ~isfile(snapshotPath)
    % CAPTURE mode (post-feature-022, pre-this-feature correctness baseline) -- FR-007(a)
    save(snapshotPath, 'armL', 'moietyFormulae', 'selectedReactionNames', 'callCounts', 'elapsedSeconds');
    fprintf(['[tyrosineReproducibilityCheck] Captured PRE-CHANGE baseline: ' ...
        'cell.ismember=%d, tabular.dotReference=%d calls; %.1fs parsing/graph-building ' ...
        'wall-clock (avg of %d runs). Snapshot: %s\n'], ...
        callCounts.ismember, callCounts.dotReference, elapsedSeconds, nTimedRuns, snapshotPath);
else
    % COMPARE mode (post-this-feature run) -- FR-007(b), FR-007(c), FR-008
    baseline = load(snapshotPath);

    assert(isequal(size(armL), size(baseline.armL)) && norm(full(armL - baseline.armL), 'fro') < 1e-8, ...
        'tyrosineReproducibilityCheck:ConservedMoietyMatrixChanged', ...
        'arm.L differs from the pre-change golden snapshot (SC-003).');
    assert(isequaln(moietyFormulae, baseline.moietyFormulae), ...
        'tyrosineReproducibilityCheck:MoietyFormulaeChanged', ...
        'moietyFormulae differs from the pre-change golden snapshot (SC-003).');
    assert(isequal(selectedReactionNames, baseline.selectedReactionNames), ...
        'tyrosineReproducibilityCheck:SelectedReactionNamesChanged', ...
        'reacting.selectedReactionNames differs from the pre-change golden snapshot (SC-003).');

    ismemberPctOfPre022 = 100 * callCounts.ismember / PRE_FEATURE_022_ISMEMBER_BASELINE;
    dotReferencePctOfPre022 = 100 * callCounts.dotReference / PRE_FEATURE_022_DOTREFERENCE_BASELINE;

    sc001Pass = callCounts.ismember <= SC001_ISMEMBER_MAX;
    sc002Pass = callCounts.dotReference <= SC002_DOTREFERENCE_MAX;
    sc005Pass = elapsedSeconds <= POST_FEATURE_022_WALLCLOCK_BASELINE_SECONDS * WALLCLOCK_REGRESSION_TOLERANCE;

    fid = fopen(resultsPath, 'a');
    fprintf(fid, '## Run %s\n\n', datestr(now, 'yyyy-mm-dd HH:MM:SS')); %#ok<TNOW1,DATST>
    fprintf(fid, '- cell.ismember calls: %d (%.1f%% of pre-feature-022 baseline %d; SC-001 requires <=%d, <=10%%): %s\n', ...
        callCounts.ismember, ismemberPctOfPre022, PRE_FEATURE_022_ISMEMBER_BASELINE, SC001_ISMEMBER_MAX, ...
        tern(sc001Pass, 'PASS', 'FAIL'));
    fprintf(fid, '- tabular.dotReference calls: %d (%.1f%% of pre-feature-022 baseline %d; SC-002 requires <=%d, <=30%%): %s\n', ...
        callCounts.dotReference, dotReferencePctOfPre022, PRE_FEATURE_022_DOTREFERENCE_BASELINE, SC002_DOTREFERENCE_MAX, ...
        tern(sc002Pass, 'PASS', 'FAIL'));
    fprintf(fid, '- Parsing/graph-building wall-clock (avg of %d runs): %.1fs (post-feature-022 baseline %.1fs; SC-005 requires no regression, +-%.0f%% noise tolerance): %s\n\n', ...
        nTimedRuns, elapsedSeconds, POST_FEATURE_022_WALLCLOCK_BASELINE_SECONDS, ...
        100 * (WALLCLOCK_REGRESSION_TOLERANCE - 1), tern(sc005Pass, 'PASS', 'FAIL'));
    fclose(fid);

    fprintf(['[tyrosineReproducibilityCheck] Structural equality holds (SC-003). ' ...
        'cell.ismember=%d (%.1f%% of pre-022 baseline, SC-001 %s); ' ...
        'tabular.dotReference=%d (%.1f%% of pre-022 baseline, SC-002 %s); ' ...
        'wall-clock=%.1fs (SC-005 %s). Results appended to: %s\n'], ...
        callCounts.ismember, ismemberPctOfPre022, tern(sc001Pass, 'PASS', 'FAIL'), ...
        callCounts.dotReference, dotReferencePctOfPre022, tern(sc002Pass, 'PASS', 'FAIL'), ...
        elapsedSeconds, tern(sc005Pass, 'PASS', 'FAIL'), resultsPath);

    assert(sc001Pass, 'tyrosineReproducibilityCheck:SC001NotMet', ...
        'SC-001 not met: cell.ismember calls (%d) exceed the <=%d threshold.', callCounts.ismember, SC001_ISMEMBER_MAX);
    assert(sc002Pass, 'tyrosineReproducibilityCheck:SC002NotMet', ...
        'SC-002 not met: tabular.dotReference calls (%d) exceed the <=%d threshold.', callCounts.dotReference, SC002_DOTREFERENCE_MAX);
    assert(sc005Pass, 'tyrosineReproducibilityCheck:SC005NotMet', ...
        'SC-005 not met: wall-clock time (%.1fs) regressed beyond the post-feature-022 baseline (%.1fs) plus noise tolerance.', ...
        elapsedSeconds, POST_FEATURE_022_WALLCLOCK_BASELINE_SECONDS);
end

function out = tern(cond, ifTrue, ifFalse)
if cond
    out = ifTrue;
else
    out = ifFalse;
end
end
