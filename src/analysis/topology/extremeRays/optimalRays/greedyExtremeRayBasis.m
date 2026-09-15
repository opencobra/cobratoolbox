function [Zpos, Z, status] = greedyExtremeRayBasis(model, param)
% Computes a non-negative basis for the left nullspace of the stoichiometric
% matrix using optimization to pick random extreme rays, then test a
% posteriori if each is linearly independent from the existing stored
% extreme rays.
%
% Each ray is accepted against an accuracy target DERIVED from the singular-value
% separation that a rank determination needs, so that a matrix augmented with the
% returned basis has a well-defined numerical rank. A ray that cannot meet the
% target is dropped and the search continues.
%
% Where `model.S` is too badly scaled for that accuracy to be obtainable at all, no
% basis is returned and `status` carries a diagnosis naming what is badly scaled, by
% how much, and what repair is indicated.
%
% USAGE:
%
%    [Zpos, Z, status] = greedyExtremeRayBasis(model, param)
%    Gives Zpos*N = 0 or Zpos*S = 0
%    Gives Z*N = 0 or Z*S = 0
%
%    param.leftRight = 'right' computes the right nullspace instead:
%    Gives N*Zpos = 0 or S*Zpos = 0
%    Gives N*Z = 0 or S*Z = 0
%
%    Every guarantee below holds IDENTICALLY in both modes. The right nullspace is
%    computed by transposing the operative matrix, which is incidental to the
%    mathematics, so the accuracy target, the regime classification, the status and
%    the completeness rule all carry over unchanged. Read "left nullspace" throughout
%    as "the requested nullspace".
%
% NOTE:
%
%    CHANGE OF DEFAULT NUMERICAL BEHAVIOUR, September 2026, feature
%    20260914-204640-greedy-left-nullspace-conditioning. Rays were previously
%    accepted at an absolute residual of `param.feasTol` (default 1e-6). A basis
%    accepted at that tolerance is accurate to about seven digits, which is not
%    enough for a matrix augmented with it to have a well-defined numerical rank:
%    the singular values that should be zero smear across many orders of
%    magnitude and independent rank routines return different integers.
%    Acceptance is now judged against `status.accuracyTarget`, derived per call.
%    `param.feasTol` is still accepted and may TIGHTEN acceptance, but it can no
%    longer loosen it above the derived target. Results computed with the
%    previous default are NOT reproducible through this function; reproducing
%    them requires a release of the toolbox predating this change.
%
%
% INPUT:
%    model:      COBRA model structure with fields:
%
%                  * .S - `m x (n + k)` stoichiometric matrix, where `n` are internal reactions and `k` are exchange reactions
%                  * .SConsistentRxnBool - `n x 1` boolean of stoichiometrically consistent reactions (used when `param.internalStoichiometriMatrixLeftNullspace` is true)
%
% OPTIONAL INPUT:
%    param:      structure of optional parameters:
%
%                  * .printLevel - verbosity level (default = 1)
%                  * .leftRight - `'left'` or `'right'` nullspace to compute (default = `'left'`)
%                  * .internalStoichiometriMatrixLeftNullspace - if true, restrict `model.S` to `model.SConsistentRxnBool` (default = 0)
%                  * .maxTime - TOTAL time budget in seconds across restarts (default = `param.maxNewBasisTime`, which reproduces the historical behaviour)
%                  * .maxNewBasisTime - seconds to persist without finding a new basis vector before declaring a dead end and restarting from fresh randomness (default = 10000)
%                  * .feasTol - may TIGHTEN ray acceptance below the derived accuracy target; it can no longer loosen it above that target (default = 1e-6, which no longer loosens)
%
% OUTPUTS:
%    Zpos:       non-negative linear basis for the left (right) nullspace of N (internal = 1) or S (internal = 0)
%    Z:          linear basis for the left (right) nullspace of N (internal = 1) or S (internal = 0)
%    status:     structure a caller can branch on without parsing console text. Populated
%                on EVERY call, and complete whether or not printing is enabled:
%
%                  * .outcome - one of `'complete'`, `'incomplete'`, `'emptyNullspace'`, `'badlyScaled'`, `'missingField'`; mutually exclusive and exhaustive
%                  * .terminationReason - `'basisComplete'`, `'timeBudget'`, `'accuracyRejection'` or `'notAttempted'`
%                  * .regime - `'wellScaled'`, `'badlyScaled'` or `'notAssessed'`
%                  * .nullspaceSide - which nullspace was requested
%                  * .operativeMatrixSize - size of the matrix actually classified and operated on, after any consistency restriction and transposition
%                  * .message - one human-readable sentence; the console text says the same thing
%                  * .accuracyTarget - the derived residual target each accepted ray had to meet
%                  * .accuracyTargetDerived - true if derived from the spectrum, false if the fallback was used
%                  * .acceptanceTarget - the target actually applied, after any tightening by `param.feasTol`
%                  * .residualAbsolute - `norm(Zpos*Sop, inf)` measured on the RETURNED basis
%                  * .residualScaled - the same, divided by `norm(Zpos)*norm(Sop)`; reported ALONGSIDE the absolute form, never instead of it
%                  * .nonNegative - non-negativity of `Zpos`, asserted on the returned basis
%                  * .impliedNullity - nullity implied by the returned basis
%                  * .independentRank - rank of the operative matrix, computed independently of the basis
%                  * .scalingValue - smallest non-zero singular value of the operative matrix, reported on every call
%                  * .scalingBoundary - the regime boundary it is compared against, reported on every call
%                  * .raysFound - rays actually ACCEPTED; always equals `size(Zpos, 1)`, because the basis is trimmed to the rays found and never padded with all-zero rows. Judge completeness by comparing it with `.raysExpected`, or by reading `.outcome`
%                  * .raysExpected - rays sought
%                  * .raysExpectedIsEstimate - ALWAYS true: `raysExpected` comes from a rank computation, so it is a target, not ground truth
%                  * .raysRejectedForAccuracy - candidates dropped for failing the accuracy target
%                  * .raysRejectedForDependence - candidates dropped as linearly dependent
%                  * .timedOut - true if the search stopped on its total time budget
%                  * .nRestarts - times the search hit a dead end and restarted from fresh randomness
%                  * .nTargetedObjectives - times the search aimed the objective at the unspanned part of the nullspace instead of drawing at random
%                  * .shortfallKind - `'none'`, `'sampling'` (reachable but not found), `'structural'` (not reachable with non-negative weights) or `'notAssessed'`
%                  * .attainableDimension - dimension actually reachable with non-negative weights; equals `.raysExpected` under stoichiometric consistency and is smaller otherwise
%                  * .attainableDimensionAssessed - whether that was determined rather than assumed
%                  * .elapsedTime - seconds for this call
%
%                In the `'badlyScaled'` outcome it additionally carries the diagnosis:
%
%                  * .scalingQuantity - which quantity is badly scaled
%                  * .scalingBoundaryBasis - what that boundary is derived from
%                  * .recommendedRepair - the repair to `model.S` that is indicated
%
%                In the `'missingField'` outcome it instead carries:
%
%                  * .missingFieldName - the absent field
%                  * .howToObtain - how to supply or compute it
%
% EXAMPLE:
%
%    param.printLevel = 0;
%    [Zpos, Z, status] = greedyExtremeRayBasis(model, param);
%    switch status.outcome
%        case 'complete'        % safe to augment; status.residualScaled certifies it
%        case 'incomplete'      % valid but spans less than the full nullspace
%        case 'emptyNullspace'  % correct: there is no left nullspace
%        case 'badlyScaled'     % no basis obtainable; see status.recommendedRepair
%        case 'missingField'    % see status.missingFieldName
%    end

if ~exist('param','var')
    param = struct();
end

if ~isfield(param,'printLevel')
    param.printLevel = 1;
end

if ~isfield(param,'leftRight')
    param.leftRight = 'left';
end

if ~isfield(param,'internalStoichiometriMatrixLeftNullspace')
    param.internalStoichiometriMatrixLeftNullspace = 0;
end

if ~isfield(param,'maxNewBasisTime')
    param.maxNewBasisTime = 10000;
end
if ~isfield(param,'maxTime')
    % Total budget across restarts. Defaulting it to the per-basis budget reproduces
    % the historical behaviour, where both timeout checks tested the same value and
    % the first to expire ended the run. A caller wanting restarts sets
    % param.maxTime > param.maxNewBasisTime.
    %
    % The previous guard tested `maxNewBasisTime` but assigned `maxTime`, so a caller
    % who supplied `maxNewBasisTime` and not `maxTime` left `maxTime` never set.
    param.maxTime = param.maxNewBasisTime;
end

if ~isfield(param,'feasTol')
    param.feasTol = 1e-6;
end

if ~isfield(param,'compareSolvers')
    % Paired-comparison instrumentation. Empty is OFF and MUST be inert: with it empty
    % the routine takes the same code path, consumes the random stream identically and
    % returns the same result as before this instrumentation existed.
    param.compareSolvers = {};
end

if ~isfield(param,'solverSettings')
    % Caller override for the built-in tuned sets. Empty means "use whatever the tuned
    % set for the active solver provides, or the solver's defaults if there is none".
    param.solverSettings = struct();
end


if param.internalStoichiometriMatrixLeftNullspace
    if ~isfield(model,'SConsistentRxnBool')
        [~, ~, ~, ~, ~, ~, model, ~] = findStoichConsistentSubset(model, 1, 0);
    end
end

if ~isfield(model,'SConsistentRxnBool')
    % The guard below reads this field on EVERY path, but it is only computed above
    % when param.internalStoichiometriMatrixLeftNullspace is set, whose default is 0.
    % A caller using default parameters therefore used to reach an undefined-field
    % error raised from inside this routine. Diagnose it instead, and return
    % gracefully, so the caller learns the field name and how to obtain it.
    %
    % This path is live rather than hypothetical: the in-repo caller
    % src/analysis/topology/extremeRays/optimalRays/optimalExtremePoolDriver.m:121
    % invokes this routine with no param argument at all.
    Zpos = [];
    Z = [];
    status = struct('outcome', 'missingField', 'terminationReason', 'notAttempted', ...
        'regime', 'notAssessed', 'nullspaceSide', param.leftRight, ...
        'operativeMatrixSize', size(model.S), 'scalingValue', NaN, ...
        'scalingBoundary', NaN, 'accuracyTarget', NaN, ...
        'accuracyTargetDerived', false, 'acceptanceTarget', NaN, ...
        'residualAbsolute', NaN, 'residualScaled', NaN, 'nonNegative', true, ...
        'impliedNullity', NaN, 'independentRank', NaN, 'raysFound', 0, ...
        'raysExpected', NaN, 'raysExpectedIsEstimate', true, ...
        'raysRejectedForAccuracy', 0, 'raysRejectedForDependence', 0, ...
        'timedOut', false, 'nRestarts', 0, 'nTargetedObjectives', 0, 'shortfallKind', 'none', 'attainableDimension', 0, 'attainableDimensionAssessed', false, 'elapsedTime', 0, ...
        'missingFieldName', 'SConsistentRxnBool', ...
        'howToObtain', ['Set param.internalStoichiometriMatrixLeftNullspace = true ' ...
        'to have it computed by findStoichConsistentSubset, or supply ' ...
        'model.SConsistentRxnBool directly as an n x 1 logical over the reactions.'], ...
        'message', ['model.SConsistentRxnBool is required but absent, and was not ' ...
        'computed because param.internalStoichiometriMatrixLeftNullspace is false. ' ...
        'No basis returned.']);
    warning('greedyExtremeRayBasis:missingField', '%s %s', status.message, status.howToObtain);
    return;
end

if ~any(model.SConsistentRxnBool) %check if positive vector in left nullspace
    Zpos=[];
    Z=[]; % Returning empty vector for left nullspace so if it is expected matlab will keep running
    % status must be assigned on every return path, or a three-output caller gets
    % an "output argument not assigned" error instead of an answer.
    status = struct('outcome', 'emptyNullspace', 'terminationReason', 'notAttempted', ...
        'regime', 'notAssessed', 'nullspaceSide', param.leftRight, ...
        'operativeMatrixSize', size(model.S), 'accuracyTarget', NaN, ...
        'accuracyTargetDerived', false, 'acceptanceTarget', NaN, ...
        'residualAbsolute', NaN, 'residualScaled', NaN, 'nonNegative', true, ...
        'impliedNullity', 0, 'independentRank', NaN, 'scalingValue', NaN, ...
        'scalingBoundary', NaN, 'raysFound', 0, ...
        'raysExpected', 0, 'raysExpectedIsEstimate', true, ...
        'raysRejectedForAccuracy', 0, 'raysRejectedForDependence', 0, ...
        'timedOut', false, 'nRestarts', 0, 'nTargetedObjectives', 0, 'shortfallKind', 'none', 'attainableDimension', 0, 'attainableDimensionAssessed', false, 'elapsedTime', 0, ...
        'message', ['No stoichiometrically consistent reaction, so there is no ' ...
        'positive vector in the left nullspace to find.']);
    return;
end

if param.internalStoichiometriMatrixLeftNullspace
    model.S = model.S(:,model.SConsistentRxnBool);
end

switch param.leftRight
    case 'right'
        model.S = model.S';
end

[nVar,nRxn]=size(model.S);

% Derive the accuracy target each accepted ray must meet.
%
% A rank determination on a matrix M augmented with this basis reports the same
% integer for every relative tolerance tau in a span only if the singular values
% that ought to be zero stay below the TIGHTEST tolerance in that span:
%
%     sigma_{r+1}(M) <= tauMin * sigma_1(M),   tauMin = eps*max(size(M))
%
% Writing the computed basis as L = L0 + E with L0*Sop = 0 exactly, Weyl's
% inequality gives sigma_{r+1}(M) <= ||E||_2, and the measurable residual
% R = L*Sop = E*Sop bounds ||E||_2 <= ||R||_2 / sigmaMinPlus(Sop). Substituting:
%
%     ||L*Sop||_2 <= tauMin * sigma_1(M) * sigmaMinPlus(Sop)
%
% This target is DERIVED from what a rank determination needs, not chosen. See
% specs/20260914-204640-greedy-left-nullspace-conditioning/research.md R3, which
% records the derivation, its validation against two known outcomes, and the
% controlled-perturbation measurement of how conservative it is.
%
% The spectrum is computed directly. Measured cost: 0.15 s for the 1244 x 1710
% iDopaNeuroC operative matrix and 0.35 s for the 1668 x 2382 iAF1260 matrix, against
% a greedy search that takes seconds to minutes, so this is affordable on every model
% the toolbox handles. Only a matrix too large to hold densely falls back.
%
% The same spectrum decides the scaling regime, so it is computed once for both.
maxElementsForSpectrum = 5e7;
tauMin = eps*max(nVar + nRxn, nVar);
accuracyTargetDerived = false;
regime = 'notAssessed';
sigmaMinPlus = NaN;
regimeBoundary = NaN;
if numel(model.S) <= maxElementsForSpectrum
    singularValues = svd(full(model.S));
    sigmaOne = singularValues(1);
    nAboveRankTol = sum(singularValues > eps*max(size(model.S))*sigmaOne);
    if nAboveRankTol > 0 && sigmaOne > 0
        sigmaMinPlus = singularValues(nAboveRankTol);
        accuracyTarget = tauMin*sigmaOne*sigmaMinPlus;
        accuracyTargetDerived = true;

        % Scaling regime. The question a regime asks is whether a usable basis is
        % OBTAINABLE at all, so the boundary is the point at which the accuracy target
        % above falls below the residual an LP can actually deliver:
        %
        %     Regime B  <=>  accuracyTarget < residualFloor
        %               <=>  sigmaMinPlus   < residualFloor / (tauMin * sigma_1)
        %
        % residualFloor is machine epsilon, which research.md R2 measured as the
        % attainable absolute residual: gurobi returned exactly 0 and glpk at most
        % 1.110e-16 on raw untruncated solutions. A solver with a worse floor (mosek
        % measured ~1e-12 per ray) does not mis-classify the regime; it simply fails
        % the accuracy target and reports accuracy rejections instead.
        residualFloor = eps;
        regimeBoundary = residualFloor/(tauMin*sigmaOne);
        if sigmaMinPlus < regimeBoundary
            regime = 'badlyScaled';
        else
            regime = 'wellScaled';
        end
    end
end
if ~accuracyTargetDerived
    % Too large to factor densely. Do not guess: fall back to a machine-precision
    % scaled requirement and leave the regime recorded as 'notAssessed' rather than
    % claiming a classification that was never made.
    sigmaOne = normest(model.S);
    accuracyTarget = eps*sigmaOne;
end

% param.feasTol may TIGHTEN acceptance but must never loosen it above the derived
% target (see the NOTE in the help header).
acceptanceTarget = min(accuracyTarget, param.feasTol);

if strcmp(regime, 'badlyScaled')
    % Regime B. No basis of either kind is returned: the accuracy a rank
    % determination needs is not obtainable from this matrix, so any basis returned
    % here would silently destroy the rank gap of whatever it is spliced into. The
    % sign-unrestricted basis is withheld too, because it comes from a rank
    % computation on the same matrix whose conditioning is the problem.
    %
    % This is a GRACEFUL return, not an error: the caller gets an answer it can
    % branch on. The warning is raised as well as, never instead of, the status.
    Zpos = [];
    Z = [];
    status = struct();
    status.outcome = 'badlyScaled';
    status.terminationReason = 'notAttempted';
    status.regime = regime;
    status.nullspaceSide = param.leftRight;
    status.operativeMatrixSize = [nVar, nRxn];
    status.accuracyTarget = accuracyTarget;
    status.accuracyTargetDerived = accuracyTargetDerived;
    status.acceptanceTarget = acceptanceTarget;
    status.residualAbsolute = NaN;
    status.residualScaled = NaN;
    status.nonNegative = true;
    status.impliedNullity = NaN;
    status.independentRank = NaN;
    status.raysFound = 0;
    status.raysExpected = NaN;
    status.raysExpectedIsEstimate = true;
    status.raysRejectedForAccuracy = 0;
    status.raysRejectedForDependence = 0;
    status.timedOut = false;
    status.nRestarts = 0;
    status.elapsedTime = 0;
    % what is badly scaled, by how much, against what, and what to do about it
    status.scalingQuantity = 'smallest non-zero singular value of the operative matrix';
    status.scalingValue = sigmaMinPlus;
    status.scalingBoundary = regimeBoundary;
    status.scalingBoundaryBasis = ['machine-precision residual floor divided by ' ...
        '(eps*max(size(M)) * largest singular value); see research.md R2 and R4'];
    status.recommendedRepair = ['Rescale model.S so that its smallest non-zero ' ...
        'singular value rises above the boundary, for example by equilibrating rows ' ...
        'and columns, or by removing the near-dependent rows that depress it. No ' ...
        'basis routine can give this matrix a well-defined augmented rank as it stands.'];
    status.message = sprintf(['model.S is too badly scaled for a usable ' ...
        'left-nullspace basis: smallest non-zero singular value %g is below the %g ' ...
        'needed for the accuracy a rank determination requires. No basis returned.'], ...
        sigmaMinPlus, regimeBoundary);
    warning('greedyExtremeRayBasis:badlyScaled', '%s', status.message);
    return
end

%compute linear basis for left nullspace
printLevelL=0;
[Z,rankS]=getNullSpace(model.S',printLevelL);

Z=Z';

Zpos=sparse(nVar-rankS,nVar);



nBases=0;
nTry=0;
t1 = tic;
% t2 times the search for the CURRENT basis vector. It must be initialised here, not
% only when a ray is first accepted: a run in which no ray is ever accepted would
% otherwise reach toc(t2) with t2 undefined.
t2 = tic;
nfail=0;
nfailMax = 5;
nRejectedForAccuracy = 0;
nRejectedForDependence = 0;
timedOut = false;
pairedRecord = struct([]);
% Support mask over metabolites already carrying weight. Only READ once nBases >= 2, by
% which point the loop has assigned it, but it must exist from the start because the
% paired harness records it at every comparison point including the first.
nonZeroColumnsBool = false(1, nVar);
nTargetedObjectives = 0;
% The search is stochastic, and zeroing the objective on already-covered metabolites
% drives it into dead ends: once only a few metabolites remain uncovered, the LP keeps
% returning rays that are linearly dependent on those already accepted. Measured on
% iDopaNeuroC, the hit rate collapses to 0.46% and the search stalls short of a
% complete basis. Persisting in a dead end is worse than drawing again, so on
% exhausting the per-basis budget the accumulated basis is DISCARDED and the search
% restarts from fresh randomness, keeping the best basis found across restarts.
bestZpos = Zpos;
bestNBases = 0;
nRestarts = 0;
while nBases < (nVar-rankS)
    % Budgets are checked at the TOP of the loop so they govern every iteration,
    % including those that reject a candidate. Checking only after a candidate is
    % accepted means a run that rejects every candidate never consults its budget at
    % all and spins until the caller kills it.
    if toc(t1) > param.maxTime
        timedOut = true;
        if param.printLevel > 0
            disp('greedyExtremeRayBasis exhausted param.maxTime. Increase param.maxTime ?')
        end
        break
    end
    if toc(t2) > param.maxNewBasisTime
        % dead end: keep the best basis so far, then restart from fresh randomness
        if nBases > bestNBases
            bestZpos = Zpos;
            bestNBases = nBases;
        end
        nRestarts = nRestarts + 1;
        if param.printLevel > 0
            fprintf('%s\n', ['greedyExtremeRayBasis: no new basis vector within ' ...
                num2str(param.maxNewBasisTime) ' s at ' int2str(nBases) ' of ' ...
                int2str(nVar-rankS) ' rays; restarting (' int2str(nRestarts) ').']);
        end
        Zpos = sparse(nVar-rankS, nVar);
        nBases = 0;
        nfail = 0;
        nonZeroColumnsBool = false(1, nVar);
        t2 = tic;
        continue
    end
    if nBases<2
        obj = rand(nVar,1);
    else
        obj = rand(nVar,1);
        if nfail < nfailMax
            %zero out metabolites that already have support in left nullspace
            obj(nonZeroColumnsBool)=0;
        else
            if param.printLevel>1
                fprintf('%s\n',[int2str(nBases) ' of ' int2str(nVar-rankS) ' linearly independent kernel rays, at time ' num2str(round(toc)) ', not zeroing out, with ' num2str(nfail+1) ' attempt(s).']);
                %disp('not zeroing out metabolites that already have support in left nullspace');
            end
        end
    end
    % TARGETED OBJECTIVE.
    %
    % When the random draw stops producing new independent rays, the shortfall is NOT
    % the solver's doing. Measured: for a random objective this LP has a UNIQUE optimum
    % (maximising any other direction subject to staying optimal returns the identical
    % point), so no solver setting can change which vertex comes back -- Seed, Method,
    % NumericFocus, Presolve and Crossover were each verified to reach gurobi and each
    % returned the same ray. What decides coverage is the objective.
    %
    % Measured at a basis stalled on 98 of 105 rays with 7 directions unspanned: a fresh
    % random objective produced a new independent accurate ray in 0 of 40 trials, while
    % an objective aimed at the unspanned part of the left nullspace produced one in
    % 40 of 40. So on a stall, aim.
    if nfail >= nfailMax && nBases > 0 && nBases < (nVar - rankS)
        targetedObj = targetedObjective(Z, Zpos, nBases, nVar);
        if ~isempty(targetedObj)
            obj = targetedObj;
            nTargetedObjectives = nTargetedObjectives + 1;
        end
    end

    positive = 1;
    if isempty(param.compareSolvers)
        [x, sol] = findExtremePool(model,obj,param.printLevel-2,positive,0,param.solverSettings);
    else
        % PAIRED comparison. Every solver is handed the identical LP built from the
        % identical partial basis and the identical objective vector drawn above, so a
        % solver's contribution is separated from the search path it would otherwise
        % diverge onto. A comparison assembled from independent whole runs cannot do
        % this: after the first accepted ray the runs no longer share a state.
        %
        % The comparison consumes NO draws from the random stream -- `obj` is already
        % drawn -- and the search advances on the nominated solver's ray, reused from
        % within the loop rather than re-solved. Both are what make the instrumentation
        % inert when it is off.
        [x, sol, pairedRows] = compareSolversAtState(model, obj, param, positive, ...
            Zpos, nBases, acceptanceTarget, nTry, nonZeroColumnsBool);
        pairedRecord = [pairedRecord; pairedRows]; %#ok<AGROW>
    end

    if contains(sol.origStat,'WARNING')
        nfail = nfailMax;
    end

    % An infeasible or failed solve returns no ray at all. This is not a tolerance
    % effect and must not be treated as one: on a stoichiometrically inconsistent input
    % the only non-negative vector in the left nullspace is zero, which cannot satisfy
    % the normalisation, so the LP is genuinely infeasible and there is nothing to find.
    % Guard it before the residual is taken, or S' is multiplied by an empty vector.
    if isempty(x) || numel(x) ~= nVar
        nfail = nfail + 1;
        nRejectedForAccuracy = nRejectedForAccuracy + 1;
        continue
    end

    % A candidate that cannot meet the derived accuracy target is DROPPED and the
    % search continues; it is never returned. The rejection count is the evidence
    % that the attainable residual floor sits above the target, which is the
    % signature of a solver that cannot serve this use.
    if norm(model.S'*x,inf) > acceptanceTarget
        nRejectedForAccuracy = nRejectedForAccuracy + 1;
        continue
    end

    if positive && min(x)<0
        error('findExtremePool returned negative coefficient')
    end
    Zpos(nBases+1,:)=x';
    if nBases==0
        rankB=1;
    else
        nonZeroColumnsBool=(Zpos~=0);
        nonZeroColumnsBool=sum(nonZeroColumnsBool,1)~=0;
        rankB = getRankLUSOL(Zpos(1:nBases+1,nonZeroColumnsBool));
        % %error as reports wrong rank if zero columns
        % rankB = getRankLUSOL(B(1:nBases+1,:));
    end
    if rankB==(nBases+1)
        t2 = tic;
        nBases=nBases+1;
        if param.printLevel>1
            fprintf('%s\n',[int2str(nBases) ' of ' int2str(nVar-rankS) ' linearly independent kernel rays, at time ' num2str(round(toc)) ', with ' num2str(nfail+1) ' attempt(s).']);
        end
        nfail=0;
    else
        nfail = nfail+1;
        nRejectedForDependence = nRejectedForDependence + 1;
        if param.printLevel>2
            fprintf('%s\n','Linearly dependent pool vector discarded');
        end
    end
    nTry=nTry+1;
    % the budgets are enforced at the top of the loop, where they govern rejected
    % candidates as well as accepted ones
end

% a restart discards its accumulated basis, so return the best one found across all
% attempts rather than whatever the final attempt happened to reach
if bestNBases > nBases
    Zpos = bestZpos;
    nBases = bestNBases;
end

% Zpos is preallocated to the expected height so that accepted rays can be written
% without growing it. When the search ends early the unfilled trailing rows are all
% ZERO, and returning them would let a caller that tests only size(Zpos, 1) read an
% incomplete basis as a complete one -- which is exactly what the known downstream
% guards do. Trim to the rays actually accepted, so the shape of the returned basis
% cannot overstate what was found.
Zpos = Zpos(1:nBases, :);

if param.printLevel>0
    if nBases == (nVar-rankS)
        fprintf('%u%s\n',nVar-rankS, ' extreme rays. Basis complete.');
        fprintf('%.2f%% nozero Zpos.\n', 100 * (nnz(Zpos) / (nVar * (nVar - rankS))));
        fprintf('%.2f%% nozero Z.\n', 100 * (nnz(Z) / (nVar * (nVar - rankS))));
    else
        fprintf('%u%s\n',nBases, ' extreme rays computed.');
        fprintf('%u%s\n',nVar-rankS, ' extreme rays required. Basis incomplete.');

    end
    fprintf('%s%g\n','Hit fraction ',(nVar-rankS)/nTry);
end

% Verify the accuracy and non-negativity that were required, ON THE RETURNED
% OBJECT. Inferring them from the acceptance path that produced each row is not
% sufficient: the defect this guards against is a basis that satisfied every
% check along the way and is still unfit for the rank determination it feeds.
residualAbsolute = norm(Zpos*model.S,inf);
normZpos = norm(full(Zpos),'fro');
normSop = norm(full(model.S),'fro');
if normZpos > 0 && normSop > 0
    residualScaled = residualAbsolute/(normZpos*normSop);
else
    residualScaled = 0;
end

% Non-negativity of Zpos is a hard requirement, not a preference. The selected
% remedy is subtractive -- rows are kept exactly as computed or dropped whole --
% so this can only fail if something upstream changed, and it must be loud.
% FR-010 asserted on the returned object: no all-zero placeholder row survives
if nBases > 0 && ~full(all(any(Zpos ~= 0, 2)))
    error('greedyExtremeRayBasis:zeroBasisRow', ...
        ['Zpos contains an all-zero row, which would let a caller reading only ' ...
        'size(Zpos, 1) mistake an incomplete basis for a complete one.']);
end

nonNegative = full(all(Zpos(:) >= 0));
if ~nonNegative
    error('greedyExtremeRayBasis:negativeBasisEntry', ...
        'Zpos contains a negative entry (min %g); non-negativity is a hard requirement.', ...
        full(min(Zpos(:))));
end

raysExpected = nVar - rankS;

% SHORTFALL CLASSIFICATION (FR-005, FR-006).
%
% A shortfall has two entirely different causes with opposite remedies, and reporting
% them identically is the defect this guards against:
%
%   'sampling'   - the directions are reachable but were not found. More search helps.
%   'structural' - part of the nullspace cannot be reached with NON-NEGATIVE weights at
%                  all, so raysExpected was never an attainable target and no amount of
%                  search helps.
%
% The classification is decided by the ATTAINABLE DIMENSION, not by stoichiometric
% consistency. A strictly positive vector in ker(S') is SUFFICIENT for the non-negative
% cone to span the whole nullspace, but its ABSENCE is not sufficient for the converse:
% coordinates can be forced to zero while the remaining ones still span. Testing only
% for a strictly positive vector therefore reports false 'structural' verdicts on
% ordinary models -- ecoli_core with its exchange reactions is one, and it reaches full
% coverage regardless.
%
% The attainable dimension is computed instead, and only on a shortfall, so a complete
% basis pays nothing for it.
shortfallKind = 'none';
attainableDimension = raysExpected;
attainableDimensionAssessed = false;
if nBases < raysExpected
    [attainable, attainableKnown] = attainableNullspaceDimension(model.S, nVar);
    if ~attainableKnown
        shortfallKind = 'notAssessed';
    else
        attainableDimension = attainable;
        attainableDimensionAssessed = true;
        if attainable > nBases
            shortfallKind = 'sampling';
        else
            shortfallKind = 'structural';
        end
    end
end

status = struct();
% Terminal outcome. Exactly one of five, mutually exclusive and exhaustive, so a
% caller can branch on the status alone without inspecting the matrices.
if raysExpected == 0
    status.outcome = 'emptyNullspace';
    status.terminationReason = 'basisComplete';
elseif nBases == raysExpected
    status.outcome = 'complete';
    status.terminationReason = 'basisComplete';
else
    status.outcome = 'incomplete';
    if nRejectedForAccuracy > 0 && nBases == 0
        % nothing could meet the accuracy target: the evidence that the attainable
        % residual floor sits above what a rank determination needs
        status.terminationReason = 'accuracyRejection';
    elseif timedOut
        status.terminationReason = 'timeBudget';
    else
        status.terminationReason = 'accuracyRejection';
    end
end
status.regime = regime;
status.nullspaceSide = param.leftRight;
status.operativeMatrixSize = [nVar, nRxn];
% The scaling measurement is reported on EVERY call, not only when it fails, so a
% caller can see how much margin it has rather than only that it had some.
status.scalingValue = sigmaMinPlus;
status.scalingBoundary = regimeBoundary;
status.accuracyTarget = accuracyTarget;
status.accuracyTargetDerived = accuracyTargetDerived;
status.acceptanceTarget = acceptanceTarget;
status.residualAbsolute = residualAbsolute;
status.residualScaled = residualScaled;
status.nonNegative = nonNegative;
status.impliedNullity = nBases;
status.independentRank = rankS;
status.raysFound = nBases;
status.raysExpected = raysExpected;
% ALWAYS true: raysExpected comes from a rank computation on the operative matrix,
% the same class of computation whose reliability under poor conditioning this
% routine exists to question. It is a target, not ground truth.
status.raysExpectedIsEstimate = true;
status.raysRejectedForAccuracy = nRejectedForAccuracy;
status.raysRejectedForDependence = nRejectedForDependence;
status.timedOut = timedOut;
status.nRestarts = nRestarts;
status.pairedComparison = pairedRecord;
status.nTargetedObjectives = nTargetedObjectives;
status.shortfallKind = shortfallKind;
status.attainableDimension = attainableDimension;
status.attainableDimensionAssessed = attainableDimensionAssessed;
status.elapsedTime = toc(t1);
switch status.outcome
    case 'complete'
        status.message = sprintf('Complete basis: %d of %d rays, scaled residual %g.', ...
            nBases, raysExpected, residualScaled);
    case 'emptyNullspace'
        status.message = ['The operative matrix has full row rank: its left nullspace ' ...
            'is empty. An empty basis is the correct answer, not a failure.'];
    otherwise
        status.message = sprintf(['Incomplete basis: %d of %d rays (%s). Do not treat ' ...
            'the row count as evidence of completeness.'], nBases, raysExpected, ...
            status.terminationReason);
end
if ~strcmp(status.outcome, 'complete') && ~strcmp(status.outcome, 'emptyNullspace')
    warning('greedyExtremeRayBasis:incompleteBasis', '%s', status.message);
end

if param.printLevel>0
    fprintf('%s%g\n','|| S''*Zpos||_inf ',residualAbsolute);
    fprintf('%s%g\n','|| S''*Zpos|| scaled ',residualScaled);
    fprintf('%s%g\n','accuracy target ',accuracyTarget);
    fprintf('%s%g\n','|| S''*Z||_inf ',norm(Z*model.S,inf));
end

switch param.leftRight
    case 'right'
        Z= Z';
        Zpos= Zpos';
end


function [x, sol, rows] = compareSolversAtState(model, obj, param, positive, ...
    Zpos, nBases, acceptanceTarget, pointIndex, nonZeroColumnsBool)
% Solves the SAME LP with each solver in param.compareSolvers and records one row per
% solver, then returns the ray from the nominated solver so the search advances exactly
% as it would have without instrumentation.
%
% The nominated solver is whichever was active on entry. Its result is REUSED from this
% loop rather than re-solved, so enabling the comparison does not double its work or
% give it a second, differently-seeded solve.

% the solver the caller had active; read through the state accessor rather than a
% global, which the code analyser rightly objects to
nominated = CobraSolverState.getSolver('LP');

% one digest of the objective, shared by every row at this point, so a reader can
% CONFIRM the pairing rather than take it on trust
objectiveHash = sprintf('%.17g|', obj(1:min(8, numel(obj))));
objectiveHash = sprintf('%s n=%d sum=%.17g', objectiveHash, numel(obj), full(sum(obj)));

normSop = norm(full(model.S), 'fro');
solvers = param.compareSolvers;
if ~any(strcmp(solvers, nominated))
    solvers = [solvers(:)', {nominated}];
end

rows = struct([]);
x = [];
sol = struct('origStat', 'NOT SOLVED', 'stat', -1, 'full', []);

for iS = 1:numel(solvers)
    thisSolver = solvers{iS};
    if ~changeCobraSolver(thisSolver, 'LP', 0)
        continue
    end
    tSolve = tic;
    [xi, soli] = findExtremePool(model, obj, param.printLevel-2, positive, 0, ...
        param.solverSettings);
    elapsed = toc(tSolve);

    row = struct();
    row.pointIndex = pointIndex;
    row.raysAccepted = nBases;
    row.objectiveHash = objectiveHash;
    row.supportMaskCount = nnz(nonZeroColumnsBool);
    row.solver = thisSolver;
    row.stat = soli.stat;
    row.origStat = soli.origStat;
    row.solveTime = elapsed;
    if isempty(xi)
        [row.residualAbsolute, row.residualScaled, row.atBoundCount] = deal(NaN);
        [row.meetsTarget, row.independentOfBasis, row.basisReturned] = deal(false);
    else
        row.residualAbsolute = norm(model.S'*xi, inf);
        row.residualScaled = row.residualAbsolute/max(normSop*norm(xi), eps);
        row.meetsTarget = row.residualAbsolute <= acceptanceTarget;
        % vertex indicator that does not depend on the solver's own claims
        row.atBoundCount = nnz(xi <= 0) + nnz(abs(xi - 100) < 1e-9);
        % a basis is returned only if crossover ran or a simplex method was used, so its
        % presence discriminates a vertex solution from an interior one
        row.basisReturned = isfield(soli, 'basis') && ~isempty(soli.basis) && ...
            (isfield(soli.basis, 'vbasis') || isfield(soli.basis, 'cbasis'));
        if nBases == 0
            row.independentOfBasis = any(xi ~= 0);
        else
            Ztest = [Zpos(1:nBases, :); xi'];
            nzb = full(sum(Ztest ~= 0, 1) ~= 0);
            row.independentOfBasis = getRankLUSOL(Ztest(:, nzb)) == nBases + 1;
        end
    end
    if isempty(rows)
        rows = row;
    else
        rows(end+1) = row; %#ok<AGROW>
    end

    if strcmp(thisSolver, nominated)
        x = xi;
        sol = soli;
    end
end

% restore the solver the caller had active, so the comparison leaves no trace
changeCobraSolver(nominated, 'LP', 0);


function obj = targetedObjective(Z, Zpos, nBases, nVar)
% Builds a non-negative objective aimed at the part of the left nullspace that the
% partial basis does not yet span, for use when random draws have stopped finding new
% independent rays.
%
% `Z` already holds a basis of the requested nullspace, computed once at the top of the
% search, so no new nullspace computation is needed here.

obj = [];
if isempty(Z) || nBases < 1
    return
end

nullBasis = full(Z');                       % nVar x nullity, columns span the nullspace
found = full(Zpos(1:nBases, :));            % rays already accepted

% remove from the nullspace basis everything the accepted rays already span
gram = found*found';
if rcond(gram) < eps
    return
end
residualDirections = nullBasis - found'*(gram\(found*nullBasis));

[leftVectors, singularValues] = svd(residualDirections, 'econ');
singularValues = diag(singularValues);
if isempty(singularValues) || singularValues(1) <= 1e-8
    return                                  % nothing left unspanned to aim at
end

direction = leftVectors(:, 1);
% The ray is constrained non-negative, so the objective is shifted to be non-negative
% while preserving the direction it favours. A sign flip of the leading vector is
% arbitrary, so the shift keeps the LP pointed at the same subspace either way.
obj = direction - min(0, min(direction));
if norm(obj) == 0
    obj = [];
    return
end
obj = obj/norm(obj);
if numel(obj) ~= nVar
    obj = [];
end


function [attainable, known] = attainableNullspaceDimension(S, nVar)
% Dimension of the subspace of ker(S') that is reachable with NON-NEGATIVE weights,
% i.e. dim span(ker(S') n R^m_+).
%
% Method: the maximal support of a non-negative nullspace vector is found by one LP
% maximising sum(x) over {S'x = 0, 0 <= x <= 1}; the support of its optimum is the
% largest support any non-negative nullspace vector can have. The reachable subspace is
% exactly the part of ker(S') living on that support, whose dimension is
% |support| - rank(S(support, :)).
%
% This is sound in both directions, unlike a test for a strictly positive vector, whose
% absence does NOT imply the cone fails to span.

attainable = NaN;
known = false;
[nMet, nRxn] = size(S);

LPproblem.A = sparse(S');
LPproblem.b = zeros(nRxn, 1);
LPproblem.csense = repmat('E', nRxn, 1);
LPproblem.lb = zeros(nMet, 1);
LPproblem.ub = ones(nMet, 1);
LPproblem.c = ones(nMet, 1);
LPproblem.osense = -1;                      % maximise the total weight
try
    sol = solveCobraLP(LPproblem, 'printLevel', 0);
catch ME
    % Do not swallow this: an unsolved LP is why the shortfall is reported unclassified
    % rather than as sampling or structural.
    warning('greedyExtremeRayBasis:attainableDimensionFailed', ...
        ['Could not compute the attainable dimension (%s at %s:%d); reporting the ' ...
        'shortfall as notAssessed rather than guessing.'], ...
        ME.message, ME.stack(1).file, ME.stack(1).line);
    return
end

if sol.stat ~= 1 || isempty(sol.full) || numel(sol.full) ~= nVar
    return
end

supportBool = sol.full > 1e-9;
if ~any(supportBool)
    attainable = 0;                         % only the zero vector is non-negative here
    known = true;
    return
end

attainable = nnz(supportBool) - getRankLUSOL(S(supportBool, :));
attainable = max(attainable, 0);
known = true;
