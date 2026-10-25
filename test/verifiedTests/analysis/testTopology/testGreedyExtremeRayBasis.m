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

        % ---- User Story 3: an incomplete basis that admits it is incomplete ----
        %
        % T034 / SC-006 / FR-010. A basis preallocated to its expected height and
        % padded with all-zero rows reads as COMPLETE to any caller that tests only
        % size(Zpos, 1) -- which is exactly what the known downstream guards do. Zero
        % rows are also rank-deficient by construction, so they destroy the rank gap of
        % whatever the basis is spliced into.
        %
        % The impossible-target run above accepted nothing at all, so it is the
        % sharpest case: the expected height is non-zero while the rays found is zero.
        assert(size(ZposStrict, 1) == statusStrict.raysFound, ...
            sprintf(['FR-010: returned %d rows for %d rays actually accepted; the row ' ...
            'count must not overstate the basis'], size(ZposStrict, 1), statusStrict.raysFound));
        assert(statusStrict.raysExpected > statusStrict.raysFound, ...
            'this case must genuinely be incomplete for the assertion above to mean anything');
        assert(isempty(ZposStrict) || all(any(ZposStrict ~= 0, 2)), ...
            'FR-010: no all-zero placeholder row may be returned');
        assert(strcmp(statusStrict.outcome, 'incomplete'), ...
            'an incomplete basis must be reported as incomplete');

        % a caller that inspects ONLY the row count must not be able to mistake this
        % for a complete basis
        assert(size(ZposStrict, 1) ~= statusStrict.raysExpected, ...
            'the row count of an incomplete basis must differ from the expected count');

        % and the same property on a partially-complete run: force early termination
        % with a budget too short to finish, rather than one that finds nothing
        shortParam = param;
        shortParam.maxNewBasisTime = 0.05;
        shortParam.maxTime = 0.05;
        warnState = warning('off', 'greedyExtremeRayBasis:incompleteBasis');
        [ZposShort, ~, statusShort] = greedyExtremeRayBasis(ecoliModel, shortParam);
        warning(warnState);
        assert(size(ZposShort, 1) == statusShort.raysFound, ...
            'FR-010: row count must equal rays found on a time-terminated run too');
        assert(isempty(ZposShort) || all(any(ZposShort ~= 0, 2)), ...
            'FR-010: no all-zero row after early termination');
        if statusShort.raysFound < statusShort.raysExpected
            assert(strcmp(statusShort.outcome, 'incomplete'), ...
                'a time-terminated partial basis must report itself incomplete');
            assert(statusShort.raysExpectedIsEstimate, ...
                'raysExpected must be flagged an estimate, not ground truth');
        end

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

        % ---- User Story 4: parameters and documentation that mean what they say ----

        % T038 / SC-015 / FR-013: the no-argument call that optimalExtremePoolDriver.m:121
        % makes must be DIAGNOSED, not crash on an undefined field.
        bareModel = struct('S', ecoliModel.S);        % deliberately no SConsistentRxnBool
        warnState = warning('off', 'greedyExtremeRayBasis:missingField');
        [ZposBare, ZBare, statusBare] = greedyExtremeRayBasis(bareModel);
        warning(warnState);
        assert(strcmp(statusBare.outcome, 'missingField'), ...
            sprintf('a model without SConsistentRxnBool gave outcome ''%s''', statusBare.outcome));
        assert(isempty(ZposBare) && isempty(ZBare), ...
            'no basis may be returned when a required field is missing');
        assert(strcmp(statusBare.missingFieldName, 'SConsistentRxnBool'), ...
            'the diagnosis must name the missing field');
        assert(~isempty(statusBare.howToObtain), ...
            'the diagnosis must say how to obtain the missing field');

        % T039 / FR-011, FR-012: each time budget governs what its documentation says,
        % and a caller supplying only the per-basis budget is not left with an
        % undefined total budget.
        budgetParam.printLevel = 0;
        budgetParam.maxNewBasisTime = 3;              % deliberately NOT setting maxTime
        warnState = warning('off', 'all');
        [~, ~, statusBudget] = greedyExtremeRayBasis(ecoliModel, budgetParam);
        warning(warnState);
        assert(isfinite(statusBudget.elapsedTime), ...
            'supplying only maxNewBasisTime must not leave the total budget undefined');
        assert(statusBudget.elapsedTime < 60, ...
            'the total budget must bound the run when only maxNewBasisTime was supplied');

        % a total budget shorter than the per-basis budget must be the binding one
        totalParam = param;
        totalParam.maxNewBasisTime = 600;
        totalParam.maxTime = 2;
        warnState = warning('off', 'all');
        [~, ~, statusTotal] = greedyExtremeRayBasis(illModel, totalParam);
        warning(warnState);
        assert(statusTotal.elapsedTime < 60, 'param.maxTime must bound the total run');

        % T041 / SC-013 / FR-020: the same contract in the RIGHT nullspace mode.
        % F2 is 3 x 2, so its right nullspace is empty while its left nullspace is not;
        % F2 transposed exercises the mirror case with a non-empty right nullspace.
        rightParam = param;
        rightParam.leftRight = 'right';
        rightModel = struct('S', F2.S', 'SConsistentRxnBool', true(size(F2.S', 2), 1));
        [ZposRight, ~, statusRight] = greedyExtremeRayBasis(rightModel, rightParam);
        assert(strcmp(statusRight.nullspaceSide, 'right'), ...
            'the status must record which nullspace was requested');
        assert(full(all(ZposRight(:) >= 0)), 'non-negativity must hold in right mode too');
        assert(isfield(statusRight, 'accuracyTarget') && isfinite(statusRight.accuracyTarget), ...
            'the accuracy target must be derived in right mode too');
        assert(~strcmp(statusRight.regime, 'notAssessed'), ...
            'the regime must be classified in right mode too');
        % right mode returns the transpose, so the basis multiplies on the other side
        assert(norm(rightModel.S * ZposRight, inf) < tolExact, ...
            'the right-nullspace basis must annihilate S from the right');

        % ---- Coverage feature: 20260915-082551-extreme-ray-coverage ----

        % T007 / SC-011: the paired-comparison instrumentation is INERT when off.
        % Measurement apparatus that perturbs what it measures is worthless, so this is
        % asserted rather than assumed.
        rng(20260915, 'twister');
        [Zoff, ~, statusOff] = greedyExtremeRayBasis(ecoliModel, param);
        instrParam = param;
        instrParam.compareSolvers = {};
        rng(20260915, 'twister');
        [Zempty, ~, statusEmpty] = greedyExtremeRayBasis(ecoliModel, instrParam);
        assert(isequal(Zoff, Zempty), ...
            'SC-011: an empty compareSolvers must give an identical basis');
        assert(statusOff.raysFound == statusEmpty.raysFound, ...
            'SC-011: an empty compareSolvers must give an identical ray count');
        assert(isempty(statusOff.pairedComparison), ...
            'SC-011: no paired record may be produced when the comparison is off');

        % T021 / SC-001 / FR-001: complete AND accurate in one call.
        %
        % Coverage is decided by the OBJECTIVE, not the solver: for a random objective
        % this LP has a unique optimum, so no solver setting can change which vertex is
        % returned. When random draws stall, the search aims the objective at the part
        % of the nullspace it has not yet spanned.
        assert(statusOff.raysFound == statusOff.raysExpected, ...
            sprintf('SC-001: found %d of %d rays', statusOff.raysFound, statusOff.raysExpected));
        assert(statusOff.residualAbsolute <= statusOff.accuracyTarget, ...
            'SC-001: the complete basis must also meet the derived accuracy target');
        assert(strcmp(statusOff.outcome, 'complete'), ...
            'SC-001: a complete accurate basis must be reported as complete');
        assert(full(all(Zoff(:) >= 0)), 'coverage must not be bought at the cost of non-negativity');

        % T022 / SC-002: the augmented matrix has one unambiguous rank
        Scov = ecoliModel.S;
        nMetCov = size(Scov, 1);
        Mcov = [Scov, -speye(nMetCov); sparse(size(Zoff, 1), size(Scov, 2)), Zoff];
        structuralRankCov = size(Mcov, 1) - size(Zoff, 1);
        sCov = svd(full(Mcov));
        ranksCov = arrayfun(@(t) sum(sCov > t * sCov(1)), tolRankSpan);
        assert(all(ranksCov == structuralRankCov), ...
            sprintf('SC-002: augmented rank %s, expected %d everywhere', ...
            mat2str(ranksCov), structuralRankCov));

        % T028 / SC-005 / FR-005, FR-006: a STRUCTURAL shortfall is reported as such,
        % against the ATTAINABLE dimension rather than the nullity.
        %
        % G1 is stoichiometrically inconsistent by construction: one reaction creates
        % mass from nothing, so its left-nullspace direction needs opposite signs and is
        % unreachable with non-negative weights. No amount of searching can find it.
        G1.S = sparse([1, -1;
                       1, 0;
                       0, 1]);
        G1.SConsistentRxnBool = true(size(G1.S, 2), 1);
        warnState = warning('off', 'all');
        [ZG1, ~, statusG1] = greedyExtremeRayBasis(G1, param);
        warning(warnState);
        assert(full(all(ZG1(:) >= 0)), 'non-negativity must hold on the inconsistent fixture');
        assert(any(strcmp(statusG1.shortfallKind, {'none', 'sampling', 'structural', 'notAssessed'})), ...
            'shortfallKind must be one of the four defined values');
        if statusG1.raysFound < statusG1.raysExpected
            assert(strcmp(statusG1.shortfallKind, 'structural'), ...
                sprintf(['FR-005: a stoichiometrically inconsistent input must give a ' ...
                'structural shortfall, got ''%s'''], statusG1.shortfallKind));
            assert(statusG1.attainableDimension <= statusG1.raysExpected, ...
                'FR-006: the attainable dimension may not exceed the nullity');
            assert(statusG1.attainableDimensionAssessed, ...
                'FR-006: a structural verdict must be assessed, not assumed');
        end

        % T029 / SC-005: a SAMPLING shortfall is classified distinctly from a structural
        % one. Forced by an impossible accuracy target on an input whose directions ARE
        % all reachable, so nothing is accepted although nothing is unreachable. F1 is
        % used rather than ecoli_core: ecoli_core's full S carries exchange reactions, so
        % it has no strictly positive conservation vector, and it makes a poor probe of
        % the sampling case.
        samplingModel = struct('S', F1.S, 'SConsistentRxnBool', true(size(F1.S, 2), 1));
        samplingParam = param;
        samplingParam.feasTol = -1;
        samplingParam.maxNewBasisTime = 5;
        warnState = warning('off', 'all');
        [~, ~, statusSampling] = greedyExtremeRayBasis(samplingModel, samplingParam);
        warning(warnState);
        assert(statusSampling.raysFound < statusSampling.raysExpected, ...
            'this case must genuinely fall short for the classification to mean anything');
        assert(strcmp(statusSampling.shortfallKind, 'sampling'), ...
            sprintf(['FR-005: a consistent input must give a sampling shortfall, ' ...
            'got ''%s'''], statusSampling.shortfallKind));
        assert(~strcmp(statusSampling.shortfallKind, statusG1.shortfallKind) || ...
            statusG1.raysFound == statusG1.raysExpected, ...
            'FR-005: sampling and structural shortfalls must be distinguishable');

        % ---- Stall feature: 20261003-132730-greedy-recon3d-stall ----

        % T007 / US1 / FR-001, FR-002, FR-003: a ray is judged, and returned, as the
        % solver computed it, not after findExtremePool zeroes its entries below
        % 10*feasTol. On Recon3D that truncation turned exact vertices (residual
        % <= 3e-16) into rejected ones (~1.6e-4), and the search stalled at 237 of 251.
        %
        % ecoli_core does not exhibit it as shipped: its rays have no entries that
        % small. Rescaling one conserved metabolite's row is a change of units: it
        % divides that metabolite's entry in every conservation vector by the same
        % factor and leaves the nullspace structure intact, which reproduces the
        % mechanism. Measured before the fix: 7 of 11 rays, 1814 accuracy rejections.
        [~, ~, ~, ~, ~, ~, ecoliConsistent] = findStoichConsistentSubset(ecoli.model, 0, 0);
        Sinternal = ecoliConsistent.S(:, ecoliConsistent.SConsistentRxnBool);
        linearLeftBasis = getNullSpace(Sinternal', 0);
        % the metabolite present in the most nullspace directions, chosen
        % programmatically so the test does not depend on a metabolite name
        [~, iRescaled] = max(sum(abs(linearLeftBasis) > 1e-9, 1));
        Srescaled = Sinternal;
        Srescaled(iRescaled, :) = Srescaled(iRescaled, :)*2e5;
        rescaledModel = struct('S', Srescaled, 'SConsistentRxnBool', true(size(Srescaled, 2), 1));
        rescaledParam = param;
        rescaledParam.internalStoichiometriMatrixLeftNullspace = 1;
        rescaledParam.maxTime = 60;
        rng(20261003, 'twister');
        warnState = warning('off', 'greedyExtremeRayBasis:incompleteBasis');
        [ZposRescaled, ~, statusRescaled] = greedyExtremeRayBasis(rescaledModel, rescaledParam);
        warning(warnState);
        assert(strcmp(statusRescaled.regime, 'wellScaled'), ...
            'the rescaled fixture must stay well scaled, or it tests the wrong regime');
        assert(strcmp(statusRescaled.outcome, 'complete'), ...
            sprintf(['FR-001: rescaled ecoli_core gave %d of %d rays (%s), with %d ' ...
            'accuracy rejections'], statusRescaled.raysFound, statusRescaled.raysExpected, ...
            statusRescaled.outcome, statusRescaled.raysRejectedForAccuracy));
        assert(statusRescaled.raysRejectedForAccuracy == 0, ...
            sprintf(['FR-002: %d exact rays were rejected for accuracy; post-solve ' ...
            'processing must not manufacture accuracy failures'], ...
            statusRescaled.raysRejectedForAccuracy));
        assert(all(full(max(abs(ZposRescaled*Srescaled), [], 2)) <= statusRescaled.acceptanceTarget), ...
            'FR-016: every returned row must meet the acceptance target');
        assert(full(min(ZposRescaled(:))) >= 0, 'FR-003: non-negativity is exact');
        assert(any(ZposRescaled(:) > 0 & ZposRescaled(:) < 1e-5), ...
            ['the fixture must contain the legitimately tiny entries that truncation ' ...
            'used to destroy, or it does not test FR-002']);

        % the same in the right-nullspace mode (spec edge case: identical behaviour)
        rightRescaledParam = rescaledParam;
        rightRescaledParam.leftRight = 'right';
        rightRescaledParam.internalStoichiometriMatrixLeftNullspace = 0;
        rightRescaledModel = struct('S', Srescaled', 'SConsistentRxnBool', true(size(Srescaled, 1), 1));
        rng(20261003, 'twister');
        warnState = warning('off', 'greedyExtremeRayBasis:incompleteBasis');
        [ZposRightRescaled, ~, statusRightRescaled] = greedyExtremeRayBasis(rightRescaledModel, rightRescaledParam);
        warning(warnState);
        assert(strcmp(statusRightRescaled.outcome, 'complete') && ...
            statusRightRescaled.raysFound == statusRescaled.raysFound && ...
            statusRightRescaled.raysRejectedForAccuracy == 0, ...
            sprintf('right mode must behave identically: %d of %d rays, %d accuracy rejections', ...
            statusRightRescaled.raysFound, statusRightRescaled.raysExpected, ...
            statusRightRescaled.raysRejectedForAccuracy));
        assert(all(full(max(abs(rightRescaledModel.S*ZposRightRescaled), [], 1)) <= ...
            statusRightRescaled.acceptanceTarget), ...
            'right mode: every returned column must meet the acceptance target');

        % T008 / US1 / FR-004: an accuracy rejection counts toward the stall
        % detection, so a run of them escalates exactly as a run of dependence failures
        % does. Before the fix the targeted objective could never fire on accuracy
        % failures (Recon3D: nTargetedObjectives = 0 after 884 rejections).
        assert(isfield(statusStrict, 'nStallEscalations') && statusStrict.nStallEscalations > 0, ...
            'FR-004: a run that rejects every candidate for accuracy must escalate');
        assert(isfield(statusRescaled, 'nStallEscalations') && ...
            statusRescaled.nStallEscalations >= 0 && ...
            statusRescaled.nStallEscalations == round(statusRescaled.nStallEscalations), ...
            'nStallEscalations must be a non-negative count on a complete run');
        % the field exists on every return path
        emptyModel = struct('S', ecoliModel.S, 'SConsistentRxnBool', false(size(ecoliModel.S, 2), 1));
        [~, ~, statusEmptyPath] = greedyExtremeRayBasis(emptyModel, param);
        assert(strcmp(statusEmptyPath.outcome, 'emptyNullspace'), ...
            'no consistent reaction must take the emptyNullspace early return');
        for earlyStatus = {statusBad, statusBare, statusEmptyPath}
            assert(isfield(earlyStatus{1}, 'nStallEscalations') && ...
                earlyStatus{1}.nStallEscalations == 0, ...
                sprintf('the ''%s'' return must carry nStallEscalations = 0', earlyStatus{1}.outcome));
        end

        % T015 / US2 / FR-008, FR-009: the attainable dimension is the dimension of
        % the subspace reachable with non-negative weights, which needs the MAXIMAL
        % support of the non-negative cone. Maximising sum(y) with y <= 1 does not
        % give it. F4's cone has extreme rays (1,1,0) and (0,2,1); that LP prefers
        % (1,1,0) (sum 2 beats 1.5), so it excluded metabolite 3, which is reachable,
        % and reported 1 instead of 2. On Recon3D the same defect reported 237 of 251
        % and a false 'structural' verdict.
        F4 = struct('S', sparse([1; -1; 2]), 'SConsistentRxnBool', true);
        shortfallParam = param;
        shortfallParam.feasTol = -1;              % forces a shortfall, so it is classified
        shortfallParam.maxNewBasisTime = 2;
        shortfallParam.maxTime = 2;
        warnState = warning('off', 'greedyExtremeRayBasis:incompleteBasis');
        [~, ~, statusF4] = greedyExtremeRayBasis(F4, shortfallParam);
        warning(warnState);
        assert(statusF4.raysFound < statusF4.raysExpected, ...
            'F4 must genuinely fall short for its classification to mean anything');
        assert(statusF4.attainableDimensionAssessed, 'FR-008: the attainable dimension must be assessed');
        assert(statusF4.attainableDimension == 2 && statusF4.raysExpected == 2, ...
            sprintf(['FR-008: F4''s whole nullspace is reachable with non-negative ' ...
            'weights, so the attainable dimension is 2, got %d'], statusF4.attainableDimension));
        assert(strcmp(statusF4.shortfallKind, 'sampling'), ...
            sprintf('FR-008: F4''s shortfall is sampling, got ''%s''', statusF4.shortfallKind));
        % FR-009: an input whose direction needs opposite signs still reads structural,
        % now with its true attainable dimension
        if statusG1.raysFound < statusG1.raysExpected
            assert(statusG1.attainableDimension == 0, ...
                sprintf(['FR-009: no non-negative vector annihilates G1, so its ' ...
                'attainable dimension is 0, got %d'], statusG1.attainableDimension));
        end

        % T018 / US3 / FR-006, FR-007: the size ceiling for the dense spectrum is a
        % parameter, and its cost is reported. Recon3D's operative matrix (5.09e7
        % elements) sat just above the old hard-coded 5e7, which silently replaced the
        % derived target with a 13-times stricter fallback and left the regime
        % unassessed. A small matrix exercises both sides of the ceiling.
        assert(isfield(statusRescaled, 'spectrumTime') && statusRescaled.accuracyTargetDerived && ...
            statusRescaled.spectrumTime >= 0, ...
            'FR-006: the default ceiling must derive the target and report the spectrum cost');
        fallbackParam = rescaledParam;
        fallbackParam.maxElementsForSpectrum = 1;
        rng(20261003, 'twister');
        warnState = warning('off', 'greedyExtremeRayBasis:incompleteBasis');
        [ZposFallback, ~, statusFallback] = greedyExtremeRayBasis(rescaledModel, fallbackParam);
        warning(warnState);
        assert(~statusFallback.accuracyTargetDerived && strcmp(statusFallback.regime, 'notAssessed'), ...
            'FR-007: above the ceiling the documented fallback must apply and say so');
        assert(statusFallback.spectrumTime == 0, 'no spectrum cost may be reported when none was incurred');
        assert(~isempty(ZposFallback) && ...
            all(full(max(abs(ZposFallback*Srescaled), [], 2)) <= statusFallback.acceptanceTarget), ...
            'FR-007: the fallback must still return a basis that meets its own target');
        % the field exists on every return path
        for earlyStatus = {statusBad, statusBare, statusEmptyPath}
            assert(isfield(earlyStatus{1}, 'spectrumTime') && earlyStatus{1}.spectrumTime >= 0, ...
                sprintf('the ''%s'' return must carry spectrumTime', earlyStatus{1}.outcome));
        end

        % FR-015 / SC-010: the historical two-output call still works unmodified
        [ZposTwo, ZTwo] = greedyExtremeRayBasis(ecoliModel, param);
        assert(full(all(ZposTwo(:) >= 0)), 'two-output call must still return a valid basis');
        assert(~isempty(ZTwo), 'two-output call must still return the linear basis');

        fprintf('Done.\n');
    end
end

% change back to the current directory
cd(currentDir);
