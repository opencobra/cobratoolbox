% Reproducibility check for SC-002: run generateFullRowRankFR on the
% variationalKinetics Recon3T (outside the repository) and print every report
% list. Writes reproduceRecon3T.log beside this script.
recon3TFile = fullfile(getenv('HOME'), 'drive', 'sbgCloud', 'projects', 'variationalKinetics', 'data', 'Recon3T', ...
    'Recon3DModel_301_xomics_input_VK_withL.mat');
logFile = fullfile(fileparts(mfilename('fullpath')), 'reproduceRecon3T.log');
if exist(logFile, 'file')
    delete(logFile);
end
diary(logFile);
fprintf('reproduceRecon3T: %s\n', recon3TFile);
loaded = load(recon3TFile);
model = loaded.model;
tic;
[modelOut, report] = generateFullRowRankFR(model, struct('printLevel', 2));
fprintf('runtime %.1f s\n', toc);

fprintf('\nrank log (iteration, m, rankLUSOL, rankQR, method):\n');
for i = 1:numel(report.rankLog)
    entry = report.rankLog(i);
    fprintf('  %d  %d  %d  %d  %s\n', entry.iteration, entry.m, entry.rankLUSOL, entry.rankQR, entry.rankMethod);
end
fprintf('\nremoved metabolites (%d):\n', numel(report.removedMets));
for i = 1:numel(report.removedMets)
    fprintf('  pass %d  %-12s %s\n', report.removedMets(i).iteration, report.removedMets(i).reason, report.removedMets(i).met);
end
fprintf('\nremoved reactions (%d):\n', numel(report.removedRxns));
for i = 1:numel(report.removedRxns)
    fprintf('  pass %d  %-12s internal %d  %s\n', report.removedRxns(i).iteration, report.removedRxns(i).reason, ...
        report.removedRxns(i).internal, report.removedRxns(i).rxn);
end
fprintf('\nlumped groups (%d):\n', numel(report.lumpedGroups));
for i = 1:numel(report.lumpedGroups)
    group = report.lumpedGroups(i);
    fprintf('  pass %d  {%s} -> %s, rewritten: %s\n', group.iteration, strjoin(group.members', ', '), ...
        group.representative, strjoin(group.rxnsRewritten', ', '));
end
fprintf('\nleft-null witnesses (%d):\n', numel(report.nullVectors));
for i = 1:numel(report.nullVectors)
    witness = report.nullVectors(i);
    fprintf('  pass %d  support %d, residual %g, remedy %s\n', witness.iteration, numel(witness.support), ...
        witness.residual, witness.remedy);
    for k = 1:numel(witness.support)
        fprintf('      %+g  %s\n', witness.coefficients(k), witness.support{k});
    end
    fprintf('    reactions removed: %s\n', strjoin(witness.rxnsRemoved', ', '));
end
fprintf('\nflagged for review (%d):\n', numel(report.flaggedForReview));
for i = 1:numel(report.flaggedForReview)
    fprintf('  %s share substrate %s\n', strjoin(report.flaggedForReview(i).rxns', ' / '), report.flaggedForReview(i).sharedSubstrate);
end
fprintf('\nm %d -> %d, n %d -> %d, rank %d -> %d, fullRowRank %d, iterations %d, stopReason ''%s''\n', ...
    report.mBefore, report.mAfter, report.nBefore, report.nAfter, report.rankBefore, report.rankAfter, ...
    report.fullRowRank, report.iterations, report.stopReason);
results = verifyModel(modelOut, 'simpleCheck', true);
fprintf('verifyModel simple check: %d\n', results);
diary('off');
