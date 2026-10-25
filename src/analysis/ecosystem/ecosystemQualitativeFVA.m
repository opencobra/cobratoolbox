function [eco, qualVectors, fvaResults] = ecosystemQualitativeFVA(eco, varargin)
% Performs a qualitative flux variability analysis (FVA) on the points of the
% abundance-growth grid of an ecosystem. For each analyzed point, the
% community model is constrained to the point (see `constrainEcosystemPoint`),
% FVA is computed for the reactions in `eco.rxn2cluster` and the flux ranges
% are translated into qualitative states (see `getQualitativeFluxStates`).
% If the feasibility of the grid points has been computed, only feasible
% points are analyzed.
%
% USAGE:
%
%    [eco, qualVectors, fvaResults] = ecosystemQualitativeFVA(eco, varargin)
%
% INPUT:
%    eco:            (structure) ecosystem structure with a grid
%                    (see `buildEcosystemGrid`)
%
% OPTIONAL INPUTS:
%    updateBounds:   (logical) scale the bounds of member reactions by the
%                    member fractions (Default = true)
%    rxnList:        (cell array) reactions to be analyzed
%                    (Default = `eco.rxn2cluster`, computed with
%                    `setEcosystemClusterReactions` if empty)
%    delta:          (double) threshold to consider fluxes as zero when
%                    translating flux ranges into qualitative states
%                    (Default = 1e-9)
%    pointIndex:     (double) indices of the grid points to analyze
%                    (Default = feasible points or all points)
%    threads:        (double) number of threads passed to `fluxVariability`.
%                    If empty, an existing parallel pool is used and FVA is
%                    serial otherwise (Default = [])
%    printLevel:     (double) 0 silent, 1 summary, 2 prints each point
%                    (Default = 1)
%
% OUTPUTS:
%    eco:            (structure) ecosystem structure with fields:
%
%                      * .qualVectors - nAnalyzed x nRxns matrix of
%                        qualitative states (columns follow `eco.rxn2cluster`)
%                      * .qualPointIndex - indices of the analyzed points
%                      * .fvaResults - nAnalyzed x nRxns x 2 array with
%                        minimum (:, :, 1) and maximum (:, :, 2) fluxes
%    qualVectors:    (double) same as `eco.qualVectors`
%    fvaResults:     (double) same as `eco.fvaResults`
%
% EXAMPLE:
%
%    eco = checkEcosystemGridFeasibility(eco);
%    eco = ecosystemQualitativeFVA(eco, 'updateBounds', true);
%
% NOTE:
%
%    Equivalent to `Ecosystem.analyze_grid(analysis='qual_fva')` of the
%    Python implementation. FVA is computed with `fluxVariability` without
%    fixing the objective (optPercentage = 0), since the member objectives
%    are already fixed by the point. Infeasible points (which can be analyzed
%    when the feasibility has not been computed) get NaN fluxes and the
%    qualitative state 5, whereas the Python implementation stops with an
%    error.
%
% .. Author: - Sebastián N. Mendoza, 13/10/2026, MATLAB implementation based on the Python code of N.E. Jiménez et al.

parser = inputParser();
parser.addRequired('eco', @(x) isstruct(x) && isfield(x, 'model') && isfield(x, 'points'));
parser.addParameter('updateBounds', true, @(x) islogical(x) || isnumeric(x));
parser.addParameter('rxnList', {}, @(x) iscellstr(x) || isstring(x));
parser.addParameter('delta', 1e-9, @(x) isnumeric(x) && isscalar(x) && x >= 0);
parser.addParameter('pointIndex', [], @(x) isnumeric(x) || islogical(x));
parser.addParameter('threads', [], @(x) isempty(x) || (isnumeric(x) && isscalar(x)));
parser.addParameter('printLevel', 1, @(x) isnumeric(x) || islogical(x));
parser.parse(eco, varargin{:});
eco = parser.Results.eco;
updateBounds = parser.Results.updateBounds;
rxnList = cellstr(parser.Results.rxnList);
delta = parser.Results.delta;
pointIndex = parser.Results.pointIndex;
threads = parser.Results.threads;
printLevel = parser.Results.printLevel;

if isempty(eco.points)
    error('Grid points are not set yet! Run buildEcosystemGrid first.');
end
if ~isempty(rxnList)
    eco.rxn2cluster = rxnList(:);
end
if isempty(eco.rxn2cluster)
    if printLevel > 0
        fprintf('No reactions previously selected for FVA and clustering!\nSetting reactions to cluster...\n');
    end
    eco = setEcosystemClusterReactions(eco, 'printLevel', printLevel);
end
rxnList = eco.rxn2cluster;
missing = setdiff(rxnList, eco.model.rxns);
if ~isempty(missing)
    error('The following reactions are not in the community model: %s', strjoin(missing, ', '));
end

nPoints = size(eco.points, 1);
if isempty(pointIndex)
    if isempty(eco.feasiblePoints)
        if printLevel > 0
            fprintf('Warning: Feasible points have not been calculated. Running qualitative fva over full grid\n');
        end
        pointIndex = (1:nPoints)';
    else
        if printLevel > 0
            fprintf('Running qualitative fva over grid feasible points...\n');
        end
        pointIndex = find(eco.feasiblePoints);
    end
elseif islogical(pointIndex)
    pointIndex = find(pointIndex);
end
pointIndex = pointIndex(:);
pfractions = eco.pfractions;
if isempty(pfractions)
    pfractions = [eco.points(:, 1), 1 - eco.points(:, 1)];
end

nAnalyzed = numel(pointIndex);
nRxns = numel(rxnList);
qualVectors = zeros(nAnalyzed, nRxns);
fvaResults = zeros(nAnalyzed, nRxns, 2);
fvaOptions = {'optPercentage', 0, 'rxnNameList', rxnList, 'printLevel', 0};
if ~isempty(threads)
    fvaOptions = [fvaOptions, {'threads', threads}];
end
nInfeasible = 0;
for i = 1:nAnalyzed
    p = pointIndex(i);
    if printLevel > 1
        fprintf('point %d/%d: [%.4f %.4f]\n', i, nAnalyzed, eco.points(p, 1), eco.points(p, 2));
    end
    modelPoint = constrainEcosystemPoint(eco, eco.points(p, :), 'updateBounds', updateBounds, ...
        'pfraction', pfractions(p, :));
    try
        [minFlux, maxFlux] = fluxVariability(modelPoint, fvaOptions{:});
    catch ME
        if ~contains(ME.message, 'infeasible or unbounded')
            rethrow(ME);
        end
        % infeasible point (feasibility not computed): NaN fluxes, qualitative state 5
        minFlux = NaN(nRxns, 1);
        maxFlux = NaN(nRxns, 1);
        nInfeasible = nInfeasible + 1;
    end
    fvaResults(i, :, 1) = minFlux(:)';
    fvaResults(i, :, 2) = maxFlux(:)';
    qualVectors(i, :) = getQualitativeFluxStates(minFlux(:)', maxFlux(:)', delta);
end
eco.qualVectors = qualVectors;
eco.qualPointIndex = pointIndex;
eco.fvaResults = fvaResults;
eco.clusters = [];
eco.k = [];
if printLevel > 0
    fprintf('Qualitative FVA computed for %d points and %d reactions.\n', nAnalyzed, nRxns);
    if nInfeasible > 0
        fprintf('Warning: %d infeasible points (NaN fluxes, qualitative state 5).\n', nInfeasible);
    end
end
end
