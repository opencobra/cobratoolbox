function modelPoint = constrainEcosystemPoint(eco, point, varargin)
% Returns the community model constrained to a point of the abundance-growth
% space. The point `[f, mu]` fixes the objective (biomass) reaction of the
% first member to `f * mu` and that of the second member to `(1 - f) * mu`.
% Optionally, the bounds of all the reactions of each member are scaled by
% the fraction of the member in the community (Chan et al., 2017).
%
% USAGE:
%
%    modelPoint = constrainEcosystemPoint(eco, point, varargin)
%
% INPUTS:
%    eco:            (structure) ecosystem structure (see `createEcosystemModel`)
%    point:          (double) 1 x 2 vector `[f, mu]` with the fraction of the
%                    first member and the community growth rate
%
% OPTIONAL INPUTS:
%    updateBounds:   (logical) scale the bounds of member reactions by the
%                    member fractions `[f, 1 - f]` (Default = true)
%    pfraction:      (double) 1 x 2 vector of member fractions used to scale
%                    the bounds (Default = `[f, 1 - f]`)
%
% OUTPUT:
%    modelPoint:     COBRA model of the community constrained to the point
%
% EXAMPLE:
%
%    modelPoint = constrainEcosystemPoint(eco, eco.points(10, :));
%    sol = optimizeCbModel(modelPoint);
%
% NOTE:
%
%    Member reactions are those listed in `eco.memberRxns`. NaN fractions
%    are replaced by zero. Equivalent to the bound updates performed by
%    `Ecosystem._analyze_point` in the Python implementation.
%
% .. Author: - Sebastián N. Mendoza, 13/10/2026, MATLAB implementation based on the Python code of N.E. Jiménez et al.

parser = inputParser();
parser.addRequired('eco', @(x) isstruct(x) && isfield(x, 'model') && isfield(x, 'objectives') && isfield(x, 'memberRxns'));
parser.addRequired('point', @(x) isnumeric(x) && numel(x) == 2);
parser.addParameter('updateBounds', true, @(x) islogical(x) || isnumeric(x));
parser.addParameter('pfraction', [], @(x) isempty(x) || (isnumeric(x) && numel(x) == 2));
parser.parse(eco, point, varargin{:});
eco = parser.Results.eco;
point = parser.Results.point(:)';
updateBounds = parser.Results.updateBounds;
pfraction = parser.Results.pfraction(:)';
if isempty(pfraction)
    pfraction = [point(1), 1 - point(1)];
end
if numel(eco.objectives) ~= 2
    error('Only communities of two members are supported.');
end

modelPoint = eco.model;
if updateBounds
    pfraction(isnan(pfraction)) = 0;
    for k = 1:numel(eco.memberRxns)
        idx = ismember(modelPoint.rxns, eco.memberRxns{k});
        modelPoint.lb(idx) = modelPoint.lb(idx) * pfraction(k);
        modelPoint.ub(idx) = modelPoint.ub(idx) * pfraction(k);
    end
end
% member growth rates at the grid point
memberGrowth = [point(1) * point(2), (1 - point(1)) * point(2)];
for k = 1:numel(eco.objectives)
    idx = strcmp(modelPoint.rxns, eco.objectives{k});
    if ~any(idx)
        error('Objective reaction %s not found in the community model.', eco.objectives{k});
    end
    modelPoint.lb(idx) = memberGrowth(k);
    modelPoint.ub(idx) = memberGrowth(k);
end
end
