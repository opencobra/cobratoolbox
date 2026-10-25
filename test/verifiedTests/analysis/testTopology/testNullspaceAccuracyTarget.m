% The COBRAToolbox: testNullspaceAccuracyTarget.m
%
% Purpose:
%     - testNullspaceAccuracyTarget tests nullspaceAccuracyTarget, which derives the
%       residual target a left-nullspace basis must meet for a matrix augmented with
%       it to have a well-defined numerical rank, and classifies the scaling regime.
%
%     - The derivation was extracted from greedyExtremeRayBasis so that
%       checkNullspaceBasis can judge a supplied basis by the identical contract. The
%       assertions pin the formula, the size ceiling for the dense spectrum, and the
%       documented fallback above it.
%
% Authors:
%     - Feature 20261003-132730-greedy-recon3d-stall, October 2026
%
% Reference:
%     specs/20261003-132730-greedy-recon3d-stall/contracts/nullspaceAccuracyTarget.md
%     specs/20260914-204640-greedy-left-nullspace-conditioning/research.md R2, R3

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testNullspaceAccuracyTarget'));
cd(fileDir);

% ecoli_core ships with the test suite; its internal (stoichiometrically consistent)
% matrix is well scaled and has a non-empty left nullspace
ecoli = load('ecoli_core_model.mat');
[~, ~, ~, ~, ~, ~, ecoliConsistent] = findStoichConsistentSubset(ecoli.model, 0, 0);
S = ecoliConsistent.S(:, ecoliConsistent.SConsistentRxnBool);

% default ceiling: the spectrum is computed and the target derived
param = struct();
target = nullspaceAccuracyTarget(S, param);
assert(target.accuracyTargetDerived, 'the target must be derived for a small matrix');
assert(strcmp(target.regime, 'wellScaled'), ...
    sprintf('ecoli_core internal must be well scaled, got ''%s''', target.regime));
assert(target.tauMin == eps*max(sum(size(S)), size(S, 1)), 'tauMin must follow its definition');
assert(target.accuracyTarget == target.tauMin*target.sigmaOne*target.sigmaMinPlus, ...
    'the derived target must equal tauMin * sigma_1 * sigma_min+');
assert(target.regimeBoundary == eps/(target.tauMin*target.sigmaOne), ...
    'the regime boundary must equal eps / (tauMin * sigma_1)');
assert(target.spectrumTime >= 0, 'the spectrum cost must be reported');

% the singular values agree with an independent computation
singularValues = svd(full(S));
assert(target.sigmaOne == singularValues(1), 'sigma_1 must be the largest singular value');

% the ceiling is inclusive: a matrix exactly at the ceiling is still factored
atCeiling = struct('maxElementsForSpectrum', numel(S));
targetAt = nullspaceAccuracyTarget(S, atCeiling);
assert(targetAt.accuracyTargetDerived, 'a matrix exactly at the ceiling must be factored');
assert(targetAt.accuracyTarget == target.accuracyTarget, ...
    'the derivation must not depend on where the ceiling sits once it is under it');

% just above the ceiling: the documented fallback, reported as not assessed
aboveCeiling = struct('maxElementsForSpectrum', numel(S) - 1);
targetAbove = nullspaceAccuracyTarget(S, aboveCeiling);
assert(~targetAbove.accuracyTargetDerived, 'above the ceiling the target must not claim to be derived');
assert(strcmp(targetAbove.regime, 'notAssessed'), ...
    'above the ceiling the regime must be reported as not assessed');
assert(abs(targetAbove.accuracyTarget - eps*normest(S)) <= 1e-12*eps*normest(S), ...
    'above the ceiling the target must fall back to eps * normest(S)');
assert(targetAbove.spectrumTime == 0, 'no spectrum cost may be reported when none was incurred');

% a badly scaled matrix (the fixture testGreedyExtremeRayBasis uses for Regime B)
badlyScaled = sparse([-1, 0, 0; 1, 0, 0; 0, 1, 0; 0, 1, 1e-12]);
targetBad = nullspaceAccuracyTarget(badlyScaled, param);
assert(strcmp(targetBad.regime, 'badlyScaled'), ...
    sprintf('the near-dependent fixture must be badly scaled, got ''%s''', targetBad.regime));
assert(targetBad.sigmaMinPlus < targetBad.regimeBoundary, ...
    'a badly scaled verdict must mean sigma_min+ lies below the boundary');

% an all-zero matrix has no spectrum to derive from: fall back, do not divide by zero
targetZero = nullspaceAccuracyTarget(sparse(3, 2), param);
assert(~targetZero.accuracyTargetDerived && strcmp(targetZero.regime, 'notAssessed'), ...
    'a zero matrix must fall back rather than claim a derivation');

fprintf('Done.\n');

% change back to the current directory
cd(currentDir);
