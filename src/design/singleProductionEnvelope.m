function singleProductionEnvelope(model, deletions, product, biomassRxn, varargin)
% singleProductionEnvelope plots maximum growth rate as a function of the
% output of one specified products
%
% USAGE:
%    singleProductionEnvelope(model, deletions, product, biomassRxn, geneDelFlag, nPts)
%
% INPUTS:
%   model:            Type: structure (COBRA model)
%                     Description: a metabolic model with at least
%                     the following fields:
% 
%                       * .rxns - Reaction IDs in the model
%                       * .mets - Metabolite IDs in the model
%                       * .S -    Stoichiometric matrix (sparse)
%                       * .b -    RHS of Sv = b (usually zeros)
%                       * .c -    Objective coefficients
%                       * .lb -   Lower bounds for fluxes
%                       * .ub -   Upper bounds for fluxes
%    deletions:       The reactions or genes to knockout of the model
%    product:         The product to investigate
%    biomassRxn:      The biomass objective function rxn name
% OPTIONAL INPUTS:
%    geneDelFlag:     Perform gene and not reaction deletions
%                     Default = false
%    nPts:            Number of points to plot for each product
%                     Default = 20
%    savePlot:        Boolean for saving 
%                     Default = 0;
%    fileName:        Name of the file where the plot is saved.
%                     Default = product
%    outputFolder:    Name of the folder where files are saved
%                     Default = Results
%
% .. Author - Sebastian Mendoza, December 9th 2017, Center for Mathematical Modeling, University of Chile, snmendoz@uc.cl

parser = inputParser();
parser.addRequired('model', @(x) isstruct(x) && isfield(x, 'S') && isfield(model, 'rxns')...
    && isfield(model, 'mets') && isfield(model, 'lb') && isfield(model, 'ub') && isfield(model, 'b')...
    && isfield(model, 'c'))
parser.addRequired('deletions', @(x)  iscell(x) && ~isempty(x))
parser.addRequired('product', @(x) ischar(x) && ~isempty(x))
parser.addRequired('biomassRxn', @(x) ischar(x) && ~isempty(x))
parser.addParameter('geneDelFlag', 0, @(x) isnumeric(x) || islogical(x));
parser.addParameter('nPts', 20, @isnumeric);
parser.addParameter('savePlot', 0, @(x) isnumeric(x) || islogical(x));
parser.addParameter('fileName', product, @(x) ischar(x))
parser.addParameter('outputFolder', 'Results', @(x) ischar(x))

parser.parse(model, deletions, product, biomassRxn, varargin{:})
model = parser.Results.model;
product = parser.Results.product;
biomassRxn = parser.Results.biomassRxn;
geneDelFlag= parser.Results.geneDelFlag;
nPts = parser.Results.nPts;
savePlot = parser.Results.savePlot;
fileName = parser.Results.fileName;
outputFolder = parser.Results.outputFolder;

% Create model with deletions

if (geneDelFlag)
    modelKO = deleteModelGenes(model, deletions);
else
    modelKO = changeRxnBounds(model, deletions, zeros(size(deletions)), 'b');
end

% find range for biomass
model = changeObjective(model, biomassRxn);
fbasol = optimizeCbModel(model, 'max');
max = fbasol.f;
x = linspace(0, max, nPts);
ymin = zeros(nPts, 1);
ymax = zeros(nPts, 1);

for i = 1:nPts
    modelY = changeRxnBounds(model, biomassRxn, x(i), 'b');
    modelY = changeObjective(modelY, product);
    fmin = optimizeCbModel(modelY, 'min');
    fmax = optimizeCbModel(modelY, 'max');
    ymin(i) = fmin.f;
    ymax(i) = fmax.f;
end
f = figure;
set(gcf, 'Visible', 'Off');
plot(x, ymin, x, ymax, 'LineWidth', 2);

% find range for biomass using K.O.s
modelKO = changeObjective(modelKO, biomassRxn);
fbasol = optimizeCbModel(modelKO, 'max');
max = fbasol.f;
target = fbasol.x(strcmp(modelKO.rxns, product));
x2 = linspace(0,max,nPts);
ymin_KO = zeros(nPts,1);
ymax_KO = zeros(nPts,1);

for i = 1:nPts
    modelY = changeRxnBounds(modelKO, biomassRxn, x2(i), 'b');
    modelY = changeObjective(modelY, product);
    fmin = optimizeCbModel(modelY, 'min');
    fmax = optimizeCbModel(modelY, 'max');
    ymin_KO(i) = fmin.f;
    ymax_KO(i) = fmax.f;
end

% plot
hold on
plot(x2, ymin_KO, 'r', x2, ymax_KO, 'm', 'LineWidth', 2);
legend('Minimun Wild-type', 'Maximun Wild-type', 'Minimun Mutant', 'Maximun Mutant')
ylabel([strrep(product, '_', '\_'), ' (mmol/gDW h)']);
xlabel('Growth Rate (1/h)');

%plot optKnock sol
plot(max, target, 'Marker', 'o', 'Color', [0 0 0], 'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor', [0.5 0.5 0.5], 'MarkerSize', 10);

if savePlot
    %directory change
    fullPath = which('optKnockTutorial');
    folder = fileparts(fullPath);
    currectDirectory = pwd;
    cd(folder);
    NewDirectory = outputFolder;
    if ~isdir(NewDirectory)
        mkdir(NewDirectory)
    end
    cd(NewDirectory)
    
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperPosition', [0 0 20 10]);
    saveas(gcf,[fileName '.png'])
    set(gcf, 'PaperOrientation', 'landscape');
    set(gcf, 'PaperPosition', [1 1 28 19]);
    saveas(f,[fileName '.pdf'])
    close(f);
    cd(currectDirectory)
    
end

end