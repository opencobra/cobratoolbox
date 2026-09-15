% The COBRAToolbox: testGreedyExtremeRayBasis.m
%
% Purpose:
%     - testGreedyExtremeRayBasis tests the functionality of greedyExtremeRayBasis,
%       the non-negative left-nullspace basis routine.
%
%     - The property under test is not merely that a basis is returned, but that the
%       basis is accurate enough that a stoichiometric matrix AUGMENTED with it has a
%       well-defined numerical rank. A basis whose rows satisfy only an absolute
%       feasibility tolerance closes the rank gap of the augmented matrix, and every
%       independent rank routine then returns a different integer.
%
%     - Fixtures F1 to F3 have a non-negative left nullspace known BY CONSTRUCTION
%       rather than by computation, so the expected answer carries no floating-point
%       error of its own. They are verified before being used to judge the routine.
%
% Authors:
%     - Feature 20260914-204640-greedy-left-nullspace-conditioning, September 2026
%
% Reference:
%     specs/20260914-204640-greedy-left-nullspace-conditioning/spec.md
%     research.md R3 records the derivation of the accuracy target asserted here.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGreedyExtremeRayBasis'));
cd(fileDir);

% require an LP solver; skip gracefully if none is available
solvers = prepareTest('needsLP', true);

% the greedy search draws random objectives, so an unseeded run is not reproducible
rng(20260914, 'twister');

% Tolerances.
%
% tolExact is for fixtures whose left nullspace is known by construction: the returned
% basis must reproduce it to machine precision, not merely to a feasibility tolerance.
tolExact = 1e-12;

% tolRankSpan is the span of RELATIVE rank tolerances over which the augmented matrix
% must report the same rank integer. Spanning three orders of magnitude is what makes
% the rank "unambiguous" rather than "unambiguous at one tolerance".
tolRankSpan = [1e-9, 1e-10, 1e-11, 1e-12];

param.printLevel = 0;
param.maxNewBasisTime = 60;

% Fixtures with an exactly known non-negative left nullspace
%
% F1 -- square, 3 x 3. A closed cycle A -> B -> C -> A.
%       Left nullspace is spanned by [1 1 1]: the total pool is conserved.
F1.S = sparse([-1, 0, 1;
                1, -1, 0;
                0, 1, -1]);
F1.Lexact = [1, 1, 1];
F1.name = 'F1 square 3x3 cycle';

% F2 -- non-square, 3 x 2 (m ~= n). An open chain A -> B -> C.
F2.S = sparse([-1, 0;
                1, -1;
                0, 1]);
F2.Lexact = [1, 1, 1];
F2.name = 'F2 non-square 3x2 chain';

% F2b -- non-square, 4 x 2, with TWO independent conserved pools, so the left
%        nullspace has dimension 2 and the routine must find more than one ray.
F2b.S = sparse([-1, 0;
                 1, 0;
                 0, -1;
                 0, 1]);
F2b.Lexact = [1, 1, 0, 0;
              0, 0, 1, 1];
F2b.name = 'F2b two conserved pools 4x2';

% F3 -- EMPTY left nullspace, 2 x 3. Full row rank, so no non-zero vector x
%       satisfies x'*S = 0. An empty basis is the CORRECT answer here.
F3.S = sparse([-1, 1, 0;
                0, -1, 1]);
F3.Lexact = zeros(0, 2);
F3.name = 'F3 empty left nullspace 2x3';

fixtures = {F1, F2, F2b, F3};
for k = 1:numel(fixtures)
    fixtures{k}.SConsistentRxnBool = true(size(fixtures{k}.S, 2), 1);
end

% verify the fixtures really are what they claim to be, before using them to judge the
% routine under test -- a fixture asserted rather than checked is not evidence
for k = 1:numel(fixtures)
    f = fixtures{k};
    assert(isempty(f.Lexact) || norm(f.Lexact * f.S, inf) == 0, ...
        sprintf('%s: claimed exact left nullspace does not annihilate S', f.name));
    expectedNullity = size(f.S, 1) - rank(full(f.S));
    assert(size(f.Lexact, 1) == expectedNullity, ...
        sprintf('%s: claimed nullity %d disagrees with rank deficiency %d', ...
        f.name, size(f.Lexact, 1), expectedNullity));
end

% genome-scale case. ecoli_core ships with the test suite and depends on no git
% submodule content, which SC-011 requires of anything run in CI.
ecoli = load('ecoli_core_model.mat');
ecoliModel.S = ecoli.model.S;
ecoliModel.SConsistentRxnBool = true(size(ecoliModel.S, 2), 1);

for k = 1:length(solvers.LP)

    fprintf('   Testing greedyExtremeRayBasis using %s ... ', solvers.LP{k});

    solverOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);

    if solverOK == 1

        % T018 / SC-001: exact fixtures, including m ~= n and an empty left nullspace
        for iF = 1:numel(fixtures)
            f = fixtures{iF};
            testModel = struct('S', f.S, 'SConsistentRxnBool', f.SConsistentRxnBool);
            [Zpos, Z, status] = greedyExtremeRayBasis(testModel, param);

            % FR-004: non-negativity is a hard requirement, asserted on the returned object
            assert(full(all(Zpos(:) >= 0)), ...
                sprintf('%s: Zpos has a negative entry', f.name));
            assert(status.nonNegative, ...
                sprintf('%s: status.nonNegative disagrees with the returned basis', f.name));

            % the returned basis must have the nullity the fixture is known to have
            assert(status.raysFound == size(f.Lexact, 1), ...
                sprintf('%s: found %d rays, expected exactly %d', ...
                f.name, status.raysFound, size(f.Lexact, 1)));

            if ~isempty(f.Lexact)
                % FR-003: every returned row annihilates S to the derived target,
                % verified on the RETURNED object
                assert(norm(Zpos * f.S, inf) < tolExact, ...
                    sprintf('%s: returned basis does not annihilate S', f.name));

                % and it must SPAN the known nullspace, not merely lie inside it
                assert(rank(full([Zpos; f.Lexact])) == size(f.Lexact, 1), ...
                    sprintf('%s: returned basis does not span the known left nullspace', f.name));
            else
                % FR-009: an empty left nullspace is the correct answer, not a failure
                assert(isempty(Zpos) || size(Zpos, 1) == 0, ...
                    sprintf('%s: expected an empty basis', f.name));
            end

            % FR-016: both residual forms are reported, never one instead of the other
            assert(isfield(status, 'residualAbsolute') && isfield(status, 'residualScaled'), ...
                sprintf('%s: status must report absolute AND scaled residual', f.name));
        end

        % T019 / SC-002: the augmented matrix has an unambiguous rank
        [L, ~, statusEcoli] = greedyExtremeRayBasis(ecoliModel, param);

        if statusEcoli.raysFound == statusEcoli.raysExpected

            S = ecoliModel.S;
            nMet = size(S, 1);

            % the augmented matrix a caller forms
            M = [S, -speye(nMet); sparse(size(L, 1), size(S, 2)), L];

            % structural rank when L spans the left nullspace
            structuralRank = size(M, 1) - size(L, 1);

            % rank by singular values, across a span of relative tolerances
            sM = svd(full(M));
            ranksAcrossSpan = arrayfun(@(t) sum(sM > t * sM(1)), tolRankSpan);

            % NOTE: agreement alone is NOT sufficient. A sufficiently wrong basis makes
            % every tolerance agree on the FULL rank. The rank must agree AT the
            % structurally expected value (research.md R3).
            assert(all(ranksAcrossSpan == structuralRank), ...
                sprintf(['augmented rank is ambiguous or wrong across the tolerance span: ' ...
                'got %s, expected %d everywhere'], mat2str(ranksAcrossSpan), structuralRank));

            % the same integer from an independent rank routine
            assert(getRankLUSOL(M) == structuralRank, ...
                sprintf('getRankLUSOL reports %d, expected %d', getRankLUSOL(M), structuralRank));

            % T020 / SC-003: the rank gap is genuinely restored
            % a nullspace basis of the augmented matrix must actually annihilate it
            [Znull, ~] = getNullSpace(M, 0);
            assert(norm(M * Znull, inf) < 1e-9, ...
                sprintf('nullspace basis of the augmented matrix has residual %g', ...
                norm(M * Znull, inf)));
        end

        % T021 / SC-014 / FR-019: the accuracy guard exercised against the failure it
        % guards, not only against success.
        %
        % A merely TINY positive target does not force the rejection path: on a
        % well-conditioned fixture the LP returns vertices whose residual is EXACTLY
        % zero, and zero passes any positive target. Measured: ecoli_core and several
        % deliberately ill-scaled fixtures all return residual 0 under both gurobi and
        % mosek. Which solver rounds, and on which fixture, is not something a test may
        % depend on.
        %
        % An IMPOSSIBLE (negative) target is therefore used, since param.feasTol may
        % only tighten (FR-015a). Every candidate must then be rejected, and the run
        % must still terminate on its budget rather than spin -- which is the
        % regression this guard protects: before the budget was moved to the top of the
        % search loop, a run that rejected every candidate never consulted it at all.
        impossibleParam = param;
        impossibleParam.feasTol = -1;
        impossibleParam.maxNewBasisTime = 5;
        [ZposStrict, ~, statusStrict] = greedyExtremeRayBasis(ecoliModel, impossibleParam);

        assert(statusStrict.acceptanceTarget < 0, ...
            'param.feasTol must be able to tighten acceptance below the derived target');
        assert(statusStrict.raysRejectedForAccuracy > 0, ...
            'an unreachable acceptance target must produce accuracy rejections');
        assert(statusStrict.raysFound == 0, ...
            'no ray can be accepted against an impossible target');
        assert(statusStrict.raysFound < statusStrict.raysExpected, ...
            'an unreachable acceptance target must not yield a complete basis');

        % FR-003a: a rejected candidate is dropped, never returned
        assert(full(all(ZposStrict(:) >= 0)), ...
            'Zpos must stay non-negative even when candidates are rejected');

        % the time budget must govern the rejection path too
        assert(statusStrict.elapsedTime < 10 * impossibleParam.maxNewBasisTime, ...
            'the time budget must bound a run that rejects every candidate');
        assert(statusStrict.timedOut, ...
            'a run that rejects every candidate must report that it timed out');

        % ---- User Story 2: Regime-B diagnosis on badly scaled input ----
        %
        % The badly scaled fixture pairs a conserved pool (rows 1-2, which give it a
        % left nullspace to find) with two nearly-parallel rows (3-4), whose near
        % dependence drives the smallest non-zero singular value of the operative
        % matrix below the measured regime boundary. Scaling a row does NOT achieve
        % this: it leaves the rank-2 subspace, and hence sigmaMinPlus, untouched.
        badlyScaledOf = @(g) sparse([-1, 0, 0;
                                      1, 0, 0;
                                      0, 1, 0;
                                      0, 1, g]);

        % T028 / SC-004: no basis of EITHER kind, no error raised, diagnosis populated
        illModel = struct('S', badlyScaledOf(1e-12), ...
            'SConsistentRxnBool', true(3, 1));
        warnState = warning('off', 'greedyExtremeRayBasis:badlyScaled');
        [ZposBad, ZBad, statusBad] = greedyExtremeRayBasis(illModel, param);
        warning(warnState);

        assert(strcmp(statusBad.outcome, 'badlyScaled'), ...
            sprintf('badly scaled input gave outcome ''%s''', statusBad.outcome));
        assert(isempty(ZposBad), 'FR-007: the non-negative basis must be withheld');
        assert(isempty(ZBad), 'FR-007: the sign-unrestricted basis must be withheld too');

        % FR-008: what is badly scaled, by how much, against what, and what to do
        assert(~isempty(statusBad.scalingQuantity), 'the diagnosis must name what is badly scaled');
        assert(isfinite(statusBad.scalingValue), 'the diagnosis must give the measured value');
        assert(isfinite(statusBad.scalingBoundary), 'the diagnosis must give the boundary violated');
        assert(statusBad.scalingValue < statusBad.scalingBoundary, ...
            'the reported value must actually violate the reported boundary');
        assert(~isempty(statusBad.scalingBoundaryBasis), ...
            'the boundary must say what it is derived from, so it can be re-derived');
        assert(~isempty(statusBad.recommendedRepair), 'the diagnosis must state the repair');

        % T029 / FR-017: a caller that suppresses ALL output is entitled to the same
        % information. Nothing above was read from the console.
        warnState = warning('off', 'all');
        quietParam = param;
        quietParam.printLevel = 0;
        [~, ~, statusQuiet] = greedyExtremeRayBasis(illModel, quietParam);
        warning(warnState);
        assert(strcmp(statusQuiet.outcome, 'badlyScaled') && ...
            ~isempty(statusQuiet.recommendedRepair) && isfinite(statusQuiet.scalingValue), ...
            'the diagnosis must be complete from the status alone, with output suppressed');

        % T030 / FR-019: the guard exercised on BOTH sides of the boundary, so it is
        % tested against a false positive as well as against the failure it guards
        wellModel = struct('S', badlyScaledOf(1), 'SConsistentRxnBool', true(3, 1));
        [ZposWell, ~, statusWell] = greedyExtremeRayBasis(wellModel, param);
        assert(strcmp(statusWell.regime, 'wellScaled'), ...
            'a well-conditioned matrix must not be classified as badly scaled');
        assert(~isempty(ZposWell), 'a well-scaled input must still yield a basis');
        assert(statusBad.scalingValue < statusWell.scalingValue, ...
            'the badly scaled fixture must actually be worse conditioned than the good one');

        % T031 / FR-009: the terminal outcomes are distinguishable from the status
        % alone. Four of the five are reachable today; 'missingField' is specified and
        % documented but is not yet produced -- that is US4 / FR-013, unimplemented.
        outcomesSeen = {statusEcoli.outcome, statusBad.outcome, statusStrict.outcome};
        for iF = 1:numel(fixtures)
            testModel = struct('S', fixtures{iF}.S, ...
                'SConsistentRxnBool', fixtures{iF}.SConsistentRxnBool);
            [~, ~, st] = greedyExtremeRayBasis(testModel, param);
            outcomesSeen{end+1} = st.outcome; %#ok<SAGROW>
        end
        assert(any(strcmp(outcomesSeen, 'complete')), 'the complete outcome must be reachable');
        assert(any(strcmp(outcomesSeen, 'emptyNullspace')), 'the emptyNullspace outcome must be reachable');
        assert(any(strcmp(outcomesSeen, 'badlyScaled')), 'the badlyScaled outcome must be reachable');
        assert(any(strcmp(outcomesSeen, 'incomplete')), 'the incomplete outcome must be reachable');
        assert(numel(unique(outcomesSeen)) >= 4, ...
            'the terminal outcomes must be distinguishable from one another');

        % every call carries a populated status, not only the failing ones
        assert(~isempty(statusEcoli.outcome) && ~isempty(statusEcoli.message) && ...
            islogical(statusEcoli.raysExpectedIsEstimate) && statusEcoli.raysExpectedIsEstimate, ...
            'status must be populated on every call, with raysExpected flagged an estimate');

        % FR-015 / SC-010: the historical two-output call still works unmodified
        [ZposTwo, ZTwo] = greedyExtremeRayBasis(ecoliModel, param);
        assert(full(all(ZposTwo(:) >= 0)), 'two-output call must still return a valid basis');
        assert(~isempty(ZTwo), 'two-output call must still return the linear basis');

        fprintf('Done.\n');
    end
end

% change back to the current directory
cd(currentDir);
