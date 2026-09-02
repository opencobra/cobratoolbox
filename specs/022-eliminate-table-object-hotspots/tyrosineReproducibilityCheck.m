% tyrosineReproducibilityCheck.m
%
% Non-CI reproducibility check for feature 022-eliminate-table-object-hotspots
% (Constitution Principle III's documented-reproducibility-check fallback for a
% multi-minute, externally-dependent benchmark; see FR-010, SC-002, SC-003,
% SC-004, SC-005). Reuses feature 021's tyrosineReproducibilityCheck.m as a
% structural template (model-loading block, capture-vs-compare mode selection
% by golden-snapshot presence, append-only results file) but is extended for
% this feature's own concerns: it captures dATM.Nodes/dATM.Edges/dBTM.Nodes/
% dBTM.Edges directly (one layer upstream of feature 021's arm/moietyFormulae/
% reacting captures) plus a sample of readABRXNFile's own atoms/bonds tables,
% and reports cell.ismember/tabular.dotAssign/tabular.dotReference call counts
% via MATLAB's built-in profile() facility rather than a hand-rolled counter
% (research.md R3) -- those three functions have no single call site this
% feature controls to instrument with a persistent counter.
%
% USAGE:
%   run('specs/022-eliminate-table-object-hotspots/tyrosineReproducibilityCheck.m')
%
% Mode is selected automatically by whether the golden snapshot already exists
% next to this script:
%   - snapshot absent  -> CAPTURE mode: run the pipeline on the current
%     (pre-change) code and save dATM/dBTM Nodes/Edges, a sample of
%     readABRXNFile atoms/bonds tables, the cell.ismember/tabular.dotAssign/
%     tabular.dotReference call counts, and wall-clock time as the baseline.
%   - snapshot present -> COMPARE mode: re-run the pipeline on the current
%     (post-change) code, assert structural equality against the snapshot
%     (SC-005), and append before/after call counts and wall-clock time
%     (SC-002, SC-003, SC-004) to tyrosine-reproducibility-results.md. This
%     script is designed to be invoked more than once (once after User Story
%     1 lands, once after User Story 2 also lands -- see tasks.md T009/T014):
%     it always asserts full structural equality (a strict identity
%     requirement that must hold at every stage), but it does NOT hard-assert
%     the SC-002 (>=90%) / SC-003 (>=70%) percentage thresholds internally --
%     those are combined-contribution thresholds that only need to hold once
%     both user stories have landed, so they are reported here and judged by
%     the task that invokes this script in its final "compare" call.
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
nSampleRxnFiles = 3; % number of atom-mapped RXN files to directly re-parse via readABRXNFile for the atoms/bonds sample (FR-010a)
nTimedRuns = 2; % SC-004: wall-clock time is averaged over at least 2 runs

thisDir = fileparts(mfilename('fullpath'));
snapshotPath = fullfile(thisDir, 'tyrosine-golden-snapshot.mat');
resultsPath = fullfile(thisDir, 'tyrosine-reproducibility-results.md');

assert(isfile(modelPath), 'tyrosineReproducibilityCheck:ModelNotFound', ...
    ['Tyrosine subsystem model not found at %s. Per spec.md''s Assumptions ' ...
     'section, adjust modelPath in this script to the correct location before running.'], modelPath);
assert(isfolder(rxnFilesDir), 'tyrosineReproducibilityCheck:RxnFilesNotFound', ...
    ['Atom-mapped RXN files not found at %s. Per spec.md''s Assumptions ' ...
     'section, adjust rxnFilesDir in this script to the correct location before running.'], rxnFilesDir);

% Ensure the toolbox (readABRXNFile, buildAtomAndBondTransitionMultigraph, and
% their same-folder dependencies) is on the MATLAB path.
if ~exist('buildAtomAndBondTransitionMultigraph', 'file')
    initCobraToolbox(false, 'agent');
end

% modelPath's actual layout (discovered by inspection, feature 021 research):
% a top-level `subModels` struct whose field names are subsystem abbreviations
% (e.g. 'tyr' for Tyrosine metabolism, 139 reactions per a `summaryTable`
% sibling field), rather than a single top-level model variable. Search
% top-level fields first, then one level into any top-level struct field, for
% a field name matching modelVarNameHint.
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
options.sanityChecks = 1; % matches testConservedReactingMoieties.m's own buildAtomAndBondTransitionMultigraph call

% --- Wall-clock measurement (SC-004: averaged over at least nTimedRuns runs) ---
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

% --- Profiled run (exact cell.ismember / tabular.dotAssign / tabular.dotReference call counts) ---
profile('on');
[dATM, ~, rxnAtomMappedBool, ~, ~, ~, ~, dBTM, ~, ~, ~, ~] = ...
    buildAtomAndBondTransitionMultigraph(model, rxnFilesDir, options);
profile('off');
profInfo = profile('info');

callCounts = struct('ismember', 0, 'dotAssign', 0, 'dotReference', 0);
for f = 1:numel(profInfo.FunctionTable)
    switch profInfo.FunctionTable(f).FunctionName
        case 'cell.ismember'
            callCounts.ismember = callCounts.ismember + profInfo.FunctionTable(f).NumCalls;
        case 'tabular.dotAssign'
            callCounts.dotAssign = callCounts.dotAssign + profInfo.FunctionTable(f).NumCalls;
        case 'tabular.dotReference'
            callCounts.dotReference = callCounts.dotReference + profInfo.FunctionTable(f).NumCalls;
    end
end
profile('clear');

% --- Sample atoms/bonds tables from readABRXNFile directly (FR-010a) ---
if ~isfile(snapshotPath)
    % CAPTURE mode: pick the sample now; the list is saved into the snapshot
    % so COMPARE mode re-parses exactly the same RXN files (apples-to-apples).
    atomMappedRxnNames = model.rxns(rxnAtomMappedBool);
    sampleRxnNames = atomMappedRxnNames(1:min(nSampleRxnFiles, numel(atomMappedRxnNames)));
else
    baselineForSampleNames = load(snapshotPath, 'sampleRxnNames');
    sampleRxnNames = baselineForSampleNames.sampleRxnNames;
end

sampleAtoms = cell(numel(sampleRxnNames), 1);
sampleBonds = cell(numel(sampleRxnNames), 1);
for s = 1:numel(sampleRxnNames)
    [sampleAtoms{s}, sampleBonds{s}] = readABRXNFile(sampleRxnNames{s}, rxnFilesDir);
end

dATMNodes = dATM.Nodes; %#ok<NASGU>
dATMEdges = dATM.Edges; %#ok<NASGU>
dBTMNodes = dBTM.Nodes; %#ok<NASGU>
dBTMEdges = dBTM.Edges; %#ok<NASGU>

if ~isfile(snapshotPath)
    % CAPTURE mode (pre-change baseline) -- FR-010(a)
    save(snapshotPath, 'dATMNodes', 'dATMEdges', 'dBTMNodes', 'dBTMEdges', ...
        'sampleRxnNames', 'sampleAtoms', 'sampleBonds', 'callCounts', 'elapsedSeconds');
    fprintf(['[tyrosineReproducibilityCheck] Captured PRE-CHANGE baseline: ' ...
        'cell.ismember=%d, tabular.dotAssign=%d, tabular.dotReference=%d calls; ' ...
        '%.1fs parsing/graph-building wall-clock (avg of %d runs). Snapshot: %s\n'], ...
        callCounts.ismember, callCounts.dotAssign, callCounts.dotReference, ...
        elapsedSeconds, nTimedRuns, snapshotPath);
else
    % COMPARE mode (post-change run) -- FR-010(b), FR-010(c)
    baseline = load(snapshotPath);

    assert(isequal(dATMNodes, baseline.dATMNodes), ...
        'tyrosineReproducibilityCheck:dATMNodesChanged', ...
        'dATM.Nodes differs from the pre-change golden snapshot (SC-005).');
    assert(isequal(dATMEdges, baseline.dATMEdges), ...
        'tyrosineReproducibilityCheck:dATMEdgesChanged', ...
        'dATM.Edges differs from the pre-change golden snapshot (SC-005).');
    assert(isequal(dBTMNodes, baseline.dBTMNodes), ...
        'tyrosineReproducibilityCheck:dBTMNodesChanged', ...
        'dBTM.Nodes differs from the pre-change golden snapshot (SC-005).');
    assert(isequal(dBTMEdges, baseline.dBTMEdges), ...
        'tyrosineReproducibilityCheck:dBTMEdgesChanged', ...
        'dBTM.Edges differs from the pre-change golden snapshot (SC-005).');
    for s = 1:numel(sampleRxnNames)
        assert(isequal(sampleAtoms{s}, baseline.sampleAtoms{s}), ...
            'tyrosineReproducibilityCheck:AtomsChanged', ...
            'readABRXNFile atoms table for %s differs from the pre-change golden snapshot (SC-005).', sampleRxnNames{s});
        assert(isequal(sampleBonds{s}, baseline.sampleBonds{s}), ...
            'tyrosineReproducibilityCheck:BondsChanged', ...
            'readABRXNFile bonds table for %s differs from the pre-change golden snapshot (SC-005).', sampleRxnNames{s});
    end

    pctReduction = @(before, after) 100 * (before - after) / before;
    ismemberReduction = pctReduction(baseline.callCounts.ismember, callCounts.ismember);
    dotAssignReduction = pctReduction(baseline.callCounts.dotAssign, callCounts.dotAssign);
    dotReferenceReduction = pctReduction(baseline.callCounts.dotReference, callCounts.dotReference);

    assert(callCounts.ismember <= baseline.callCounts.ismember, ...
        'tyrosineReproducibilityCheck:NoIsmemberReduction', ...
        'cell.ismember call count did not decrease (before=%d, after=%d).', ...
        baseline.callCounts.ismember, callCounts.ismember);

    fid = fopen(resultsPath, 'a');
    fprintf(fid, '## Run %s\n\n', datestr(now, 'yyyy-mm-dd HH:MM:SS')); %#ok<TNOW1,DATST>
    fprintf(fid, '- cell.ismember calls: %d -> %d (reduction: %.1f%%)\n', ...
        baseline.callCounts.ismember, callCounts.ismember, ismemberReduction);
    fprintf(fid, '- tabular.dotAssign calls: %d -> %d (reduction: %.1f%%)\n', ...
        baseline.callCounts.dotAssign, callCounts.dotAssign, dotAssignReduction);
    fprintf(fid, '- tabular.dotReference calls: %d -> %d (reduction: %.1f%%)\n', ...
        baseline.callCounts.dotReference, callCounts.dotReference, dotReferenceReduction);
    fprintf(fid, '- Parsing/graph-building wall-clock (avg of %d runs): %.1fs -> %.1fs\n\n', ...
        nTimedRuns, baseline.elapsedSeconds, elapsedSeconds);
    fclose(fid);

    fprintf(['[tyrosineReproducibilityCheck] PASS (structural equality holds). ' ...
        'cell.ismember %d -> %d (%.1f%%); tabular.dotAssign %d -> %d (%.1f%%); ' ...
        'tabular.dotReference %d -> %d (%.1f%%). Wall-clock %.1fs -> %.1fs. ' ...
        'Results appended to: %s\n'], ...
        baseline.callCounts.ismember, callCounts.ismember, ismemberReduction, ...
        baseline.callCounts.dotAssign, callCounts.dotAssign, dotAssignReduction, ...
        baseline.callCounts.dotReference, callCounts.dotReference, dotReferenceReduction, ...
        baseline.elapsedSeconds, elapsedSeconds, resultsPath);
end
