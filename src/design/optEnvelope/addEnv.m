function line = addEnv(origModel, biomass, desiredProduct, varargin)
% addEnv adds envelope to figure
% Algorithm is able to knock out genes as well as reactions to produce
% production envelope
%
%INPUT
%  origModel         COBRA model structure
%  biomass           Reaction name of biomass
%  desiredProduct    Reaction name of desired product
%  KnockOuts         (opt) List of knockouts for production envelope (default: {})
%  colour            (opt) Short name for colour of line to plot (default: 'r' (red))
%  prodMol           (opt) Molar mass of target product for yield plot
%  subUptake         (opt) Uptake of substrate for yield plot
%  molarSum          (opt) Molar mass of substrate for yield plot
%
%OUTPUT
%  line              Line data for plot function
%
%NOTES
%  Sometimes last point of envelope drops to zero (might be rounding error)
%  but this function connects last points of lines so the graph creates
%  continuous line.
% This algorithm only adds graph. It does not change labels.
%
% Created by Kristaps Berzins    31/10/2022
% Modified by Kristaps Berzins   30/09/2024

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

