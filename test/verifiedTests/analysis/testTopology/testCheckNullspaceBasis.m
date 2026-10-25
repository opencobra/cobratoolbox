% The COBRAToolbox: testCheckNullspaceBasis.m
%
% Purpose:
%     - testCheckNullspaceBasis tests checkNullspaceBasis, which judges a basis the
%       caller already holds (for example a model.L loaded with a model) by the same
%       accuracy contract greedyExtremeRayBasis certifies its own output against.
%
%     - Each verdict is exercised on a basis constructed to earn it, starting from a
%       basis known to be valid, so that every outcome is shown to be reachable and
%       to mean what it says.
%
% Authors:
%     - Feature 20261003-132730-greedy-recon3d-stall, October 2026
%
% Reference:
%     specs/20261003-132730-greedy-recon3d-stall/contracts/checkNullspaceBasis.md

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCheckNullspaceBasis'));
cd(fileDir);

% a valid basis is produced by greedyExtremeRayBasis, which needs an LP solver
solvers = prepareTest('needsLP', true);
rng(20261003, 'twister');

ecoli = load('ecoli_core_model.mat');
[~, ~, ~, ~, ~, ~, ecoliModel] = findStoichConsistentSubset(ecoli.model, 0, 0);

param.printLevel = 0;
param.internalStoichiometriMatrixLeftNullspace = 1;
param.maxTime = 60;
Sop = ecoliModel.S(:, ecoliModel.SConsistentRxnBool);

for k = 1:length(solvers.LP)

    fprintf('   Testing checkNullspaceBasis using %s ... ', solvers.LP{k});

    % greedyExtremeRayBasis nominates its own vertex-returning solver, so the loop
    % only needs some LP solver to be available
    if changeCobraSolver(solvers.LP{k}, 'LP', 0) == 1

        [B, ~, statusB] = greedyExtremeRayBasis(ecoliModel, param);
        assert(strcmp(statusB.outcome, 'complete'), ...
            'the reference basis must be complete for this test to mean anything');

        % a complete accurate non-negative basis is valid
        report = checkNullspaceBasis(ecoliModel, B, param);
        assert(strcmp(report.outcome, 'valid'), ...
            sprintf('a complete accurate basis gave ''%s''', report.outcome));
        assert(report.spansNullspace && isempty(report.failingRows) && report.nonNegative, ...
            'a valid basis must span, have no failing rows, and be non-negative');
        assert(report.rankB == report.nullity && report.nullity == size(B, 1), ...
            'rank and nullity must agree for a complete basis');
        assert(isequal(report.residualByRow, full(max(abs(B*Sop), [], 2))), ...
            'the per-row residual must be the same metric greedyExtremeRayBasis uses');
        assert(report.acceptanceTarget == statusB.acceptanceTarget, ...
            'the target must be the one greedyExtremeRayBasis applied to the same matrix');

        % one row knocked off the nullspace is inaccurate, and only that row fails
        Bperturbed = B;
        [~, jNonZero] = max(Bperturbed(1, :));
        Bperturbed(1, jNonZero) = Bperturbed(1, jNonZero) + 1e-6;
        reportPerturbed = checkNullspaceBasis(ecoliModel, Bperturbed, param);
        assert(strcmp(reportPerturbed.outcome, 'inaccurate'), ...
            sprintf('a perturbed row gave ''%s''', reportPerturbed.outcome));
        assert(isequal(reportPerturbed.failingRows(:)', 1), ...
            'exactly the perturbed row must be reported as failing');
        assert(reportPerturbed.spansNullspace, 'a perturbation this small must not change the rank');

        % a negative entry takes precedence over every other verdict
        Bnegative = Bperturbed;
        Bnegative(2, 1) = -1e-3;
        reportNegative = checkNullspaceBasis(ecoliModel, Bnegative, param);
        assert(strcmp(reportNegative.outcome, 'negative') && ~reportNegative.nonNegative, ...
            sprintf('a negative entry gave ''%s''', reportNegative.outcome));

        % a missing row cannot span the nullspace
        reportShort = checkNullspaceBasis(ecoliModel, B(1:end-1, :), param);
        assert(strcmp(reportShort.outcome, 'rankDeficient') && ~reportShort.spansNullspace, ...
            sprintf('a basis missing a row gave ''%s''', reportShort.outcome));

        % a dependent row also cannot be a basis, though it spans
        reportDependent = checkNullspaceBasis(ecoliModel, [B; B(1, :) + B(2, :)], param);
        assert(strcmp(reportDependent.outcome, 'rankDeficient'), ...
            sprintf('a basis with a dependent row gave ''%s''', reportDependent.outcome));

        % malformed input is an error, never a verdict
        try
            checkNullspaceBasis(ecoliModel, B(:, 1:end-1), param);
            mismatchRaised = false;
        catch ME
            mismatchRaised = strcmp(ME.identifier, 'checkNullspaceBasis:dimensionMismatch');
        end
        assert(mismatchRaised, 'a basis of the wrong width must raise checkNullspaceBasis:dimensionMismatch');

        % right mode: the same verdicts for the transposed problem
        rightParam = param;
        rightParam.leftRight = 'right';
        rightParam.internalStoichiometriMatrixLeftNullspace = 0;
        rightModel = struct('S', Sop', 'SConsistentRxnBool', true(size(Sop, 1), 1));
        reportRight = checkNullspaceBasis(rightModel, B', rightParam);
        assert(strcmp(reportRight.outcome, 'valid'), ...
            sprintf('the transposed problem gave ''%s'' in right mode', reportRight.outcome));

        fprintf('Done.\n');
    end
end

% change back to the current directory
cd(currentDir);
