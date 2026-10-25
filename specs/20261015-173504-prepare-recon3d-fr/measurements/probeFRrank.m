% Phase-0 probe: reproduce the spec's m / rank([F,R]) figures on the candidate
% input models, with the spec's default column selection, and record how
% getRankLUSOL and a sparse QR behave at this scale.
cbtRoot = fileparts(which('initCobraToolbox'));
files = { ...
    fullfile(getenv('HOME'), 'drive', 'sbgCloud', 'projects', 'variationalKinetics', 'data', 'Recon3T', 'Recon3DModel_301_xomics_input_VK_withL.mat'), ...
    fullfile(getenv('HOME'), 'drive', 'sbgCloud', 'projects', 'variationalKinetics', 'data', 'Recon3T', 'Recon3DModel_301_xomics_input.mat'), ...
    fullfile(cbtRoot, 'test', 'models', 'mat', 'Recon3DModel_301_xomics_input.mat'), ...
    fullfile(cbtRoot, 'papers', '2023_iDopaNeuro', 'models', 'iDopaNeuroC.mat')};
for i = 1:numel(files)
    fprintf('\n=== %s\n', files{i});
    L = load(files{i});
    fn = fieldnames(L);
    model = L.(fn{1});
    fprintf('var %s, size(S) = %d x %d, SConsistentRxnBool %d, SIntRxnBool %d\n', fn{1}, size(model.S), ...
        isfield(model, 'SConsistentRxnBool'), isfield(model, 'SIntRxnBool'));
    if isfield(model, 'SConsistentRxnBool')
        rxnBool = model.SConsistentRxnBool;
        src = 'SConsistentRxnBool';
    else
        model = findSExRxnInd(model, [], 0);
        rxnBool = model.SIntRxnBool;
        src = 'SIntRxnBool';
    end
    N = model.S(:, rxnBool);
    F = max(-N, 0);
    R = max(N, 0);
    FR = [F, R];
    m = size(FR, 1);
    zeroRow = full(sum(FR ~= 0, 2) == 0);
    [~, ia] = unique(FR, 'rows', 'stable');
    fprintf('rxnBool from %s: k = %d, m = %d, zero rows = %d, distinct rows = %d\n', src, nnz(rxnBool), m, nnz(zeroRow), numel(ia));
    tic; rL = getRankLUSOL(FR, 0); tL = toc;
    fprintf('getRankLUSOL rank = %d (%.2f s)\n', rL, tL);
    tic;
    [~, Rq, ~] = qr(FR', sparse(size(FR, 2), 0), 0);
    d = abs(full(diag(Rq)));
    rQ = nnz(d > max(size(FR)) * eps * max(d));
    tQ = toc;
    fprintf('sparse QR rank = %d (%.2f s), m - rank = %d\n', rQ, tQ, m - rQ);
    fprintf('zero-row mets: %s\n', strjoin(model.mets(zeroRow)', ' '));
end
