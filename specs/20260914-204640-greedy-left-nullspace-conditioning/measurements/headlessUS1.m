initCobraToolbox(false);
changeCobraSolver('gurobi','LP',0);
rng(20260914,'twister');
p.printLevel=0; p.maxNewBasisTime=20;
root='/home/rfleming/drive/sbgCloud/code/fork-cobratoolbox';
F={};
F{1}=struct('name','F1 sq 3x3','S',sparse([-1 0 1;1 -1 0;0 1 -1]));
F{2}=struct('name','F2 chain 3x2','S',sparse([-1 0;1 -1;0 1]));
F{3}=struct('name','F2b pools 4x2','S',sparse([-1 0;1 0;0 -1;0 1]));
F{4}=struct('name','F3 empty 2x3','S',sparse([-1 1 0;0 -1 1]));
d=load([root '/test/models/mat/ecoli_core_model.mat']); fn=fieldnames(d); m=d.(fn{1});
F{5}=struct('name','ecoli_core','S',m.S);
for k=1:numel(F), F{k}.SConsistentRxnBool=true(size(F{k}.S,2),1); end
fprintf('\nRESULTS\n');
fprintf('%-16s %-10s %-10s %-10s %5s %5s %6s %6s %7s %3s\n','model','target','resAbs','resScaled','fnd','exp','rejAcc','nonNeg','secs','TO');
for k=1:numel(F)
  mm=struct('S',F{k}.S,'SConsistentRxnBool',F{k}.SConsistentRxnBool);
  [Zp,~,st]=greedyExtremeRayBasis(mm,p);
  fprintf('%-16s %-10.3e %-10.3e %-10.3e %5d %5d %6d %6d %7.2f %3d\n',F{k}.name, ...
    st.accuracyTarget,st.residualAbsolute,st.residualScaled,st.raysFound,st.raysExpected, ...
    st.raysRejectedForAccuracy,st.nonNegative,st.elapsedTime,st.timedOut);
end
fprintf('DONE\n');
