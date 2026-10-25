% Is the AUGMENTED system better behaved? Direct comparison on iDopaNeuroC.
initCobraToolbox(false); rng(20260914,'twister');
root='/home/rfleming/drive/sbgCloud/code/fork-cobratoolbox';
d=load([root '/papers/2023_iDopaNeuro/models/iDopaNeuroC.mat']); m=d.iDopaNeuroC;
N = m.S(:, m.SConsistentRxnBool); nMet = size(N,1);
taus = [1e-9 1e-10 1e-11 1e-12 eps*max(1349,2954)];

    function report(tag, L, N, nMet, taus)
        M = [N, -speye(nMet); sparse(size(L,1), size(N,2)), L];
        structural = size(M,1) - size(L,1);
        sM = svd(full(M));
        ranks = arrayfun(@(t) sum(sM > t*sM(1)), taus);
        rl = getRankLUSOL(M);
        [Zn, rn] = getNullSpace(M, 0);
        resNull = norm(M*Zn, inf);
        resL = norm(full(L*N), inf);
        fprintf('\n[%s]  L is %d x %d, ||L*N||_inf = %.4e\n', tag, size(L,1), size(L,2), resL);
        fprintf('  augmented M %d x %d, structural rank %d\n', size(M,1), size(M,2), structural);
        fprintf('  SVD ranks across tolerances : %s\n', mat2str(ranks));
        fprintf('  getRankLUSOL                : %d\n', rl);
        fprintf('  getNullSpace implied rank   : %d\n', size(M,2)-size(Zn,2));
        agree = all(ranks==structural) && rl==structural;
        fprintf('  ALL AGREE AT STRUCTURAL RANK: %d\n', agree);
        fprintf('  ||M*ker(M)||_inf            : %.4e\n', resNull);
    end

% OLD behaviour: a basis accepted at the pre-change tolerance (mosek-class, 9.3e-09)
old = load([root '/specs/20260914-204640-greedy-left-nullspace-conditioning/measurements/R1c_mosek.mat']);
report('OLD: soft basis, pre-change acceptance', old.Zpos, N, nMet, taus);

% NEW behaviour: the current code, gurobi
changeCobraSolver('gurobi','LP',0);
p.printLevel=0; p.maxNewBasisTime=40; p.maxTime=300;
ws=warning('off','all'); [Lnew,~,st]=greedyExtremeRayBasis(struct('S',N,'SConsistentRxnBool',true(size(N,2),1)), p); warning(ws);
fprintf('\n(new basis: outcome=%s, %d of %d rays, residual %.4e)\n', st.outcome, st.raysFound, st.raysExpected, st.residualAbsolute);
report('NEW: current code, gurobi', Lnew, N, nMet, taus);
