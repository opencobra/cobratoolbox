%seed = 1;
%rng(seed);

% load polyoptes
P = model;
numSamples = 100;
numSteps = 25^2;

% sampling
tic;
[samples, rPolytope] = chrrSampler(P, numSteps, numSamples, 3);

% return to original space
samplesNew = rPolytope.x0 * ones(1, size(samples, 2));
samplesNew(rPolytope.idx,:) = samplesNew(rPolytope.idx,:) + samples;

% check lb <= x <= ub
% b1 = samplesNew - P.lb;
% b2 = P.ub - samplesNew;
% assert(min(b1(:))>=0);
% assert(min(b2(:))>=0);

% check Ax = b
% slack = abs(P.b-P.S*samplesNew);
% assert(min(slack(:))<1e-9);