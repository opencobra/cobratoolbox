% US1 verification across fixtures and real models, both solvers.
rng(20260914,'twister');
p.printLevel = 0; p.maxNewBasisTime = 60;
F = {}; 
F{1} = struct('name','F1 square 3x3',    'S', sparse([-1 0 1;1 -1 0;0 1 -1]));
F{2} = struct('name','F2 chain 3x2',     'S', sparse([-1 0;1 -1;0 1]));
F{3} = struct('name','F2b two pools 4x2','S', sparse([-1 0;1 0;0 -1;0 1]));
F{4} = struct('name','F3 empty ns 2x3',  'S', sparse([-1 1 0;0 -1 1]));
for k=1:numel(F), F{k}.SConsistentRxnBool = true(size(F{k}.S,2),1); end

root='/home/rfleming/drive/sbgCloud/code/fork-cobratoolbox';
d=load([root '/test/models/mat/ecoli_core_model.mat']); fn=fieldnames(d); m=d.(fn{1});
F{5}=struct('name','ecoli_core','S',m.S,'SConsistentRxnBool',true(size(m.S,2),1));
d=load([root '/test/models/mat/iAF1260.mat']); fn=fieldnames(d); m=d.(fn{1});
F{6}=struct('name','iAF1260','S',m.S,'SConsistentRxnBool',true(size(m.S,2),1));
d=load([root '/papers/2023_iDopaNeuro/models/iDopaNeuroC.mat']); m=d.iDopaNeuroC;
F{7}=struct('name','iDopaNeuroC(int)','S',m.S(:,m.SConsistentRxnBool),'SConsistentRxnBool',true(nnz(m.SConsistentRxnBool),1));

fprintf('%-18s %-8s %-11s %-11s %-11s %5s %5s %6s %6s\n','model','solver','target','resAbs','resScaled','found','exp','rejAcc','nonNeg');
for s = {'gurobi','mosek'}
    if ~changeCobraSolver(s{1},'LP',0), continue; end
    for k = 1:numel(F)
        mm.S = F{k}.S; mm.SConsistentRxnBool = F{k}.SConsistentRxnBool;
        try
            [Zpos,~,st] = greedyExtremeRayBasis(mm, p);
            fprintf('%-18s %-8s %-11.3e %-11.3e %-11.3e %5d %5d %6d %6d\n', F{k}.name, s{1}, ...
                st.accuracyTarget, st.residualAbsolute, st.residualScaled, st.raysFound, ...
                st.raysExpected, st.raysRejectedForAccuracy, st.nonNegative);
        catch ME
            fprintf('%-18s %-8s ERROR %s (%s:%d)\n', F{k}.name, s{1}, ME.message, ME.stack(1).name, ME.stack(1).line);
        end
    end
end
