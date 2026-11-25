function pathways = optStoicMinFlux(database, overallMets, overallCoefs, varargin)
% Identifies pathways with minimal total flux that carry out a given overall
% stoichiometric conversion (minFlux, Chowdhury and Maranas, 2015).
% Alternative pathways are enumerated with integer cuts.
%
% USAGE:
%
%    pathways = optStoicMinFlux(database, overallMets, overallCoefs, varargin)
%
% INPUTS:
%    database:          (structure) database loaded with `loadOptStoicDatabase`
%    overallMets:       (cell array) metabolites of the overall conversion
%    overallCoefs:      (double) their stoichiometric coefficients (negative
%                       for consumed metabolites, positive for produced ones)
%
% OPTIONAL INPUTS:
%    varargin:          any optional input of `findOptStoicPathways`
%                       (except 'method'), e.g. 'nSolutions', 'flexibleMets',
%                       'flexibleBounds', 'excludedRxns', 'excludedMets',
%                       'maxRxns', 'integerFlux', 'timeLimit', 'printLevel'
%
% OUTPUT:
%    pathways:          (structure) pathways found (see `findOptStoicPathways`)
%
% EXAMPLE:
%
%    pathways = optStoicMinFlux(database, {'C00267', 'C00033'}, [-1 3], ...
%        'flexibleMets', {'C00080'}, 'flexibleBounds', [-10 10], 'nSolutions', 10);
%
% .. Author: - Sebastián N. Mendoza, 13/10/2026, MATLAB implementation based on minFlux.gms (A. Chowdhury, C.Y. Ng, C.D. Maranas)

if nargin < 3
    error('database, overallMets and overallCoefs must be provided.');
end
if any(strcmpi(varargin(1:2:end), 'method'))
    error('The method cannot be changed in optStoicMinFlux. Use findOptStoicPathways instead.');
end
pathways = findOptStoicPathways(database, overallMets, overallCoefs, 'method', 'minFlux', varargin{:});
end
