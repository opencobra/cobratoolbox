function [ParetoFrontier, fluxSolutions, minFluxes, maxFluxes] = computeParetoOptimality(model, rxn1, rxn2, varargin)
% Performs Pareto optimality analysis for two objective functions by
% simultaneously optimizing two reactions (e.g., the biomass objective
% functions of two joined organisms). The result is a depiction of the
% tradeoff between the two competing objectives.
%
% Multiobjective analysis of two reactions is performed by using the
% approach described in Oberhardt, M. A., J. B. Goldberg, et al. (2010).
% "Metabolic network analysis of Pseudomonas aeruginosa during chronic
% cystic fibrosis lung infection." J Bacteriol 192(20): 5534-5548. One
% reaction is fixed at different intervals and the other reaction is
% optimized.
%
% USAGE:
%
%     [ParetoFrontier,fluxSolutions,minFluxes,maxFluxes] = computeParetoOptimality(model,rxn1,rxn2,dinc,FVAflag)
%
% INPUTS:
%     model:            COBRA metabolic reconstruction
%     rxn1:             Reaction ID of the first reaction to be optimized
%     rxn2:             Reaction ID of the second reaction to be optimized
%
% OPTIONAL INPUTS:
%     dinc:             An index which indicates the distance between steps at
%                       which the flux of each reaction is fixed (default=0.001).
%     FVAflag:          If true, flux variability analysis is performed at each
%                       step.
%
% OUTPUTS:
%     ParetoFrontier:   Lists the objective values for both reactions next to
%                       the interval step. Column 1:the interval step. Column 2
%                       and 3: the flux values of rxn1 in and rxn2,
%                       respectively, at the interval step.
%
% OPTIONAL OUTPUTS:
%     fluxSolutions:    Contains the flux solutions every interval step as a
%                       matrix of structures
%     minFluxes:        Reports fastFVA results for every step (minFlux) with
%                       one column for each interval step
%     maxFluxes:        Reports fastFVA results for every step (maxFlux) with
%                       one column for each interval step
%
% .. Author:
%    - Almut Heinken, 2011-2018. Last modified 03/2018

% Define default input parameters if not specified
parser = inputParser();
parser.addRequired('model', @isstruct);
parser.addRequired('rxn1', @(x) ischar(x) || iscell(x))
parser.addRequired('rxn2', @(x) ischar(x) || iscell(x))
parser.addParameter('dinc', 0.001, @(x) isnumeric(x))
parser.addParameter('FVAflag', false, @(x) isnumeric(x) || islogical(x))

parser.parse(model, rxn1, rxn2, varargin{:})

model = parser.Results.model;
rxn1 = parser.Results.rxn1;
rxn2 = parser.Results.rxn2;
dinc = parser.Results.dinc;
FVAflag = parser.Results.FVAflag;

% set a solver if not done yet
global CBT_LP_SOLVER
solver = CBT_LP_SOLVER;
if isempty(solver)
    initCobraToolbox(false); %Don't update the toolbox automatically
end

% Find the range of possible optimal values for both objective functions
model = changeObjective(model, rxn1);
model.osenseStr = 'max';
[solution] = solveCobraLP(buildLPproblemFromModel(model));
dmaxRxn1 = solution.obj;
model = changeObjective(model, rxn2);
model.osenseStr = 'min';
[solution] = solveCobraLP(buildLPproblemFromModel(model));
dminRxn1 = solution.obj;
model = changeObjective(model, rxn2);
model.osenseStr = 'max';
[solution] = solveCobraLP(buildLPproblemFromModel(model));
dmaxRxn2 = solution.obj;
model = changeObjective(model, rxn2);
model.osenseStr = 'min';
[solution] = solveCobraLP(buildLPproblemFromModel(model));
dminRxn2 = solution.obj;

% Find the indices for both reactions so the computed fluxes can be
% retrieved
rxnID1 = find(ismember(model.rxns, rxn1));
rxnID2 = find(ismember(model.rxns, rxn2));

% Start the computation of the Pareto frontier
model.osenseStr = 'max';
ParetoFrontier{1, 1} = 'Index';
ParetoFrontier{1, 2} = rxn1;
ParetoFrontier{1, 3} = rxn2;
cnt = 1;
minFluxes = {};
maxFluxes = {};

% optimize the second reaction and fix the flux through the first reaction
modelOri = model;
model = changeObjective(model, rxn2);
for i = dminRxn1:dinc:dmaxRxn1
    model = changeRxnBounds(model, rxn1, i, 'b');
    model.osense = -1;
    [solution] = solveCobraLP(buildLPproblemFromModel(model));
    if solution.stat == 1
        ParetoFrontier{cnt + 1, 1} = i;
        ParetoFrontier{cnt + 1, 2} = solution.full(rxnID1);
        ParetoFrontier{cnt + 1, 3} = solution.full(rxnID2);
        fluxSolutions{:, cnt} = solution;
    else
        ParetoFrontier{cnt + 1, 1} = i;
        ParetoFrontier{cnt + 1, 2} = NaN;
        ParetoFrontier{cnt + 1, 3} = NaN;
    end
    % is flux variability analysis is performed
    if FVAflag == true
        [minFlux, maxFlux, optsol, ret] = fastFVA(model, 99.9, 'max');
        minFluxes(:, cnt) = minFlux;
        maxFluxes(:, cnt) = maxFlux;
    end
    cnt = cnt + 1;
end
model = modelOri;

% optimize the first reaction and fix the flux through the second reaction
model = changeObjective(model, rxn1);
for i = dminRxn2:dinc:dmaxRxn2
    model = changeRxnBounds(model, rxn2, i, 'b');
    model.osense = -1;
    [solution] = solveCobraLP(buildLPproblemFromModel(model));
    if solution.stat == 1
        ParetoFrontier{cnt + 1, 1} = i;
        ParetoFrontier{cnt + 1, 2} = solution.full(rxnID1);
        ParetoFrontier{cnt + 1, 3} = solution.full(rxnID2);
        fluxSolutions{:, cnt} = solution;
    else
        ParetoFrontier{cnt + 1, 1} = i;
        ParetoFrontier{cnt + 1, 2} = NaN;
        ParetoFrontier{cnt + 1, 3} = NaN;
    end
    % is flux variability analysis is performed
    if FVAflag == true
        [minFlux, maxFlux, optsol, ret] = fastFVA(model, 99.9, 'max');
        minFluxes(:, cnt) = minFlux;
        maxFluxes(:, cnt) = maxFlux;
    end
    cnt = cnt + 1;
end

% plot the resulting Pareto frontier and save the plot
figure;
fluxes1 = cell2mat(ParetoFrontier(2:end, 2));
fluxes2 = cell2mat(ParetoFrontier(2:end, 3));
scatter(fluxes1, fluxes2);
h = xlabel(rxn1);
set(h, 'interpreter', 'none');
h = ylabel(rxn2);
set(h, 'interpreter', 'none');
title('Pareto optimality analysis')

end
