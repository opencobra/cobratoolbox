function out = probeRayResidual(S, obj, positive)
% Measures the left-nullspace residual of one extreme ray BEFORE and AFTER the
% post-solve truncation that findExtremePool.m:66 applies, to test the R1 hypothesis.
%
% USAGE:
%
%    out = probeRayResidual(S, obj, positive)
%
% INPUTS:
%    S:          `m x n` stoichiometric matrix
%
% OPTIONAL INPUTS:
%    obj:        `m x 1` objective coefficient vector (default = random)
%    positive:   if true, restrict the ray to non-negative coefficients (default = 1)
%
% OUTPUT:
%    out:        structure with fields:
%
%                  * .residualRawAbs - `norm(S'*x_raw, inf)` before truncation
%                  * .residualTruncAbs - `norm(S'*x_trunc, inf)` after truncation
%                  * .residualRawScaled - the same, scaled by `norm(S)*norm(x)`
%                  * .residualTruncScaled - the same, scaled
%                  * .nZeroed - number of entries the truncation destroyed
%                  * .maxZeroed - largest magnitude the truncation destroyed
%                  * .epsilon - the truncation threshold actually used
%                  * .stat - solver status
%                  * .origStat - solver-native status
%                  * .xRaw - the untruncated LP solution
%                  * .xTrunc - the solution after the findExtremePool truncation
%
% NOTE:
%
%    This is a THROWAWAY RESEARCH PROBE for feature
%    20260914-204640-greedy-left-nullspace-conditioning, not toolbox source. It
%    deliberately REPLICATES the LP that findExtremePool builds (:53-64) rather than
%    calling it, because findExtremePool returns only the already-truncated vector and
%    the whole point of this measurement is to see the untruncated one. Keep the
%    replication in sync with findExtremePool.m if that file changes.
%
% Author: - feature 20260914-204640, 2026-09-14

if ~exist('positive', 'var') || isempty(positive)
    positive = 1;
end

A = S';
[n, m] = size(A);

if ~exist('obj', 'var') || isempty(obj)
    obj = rand(m, 1);
end

% --- identical to findExtremePool.m:53-64 ---
LPProblem.A = sparse([A; ones(1, m)]);
LPProblem.b = [zeros(n, 1); 1];
LPProblem.c = obj;
if positive
    LPProblem.lb = zeros(size(LPProblem.A, 2), 1);
else
    LPProblem.lb = -100*ones(size(LPProblem.A, 2), 1);
end
LPProblem.ub = 100*ones(size(LPProblem.A, 2), 1);
LPProblem.osense = -1;
LPProblem.csense(1:size(LPProblem.A, 1), 1) = 'E';
sol = solveCobraLP(LPProblem, 'printLevel', 0);

% --- identical to findExtremePool.m:36-39 ---
feasTol = getCobraSolverParams('LP', 'feasTol');
epsilon = feasTol*10;

xRaw = sol.full;
xTrunc = xRaw;
xTrunc(abs(xTrunc) < epsilon) = 0;     % findExtremePool.m:66

out.epsilon = epsilon;
out.stat = sol.stat;
out.origStat = sol.origStat;
out.xRaw = xRaw;
out.xTrunc = xTrunc;

if isempty(xRaw)
    [out.residualRawAbs, out.residualTruncAbs] = deal(NaN);
    [out.residualRawScaled, out.residualTruncScaled] = deal(NaN);
    [out.nZeroed, out.maxZeroed, out.minSurviving] = deal(NaN);
    return
end

normS = norm(full(S), 'fro');
out.residualRawAbs = norm(S'*xRaw, inf);
out.residualTruncAbs = norm(S'*xTrunc, inf);
out.residualRawScaled = out.residualRawAbs/(normS*max(norm(xRaw), eps));
out.residualTruncScaled = out.residualTruncAbs/(normS*max(norm(xTrunc), eps));

zeroedBool = abs(xRaw) < epsilon & xRaw ~= 0;
out.nZeroed = nnz(zeroedBool);
if any(zeroedBool)
    out.maxZeroed = max(abs(xRaw(zeroedBool)));
else
    out.maxZeroed = 0;
end
survivingBool = xTrunc ~= 0;
if any(survivingBool)
    out.minSurviving = min(abs(xTrunc(survivingBool)));
else
    out.minSurviving = NaN;
end
