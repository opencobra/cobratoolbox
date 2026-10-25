function target = nullspaceAccuracyTarget(Sop, param)
% Derives the residual target that a basis for the left nullspace of `Sop` must meet
% for a matrix augmented with that basis to have a well-defined numerical rank, and
% classifies the scaling regime of `Sop` from the same spectrum.
%
% This is the single source of the accuracy contract applied by
% `greedyExtremeRayBasis` to the basis it computes and by `checkNullspaceBasis` to a
% basis a caller supplies, so that the two certifications cannot drift apart.
%
% USAGE:
%
%    target = nullspaceAccuracyTarget(Sop, param)
%
% INPUT:
%    Sop:        `m x n` operative matrix. The basis being judged spans its LEFT
%                nullspace, `B*Sop = 0`. A caller certifying a right-nullspace basis
%                passes the transpose.
%
% OPTIONAL INPUT:
%    param:      structure of optional parameters:
%
%                  * .maxElementsForSpectrum - largest `numel(Sop)` for which the dense
%                    spectrum is computed (default = 1e8). Above it the documented
%                    fallback applies and the regime is not assessed.
%
% OUTPUT:
%    target:     structure with fields:
%
%                  * .accuracyTarget - largest admissible per-row residual `max|b*Sop|`
%                  * .accuracyTargetDerived - true if derived from the spectrum, false if the fallback `eps*normest(Sop)` was used
%                  * .regime - `'wellScaled'`, `'badlyScaled'` or `'notAssessed'`
%                  * .sigmaOne - largest singular value (`normest(Sop)` on the fallback path)
%                  * .sigmaMinPlus - smallest non-zero singular value (NaN if not derived)
%                  * .regimeBoundary - value of `sigmaMinPlus` below which the regime is badly scaled (NaN if not derived)
%                  * .tauMin - tightest relative rank tolerance, `eps*max(m + n, m)`
%                  * .spectrumTime - seconds spent on the spectrum (0 if it was not computed)
%
% EXAMPLE:
%
%    target = nullspaceAccuracyTarget(model.S(:, model.SConsistentRxnBool), struct());
%    fprintf('each row of a left-nullspace basis must satisfy max|b*S| <= %g\n', ...
%        target.accuracyTarget);
%
% NOTE:
%
%    Extracted verbatim from greedyExtremeRayBasis by feature
%    20261003-132730-greedy-recon3d-stall. The mathematics is unchanged; only the
%    size ceiling became a parameter, and its default rose from 5e7 to 1e8 elements
%    on the measured cost recorded in that feature's research.md R3: 5.3 s for the
%    5824 x 8748 Recon3D operative matrix and 8.3 s for a 1.0e8-element matrix
%    (0.75 GB dense). Under the old ceiling the Recon3D matrix, at 5.09e7 elements,
%    missed the derivation and fell back to a target 13 times stricter, with its
%    regime unassessed.
%
% .. Author: - Feature 20261003-132730-greedy-recon3d-stall, October 2026

if ~exist('param', 'var') || isempty(param)
    param = struct();
end
if ~isfield(param, 'maxElementsForSpectrum')
    param.maxElementsForSpectrum = 1e8;
end

[nVar, nRxn] = size(Sop);

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
% iDopaNeuroC operative matrix, 0.35 s for the 1668 x 2382 iAF1260 matrix, 5.3 s for
% the 5824 x 8748 Recon3D matrix and 8.3 s at the 1e8-element ceiling, against a
% greedy search that takes seconds to minutes, so this is affordable on every model
% the toolbox handles. Only a matrix too large to hold densely falls back.
%
% The same spectrum decides the scaling regime, so it is computed once for both.
tauMin = eps*max(nVar + nRxn, nVar);
accuracyTargetDerived = false;
regime = 'notAssessed';
sigmaMinPlus = NaN;
regimeBoundary = NaN;
spectrumTime = 0;
if numel(Sop) <= param.maxElementsForSpectrum
    spectrumTimer = tic;
    singularValues = svd(full(Sop));
    spectrumTime = toc(spectrumTimer);
    sigmaOne = singularValues(1);
    nAboveRankTol = sum(singularValues > eps*max(size(Sop))*sigmaOne);
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
    sigmaOne = normest(Sop);
    accuracyTarget = eps*sigmaOne;
end

target = struct('accuracyTarget', accuracyTarget, ...
    'accuracyTargetDerived', accuracyTargetDerived, ...
    'regime', regime, ...
    'sigmaOne', sigmaOne, ...
    'sigmaMinPlus', sigmaMinPlus, ...
    'regimeBoundary', regimeBoundary, ...
    'tauMin', tauMin, ...
    'spectrumTime', spectrumTime);
