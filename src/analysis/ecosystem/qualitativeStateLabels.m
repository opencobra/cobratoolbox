function labels = qualitativeStateLabels(qualStates)
% Converts qualitative flux state codes into their labels:
% -3 -> '-', -2 -> '--', -1 -> '-0', 0 -> '0', 1 -> '0+', 2 -> '++',
% 3 -> '+', 4 -> '-+', 5 -> 'err', 100 -> 'var' and NaN -> 'NaN'.
%
% USAGE:
%
%    labels = qualitativeStateLabels(qualStates)
%
% INPUT:
%    qualStates:   (double) array of qualitative state codes
%                  (see `getQualitativeFluxStates`)
%
% OUTPUT:
%    labels:       (cell array) labels, same size as qualStates
%
% EXAMPLE:
%
%    labels = qualitativeStateLabels([-1 0 4 NaN])
%    % returns {'-0', '0', '-+', 'NaN'}
%
% .. Author: - Sebastián N. Mendoza, 13/10/2026, MATLAB implementation based on the Python code of N.E. Jiménez et al.

if nargin < 1 || ~isnumeric(qualStates)
    error('qualStates must be a numeric array.');
end
codes = [-3, -2, -1, 0, 1, 2, 3, 4, 5, 100];
names = {'-', '--', '-0', '0', '0+', '++', '+', '-+', 'err', 'var'};
labels = repmat({'NaN'}, size(qualStates));
for i = 1:numel(codes)
    labels(qualStates == codes(i)) = names(i);
end
end
