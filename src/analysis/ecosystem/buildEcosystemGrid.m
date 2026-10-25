function eco = buildEcosystemGrid(eco, varargin)
% Builds a regular grid over the abundance-growth space of a two-member
% community. Each point is defined by the fraction of the first member in the
% community (`f`, x axis, from 0 to 1) and the community growth rate
% (`mu`, y axis, from 0 to the maximum community growth). At a grid point
% the member growth rates are `f * mu` and `(1 - f) * mu`. The maximum
% community growth is computed by maximizing the sum of member objectives
% in a relaxed problem, in which positive lower bounds (e.g. ATP
% maintenance) are set to zero.
%
% USAGE:
%
%    eco = buildEcosystemGrid(eco, varargin)
%
% INPUT:
%    eco:                 (structure) ecosystem structure (see `createEcosystemModel`)
%
% OPTIONAL INPUTS:
%    numPoints:           (double) number of points on each axis (Default = 10)
%    dropZero:            (logical) remove the point (0, 0) (Default = true)
%    ignoreMaintenance:   (logical) set positive lower bounds to zero to
%                         compute the maximum community growth (Default = true)
%    maxCommunityGrowth:  (double) maximum community growth. If provided, it
%                         is not computed (Default = [])
%    printLevel:          (double) verbosity level (Default = 1)
%
% OUTPUT:
%    eco:                 (structure) ecosystem structure with fields:
%
%                           * .points - nPoints x 2 matrix with the grid points
%                             `[f, mu]`, ordered with `f` varying fastest
%                           * .pfractions - nPoints x 2 matrix with the member
%                             fractions `[f, 1 - f]` of each point
%                           * .maxCommunityGrowth - maximum community growth
%                           * .limits - 2 x 2 matrix with [min; max] values
%                             of the grid on each axis
%
% EXAMPLE:
%
%    eco = buildEcosystemGrid(eco, 'numPoints', 10);
%
% NOTE:
%
%    Only communities of two members are supported, as in the Python
%    implementation (`Ecosystem.build_grid` and
%    `Ecosystem.get_points_distribution`).
%
% .. Author: - Sebastián N. Mendoza, 13/10/2026, MATLAB implementation based on the Python code of N.E. Jiménez et al.

parser = inputParser();
parser.addRequired('eco', @(x) isstruct(x) && isfield(x, 'model'));
parser.addParameter('numPoints', 10, @(x) isnumeric(x) && isscalar(x) && x >= 2);
parser.addParameter('dropZero', true, @(x) islogical(x) || isnumeric(x));
parser.addParameter('ignoreMaintenance', true, @(x) islogical(x) || isnumeric(x));
parser.addParameter('maxCommunityGrowth', [], @(x) isempty(x) || (isnumeric(x) && isscalar(x) && x > 0));
parser.addParameter('printLevel', 1, @(x) isnumeric(x) || islogical(x));
parser.parse(eco, varargin{:});
eco = parser.Results.eco;
numPoints = parser.Results.numPoints;
dropZero = parser.Results.dropZero;
ignoreMaintenance = parser.Results.ignoreMaintenance;
maxCom = parser.Results.maxCommunityGrowth;
printLevel = parser.Results.printLevel;

if numel(eco.prefixes) ~= 2
    error('Only communities of two members are supported.');
end

if isempty(maxCom)
    model = eco.model;
    if ignoreMaintenance
        model.lb(model.lb > 0) = 0;
    end
    sol = optimizeCbModel(model, 'max');
    if sol.stat ~= 1
        error('The relaxed community model is infeasible or unbounded (stat = %d).', sol.stat);
    end
    maxCom = sol.f;
end
if printLevel > 0
    fprintf('Maximum community: %g\n', maxCom);
end

fValues = linspace(0, 1, numPoints);
muValues = linspace(0, maxCom, numPoints);
[F, MU] = meshgrid(fValues, muValues);
% row-major order: f varies fastest (as numpy ravel)
F = F';
MU = MU';
points = [F(:), MU(:)];
mins = [0, 0];
maxs = [1, maxCom];
if dropZero
    points = points(2:end, :);
    mins = min(points, [], 1);
    maxs = max(points, [], 1);
end

eco.points = points;
eco.pfractions = [points(:, 1), 1 - points(:, 1)];
eco.maxCommunityGrowth = maxCom;
eco.limits = [mins; maxs];
eco.feasiblePoints = [];
eco.qualVectors = [];
eco.qualPointIndex = [];
eco.fvaResults = [];
eco.clusters = [];
eco.k = [];
end
