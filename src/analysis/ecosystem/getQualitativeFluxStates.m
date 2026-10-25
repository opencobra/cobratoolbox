function [qualStates, qualLabels] = getQualitativeFluxStates(minFlux, maxFlux, delta)
% Translates flux ranges obtained by flux variability analysis into
% qualitative flux states. The codes and labels of the states are:
%
%    ====  =====  ==================================================
%    code  label  condition (|x| <= delta is considered zero)
%    ====  =====  ==================================================
%     -3    -     min = max < 0 (fixed negative flux)
%     -2    --    min < 0 and max < 0 (variable negative flux)
%     -1    -0    min < 0 and max = 0
%      0    0     min = max = 0
%      1    0+    min = 0 and max > 0
%      2    ++    min > 0 and max > 0 (variable positive flux)
%      3    +     min = max > 0 (fixed positive flux)
%      4    -+    min < 0 and max > 0
%      5    err   none of the above (e.g. NaN values)
%    ====  =====  ==================================================
%
% USAGE:
%
%    [qualStates, qualLabels] = getQualitativeFluxStates(minFlux, maxFlux, delta)
%
% INPUTS:
%    minFlux:      (double) array with minimum fluxes
%    maxFlux:      (double) array with maximum fluxes (same size as minFlux)
%
% OPTIONAL INPUT:
%    delta:        (double) threshold to consider a flux, or the difference
%                  between maximum and minimum fluxes, as zero (Default = 1e-9)
%
% OUTPUTS:
%    qualStates:   (double) array with the qualitative state codes (same
%                  size as minFlux)
%    qualLabels:   (cell array) labels of the qualitative states
%
% EXAMPLE:
%
%    qualStates = getQualitativeFluxStates([-1; 0; 2], [1; 0; 2], 1e-9)
%    % returns [4; 0; 3]
%
% NOTE:
%
%    The conditions are evaluated in the same order as `qual_translate` in
%    `Ecosystem._analyze_point` of the Python implementation.
%
% .. Author: - Sebastián N. Mendoza, 13/10/2026, MATLAB implementation based on the Python code of N.E. Jiménez et al.

if nargin < 2
    error('minFlux and maxFlux must be provided.');
end
if nargin < 3 || isempty(delta)
    delta = 1e-9;
end
if ~isnumeric(minFlux) || ~isnumeric(maxFlux) || ~isequal(size(minFlux), size(maxFlux))
    error('minFlux and maxFlux must be numeric arrays of the same size.');
end
if ~isnumeric(delta) || ~isscalar(delta) || delta < 0
    error('delta must be a non-negative scalar.');
end

mn = minFlux;
mx = maxFlux;
qualStates = 5 * ones(size(mn));
assigned = false(size(mn));

cond = mx < -delta & mn < -delta;
qualStates(cond) = -2;
qualStates(cond & abs(mx - mn) < delta) = -3;
assigned = assigned | cond;

cond = ~assigned & (mx >= -delta & mx <= delta) & (mn >= -delta & mn <= delta);
qualStates(cond) = 0;
assigned = assigned | cond;

cond = ~assigned & (mx >= -delta & mx < delta) & (mn < -delta);
qualStates(cond) = -1;
assigned = assigned | cond;

cond = ~assigned & (mn >= -delta & mn <= delta) & mx > delta;
qualStates(cond) = 1;
assigned = assigned | cond;

cond = ~assigned & mx > delta & mn > delta;
qualStates(cond) = 2;
qualStates(cond & abs(mx - mn) < delta) = 3;
assigned = assigned | cond;

cond = ~assigned & mn < -delta & mx > delta;
qualStates(cond) = 4;

if nargout > 1
    qualLabels = qualitativeStateLabels(qualStates);
end
end
