% R1: is the post-solve truncation, not the LP floor, the operative cause?
% Task T004. Decision rule fixed in advance (research.md R1).
rng(20260914, 'twister');
addpath(fileparts(mfilename('fullpath')));

models = struct('name', {'ecoli_core', 'iAF1260'}, 'file', ...
    {'test/models/mat/ecoli_core_model.mat', 'test/models/mat/iAF1260.mat'});
solvers = {'gurobi', 'mosek'};
nRays = 50;   % per model per solver -> 50*2*2 = 200 rays

root = '/home/rfleming/drive/sbgCloud/code/fork-cobratoolbox';
rows = {};
for iM = 1:numel(models)
    d = load(fullfile(root, models(iM).file));
    fn = fieldnames(d);
    model = d.(fn{1});
    S = model.S;
    fprintf('\n=== %s : S is %d x %d, nnz %d ===\n', models(iM).name, size(S, 1), size(S, 2), nnz(S));
    for iS = 1:numel(solvers)
        ok = changeCobraSolver(solvers{iS}, 'LP', 0);
        if ~ok
            fprintf('  %s unavailable, skipped\n', solvers{iS});
            continue
        end
        rawAbs = nan(nRays, 1); trAbs = nan(nRays, 1);
        rawScl = nan(nRays, 1); trScl = nan(nRays, 1);
        nZero = nan(nRays, 1); maxZero = nan(nRays, 1); minSurv = nan(nRays, 1);
        nOptimal = 0;
        for k = 1:nRays
            o = probeRayResidual(S, rand(size(S, 1), 1), 1);
            if o.stat == 1
                nOptimal = nOptimal + 1;
            end
            rawAbs(k) = o.residualRawAbs;  trAbs(k) = o.residualTruncAbs;
            rawScl(k) = o.residualRawScaled; trScl(k) = o.residualTruncScaled;
            nZero(k) = o.nZeroed; maxZero(k) = o.maxZeroed; minSurv(k) = o.minSurviving;
        end
        fprintf('  solver %-8s  optimal %d/%d  epsilon %g\n', solvers{iS}, nOptimal, nRays, o.epsilon);
        fprintf('    residual RAW    abs median %.3e  max %.3e | scaled median %.3e\n', ...
            median(rawAbs, 'omitnan'), max(rawAbs), median(rawScl, 'omitnan'));
        fprintf('    residual TRUNC  abs median %.3e  max %.3e | scaled median %.3e\n', ...
            median(trAbs, 'omitnan'), max(trAbs), median(trScl, 'omitnan'));
        fprintf('    ratio TRUNC/RAW median %.3e\n', median(trAbs./rawAbs, 'omitnan'));
        fprintf('    entries zeroed median %g max %g | largest zeroed %.3e | smallest surviving %.3e\n', ...
            median(nZero, 'omitnan'), max(nZero), max(maxZero), min(minSurv));
        rows{end+1} = struct('model', models(iM).name, 'solver', solvers{iS}, ...
            'rawAbsMed', median(rawAbs, 'omitnan'), 'trAbsMed', median(trAbs, 'omitnan'), ...
            'rawSclMed', median(rawScl, 'omitnan'), 'trSclMed', median(trScl, 'omitnan'), ...
            'ratioMed', median(trAbs./rawAbs, 'omitnan'), 'nZeroMed', median(nZero, 'omitnan'), ...
            'maxZeroed', max(maxZero), 'minSurv', min(minSurv), 'nOptimal', nOptimal); %#ok<SAGROW>
    end
end
save(fullfile(fileparts(mfilename('fullpath')), 'R1_results.mat'), 'rows');
fprintf('\nR1 replicates: %d rays per model per solver\n', nRays);
