% The COBRAToolbox: testGreedyExtremeRayBasisResume.m
%
% Purpose:
%     - Tests the checkpoint (param.checkpointFile) of greedyExtremeRayBasis and resuming
%       from it through param.initialBasis, which completes a supplied partial basis.
%     - Both options are inert when absent: the result without them is unchanged.
%     - A supplied vector is judged by the acceptance rule, so a corrupted one is
%       rejected for accuracy and reported, and the others are kept.
%     - The partial basis is written on every exit path, including the time budget, in
%       the caller's orientation, so it resumes without a transpose in either mode.
%     - Rays are compared with isequal deliberately: kept vectors are COPIED, not
%       computed, and must come back bit-for-bit unchanged (FR-001, SC-002).
%
% Authors:
%     - Variational kinetics feature 089 large-model-solver-speed, November 2026
%     - Feature 20261106-213424-greedy-basis-reconcile (supplied-basis semantics), November 2026

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
assert(s0.initialBasisKept == 0 && isempty(s0.checkpointFile));
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
assert(strcmp(C.leftRight, 'left'), 'checkpoint must record its mode');
assert(isequal(C.operativeFingerprint(1:2), size(N)), 'fingerprint wrong');

% 3. Seed with the complete basis: returned unchanged, nothing to search.
[L2, ~, s2] = greedyExtremeRayBasis(model, setfield(param, 'initialBasis', L0)); %#ok<SFLD>
assert(strcmp(s2.outcome, 'complete') && s2.initialBasisKept == nRays && s2.nLPSolves == 0);
assert(isequal(L2, L0), 'complete seed not returned unchanged');

% 4. Seed with a partial basis whose first row is corrupted: that row is rejected for
% accuracy and reported, the others are kept, and the search completes the basis.
seed = L0(1:end-1, :);
seed(1, :) = seed(1, :) + 1e-3*double(seed(2, :) == 0);   % breaks L*N = 0
[L3, ~, s3] = greedyExtremeRayBasis(model, setfield(param, 'initialBasis', seed)); %#ok<SFLD>
assert(s3.initialBasisKept == nRays - 2, 'corrupted seed row not dropped');
assert(s3.initialBasisRejected == 1 && isequal(s3.initialBasisRejectedIndex, 1) && ...
    strcmp(s3.initialBasisRejectedReason{1}, 'accuracy'), 'corrupted row not reported as an accuracy rejection');
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
assert(strcmp(s6.outcome, 'complete') && s6.initialBasisKept == 2 && size(L6, 1) == nRays);
assert(isequal(L6(1:2, :), C.Zpos), 'checkpointed rays not returned unchanged as leading rows (SC-002)');

% 6. A seed of the wrong width is an error, not a silent truncation.
try
    greedyExtremeRayBasis(model, setfield(param, 'initialBasis', L0(:, 1:end-1))); %#ok<SFLD>
    error('testGreedyExtremeRayBasisResume:noError', 'wrong-width seed accepted');
catch ME
    assert(strcmp(ME.identifier, 'greedyExtremeRayBasis:initialBasisSize'), ME.message);
end

% 7. Right mode: the checkpoint holds columns, as the caller supplies them, and resumes
% with no transpose. The right nullspace of N' is the left nullspace of N.
rightModel = struct('S', N', 'SConsistentRxnBool', true(size(N, 1), 1));
rightParam = param;
rightParam.leftRight = 'right';
rightParam.internalStoichiometriMatrixLeftNullspace = 0;
delete(ck);
p7 = rightParam;
p7.maxTime = 0;
p7.checkpointFile = ck;
p7.initialBasis = L0(1:2, :)';
[R7, ~, s7] = greedyExtremeRayBasis(rightModel, p7);
assert(strcmp(s7.outcome, 'incomplete') && size(R7, 2) == 2 && s7.initialBasisKept == 2);
C = load(ck);
assert(strcmp(C.leftRight, 'right') && C.nBases == 2 && isequal(size(C.Zpos), [size(N, 1), 2]), ...
    'right-mode checkpoint not in the caller''s (column) orientation');
assert(isequal(C.Zpos, R7), 'right-mode checkpoint differs from the returned basis');
[R8, ~, s8] = greedyExtremeRayBasis(rightModel, setfield(rightParam, 'initialBasis', C.Zpos)); %#ok<SFLD>
assert(strcmp(s8.outcome, 'complete') && s8.initialBasisKept == 2 && size(R8, 2) == nRays);
assert(isequal(R8(:, 1:2), C.Zpos), 'right-mode resume did not keep the checkpointed columns');
assert(max(abs(N'*R8), [], 'all') <= s8.acceptanceTarget);

fprintf('testGreedyExtremeRayBasisResume: all checks passed (%d rays).\n', nRays);
cd(currentDir);
