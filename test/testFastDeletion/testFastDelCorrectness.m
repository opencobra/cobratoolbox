function testFastDelCorrectness(model)
% Test the correctness of fastSingleGeneDeletion and fastSingleRxnDeletion
% and summarise the results, for any given model


fprintf('Gene deletion:\n');
t = tic;
[grRatio_f, grRateKO_f, grRateWT_f, hasEffect_f, delRxns_f] = fastSingleGeneDeletion(model);
t_fast = toc(t);

t = tic;
[grRatio, grRateKO, grRateWT, hasEffect, delRxns] = singleGeneDeletion(model);
t_reg = toc(t);

% Now compare
fprintf('Difference in grRatios -- min: %.1e, max: %.1e; vec distance = %.1e\n', max(grRatio - grRatio_f), min(grRatio - grRatio_f), norm(grRatio - grRatio_f));
fprintf('# differences in hasEffect (~saving): %d\n', sum(hasEffect_f ~= hasEffect));
fprintf('delRxns equal? %d\n', isequal(delRxns, delRxns_f));
fprintf('Fast deletion completed in %.1f%% of time! (%.1f sec vs %.1f sec)\n', t_fast/t_reg*100, t_fast, t_reg);

fprintf('Reaction deletion:\n');
t = tic;
[grRatio_f,grRateKO_f,grRateWT_f,hasEffect_f,delRxns_f,fluxSolution_f] = fastSingleRxnDeletion(model);
t_fast = toc(t);

t = tic;
[grRatio,grRateKO,grRateWT,hasEffect,delRxns,fluxSolution] = singleRxnDeletion(model);
t_reg = toc(t);

% Now compare
fprintf('Difference in grRatios -- min: %.1e, max: %.1e; vec distance = %.1e\n', max(grRatio - grRatio_f), min(grRatio - grRatio_f), norm(grRatio - grRatio_f));
fprintf('# differences in hasEffect (~saving): %d\n', sum(hasEffect_f ~= hasEffect));
fprintf('delRxns equal? %d\n', isequal(delRxns, delRxns_f));
fprintf('Fast deletion completed in %.1f%% of time! (%.1f sec vs %.1f sec)\n', t_fast/t_reg*100, t_fast, t_reg);

