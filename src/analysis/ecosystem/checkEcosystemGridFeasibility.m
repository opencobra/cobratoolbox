function [eco, feasiblePoints] = checkEcosystemGridFeasibility(eco, varargin)
% Checks the feasibility of each point of the abundance-growth grid of an
% ecosystem. A point `[f, mu]` is feasible if the community model admits a
% steady state flux distribution when the member growth rates are fixed to
% `f * mu` and `(1 - f) * mu` (and, optionally, the bounds of the member
% reactions are scaled by the member fractions).
%
% USAGE:
%
%    [eco, feasiblePoints] = checkEcosystemGridFeasibility(eco, varargin)
%
% INPUT:
%    eco:              (structure) ecosystem structure with a grid
%                      (see `buildEcosystemGrid`)
%
% OPTIONAL INPUTS:
%    updateBounds:     (logical) scale the bounds of member reactions by the
%                      member fractions (Default = true)
%    pointIndex:       (double) indices of the points to be analyzed. The
%                      remaining points are considered infeasible
%                      (Default = all points)
%    printLevel:       (double) 0 silent, 1 summary, 2 prints each point
%                      (Default = 1)
%
% OUTPUTS:
%    eco:              (structure) ecosystem structure with field
%                      `.feasiblePoints` (nPoints x 1 logical)
%    feasiblePoints:   (logical) nPoints x 1 vector, true for feasible points
%
% EXAMPLE:
%
%    eco = checkEcosystemGridFeasibility(eco, 'updateBounds', true);
%
% NOTE:
%
%    Equivalent to `Ecosystem.analyze_grid(analysis='feasibility')` of the
%    Python implementation.
%
% .. Author: - Sebastián N. Mendoza, 13/10/2026, MATLAB implementation based on the Python code of N.E. Jiménez et al.

parser = inputParser();
parser.addRequired('eco', @(x) isstruct(x) && isfield(x, 'model') && isfield(x, 'points'));
parser.addParameter('updateBounds', true, @(x) islogical(x) || isnumeric(x));
parser.addParameter('pointIndex', [], @(x) isnumeric(x) || islogical(x));
parser.addParameter('printLevel', 1, @(x) isnumeric(x) || islogical(x));
parser.parse(eco, varargin{:});
eco = parser.Results.eco;
updateBounds = parser.Results.updateBounds;
pointIndex = parser.Results.pointIndex;
printLevel = parser.Results.printLevel;

if isempty(eco.points)
    error('Grid points are not set yet! Run buildEcosystemGrid first.');
end
nPoints = size(eco.points, 1);
if isempty(pointIndex)
    pointIndex = 1:nPoints;
elseif islogical(pointIndex)
    pointIndex = find(pointIndex);
end
pfractions = eco.pfractions;
if isempty(pfractions)
    pfractions = [eco.points(:, 1), 1 - eco.points(:, 1)];
end

feasiblePoints = false(nPoints, 1);
for p = pointIndex(:)'
    modelPoint = constrainEcosystemPoint(eco, eco.points(p, :), 'updateBounds', updateBounds, ...
        'pfraction', pfractions(p, :));
    sol = optimizeCbModel(modelPoint, 'max');
    feasiblePoints(p) = sol.stat == 1;
    if printLevel > 1
        fprintf('[%.4f %.4f] feasible = %d\n', eco.points(p, 1), eco.points(p, 2), feasiblePoints(p));
    end
end
eco.feasiblePoints = feasiblePoints;
if printLevel > 0
    fprintf('grid feasible points: %d / %d\n', sum(feasiblePoints), nPoints);
end
end
