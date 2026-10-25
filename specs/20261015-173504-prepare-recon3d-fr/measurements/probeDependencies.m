% Phase-0 probe: classify the [F,R] row dependencies (zero rows, identical-row
% groups, remaining left-null vectors) of the iDopaNeuro variants and of the
% in-repo Recon3D test model, to fix the acceptance evidence available in CI.
cbtRoot = fileparts(which('initCobraToolbox'));
files = { ...
    fullfile(cbtRoot, 'papers', '2023_iDopaNeuro', 'models', 'iDopaNeuroC.mat'), ...
    fullfile(cbtRoot, 'papers', '2023_iDopaNeuro', 'models', 'iDopaNeuroCT.mat'), ...
    fullfile(cbtRoot, 'test', 'models', 'mat', 'Recon3DModel_301_xomics_input.mat')};
for i = 1:numel(files)
    fprintf('\n=== %s\n', files{i});
    L = load(files{i});
    fn = fieldnames(L);
    model = L.(fn{1});
    N = model.S(:, model.SConsistentRxnBool);
    F = max(-N, 0);
    R = max(N, 0);
    FR = [F, R];
    m = size(FR, 1);
    fprintf('m = %d, rank = %d\n', m, getRankLUSOL(FR, 0));
    zeroRow = full(sum(FR ~= 0, 2) == 0);
    fprintf('zero rows: %s\n', strjoin(model.mets(zeroRow)', ' '));
    nz = find(~zeroRow);
    [~, ia, ic] = unique(FR(nz, :), 'rows', 'stable');
    for g = 1:numel(ia)
        members = nz(ic == g);
        if numel(members) > 1
            rxnInd = find(any(N(members, :), 1));
            rxnNames = model.rxns(model.SConsistentRxnBool);
            fprintf('identical group: %s in %s\n', strjoin(model.mets(members)', ' '), strjoin(rxnNames(rxnInd)', ' '));
        end
    end
    % remaining dependencies among the distinct nonzero rows
    keep = nz(ia);
    A = FR(keep, :)';
    [~, Rq, E] = qr(A, sparse(size(A, 1), 0), 0);
    d = abs(full(diag(Rq)));
    rk = nnz(d > max(size(A)) * eps * max(d));
    for t = 1:(size(A, 2) - rk)
        c = full(Rq(1:rk, 1:rk) \ Rq(1:rk, rk + t));
        idx = find(abs(c) > 1e-8);
        fprintf('sum dependency: %s =', model.mets{keep(E(rk + t))});
        for q = idx'
            fprintf(' %+g*%s', c(q), model.mets{keep(E(q))});
        end
        fprintf('\n');
    end
end
