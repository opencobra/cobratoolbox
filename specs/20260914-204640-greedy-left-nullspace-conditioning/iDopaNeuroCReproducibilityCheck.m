function results = iDopaNeuroCReproducibilityCheck(param)
% Reproducibility check for SC-005 of feature 20260914-204640: iDopaNeuroC must either
% yield a basis giving the augmented matrix an unambiguous rank, or return the
% bad-scaling diagnosis. Silently returning a basis with the pre-change accuracy is not
% an acceptable outcome.
%
% USAGE:
%
%    results = iDopaNeuroCReproducibilityCheck(param)
%
% OPTIONAL INPUT:
%    param:      structure of optional parameters:
%
%                  * .maxNewBasisTime - dead-end threshold in seconds (default = 30)
%                  * .maxTime - total budget in seconds (default = 180)
%                  * .solver - LP solver to use (default = `'gurobi'`)
%
% OUTPUT:
%    results:    structure recording every quantity SC-009 requires, plus the
%                pass/fail verdict against SC-005
%
% NOTE:
%
%    This is a DOCUMENTED REPRODUCIBILITY CHECK, not a CI test, and it is deliberately
%    not registered under test/verifiedTests/. The model it needs lives at
%    papers/2023_iDopaNeuro/models/iDopaNeuroC.mat, and `papers` is a GIT SUBMODULE
%    whose initialisation is gated during toolbox initialisation, so it cannot be
%    relied upon to be present in CI. Constitution Principle III sanctions a documented
%    reproducibility check where full automation is not yet practical and requires the
%    reason for deferral to be stated; the reason is stated here.
%
%    Run it manually after `git submodule update --init papers`. Expected output is
%    recorded in iDopaNeuroCReproducibility-expected.md beside this file.
%
% Author: - feature 20260914-204640-greedy-left-nullspace-conditioning, 2026-09-15

if ~exist('param', 'var') || isempty(param)
    param = struct();
end
if ~isfield(param, 'maxNewBasisTime')
    param.maxNewBasisTime = 30;
end
if ~isfield(param, 'maxTime')
    param.maxTime = 180;
end
if ~isfield(param, 'solver')
    param.solver = 'gurobi';
end

modelFile = fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))), ...
    'papers', '2023_iDopaNeuro', 'models', 'iDopaNeuroC.mat');
if ~exist(modelFile, 'file')
    error('greedyExtremeRayBasis:reproducibilityModelMissing', ...
        ['%s not found. papers/ is a git submodule; run ' ...
        '"git submodule update --init papers" first.'], modelFile);
end

solverOK = changeCobraSolver(param.solver, 'LP', 0);
if ~solverOK
    error('greedyExtremeRayBasis:reproducibilitySolverMissing', ...
        'LP solver %s is not available.', param.solver);
end

% the greedy search draws random objectives, so the seed is part of the record
rng(20260914, 'twister');

loaded = load(modelFile);
model = loaded.iDopaNeuroC;
S = model.S(:, model.SConsistentRxnBool);          % internal, as the caller uses it

basisParam.printLevel = 0;
basisParam.maxNewBasisTime = param.maxNewBasisTime;
basisParam.maxTime = param.maxTime;
checkModel = struct('S', S, 'SConsistentRxnBool', true(size(S, 2), 1));

[L, ~, status] = greedyExtremeRayBasis(checkModel, basisParam);

results = struct();
results.solver = param.solver;
results.seed = 20260914;
results.replicates = 1;
results.operativeMatrixSize = size(S);
results.outcome = status.outcome;
results.regime = status.regime;
results.terminationReason = status.terminationReason;
results.scalingValue = status.scalingValue;
results.scalingBoundary = status.scalingBoundary;
results.accuracyTarget = status.accuracyTarget;
results.residualAbsolute = status.residualAbsolute;
results.residualScaled = status.residualScaled;
results.nonNegative = status.nonNegative;
results.raysFound = status.raysFound;
results.raysExpected = status.raysExpected;
results.elapsedTime = status.elapsedTime;
results.zeroRowsReturned = full(sum(~any(L ~= 0, 2)));
results.rowCountMatchesRaysFound = (size(L, 1) == status.raysFound);

% SC-005: either an accurate basis, or the bad-scaling diagnosis. Never a basis that
% silently fails the accuracy a rank determination needs.
if strcmp(status.outcome, 'badlyScaled')
    results.verdict = 'PASS (diagnosed as badly scaled)';
elseif isfinite(status.residualAbsolute) && status.residualAbsolute <= status.accuracyTarget
    results.verdict = 'PASS (basis meets the derived accuracy target)';
else
    results.verdict = 'FAIL (a basis was returned that misses the accuracy target)';
end

fprintf('\niDopaNeuroC reproducibility check (SC-005)\n');
fprintf('  solver %s, seed %d, %d replicate\n', results.solver, results.seed, results.replicates);
fprintf('  operative matrix        %d x %d\n', results.operativeMatrixSize);
fprintf('  outcome / regime        %s / %s (%s)\n', results.outcome, results.regime, ...
    results.terminationReason);
fprintf('  sigmaMinPlus / boundary %.4e / %.4e\n', results.scalingValue, results.scalingBoundary);
fprintf('  accuracy target         %.4e\n', results.accuracyTarget);
fprintf('  residual abs / scaled   %.4e / %.4e\n', results.residualAbsolute, results.residualScaled);
fprintf('  rays found / expected   %d / %d\n', results.raysFound, results.raysExpected);
fprintf('  zero rows returned      %d\n', results.zeroRowsReturned);
fprintf('  row count == raysFound  %d\n', results.rowCountMatchesRaysFound);
fprintf('  non-negative            %d\n', results.nonNegative);
fprintf('  runtime                 %.1f s\n', results.elapsedTime);
fprintf('  VERDICT: %s\n\n', results.verdict);
