% R1 (refined): measure raw-vs-truncated residual INSIDE the greedy accumulation,
% where greedyExtremeRayBasis:111 zeroes the objective on already-covered metabolites
% and drives later rays onto scarcer support. Task T004.
rng(20260914, 'twister');
addpath(fileparts(mfilename('fullpath')));
root = '/home/rfleming/drive/sbgCloud/code/fork-cobratoolbox';

models = struct('name', {'ecoli_core', 'iAF1260'}, 'file', ...
    {'test/models/mat/ecoli_core_model.mat', 'test/models/mat/iAF1260.mat'});
solvers = {'gurobi', 'mosek'};

for iM = 1:numel(models)
    d = load(fullfile(root, models(iM).file)); fn = fieldnames(d); model = d.(fn{1});
    S = model.S; nVar = size(S, 1);
    [~, rankS] = getNullSpace(S', 0);
    nNeed = nVar - rankS;
    fprintf('\n=== %s : S %d x %d | rank %d | left nullity %d ===\n', ...
        models(iM).name, size(S,1), size(S,2), rankS, nNeed);
    for iS = 1:numel(solvers)
        if ~changeCobraSolver(solvers{iS}, 'LP', 0), continue; end
        Zpos = sparse(0, nVar);
        nonZeroColumnsBool = false(1, nVar);
        acc = [];   % per accepted ray
        nTry = 0; nBases = 0; tStart = tic;
        while nBases < nNeed && nTry < 400 && toc(tStart) < 300
            nTry = nTry + 1;
            obj = rand(nVar, 1);
            if nBases >= 2
                obj(nonZeroColumnsBool) = 0;      % greedyExtremeRayBasis.m:111
            end
            o = probeRayResidual(S, obj, 1);
            if isnan(o.residualTruncAbs), continue; end
            % acceptance as greedyExtremeRayBasis.m:126 applies it, on the TRUNCATED ray
            if o.residualTruncAbs > 1e-6, continue; end
            acc(end+1, :) = [o.residualRawAbs, o.residualTruncAbs, o.residualRawScaled, ...
                o.residualTruncScaled, o.nZeroed, o.maxZeroed, o.minSurviving]; %#ok<SAGROW>
            nBases = nBases + 1;
            Zpos(nBases, :) = o.xTrunc';
            % greedyExtremeRayBasis.m:137-138 -- metabolites already carrying support
            nonZeroColumnsBool = full(sum(Zpos ~= 0, 1) ~= 0);
        end
        if isempty(acc)
            fprintf('  %-8s no rays accepted\n', solvers{iS}); continue
        end
        fprintf('  solver %-8s accepted %d of %d needed in %d tries (%.1f s)\n', ...
            solvers{iS}, nBases, nNeed, nTry, toc(tStart));
        fprintf('    raw   abs: median %.3e  max %.3e\n', median(acc(:,1)), max(acc(:,1)));
        fprintf('    trunc abs: median %.3e  max %.3e\n', median(acc(:,2)), max(acc(:,2)));
        fprintf('    entries zeroed: median %g  max %g | largest zeroed %.3e\n', ...
            median(acc(:,5)), max(acc(:,5)), max(acc(:,6)));
        fprintf('    smallest surviving entry across rays: %.3e\n', min(acc(:,7)));
        fprintf('    support covered: %d of %d metabolites | basis density %.3f%%\n', ...
            nnz(nonZeroColumnsBool), nVar, 100*nnz(Zpos)/numel(Zpos));
        RR = full(Zpos*S);
        fprintf('    ASSEMBLED basis residual: abs %.3e | scaled %.3e\n', ...
            norm(RR, inf), norm(RR, inf)/(norm(full(Zpos),'fro')*norm(full(S),'fro')));
        nWorse = sum(acc(:,2) > 10*max(acc(:,1), realmin));
        fprintf('    rays where truncation worsened residual >10x: %d of %d\n', nWorse, size(acc,1));
    end
end
