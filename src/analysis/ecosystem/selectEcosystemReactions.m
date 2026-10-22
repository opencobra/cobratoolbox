function eco = selectEcosystemReactions(eco, rxnList)
% Restricts the reactions considered for clustering (`eco.rxn2cluster`) to
% a subset, keeping the corresponding columns of the qualitative vectors and
% FVA results. Previous clustering results are reset.
%
% USAGE:
%
%    eco = selectEcosystemReactions(eco, rxnList)
%
% INPUTS:
%    eco:        (structure) ecosystem structure (see `createEcosystemModel`
%                or `loadEcosystemScenario`)
%    rxnList:    (cell array or logical) reactions to keep, given as IDs or
%                as a logical vector over `eco.rxn2cluster`
%
% OUTPUT:
%    eco:        (structure) updated ecosystem structure
%
% EXAMPLE:
%
%    % keep exchange reactions only
%    eco = selectEcosystemReactions(eco, contains(eco.rxn2cluster, 'EX_'));
%
% .. Author: - Sebastián N. Mendoza, 13/10/2026, MATLAB implementation based on the Python code of N.E. Jiménez et al.

if nargin < 2
    error('eco and rxnList must be provided.');
end
if ~isstruct(eco) || ~isfield(eco, 'rxn2cluster')
    error('eco must be an ecosystem structure.');
end
if islogical(rxnList)
    if numel(rxnList) ~= numel(eco.rxn2cluster)
        error('A logical rxnList must have one element per reaction in eco.rxn2cluster.');
    end
    cols = find(rxnList);
else
    rxnList = cellstr(rxnList);
    [found, cols] = ismember(rxnList(:), eco.rxn2cluster);
    if ~all(found)
        error('Reactions not found in eco.rxn2cluster: %s', strjoin(rxnList(~found), ', '));
    end
end
eco.rxn2cluster = eco.rxn2cluster(cols);
if isfield(eco, 'qualVectors') && ~isempty(eco.qualVectors)
    eco.qualVectors = eco.qualVectors(:, cols);
end
if isfield(eco, 'fvaResults') && ~isempty(eco.fvaResults)
    eco.fvaResults = eco.fvaResults(:, cols, :);
end
eco.clusters = [];
eco.k = [];
end
