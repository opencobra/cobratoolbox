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
%                  * .exactAccuracyTarget - if true, derive the acceptance target from a full singular value decomposition of the operative matrix instead of the conservative machine-precision default; costs a dense svd, so it is off by default (default = 0)
%
% OUTPUTS:
%    Zpos:       non-negative linear basis for the left (right) nullspace of N (internal = 1) or S (internal = 0)
%    Z:          linear basis for the left (right) nullspace of N (internal = 1) or S (internal = 0)
%    status:     structure recording the terminal outcome and the accuracy actually achieved:
%
%                  * .accuracyTarget - the derived residual target each accepted ray had to meet
%                  * .accuracyTargetDerived - true if the target was derived from the operative matrix, false if the conservative fallback was used
%                  * .residualAbsolute - `norm(Zpos*Sop, inf)` measured on the RETURNED basis
%                  * .residualScaled - the same, divided by `norm(Zpos)*norm(Sop)`
%                  * .nonNegative - non-negativity of `Zpos`, asserted on the returned basis
%                  * .raysFound - rays actually accepted
%                  * .raysExpected - rays sought
%                  * .raysRejectedForAccuracy - candidates dropped for failing the accuracy target
%                  * .raysRejectedForDependence - candidates dropped as linearly dependent
%                  * .timedOut - true if the search stopped on its total time budget rather than completing
%                  * .nRestarts - times the search hit a dead end and restarted from fresh randomness
%                  * .elapsedTime - seconds for this call
%
% EXAMPLE:
%
%    param.printLevel = 0;
%    [Zpos, Z, status] = greedyExtremeRayBasis(model, param);
%    assert(status.nonNegative)

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


if param.internalStoichiometriMatrixLeftNullspace
    if ~isfield(model,'SConsistentRxnBool')
        [~, ~, ~, ~, ~, ~, model, ~] = findStoichConsistentSubset(model, 1, 0);
    end
end

if ~any(model.SConsistentRxnBool) %check if positive vector in left nullspace
    Zpos=[];
    Z=[]; % Returning empty vector for left nullspace so if it is expected matlab will keep running
    % status must be assigned on every return path, or a three-output caller gets
    % an "output argument not assigned" error instead of an answer.
    status = struct('accuracyTarget', NaN, 'accuracyTargetDerived', false, ...
        'acceptanceTarget', NaN, 'residualAbsolute', NaN, 'residualScaled', NaN, ...
        'nonNegative', true, 'raysFound', 0, 'raysExpected', 0, ...
        'raysRejectedForAccuracy', 0, 'raysRejectedForDependence', 0, ...
        'timedOut', false, 'nRestarts', 0, 'elapsedTime', 0);
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
% Computing sigmaMinPlus exactly requires a full svd (minutes on a genome-scale S)
% and svds(...,'smallestnz') is no faster on these matrices, so the exact form is
% opt-in. The DEFAULT target is the machine-precision residual scale of the operative
% matrix, eps*norm(Sop): the residual at which a row is indistinguishable from an
% exact nullspace vector in floating point at this matrix's scale.
%
% The default is the CONSERVATIVE choice for a well-scaled matrix. Measured on
% iDopaNeuroC it is 84x stricter than the exact derived target (1.42e-14 against
% 1.19e-12), so a row that passes it would also have passed the exact target.
%
% LIMITATION, stated rather than hidden: for a BADLY SCALED matrix, where
% sigmaMinPlus is very small, the exact target falls below eps*norm(Sop) and this
% default becomes too loose. That is the Regime-B condition, which this slice does
% not yet detect (spec.md FR-005 to FR-008). Until it does, pass
% param.exactAccuracyTarget = true on a badly scaled matrix.
tauMin = eps*max(nVar + nRxn, nVar);
accuracyTargetDerived = false;
if isfield(param, 'exactAccuracyTarget') && param.exactAccuracyTarget
    singularValues = svd(full(model.S));
    sigmaOne = singularValues(1);
    nAboveRankTol = sum(singularValues > eps*max(size(model.S))*sigmaOne);
    if nAboveRankTol > 0
        accuracyTarget = tauMin*sigmaOne*singularValues(nAboveRankTol);
        accuracyTargetDerived = true;
    end
end
if ~accuracyTargetDerived
    accuracyTarget = eps*normest(model.S);
end

% param.feasTol may TIGHTEN acceptance but must never loosen it above the derived
% target (see the NOTE in the help header).
acceptanceTarget = min(accuracyTarget, param.feasTol);

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
    positive = 1;
    [x, sol] = findExtremePool(model,obj,param.printLevel-2,positive);
    
    if contains(sol.origStat,'WARNING')
        nfail = nfailMax;
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
nonNegative = full(all(Zpos(:) >= 0));
if ~nonNegative
    error('greedyExtremeRayBasis:negativeBasisEntry', ...
        'Zpos contains a negative entry (min %g); non-negativity is a hard requirement.', ...
        full(min(Zpos(:))));
end

status = struct();
status.accuracyTarget = accuracyTarget;
status.accuracyTargetDerived = accuracyTargetDerived;
status.acceptanceTarget = acceptanceTarget;
status.residualAbsolute = residualAbsolute;
status.residualScaled = residualScaled;
status.nonNegative = nonNegative;
status.raysFound = nBases;
status.raysExpected = nVar - rankS;
status.raysRejectedForAccuracy = nRejectedForAccuracy;
status.raysRejectedForDependence = nRejectedForDependence;
status.timedOut = timedOut;
status.nRestarts = nRestarts;
status.elapsedTime = toc(t1);

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


