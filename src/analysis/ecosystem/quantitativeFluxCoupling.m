function [qfca, selectedPoints] = quantitativeFluxCoupling(eco, gridX, gridY, rxnPair, varargin)
% Performs a quantitative flux coupling analysis (qFCA) between two
% reactions at selected points of the abundance-growth grid of an ecosystem.
% For each requested coordinate `[x, y]` the closest feasible grid point is
% selected and the community model is constrained to it. Then, the flux of
% the first reaction is fixed to `nSteps` values spanning its feasible range
% and the minimum and maximum fluxes of the second reaction are computed.
% Fluxes of member reactions are normalized by the member fraction (i.e.
% they are expressed per unit of member biomass).
%
% USAGE:
%
%    [qfca, selectedPoints] = quantitativeFluxCoupling(eco, gridX, gridY, rxnPair, varargin)
%
% INPUTS:
%    eco:              (structure) ecosystem structure with feasible points
%                      (see `checkEcosystemGridFeasibility`)
%    gridX:            (double) values of the member fraction `f` (x axis)
%    gridY:            (double) values of the community growth `mu` (y axis).
%                      Points are visited for each y (outer loop) and each x
%                      (inner loop)
%    rxnPair:          (cell array) IDs of the two reactions to analyze,
%                      e.g. `{'org1_EX_A', 'org2_EX_A'}`
%
% OPTIONAL INPUTS:
%    nSteps:           (double) number of values of the first reaction
%                      (Default = 50)
%    updateBounds:     (logical) scale the bounds of member reactions by the
%                      member fractions (Default = true)
%    printLevel:       (double) verbosity level (Default = 1)
%
% OUTPUTS:
%    qfca:             (table) table with variables `rxn1` (value of the
%                      first reaction), `rxn2` (minimum or maximum value of
%                      the second reaction), `FVA` ('minimum' or 'maximum')
%                      and `point` (coordinates of the grid point as text).
%                      The reaction IDs are stored in
%                      `qfca.Properties.UserData.rxnPair`
%    selectedPoints:   (double) indices of the selected grid points
%
% EXAMPLE:
%
%    qfca = quantitativeFluxCoupling(eco, [0.2 0.4 0.6 0.8], [60 40 20], {'org1_EX_A', 'org2_EX_A'});
%    plotQuantitativeFluxCoupling(qfca);
%
% NOTE:
%
%    Equivalent to `Ecosystem.quan_FCA` of the Python implementation.
%    Reactions that do not belong to a member are not normalized.
%
% .. Author: - Sebastián N. Mendoza, 13/10/2026, MATLAB implementation based on the Python code of N.E. Jiménez et al.

parser = inputParser();
parser.addRequired('eco', @(x) isstruct(x) && isfield(x, 'points') && isfield(x, 'feasiblePoints'));
parser.addRequired('gridX', @isnumeric);
parser.addRequired('gridY', @isnumeric);
parser.addRequired('rxnPair', @(x) (iscellstr(x) || isstring(x)) && numel(x) == 2);
parser.addParameter('nSteps', 50, @(x) isnumeric(x) && isscalar(x) && x >= 2);
parser.addParameter('updateBounds', true, @(x) islogical(x) || isnumeric(x));
parser.addParameter('printLevel', 1, @(x) isnumeric(x) || islogical(x));
parser.parse(eco, gridX, gridY, rxnPair, varargin{:});
eco = parser.Results.eco;
gridX = parser.Results.gridX(:)';
gridY = parser.Results.gridY(:)';
rxnPair = cellstr(parser.Results.rxnPair);
nSteps = parser.Results.nSteps;
updateBounds = parser.Results.updateBounds;
printLevel = parser.Results.printLevel;

if isempty(eco.feasiblePoints)
    error('Feasible points have not been computed. Run checkEcosystemGridFeasibility first.');
end
if ~all(ismember(rxnPair, eco.model.rxns))
    error('Reactions not found in the community model: %s', strjoin(rxnPair(~ismember(rxnPair, eco.model.rxns)), ', '));
end
if printLevel > 0
    fprintf('Quantitative Flux Coupling analysis\n Initializing grid...\n');
end
feasibleIdx = find(eco.feasiblePoints);
feasiblePoints = eco.points(feasibleIdx, :);
selectedPoints = [];
for y = gridY
    for x = gridX
        distances = sqrt(sum((feasiblePoints - [x, y]) .^ 2, 2));
        [dmin, iMin] = min(distances);
        selectedPoints(end + 1, 1) = feasibleIdx(iMin); %#ok<AGROW>
        if printLevel > 0
            fprintf('the closest point to [%g, %g] is [%.4f, %.4f], at a distance of %.4g\n', ...
                x, y, feasiblePoints(iMin, 1), feasiblePoints(iMin, 2), dmin);
        end
    end
end

% member that owns each reaction (0 = community reaction)
owner = zeros(1, 2);
for r = 1:2
    for k = 1:numel(eco.memberRxns)
        if any(strcmp(eco.memberRxns{k}, rxnPair{r}))
            owner(r) = k;
        end
    end
end

nRows = numel(selectedPoints) * nSteps * 2;
rxn1 = NaN(nRows, 1);
rxn2 = NaN(nRows, 1);
fvaType = cell(nRows, 1);
pointLabel = cell(nRows, 1);
row = 0;
for p = selectedPoints(:)'
    point = eco.points(p, :);
    pfraction = [point(1), 1 - point(1)];
    modelPoint = constrainEcosystemPoint(eco, point, 'updateBounds', updateBounds, 'pfraction', pfraction);
    normFactor = ones(1, 2);
    for r = 1:2
        if owner(r) > 0
            normFactor(r) = pfraction(owner(r));
        end
    end
    label = sprintf('[%s, %s]', num2str(round(point(1), 3)), num2str(round(point(2), 3)));
    if printLevel > 0
        fprintf('Selected point [%.4f %.4f], fractions [%.4f %.4f]\n', point(1), point(2), pfraction(1), pfraction(2));
    end
    [minRef, maxRef] = fluxVariability(modelPoint, 'optPercentage', 0, 'rxnNameList', rxnPair(1), 'printLevel', 0, 'threads', 1);
    values = linspace(minRef, maxRef, nSteps);
    rxnIdx = find(strcmp(modelPoint.rxns, rxnPair{1}));
    for val = values
        modelVal = modelPoint;
        modelVal.lb(rxnIdx) = val;
        modelVal.ub(rxnIdx) = val;
        try
            [minFlux, maxFlux] = fluxVariability(modelVal, 'optPercentage', 0, 'rxnNameList', rxnPair(2), 'printLevel', 0, 'threads', 1);
        catch
            [minFlux, maxFlux] = deal(NaN);
        end
        rxn1(row + 1) = val / normFactor(1);
        rxn2(row + 1) = minFlux / normFactor(2);
        fvaType{row + 1} = 'minimum';
        pointLabel{row + 1} = label;
        rxn1(row + 2) = val / normFactor(1);
        rxn2(row + 2) = maxFlux / normFactor(2);
        fvaType{row + 2} = 'maximum';
        pointLabel{row + 2} = label;
        row = row + 2;
    end
end
qfca = table(rxn1, rxn2, fvaType, pointLabel, 'VariableNames', {'rxn1', 'rxn2', 'FVA', 'point'});
qfca.Properties.UserData.rxnPair = rxnPair;
qfca.Properties.UserData.pointIndex = selectedPoints;
end
