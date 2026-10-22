function eco = setEcosystemClusterReactions(eco, varargin)
% Defines the set of reactions of the community model that will be analyzed
% by qualitative flux variability analysis and used to cluster the points of
% the abundance-growth grid (`eco.rxn2cluster`). By default, all the
% non-blocked reactions of the community model (under its current bounds)
% are selected. Alternatively, a list of reactions can be provided.
%
% USAGE:
%
%    eco = setEcosystemClusterReactions(eco, varargin)
%
% INPUT:
%    eco:            (structure) ecosystem structure (see `createEcosystemModel`)
%
% OPTIONAL INPUTS:
%    rxnList:        (cell array) reactions to be analyzed. If provided,
%                    blocked reactions are not computed (Default = {})
%    tol:            (double) tolerance to consider a reaction as blocked,
%                    i.e. |minFlux| < tol and |maxFlux| < tol (Default = 1e-7)
%    printLevel:     (double) verbosity level (Default = 1)
%
% OUTPUT:
%    eco:            (structure) ecosystem structure with the fields:
%
%                      * .rxn2cluster - sorted (ASCII order) list of reaction
%                        IDs to be analyzed
%                      * .nonBlocked - non-blocked reactions (when computed)
%
% EXAMPLE:
%
%    eco = setEcosystemClusterReactions(eco);
%    % only exchange reactions
%    eco.rxn2cluster = eco.rxn2cluster(contains(eco.rxn2cluster, 'EX_'));
%
% NOTE:
%
%    Blocked reactions are found with flux variability analysis
%    (`fluxVariability`) without fixing the objective (optPercentage = 0),
%    as `cobra.flux_analysis.find_blocked_reactions` does in the Python
%    implementation (`Ecosystem.set_cluster_reactions`). Reduction of the
%    reaction set based on flux coupling analysis is not implemented.
%
% .. Author: - Sebastián N. Mendoza, 13/10/2026, MATLAB implementation based on the Python code of N.E. Jiménez et al.

parser = inputParser();
parser.addRequired('eco', @(x) isstruct(x) && isfield(x, 'model'));
parser.addParameter('rxnList', {}, @(x) iscellstr(x) || isstring(x));
parser.addParameter('tol', 1e-7, @(x) isnumeric(x) && isscalar(x) && x >= 0);
parser.addParameter('printLevel', 1, @(x) isnumeric(x) || islogical(x));
parser.parse(eco, varargin{:});
eco = parser.Results.eco;
rxnList = cellstr(parser.Results.rxnList);
tol = parser.Results.tol;
printLevel = parser.Results.printLevel;

if ~isempty(rxnList)
    missing = setdiff(rxnList, eco.model.rxns);
    if ~isempty(missing)
        error('The following reactions are not in the community model: %s', strjoin(missing, ', '));
    end
    rxn2cluster = rxnList(:);
else
    if printLevel > 0
        fprintf('Missing FCA results\nUsing non-blocked reactions only\n');
    end
    model = eco.model;
    [minFlux, maxFlux] = fluxVariability(model, 'optPercentage', 0, 'rxnNameList', model.rxns, 'printLevel', 0);
    blocked = abs(minFlux) < tol & abs(maxFlux) < tol;
    rxn2cluster = model.rxns(~blocked);
    eco.nonBlocked = rxn2cluster;
end
eco.rxn2cluster = sort(rxn2cluster);
if printLevel > 0
    fprintf('Total reactions considered for fva and clustering: %d\n', numel(eco.rxn2cluster));
end
end
