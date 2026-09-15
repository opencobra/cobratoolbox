% R1/R2: paired comparison of gurobi and mosek at identical greedy state. Tasks T008, T009.
initCobraToolbox(false); rng(20260915,'twister');
root='/home/rfleming/drive/sbgCloud/code/fork-cobratoolbox';
d=load([root '/papers/2023_iDopaNeuro/models/iDopaNeuroC.mat']); m=d.iDopaNeuroC;
N = m.S(:, m.SConsistentRxnBool);
mm = struct('S', N, 'SConsistentRxnBool', true(size(N,2),1));

changeCobraSolver('gurobi','LP',0);
p.printLevel=0; p.maxNewBasisTime=25; p.maxTime=120;
p.compareSolvers = {'gurobi','mosek'};
ws = warning('off','all');
[~,~,st] = greedyExtremeRayBasis(mm, p);
warning(ws);

R = st.pairedComparison;
fprintf('\nPAIRED POINTS: %d rows over %d comparison points\n', numel(R), numel(unique([R.pointIndex])));
fprintf('rays found %d of %d\n\n', st.raysFound, st.raysExpected);

% audit the pairing itself: within each point every solver must share objectiveHash
pts = unique([R.pointIndex]); okPair = true;
for k = pts
    g = R([R.pointIndex]==k);
    if numel(unique({g.objectiveHash})) ~= 1, okPair = false; end
end
fprintf('PAIRING AUDIT: every solver at a point received the same objective: %d\n\n', okPair);

for s = {'gurobi','mosek'}
    r = R(strcmp({R.solver}, s{1}));
    if isempty(r), continue; end
    fprintf('%-8s n=%3d | residual med %.3e max %.3e | meetsTarget %3d/%3d | independent %3d/%3d | basisReturned %3d/%3d | atBound med %5.0f | t med %.3f s\n', ...
        s{1}, numel(r), median([r.residualAbsolute]), max([r.residualAbsolute]), ...
        nnz([r.meetsTarget]), numel(r), nnz([r.independentOfBasis]), numel(r), ...
        nnz([r.basisReturned]), numel(r), median([r.atBoundCount]), median([r.solveTime]));
end
save([root '/specs/20260915-082551-extreme-ray-coverage/measurements/pairedCampaign.mat'], 'R', 'st');
