% The COBRAToolbox: testGreedyExtremeRayBasisResume.m
%
% Purpose:
%     - Tests the resume (param.initialBasis) and checkpoint (param.checkpointFile)
%       options of greedyExtremeRayBasis.
%     - Both options are inert when absent: the result without them is unchanged.
%     - A seed is re-judged by the acceptance rule, so a corrupted row is dropped.
%     - The partial basis is written on every exit path, including the time budget.
%
% Authors:
%     - Variational kinetics feature 089 large-model-solver-speed, November 2026

currentDir = pwd;
fileDir = fileparts(which('testGreedyExtremeRayBasisResume'));
cd(fileDir);

solvers = prepareTest('needsLP', true);

% A model whose internal left nullspace has several rays.
model = getDistributedModel('ecoli_core_model.mat');
[~, ~, ~, ~, ~, ~, model] = findStoichConsistentSubset(model, 0, 0);

param = struct('printLevel', 0, 'internalStoichiometriMatrixLeftNullspace', 1, ...
    'maxTime', 600, 'maxNewBasisTime', 600);
N = model.S(:, model.SConsistentRxnBool);

% 1. Without the new options: a complete basis, and the same basis as a second
% identically seeded call (the options are inert when absent).
rng(89, 'twister');
[L0, ~, s0] = greedyExtremeRayBasis(model, param);
assert(strcmp(s0.outcome, 'complete'), 'reference basis incomplete');
assert(s0.raysSeeded == 0 && isempty(s0.checkpointFile));
nRays = size(L0, 1);
assert(nRays >= 3, 'fixture needs at least three rays');

% 2. Checkpoint on success holds the returned basis, marked final.
ck = [tempname '.mat'];
cleanupFile = onCleanup(@() delete(ck));
rng(89, 'twister');
[L1, ~, s1] = greedyExtremeRayBasis(model, setfield(param, 'checkpointFile', ck)); %#ok<SFLD>
assert(isequal(L1, L0), 'checkpointing changed the result');
assert(strcmp(s1.checkpointFile, ck));
C = load(ck);
assert(C.final && C.nBases == nRays && isequal(C.Zpos, L0), 'final checkpoint wrong');
assert(isequal(C.operativeFingerprint(1:2), size(N)), 'fingerprint wrong');

% 3. Seed with the complete basis: returned unchanged, nothing to search.
[L2, ~, s2] = greedyExtremeRayBasis(model, setfield(param, 'initialBasis', L0)); %#ok<SFLD>
assert(strcmp(s2.outcome, 'complete') && s2.raysSeeded == nRays);
assert(isequal(L2, L0), 'complete seed not returned unchanged');

% 4. Seed with a partial basis whose first row is corrupted: that row is dropped, the
% others are kept, and the search completes the basis.
seed = L0(1:end-1, :);
seed(1, :) = seed(1, :) + 1e-3*double(seed(2, :) == 0);   % breaks L*N = 0
[L3, ~, s3] = greedyExtremeRayBasis(model, setfield(param, 'initialBasis', seed)); %#ok<SFLD>
assert(s3.raysSeeded == nRays - 2, 'corrupted seed row not dropped');
assert(strcmp(s3.outcome, 'complete') && size(L3, 1) == nRays);
assert(isequal(L3(1:nRays-2, :), L0(2:end-1, :)), 'kept seed rows not at the top');
assert(max(abs(L3*N), [], 'all') <= s3.acceptanceTarget);

% 5. Time budget: an exhausted budget still writes the partial basis, marked final
% (it is the verified returned object), and resuming from it completes the basis.
delete(ck);
p5 = param;
p5.maxTime = 0;
p5.checkpointFile = ck;
p5.initialBasis = L0(1:2, :);
[L5, ~, s5] = greedyExtremeRayBasis(model, p5);
assert(strcmp(s5.outcome, 'incomplete') && s5.timedOut && size(L5, 1) == 2);
C = load(ck);
assert(C.nBases == 2 && isequal(C.Zpos, L5), 'partial basis not saved on time budget');
[L6, ~, s6] = greedyExtremeRayBasis(model, setfield(param, 'initialBasis', C.Zpos)); %#ok<SFLD>
assert(strcmp(s6.outcome, 'complete') && s6.raysSeeded == 2 && size(L6, 1) == nRays);

% 6. A seed of the wrong width is an error, not a silent truncation.
try
    greedyExtremeRayBasis(model, setfield(param, 'initialBasis', L0(:, 1:end-1))); %#ok<SFLD>
    error('testGreedyExtremeRayBasisResume:noError', 'wrong-width seed accepted');
catch ME
    assert(strcmp(ME.identifier, 'greedyExtremeRayBasis:initialBasisSize'), ME.message);
end

fprintf('testGreedyExtremeRayBasisResume: all checks passed (%d rays).\n', nRays);
cd(currentDir);
