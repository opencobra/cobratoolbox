function results = baselineRecord(mode)
% Records, or compares against, the behaviour of `greedyExtremeRayBasis` before feature
% 20261025-235131-greedy-initial-basis, so that SC-004 (unchanged outputs without
% `param.initialBasis`) is checked against evidence rather than asserted.
%
% USAGE:
%
%    results = baselineRecord(mode)
%
% INPUT:
%    mode:       `'record'` runs the function and saves its outputs to `baseline/<run>.mat`
%                and a summary to `baseline-summary.md`; `'compare'` re-runs and checks
%                the outputs against the saved ones
%
% OUTPUT:
%    results:    structure array, one element per run, with the counts, the `Zpos` hash
%                and, in `'compare'` mode, the verdict
%
% NOTE:
%
%    A DOCUMENTED REPRODUCIBILITY CHECK (constitution Principle III), not a CI test: the
%    iDopaNeuroC run needs the `papers` git submodule. Run `'record'` on the UNMODIFIED
%    function, before any source edit (task T002), and `'compare'` after each change.
%
%    In `'compare'` mode `Zpos` and `Z` must be value-identical and every status field
%    present in the baseline must be equal, except `elapsedTime`, `spectrumTime` and
%    `pairedComparison`. A run whose outputs differ is accepted only if it reports
%    `status.nSignRetries > 0`, the exemption fixed by spec FR-013; otherwise it is an
%    error. Runs that restarted (`nRestarts > 0`) depend on wall-clock budgets and are
%    flagged, since their path is not reproducible by seed alone.
%
% Author: - feature 20261025-235131-greedy-initial-basis, 2026-10-26

if ~exist('mode', 'var') || isempty(mode)
    mode = 'compare';
end
if ~any(strcmp(mode, {'record', 'compare'}))
    error('baselineRecord:mode', 'mode must be ''record'' or ''compare''.');
end

featureDir = fileparts(mfilename('fullpath'));
repoRoot = fileparts(fileparts(featureDir));
baselineDir = fullfile(featureDir, 'baseline');
if ~exist(baselineDir, 'dir')
    mkdir(baselineDir);
end

if ~changeCobraSolver('gurobi', 'LP', 0)
    error('baselineRecord:solverMissing', 'gurobi is required for the baseline.');
end

% the runs: name, model, leftRight, time budgets
ecoli = load('ecoli_core_model.mat');
ecoliModel = struct('S', ecoli.model.S, ...
    'SConsistentRxnBool', true(size(ecoli.model.S, 2), 1));

runs = struct('name', {}, 'model', {}, 'leftRight', {}, 'maxNewBasisTime', {}, 'maxTime', {});
runs(end+1) = struct('name', 'ecoliLeft', 'model', ecoliModel, 'leftRight', 'left', ...
    'maxNewBasisTime', 60, 'maxTime', 60);
% Right mode on S' poses the same mathematical problem as the left run, so it completes
% deterministically and exercises the transposition path. Right mode on S itself (the
% flux cone of ecoli_core) stops on its wall-clock budget at 1 of 28 rays, so its path
% depends on timing and cannot serve as a bit-for-bit baseline.
ecoliTransposed = struct('S', ecoli.model.S', ...
    'SConsistentRxnBool', true(size(ecoli.model.S, 1), 1));
runs(end+1) = struct('name', 'ecoliRight', 'model', ecoliTransposed, 'leftRight', 'right', ...
    'maxNewBasisTime', 60, 'maxTime', 60);

dopaFile = fullfile(repoRoot, 'papers', '2023_iDopaNeuro', 'models', 'iDopaNeuroC.mat');
if exist(dopaFile, 'file')
    loaded = load(dopaFile);
    dopa = loaded.iDopaNeuroC;
    S = dopa.S(:, dopa.SConsistentRxnBool);
    runs(end+1) = struct('name', 'iDopaNeuroCLeft', ...
        'model', struct('S', S, 'SConsistentRxnBool', true(size(S, 2), 1)), ...
        'leftRight', 'left', 'maxNewBasisTime', 30, 'maxTime', 180);
else
    fprintf('baselineRecord: %s not found; iDopaNeuroC run skipped.\n', dopaFile);
end

excludedFields = {'elapsedTime', 'spectrumTime', 'pairedComparison'};
results = struct('name', {}, 'raysFound', {}, 'raysExpected', {}, ...
    'nTargetedObjectives', {}, 'nRestarts', {}, 'zposHash', {}, 'verdict', {});

for iRun = 1:numel(runs)
    thisRun = runs(iRun);
    param = struct('printLevel', 0, 'leftRight', thisRun.leftRight, ...
        'maxNewBasisTime', thisRun.maxNewBasisTime, 'maxTime', thisRun.maxTime);
    rng(20261025, 'twister');
    [Zpos, Z, status] = greedyExtremeRayBasis(thisRun.model, param);

    result = struct();
    result.name = thisRun.name;
    result.raysFound = status.raysFound;
    result.raysExpected = status.raysExpected;
    result.nTargetedObjectives = status.nTargetedObjectives;
    result.nRestarts = status.nRestarts;
    result.zposHash = hashMatrix(Zpos);
    result.verdict = '';

    baselineFile = fullfile(baselineDir, [thisRun.name '.mat']);
    switch mode
        case 'record'
            save(baselineFile, 'Zpos', 'Z', 'status');
            result.verdict = 'recorded';
        case 'compare'
            if ~exist(baselineFile, 'file')
                error('baselineRecord:noBaseline', ...
                    'No baseline for %s; run baselineRecord(''record'') on the unmodified function first.', ...
                    thisRun.name);
            end
            base = load(baselineFile);
            differences = {};
            if ~isequal(Zpos, base.Zpos)
                differences{end+1} = 'Zpos'; %#ok<AGROW>
            end
            if ~isequal(Z, base.Z)
                differences{end+1} = 'Z'; %#ok<AGROW>
            end
            baseFields = setdiff(fieldnames(base.status), excludedFields);
            for iField = 1:numel(baseFields)
                fieldName = baseFields{iField};
                if ~isfield(status, fieldName)
                    differences{end+1} = ['status.' fieldName ' (missing)']; %#ok<AGROW>
                elseif ~isequaln(status.(fieldName), base.status.(fieldName))
                    differences{end+1} = ['status.' fieldName]; %#ok<AGROW>
                end
            end
            if isempty(differences)
                result.verdict = 'identical';
            else
                nSignRetries = 0;
                if isfield(status, 'nSignRetries')
                    nSignRetries = status.nSignRetries;
                end
                if nSignRetries > 0
                    result.verdict = sprintf(['divergent with %d sign retr%s ' ...
                        '(FR-013 exemption): %s'], nSignRetries, ...
                        pluralSuffix(nSignRetries), strjoin(differences, ', '));
                else
                    error('baselineRecord:divergence', ...
                        '%s diverged without a sign retry: %s', thisRun.name, ...
                        strjoin(differences, ', '));
                end
            end
    end
    if result.nRestarts > 0
        result.verdict = [result.verdict ' [restarted: wall-clock dependent]'];
    end
    fprintf('baselineRecord %-16s %-9s rays %d/%d targeted %d restarts %d hash %s : %s\n', ...
        thisRun.name, mode, result.raysFound, result.raysExpected, ...
        result.nTargetedObjectives, result.nRestarts, result.zposHash(1:12), result.verdict);
    results(end+1) = result; %#ok<AGROW>
end

if strcmp(mode, 'record')
    writeSummary(fullfile(featureDir, 'baseline-summary.md'), results);
end


function hash = hashMatrix(A)
% SHA-256 of the bytes of full(A), as a hexadecimal string
digest = java.security.MessageDigest.getInstance('SHA-256');
digest.update(typecast(full(double(A(:))), 'uint8'));
hash = lower(reshape(dec2hex(typecast(digest.digest(), 'uint8'))', 1, []));


function suffix = pluralSuffix(n)
if n == 1
    suffix = 'y';
else
    suffix = 'ies';
end


function writeSummary(fileName, results)
fid = fopen(fileName, 'w');
if fid < 0
    error('baselineRecord:write', 'Cannot write %s.', fileName);
end
closeFile = onCleanup(@() fclose(fid));
fprintf(fid, '# Baseline: greedyExtremeRayBasis before feature 20261025-235131\n\n');
fprintf(fid, 'Recorded %s on MATLAB %s with gurobi, seed `rng(20261025, ''twister'')` before each run.\n', ...
    char(datetime('now', 'TimeZone', 'UTC', 'Format', 'yyyy-MM-dd HH:mm:ss''Z''')), version);
fprintf(fid, 'Source: `greedyExtremeRayBasis.m` at commit %s, unmodified.\n\n', gitHead());
fprintf(fid, '| Run | raysFound | raysExpected | nTargetedObjectives | nRestarts | SHA-256 of full(Zpos) |\n');
fprintf(fid, '|---|---|---|---|---|---|\n');
for i = 1:numel(results)
    fprintf(fid, '| %s | %d | %d | %d | %d | `%s` |\n', results(i).name, results(i).raysFound, ...
        results(i).raysExpected, results(i).nTargetedObjectives, results(i).nRestarts, ...
        results(i).zposHash);
end
fprintf(fid, '\nThe `.mat` files in `baseline/` hold the full outputs and are not committed.\n');


function head = gitHead()
[exitCode, out] = system('git rev-parse --short HEAD');
if exitCode == 0
    head = strtrim(out);
else
    head = 'unknown';
end
