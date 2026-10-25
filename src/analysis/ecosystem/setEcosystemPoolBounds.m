function eco = setEcosystemPoolBounds(eco, poolMets, poolBounds, bioCons)
% Changes the bounds of the pool exchange reactions of a set of exchanged
% metabolites of an ecosystem. Optionally, a biological constraint
% (`bioCons`) can be imposed on the uptake of these metabolites by each
% member: if the new lower bound of the pool exchange is non-positive (i.e.
% the metabolite can enter the community), the lower bound of the exchange
% reaction of each member is set to `bioCons`.
%
% USAGE:
%
%    eco = setEcosystemPoolBounds(eco, poolMets, poolBounds, bioCons)
%
% INPUTS:
%    eco:          (structure) ecosystem structure (see `createEcosystemModel`)
%    poolMets:     (cell array or string) IDs of the exchanged metabolites
%                  without member prefix nor `_pool` suffix, e.g. `{'A_e'}`
%                  or `'glc__D_e'`
%    poolBounds:   (double) n x 2 matrix with the new [lower, upper] bounds
%                  of the pool exchange reaction of each metabolite. A
%                  single row is applied to all metabolites
%
% OPTIONAL INPUT:
%    bioCons:      (double) lower bound imposed on the member exchange
%                  reactions of the metabolites whose new pool lower bound is
%                  non-positive (Default = [], member bounds are not changed)
%
% OUTPUT:
%    eco:          (structure) ecosystem structure with updated bounds in
%                  `eco.model`. The non-blocked reaction list is reset.
%
% EXAMPLE:
%
%    % glucose uptake of the community limited to 10 and the uptake of each
%    % member limited to 10 (biological constraint)
%    eco = setEcosystemPoolBounds(eco, {'glc__D_e'}, [-10 1000], -10);
%
% NOTE:
%
%    Metabolites that are not part of the pool are skipped with a warning.
%    Equivalent to `Ecosystem.set_pool_bounds` of the Python implementation.
%
% .. Author: - Sebastián N. Mendoza, 13/10/2026, MATLAB implementation based on the Python code of N.E. Jiménez et al.

if nargin < 3
    error('eco, poolMets and poolBounds must be provided.');
end
if nargin < 4
    bioCons = [];
end
if ~isstruct(eco) || ~isfield(eco, 'model') || ~isfield(eco, 'exchangeInfo')
    error('eco must be an ecosystem structure created with createEcosystemModel.');
end
if ischar(poolMets) || isstring(poolMets)
    poolMets = cellstr(poolMets);
end
if ~iscellstr(poolMets)
    error('poolMets must be a cell array of strings.');
end
if ~isnumeric(poolBounds) || size(poolBounds, 2) ~= 2
    error('poolBounds must be a n x 2 numeric matrix.');
end
if size(poolBounds, 1) == 1
    poolBounds = repmat(poolBounds, numel(poolMets), 1);
end
if size(poolBounds, 1) ~= numel(poolMets)
    error('The number of rows of poolBounds must be equal to the number of metabolites.');
end
if ~isempty(bioCons) && (~isnumeric(bioCons) || ~isscalar(bioCons))
    error('bioCons must be a numeric scalar or empty.');
end
if any(poolBounds(:, 1) > poolBounds(:, 2))
    error('Lower bounds must be lower than or equal to upper bounds.');
end

model = eco.model;
info = eco.exchangeInfo;
for i = 1:numel(poolMets)
    e = find(strcmp(info.mets, poolMets{i}), 1);
    if isempty(e)
        warning('%s is not a part of pool metabolites. Skipping it.', poolMets{i});
        continue
    end
    rxnIdx = find(strcmp(model.rxns, info.poolRxns{e}), 1);
    model.lb(rxnIdx) = poolBounds(i, 1);
    model.ub(rxnIdx) = poolBounds(i, 2);
    if poolBounds(i, 1) <= 0 && ~isempty(bioCons)
        memberRxns = info.memberRxns(e, :);
        memberRxns = memberRxns(~cellfun(@isempty, memberRxns));
        model.lb(ismember(model.rxns, memberRxns)) = bioCons;
    end
end
eco.model = model;
eco.nonBlocked = [];
end
