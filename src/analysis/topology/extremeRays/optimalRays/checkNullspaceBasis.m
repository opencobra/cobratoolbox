function report = checkNullspaceBasis(model, B, param)
% Judges a basis the caller already holds, for example a `model.L` loaded with a
% model, against the accuracy contract `greedyExtremeRayBasis` certifies its own
% output against: non-negativity, full row rank equal to the nullity, and every row
% meeting the derived accuracy target.
%
% A basis can be non-negative and span the nullspace and still be unfit for a rank
% determination on a matrix augmented with it, because rows that lie measurably
% outside the exact nullspace add spurious numerical rank. This function says which
% rows those are.
%
% USAGE:
%
%    report = checkNullspaceBasis(model, B, param)
%    Judges B*S = 0 (left) or S*B = 0 (right, param.leftRight = 'right')
%
% INPUTS:
%    model:      COBRA model structure with fields:
%
%                  * .S - `m x n` stoichiometric matrix
%                  * .SConsistentRxnBool - `n x 1` boolean of stoichiometrically consistent reactions (used when `param.internalStoichiometriMatrixLeftNullspace` is true; computed by `findStoichConsistentSubset` if absent)
%    B:          candidate basis: `k x m` for the left nullspace, `n x k` for the right nullspace
%
% OPTIONAL INPUT:
%    param:      structure of optional parameters, with the same meaning and defaults
%                as in `greedyExtremeRayBasis`:
%
%                  * .printLevel - verbosity level (default = 1)
%                  * .leftRight - `'left'` or `'right'` nullspace (default = `'left'`)
%                  * .internalStoichiometriMatrixLeftNullspace - if true, restrict `model.S` to `model.SConsistentRxnBool` (default = 0)
%                  * .feasTol - may TIGHTEN the acceptance target, never loosen it (default = 1e-6, which does not loosen)
%                  * .maxElementsForSpectrum - largest matrix for which the dense spectrum is computed (default = 1e8)
%
% OUTPUT:
%    report:     structure with fields:
%
%                  * .outcome - `'valid'`, `'inaccurate'` (some rows exceed the target), `'rankDeficient'` (rank of `B` differs from the nullity, or `B` has dependent rows) or `'negative'` (some entry < 0); precedence negative > rankDeficient > inaccurate > valid
%                  * .accuracyTarget, .accuracyTargetDerived, .regime - as in `nullspaceAccuracyTarget`
%                  * .acceptanceTarget - the target applied, after any tightening by `param.feasTol`
%                  * .residualByRow - `max(abs(B*Sop), [], 2)`, the per-row metric `greedyExtremeRayBasis` uses
%                  * .failingRows - indices of rows with `residualByRow > acceptanceTarget`
%                  * .residualAbsolute - largest per-row residual
%                  * .residualScaled - `residualAbsolute / (norm(B,'fro') * norm(Sop,'fro'))`
%                  * .nonNegative - true if every entry of `B` is non-negative
%                  * .rankB - numerical rank of `B`
%                  * .nullity - dimension of the requested nullspace of the operative matrix
%                  * .spansNullspace - true if `rankB` equals `nullity`
%                  * .operativeMatrixSize - size of the matrix the basis was judged against
%                  * .message - one human-readable sentence
%
% EXAMPLE:
%
%    load('Recon3DModel_301_xomics_input_VK_withL.mat')   % provides model with model.L
%    param.internalStoichiometriMatrixLeftNullspace = 1;
%    report = checkNullspaceBasis(model, model.L, param);
%    disp(report.message)
%
% NOTE:
%
%    The target is derived by `nullspaceAccuracyTarget`, the same function
%    `greedyExtremeRayBasis` uses, so the two judgements cannot drift apart. A
%    verdict on a bad basis is DATA, not an error: only malformed input (a basis of
%    the wrong width) raises `checkNullspaceBasis:dimensionMismatch`.
%
% .. Author: - Feature 20261003-132730-greedy-recon3d-stall, October 2026

if ~exist('param', 'var') || isempty(param)
    param = struct();
end
if ~isfield(param, 'printLevel')
    param.printLevel = 1;
end
if ~isfield(param, 'leftRight')
    param.leftRight = 'left';
end
if ~isfield(param, 'internalStoichiometriMatrixLeftNullspace')
    param.internalStoichiometriMatrixLeftNullspace = 0;
end
if ~isfield(param, 'feasTol')
    param.feasTol = 1e-6;
end
if ~isfield(param, 'maxElementsForSpectrum')
    param.maxElementsForSpectrum = 1e8;
end

% build the operative matrix exactly as greedyExtremeRayBasis does
Sop = model.S;
if param.internalStoichiometriMatrixLeftNullspace
    if ~isfield(model, 'SConsistentRxnBool')
        [~, ~, ~, ~, ~, ~, model, ~] = findStoichConsistentSubset(model, 1, 0);
    end
    Sop = model.S(:, model.SConsistentRxnBool);
end
switch param.leftRight
    case 'right'
        Sop = Sop';
        B = B';
end

if size(B, 2) ~= size(Sop, 1)
    error('checkNullspaceBasis:dimensionMismatch', ...
        ['The basis has %d columns but the operative matrix has %d rows; a %s-nullspace ' ...
        'basis must match it.'], size(B, 2), size(Sop, 1), param.leftRight);
end

target = nullspaceAccuracyTarget(Sop, param);
acceptanceTarget = min(target.accuracyTarget, param.feasTol);

residualByRow = full(max(abs(B*Sop), [], 2));
if isempty(residualByRow)
    residualByRow = zeros(0, 1);
end
failingRows = find(residualByRow > acceptanceTarget);
if isempty(residualByRow)
    residualAbsolute = 0;
else
    residualAbsolute = max(residualByRow);
end
normB = norm(full(B), 'fro');
normSop = norm(full(Sop), 'fro');
if normB > 0 && normSop > 0
    residualScaled = residualAbsolute/(normB*normSop);
else
    residualScaled = 0;
end

nonNegative = full(all(B(:) >= 0));

% the nullity comes from the same rank computation greedyExtremeRayBasis uses
[~, rankSop] = getNullSpace(Sop', 0);
nullity = size(Sop, 1) - rankSop;
if isempty(B)
    rankB = 0;
elseif numel(B) <= param.maxElementsForSpectrum
    rankB = rank(full(B));
else
    rankB = getRankLUSOL(B);
end
spansNullspace = rankB == nullity;

if ~nonNegative
    outcome = 'negative';
    message = sprintf('Not a non-negative basis: smallest entry %g.', full(min(B(:))));
elseif ~spansNullspace || rankB < size(B, 1)
    outcome = 'rankDeficient';
    message = sprintf('Not a basis: %d rows of rank %d against a nullity of %d.', ...
        size(B, 1), rankB, nullity);
elseif ~isempty(failingRows)
    outcome = 'inaccurate';
    message = sprintf(['Spans the nullspace, but %d of %d rows exceed the accuracy ' ...
        'target %g (worst residual %g).'], numel(failingRows), size(B, 1), ...
        acceptanceTarget, residualAbsolute);
else
    outcome = 'valid';
    message = sprintf(['Valid: %d non-negative rows spanning the nullspace, worst ' ...
        'residual %g within the target %g.'], size(B, 1), residualAbsolute, acceptanceTarget);
end

report = struct();
report.outcome = outcome;
report.accuracyTarget = target.accuracyTarget;
report.accuracyTargetDerived = target.accuracyTargetDerived;
report.regime = target.regime;
report.acceptanceTarget = acceptanceTarget;
report.residualByRow = residualByRow;
report.failingRows = failingRows;
report.residualAbsolute = residualAbsolute;
report.residualScaled = residualScaled;
report.nonNegative = nonNegative;
report.rankB = rankB;
report.nullity = nullity;
report.spansNullspace = spansNullspace;
report.operativeMatrixSize = size(Sop);
report.message = message;

if param.printLevel > 0
    fprintf('checkNullspaceBasis: %s\n', message);
end
