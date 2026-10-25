% R1 on iDopaNeuroC -- the ONLY model where the defect is known to manifest. Task T004.
rng(20260914, 'twister');
addpath(fileparts(mfilename('fullpath')));
d = load('/home/rfleming/drive/sbgCloud/code/fork-cobratoolbox/papers/2023_iDopaNeuro/models/iDopaNeuroC.mat');
model = d.iDopaNeuroC;
S = model.S(:, model.SConsistentRxnBool);     % internal, as the caller uses it
nVar = size(S, 1);
[~, rankS] = getNullSpace(S', 0);
nNeed = nVar - rankS;
fprintf('iDopaNeuroC internal: %d x %d | rank %d | left nullity %d\n', size(S,1), size(S,2), rankS, nNeed);

for solver = {'gurobi', 'mosek'}
    if ~changeCobraSolver(solver{1}, 'LP', 0), continue; end
    Zpos = sparse(0, nVar); nonZeroColumnsBool = false(1, nVar);
    acc = []; nTry = 0; nBases = 0; nfail = 0; nfailMax = 5; tStart = tic;
    while nBases < nNeed && toc(tStart) < 600
        nTry = nTry + 1;
        obj = rand(nVar, 1);
        if nBases >= 2 && nfail < nfailMax
            obj(nonZeroColumnsBool) = 0;          % greedyExtremeRayBasis.m:111
        end
        o = probeRayResidual(S, obj, 1);
        if isnan(o.residualTruncAbs), nfail = nfail+1; continue; end
        if o.residualTruncAbs > 1e-6                % acceptance test :126
            nfail = nfail + 1; continue
        end
        Ztest = [Zpos; o.xTrunc'];
        nzb = full(sum(Ztest ~= 0, 1) ~= 0);
        if getRankLUSOL(Ztest(:, nzb)) ~= nBases+1  % independence test :139
            nfail = nfail + 1; continue
        end
        Zpos = Ztest; nBases = nBases + 1; nfail = 0;
        nonZeroColumnsBool = nzb;
        acc(end+1, :) = [o.residualRawAbs, o.residualTruncAbs, o.nZeroed, o.maxZeroed, o.minSurviving]; %#ok<SAGROW>
    end
    RR = full(Zpos*S);
    fprintf('\n--- %s: accepted %d of %d in %d tries (%.1f s) ---\n', solver{1}, nBases, nNeed, nTry, toc(tStart));
    fprintf('  per-ray raw   abs: median %.3e  max %.3e\n', median(acc(:,1)), max(acc(:,1)));
    fprintf('  per-ray trunc abs: median %.3e  max %.3e\n', median(acc(:,2)), max(acc(:,2)));
    fprintf('  entries zeroed: median %g max %g | largest zeroed %.3e\n', median(acc(:,3)), max(acc(:,3)), max(acc(:,4)));
    fprintf('  SMALLEST SURVIVING ENTRY: %.4e   (seed reported 1.252e-05)\n', min(acc(:,5)));
    fprintf('  ASSEMBLED residual: abs %.4e | scaled %.4e   (seed: 1.418e-07 / 2.218e-09)\n', ...
        norm(RR, inf), norm(RR, inf)/(norm(full(Zpos),'fro')*norm(full(S),'fro')));
    fprintf('  min |Zpos| nonzero: %.4e | max: %.4e\n', min(abs(nonzeros(Zpos))), max(abs(nonzeros(Zpos))));
    save(sprintf('%s/R1c_%s.mat', fileparts(mfilename('fullpath')), solver{1}), 'Zpos', 'acc');
end
