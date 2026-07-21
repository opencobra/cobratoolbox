function line = addEnv(origModel, biomass, desiredProduct, varargin)
% addEnv adds a production envelope to the current figure
%
% Adds a production envelope (with optional knockouts) to the active figure.
% The algorithm is able to knock out genes as well as reactions to produce
% the production envelope.
%
% USAGE:
%
%    line = addEnv(origModel, biomass, desiredProduct, varargin)
%
% INPUTS:
%    origModel:         COBRA model structure with fields:
%
%                         * .S - Stoichiometric matrix
%                         * .rxns - Reaction identifiers
%                         * .mets - Metabolite identifiers
%                         * .lb - Lower bounds
%                         * .ub - Upper bounds
%                         * .b - Right hand side values for metabolite constraints
%                         * .c - Objective coefficients
%    biomass:           Reaction name of biomass [char]
%    desiredProduct:    Reaction name of desired product [char]
%
% OPTIONAL INPUTS:
%    KnockOuts:         List of knockouts (reaction or gene IDs) for the
%                       production envelope [cell array] (default: {})
%    colour:            Colour of the plotted line (any valid MATLAB colour)
%                       (default: 'r')
%    prodMol:           Molar mass of the target product for a yield plot
%                       [double] (default: [])
%    subUptake:         Uptake of substrate for a yield plot [double]
%                       (default: 10)
%    molarSum:          Molar mass of substrate for a yield plot [double]
%                       (default: 180)
%
% OUTPUTS:
%    line:              Line object returned by `plot` for the maximum edge
%                       of the envelope
%
% NOTE:
%    Sometimes the last point of the envelope drops to zero (possibly a
%    rounding error); this function connects the last points of the lines so
%    the graph forms a continuous line. This algorithm only adds the graph;
%    it does not change labels.
%
% EXAMPLE:
%
%    line = addEnv(model, 'BIOMASS_Ecoli', 'EX_ac_e', {'GHMT2r', 'GND'}, 'm')
%
% .. Authors:
%       - Kristaps Berzins, 31/10/2022, created
%       - Kristaps Berzins, 30/09/2024, modified

parser = inputParser();
parser.addRequired('model', @(x) isstruct(x) && isfield(x, 'S') && isfield(origModel, 'rxns')...
    && isfield(origModel, 'mets') && isfield(origModel, 'lb') && isfield(origModel, 'ub') && isfield(origModel, 'b')...
    && isfield(origModel, 'c'))
parser.addRequired('biomass', @(x) any(validatestring(x, origModel.rxns)))
parser.addRequired('desiredProduct', @(x) any(validatestring(x, origModel.rxns)))
parser.addOptional('KnockOuts', {}, @(x) iscell(x) && ismatrix(x))
parser.addOptional('colour', 'r', @(x) any(validatecolor(x)))
parser.addOptional('prodMol', [], @(x) isnumeric(x))
parser.addOptional('subUptake', 10, @(x) isnumeric(x))
parser.addOptional('molarSum', 180, @(x) isnumeric(x))

parser.parse(origModel, biomass, desiredProduct, varargin{:});
origModel = parser.Results.model;
biomass = parser.Results.biomass;
desiredProduct = parser.Results.desiredProduct;
KnockOuts = parser.Results.KnockOuts;
colour = parser.Results.colour;
prodMol = parser.Results.prodMol;
subUptake = parser.Results.subUptake;
molarSum = parser.Results.molarSum;

if isempty(prodMol)
    prodMolIs = false;
else
    prodMolIs = true;
end

model = origModel;

if any(ismember(model.rxns, KnockOuts))
    rxns = ismember(model.rxns, KnockOuts);
    model.ub(rxns) = 0;
    model.lb(rxns) = 0;
elseif any(ismember(model.genes, KnockOuts))
    model = buildRxnGeneMat(model);
    [model, ~, ~] = deleteModelGenes(model, KnockOuts);
%elseif %Enzymes
end

solMin = optimizeCbModel(model, 'min');
solMax = optimizeCbModel(model, 'max');
controlFlux1 = linspace(solMin.f, solMax.f, 100)';
if nnz(controlFlux1) == 0
    return;
end
model = changeObjective(model, desiredProduct);

for i = 1:numel(controlFlux1)
    model = changeRxnBounds(model, biomass, controlFlux1(i), 'b');
    s = optimizeCbModel(model, 'min'); Min1(i, 1) = s.f;
    if s.stat == 0
        model = changeRxnBounds(model, biomass, controlFlux1(i) - 0.0001 * controlFlux1(i), 'b');
        s = optimizeCbModel(model, 'min'); Min1(i, 1) = s.f;
        s = optimizeCbModel(model, 'max'); Max1(i, 1) = s.f;
    end
    s = optimizeCbModel(model, 'max'); Max1(i, 1) = s.f;
    if s.stat == 0
        model = changeRxnBounds(model, biomass, controlFlux1(i) - 0.0001 * controlFlux1(i), 'b');
        s= optimizeCbModel(model,'min');Min1(i,1)=s.f;
        s= optimizeCbModel(model,'max');Max1(i,1)=s.f;
    end
end

if prodMolIs
    controlFlux1 = controlFlux1 / subUptake * 1000 / molarSum;
    Max1 = Max1 / molarSum * prodMol / subUptake;
    Min1 = Min1 / molarSum * prodMol / subUptake;
end

hold on
line = plot(controlFlux1, Max1, 'color', colour, 'LineWidth', 2);
plot(controlFlux1, Min1, 'color', colour, 'LineWidth', 2)
hold off

