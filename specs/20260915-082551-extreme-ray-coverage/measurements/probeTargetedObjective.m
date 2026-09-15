% Is coverage controlled by the OBJECTIVE rather than the solver? Build a partial basis,
% then compare a fresh RANDOM objective against one TARGETED at the part of the left
% nullspace the basis does not yet span.
initCobraToolbox(false); changeCobraSolver('gurobi','LP',0); rng(20260915,'twister');
root='/home/rfleming/drive/sbgCloud/code/fork-cobratoolbox';
d=load([root '/papers/2023_iDopaNeuro/models/iDopaNeuroC.mat']); m=d.iDopaNeuroC;
N = m.S(:, m.SConsistentRxnBool); nMet = size(N,1);
mm = struct('S', N, 'SConsistentRxnBool', true(size(N,2),1));

p.printLevel=0; p.maxNewBasisTime=45; p.maxTime=45;
ws=warning('off','all'); [Zp,~,st] = greedyExtremeRayBasis(mm, p); warning(ws);
k = st.raysFound;
fprintf('partial basis: %d of %d rays\n', k, st.raysExpected);

W = null(full(N'));                 % orthonormal basis of ker(N'), 105 columns
% part of ker(N') NOT yet spanned by the rows of Zp
P = W - (full(Zp)'*((full(Zp)*full(Zp)')\(full(Zp)*W)));
[U,S2,~] = svd(P, 'econ'); sv = diag(S2);
nUnspanned = sum(sv > 1e-8);
fprintf('unspanned directions remaining: %d\n\n', nUnspanned);

nTrial = 40; randHit = 0; targHit = 0;
for t = 1:nTrial
    % (a) random objective, as the search does today
    o1 = rand(nMet,1); nz = full(sum(Zp~=0,1)~=0); o1(nz) = 0;
    x1 = findExtremePool(mm, o1, 0, 1, 0, struct());
    if ~isempty(x1) && norm(N'*x1,inf) <= st.acceptanceTarget
        if getRankLUSOL([Zp; x1']) == k+1, randHit = randHit + 1; end
    end
    % (b) objective TARGETED at an unspanned direction
    u = U(:, 1 + mod(t-1, max(nUnspanned,1)));
    o2 = u - min(0, min(u));            % shift to non-negative; direction preserved
    x2 = findExtremePool(mm, o2, 0, 1, 0, struct());
    if ~isempty(x2) && norm(N'*x2,inf) <= st.acceptanceTarget
        if getRankLUSOL([Zp; x2']) == k+1, targHit = targHit + 1; end
    end
end
fprintf('RANDOM   objective: %d of %d trials yielded a NEW independent accurate ray (%.0f%%)\n', randHit, nTrial, 100*randHit/nTrial);
fprintf('TARGETED objective: %d of %d trials yielded a NEW independent accurate ray (%.0f%%)\n', targHit, nTrial, 100*targHit/nTrial);
