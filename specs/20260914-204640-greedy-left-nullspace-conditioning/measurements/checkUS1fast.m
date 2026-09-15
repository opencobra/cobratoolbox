rng(20260914,'twister');
p.printLevel = 0; p.maxNewBasisTime = 45;
F = {};
F{1} = struct('name','F1 square 3x3',    'S', sparse([-1 0 1;1 -1 0;0 1 -1]));
F{2} = struct('name','F2 chain 3x2',     'S', sparse([-1 0;1 -1;0 1]));
F{3} = struct('name','F2b two pools 4x2','S', sparse([-1 0;1 0;0 -1;0 1]));
F{4} = struct('name','F3 empty ns 2x3',  'S', sparse([-1 1 0;0 -1 1]));
root='/home/rfleming/drive/sbgCloud/code/fork-cobratoolbox';
d=load([root '/test/models/mat/ecoli_core_model.mat']); fn=fieldnames(d); m=d.(fn{1});
F{5}=struct('name','ecoli_core','S',m.S);
for k=1:numel(F), F{k}.SConsistentRxnBool = true(size(F{k}.S,2),1); end

fprintf('%-18s %-7s %-10s %-10s %-10s %5s %5s %6s %6s %7s\n', ...
  'model','solver','target','resAbs','resScaled','found','exp','rejAcc','nonNeg','secs');
for s = {'gurobi','mosek'}
    if ~changeCobraSolver(s{1},'LP',0), continue; end
    for k = 1:numel(F)
        mm.S = F{k}.S; mm.SConsistentRxnBool = F{k}.SConsistentRxnBool;
        [Zpos,~,st] = greedyExtremeRayBasis(mm, p);
        fprintf('%-18s %-7s %-10.3e %-10.3e %-10.3e %5d %5d %6d %6d %7.2f\n', F{k}.name, s{1}, ...
            st.accuracyTarget, st.residualAbsolute, st.residualScaled, st.raysFound, ...
            st.raysExpected, st.raysRejectedForAccuracy, st.nonNegative, st.elapsedTime);
    end
end

% augmented-rank check on ecoli_core (the SC-002 property)
changeCobraSolver('gurobi','LP',0);
mm.S = F{5}.S; mm.SConsistentRxnBool = F{5}.SConsistentRxnBool;
[L,~,st] = greedyExtremeRayBasis(mm, p);
S = mm.S; nMet = size(S,1);
M = [S, -speye(nMet); sparse(size(L,1), size(S,2)), L];
structuralRank = size(M,1) - size(L,1);
sM = svd(full(M));
ranks = arrayfun(@(t) sum(sM > t*sM(1)), [1e-9 1e-10 1e-11 1e-12]);
fprintf('\necoli_core augmented M %dx%d | structural rank %d\n', size(M,1), size(M,2), structuralRank);
fprintf('  ranks across span: %s | getRankLUSOL %d\n', mat2str(ranks), getRankLUSOL(M));
Zn = getNullSpace(M,0);
fprintf('  nullspace residual of augmented matrix: %.3e\n', norm(M*Zn, inf));
