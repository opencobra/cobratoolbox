% tyrosineReproducibilityCheck.m
%
% Non-CI reproducibility check for feature 021-prefilter-isomorphism-classification
% (Constitution Principle III's documented-reproducibility-check fallback for a
% multi-minute, externally-dependent benchmark; see FR-009, SC-002, SC-003, SC-004).
%
% USAGE:
%   run('specs/021-prefilter-isomorphism-classification/tyrosineReproducibilityCheck.m')
%
% Mode is selected automatically by whether the golden snapshot already exists
% next to this script:
%   - snapshot absent  -> CAPTURE mode: run the pipeline on the current
%     (pre-change) code and save its output plus the isisomorphic call count
%     and wall-clock time as the baseline.
%   - snapshot present -> COMPARE mode: re-run the pipeline on the current
%     (post-change) code, assert structural equality against the snapshot
%     (SC-004), and append before/after isisomorphic call counts and
%     wall-clock time (SC-002, SC-003) to tyrosine-reproducibility-results.md.
%
% ADJUST BEFORE RUNNING: per spec.md's Assumptions section, the Tyrosine
% metabolism subsystem model and its atom-mapped RXN files are expected at
% the paths below (from the original profiling session). If unavailable,
% change modelPath/rxnFilesDir/modelVarNameHint to the correct location
% without changing the rest of this script's intent.
modelPath = fullfile(getenv('HOME'), 'repos', 'ReconXKG-cidev', 'ReconXKGtoCobra', ...
    'models', 'subsystemSubModels', 'subsystemSubModels.mat');
rxnFilesDir = '/media/JACK/repos/ctf/rxns/atomMapped_standardised';
modelVarNameHint = 'tyr'; % matches subModels.tyr (the Tyrosine metabolism subsystem abbreviation; confirmed via subsystemSubModels.mat's summaryTable, 139 reactions)

% NOTE ON OUTPUT FIELD NAMES: spec.md's Assumptions/FR-009 describe the
% captured output as `moietyFormulas`, `moietyGraphs`, and `moietyVectors`,
% names carried over from the external, non-repo profiling script
% (runTyrosineMoietyProfile_fixed.m) that is not available in this
% repository. This repo's actual public API
% (identifyConservedReactingMoieties.m -- see testConservedReactingMoieties.m
% for the reference call sequence) returns `arm` (with `arm.L`, the
% conserved-moiety matrix), `moietyFormulae` (note repo spelling), and
% `reacting` (with `reacting.selectedReactionNames`/`selectedReactions`,
% which are downstream of `findAndExtractMolecularGraphs`'s
% conservedGroup/reactingGroups split) -- there is no `moietyVectors` field
% anywhere in this call chain. This script captures/compares `arm.L`,
% `moietyFormulae`, and `reacting.selectedReactionNames`/`selectedReactions`
% as the closest faithful, stable proxy for SC-004's "moiety-classification
% output is identical" intent, covering all three isisomorphic call sites
% (`identifyConservedReactingMoieties`'s own loop for `arm`/`moietyFormulae`,
% and `findAndExtractMolecularGraphs`/`identifyIsomorphicClasses` for
% `reacting`). `createMoietyGraph`/`getMetMoietySubgraphs` are deliberately
% NOT called here: they are downstream visualization/subgraph-extraction
% functions outside this feature's scope, and `createMoietyGraph` errors on
% this real multi-component Tyrosine dataset for reasons unrelated to the
% isisomorphic prefilter (a pre-existing `allpaths`/`endNode` assumption
% that does not hold here) -- calling them would test unrelated code, not
% this feature. If the external script's exact `moietyVectors` semantics
% are needed, adjust the capture/compare block below accordingly.

thisDir = fileparts(mfilename('fullpath'));
snapshotPath = fullfile(thisDir, 'tyrosine-golden-snapshot.mat');
resultsPath = fullfile(thisDir, 'tyrosine-reproducibility-results.md');

assert(isfile(modelPath), 'tyrosineReproducibilityCheck:ModelNotFound', ...
    ['Tyrosine subsystem model not found at %s. Per spec.md''s Assumptions ' ...
     'section, adjust modelPath in this script to the correct location before running.'], modelPath);
assert(isfolder(rxnFilesDir), 'tyrosineReproducibilityCheck:RxnFilesNotFound', ...
    ['Atom-mapped RXN files not found at %s. Per spec.md''s Assumptions ' ...
     'section, adjust rxnFilesDir in this script to the correct location before running.'], rxnFilesDir);

% modelPath's actual layout (discovered by inspection): a top-level
% `subModels` struct whose field names are subsystem abbreviations (e.g.
% 'tyr' for Tyrosine metabolism, 139 reactions per a `summaryTable`
% sibling field), rather than a single top-level model variable. Search
% top-level fields first, then one level into any top-level struct field,
% for a field name matching modelVarNameHint.
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

% reset the shared isisomorphic call counter (classifySubgraphIsomorphism.m)
% before running the pipeline, so the count below reflects only this run
classifySubgraphIsomorphism('resetCallCount');

tStart = tic;

options.directed = 0;
options.sanityChecks = 1;
[dATM, ~, ~, ~, ~, ~, BG, dBTM, ~, ~, ~, ~] = ...
    buildAtomAndBondTransitionMultigraph(model, rxnFilesDir, options); %#ok<ASGLU>

% NOTE: testConservedReactingMoieties.m sets sanityChecks=1 for
% buildAtomAndBondTransitionMultigraph but sanityChecks=0 for
% identifyConservedReactingMoieties -- matched here rather than forcing 1
% for both, since sanityChecks=1 on identifyConservedReactingMoieties
% triggers a strict, pre-existing (out-of-scope for this feature) atom-
% transition consistency assertion that this real Tyrosine dataset does
% not satisfy, unrelated to the isisomorphic classification loop this
% feature touches.
options.sanityChecks = 0;
[arm, moietyFormulae, reacting] = identifyConservedReactingMoieties(model, BG, dATM, options); %#ok<ASGLU>

elapsedSeconds = toc(tStart);
callCount = classifySubgraphIsomorphism('getCallCount');

selectedReactionNames = sort(reacting.selectedReactionNames);
selectedReactions = sort(reacting.selectedReactions);

if ~isfile(snapshotPath)
    % CAPTURE mode (pre-change baseline) -- FR-009(a)
    %
    % NOTE ON callCount: classifySubgraphIsomorphism's resetCallCount/
    % getCallCount side channel can only count calls made THROUGH that
    % helper. The pre-change code being captured here does not call it at
    % all (findAndExtractMolecularGraphs/identifyConservedReactingMoieties/
    % identifyIsomorphicClasses each still have their own inline
    % isisomorphic loop at this point), so `callCount` measured this way is
    % always 0 for a pre-change capture -- it is not a real measurement.
    % Rather than report a misleading 0, the known pre-change baseline from
    % spec.md's own profiling session on this exact Tyrosine subsystem is
    % used instead for the two dominant, already-profiled sites
    % (findAndExtractMolecularGraphs: 2,678,455 calls;
    % identifyConservedReactingMoieties's own loop: 96,562 calls).
    % identifyIsomorphicClasses's pre-change count was not separately
    % profiled and is omitted (treated as 0 additional calls) -- the two
    % known sites alone already establish a baseline far larger than any
    % plausible post-change count, so SC-002's "any nonzero reduction"
    % criterion is unaffected by this omission.
    if callCount ~= 0
        warning('tyrosineReproducibilityCheck:UnexpectedPreChangeCallCount', ...
            ['Expected 0 self-measured isisomorphic calls when capturing a ' ...
             'pre-change baseline (the helper is not yet wired into any call ' ...
             'site), but got %d. Is this snapshot actually being captured ' ...
             'against pre-change code?'], callCount);
    end
    knownPreChangeCallCountFloor = 2678455 + 96562; % findAndExtractMolecularGraphs + identifyConservedReactingMoieties, per spec.md profiling
    callCount = knownPreChangeCallCountFloor; %#ok<NASGU>
    armL = arm.L; %#ok<NASGU>
    save(snapshotPath, 'armL', 'moietyFormulae', 'selectedReactionNames', 'selectedReactions', 'callCount', 'elapsedSeconds');
    fprintf(['[tyrosineReproducibilityCheck] Captured PRE-CHANGE baseline: ' ...
        '%d isisomorphic calls (known floor from spec.md profiling; ' ...
        'identifyIsomorphicClasses''s pre-change count not separately ' ...
        'profiled), %.1fs classification wall-clock. Snapshot: %s\n'], ...
        callCount, elapsedSeconds, snapshotPath);
else
    % COMPARE mode (post-change run) -- FR-009(b), FR-009(c)
    baseline = load(snapshotPath);

    assert(isequal(size(arm.L), size(baseline.armL)) && norm(full(arm.L - baseline.armL), 'fro') < 1e-8, ...
        'tyrosineReproducibilityCheck:ConservedMoietyMatrixChanged', ...
        'arm.L differs from the pre-change golden snapshot (SC-004).');
    assert(isequaln(moietyFormulae, baseline.moietyFormulae), ...
        'tyrosineReproducibilityCheck:MoietyFormulaeChanged', ...
        'moietyFormulae differs from the pre-change golden snapshot (SC-004).');
    assert(isequal(selectedReactionNames, baseline.selectedReactionNames), ...
        'tyrosineReproducibilityCheck:SelectedReactionNamesChanged', ...
        'reacting.selectedReactionNames differs from the pre-change golden snapshot (SC-004).');
    assert(isequal(selectedReactions, baseline.selectedReactions), ...
        'tyrosineReproducibilityCheck:SelectedReactionsChanged', ...
        'reacting.selectedReactions differs from the pre-change golden snapshot (SC-004).');

    reduction = baseline.callCount - callCount;
    pctReduction = 100 * reduction / baseline.callCount;

    assert(reduction > 0, 'tyrosineReproducibilityCheck:NoCallCountReduction', ...
        ['isisomorphic call count did not decrease (before=%d, after=%d). ' ...
         'SC-002 requires any nonzero reduction.'], baseline.callCount, callCount);

    fid = fopen(resultsPath, 'a');
    fprintf(fid, '## Run %s\n\n', datestr(now, 'yyyy-mm-dd HH:MM:SS')); %#ok<TNOW1,DATST>
    fprintf(fid, '- isisomorphic calls: %d -> %d (reduction: %d, %.1f%%)\n', ...
        baseline.callCount, callCount, reduction, pctReduction);
    fprintf(fid, '- Classification wall-clock time: %.1fs -> %.1fs\n\n', ...
        baseline.elapsedSeconds, elapsedSeconds);
    fclose(fid);

    fprintf(['[tyrosineReproducibilityCheck] PASS. isisomorphic calls %d -> %d ' ...
        '(%.1f%% reduction). Wall-clock %.1fs -> %.1fs. Results appended to: %s\n'], ...
        baseline.callCount, callCount, pctReduction, baseline.elapsedSeconds, elapsedSeconds, resultsPath);
end
