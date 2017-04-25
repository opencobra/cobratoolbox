function [x1,x2,y] = doubleProductionEnvelope(model,deletions,prod1,prod2,biomassRxn,geneDelFlag,nPts)
% Plots maximum growth rate as a function of the
% output of two specified products
%
% USAGE:
%
%    [x1, x2, y] = doubleProductionEnvelope(model, deletions, prod1, prod2, biomassRxn, geneDelFlag, nPts)
%
% INPUTS:
%    model:         COBRA model structure
%    deletions:     The reactions or genes to knockout of the model
%    prod1:         One of the two products to investigate
%    prod2:         The other product to investigate
%
% OPTIONAL INPUTS:
%    biomassRxn:    The biomass objective function rxn name
%                   (Default = 'biomass_SC4_bal')
%    geneDelFlag:   Perform gene and not reaction deletions
%                   (Default = false)
%    nPts:          Number of points to plot for each product
%                   (Default = 20)
%
% OUTPUTS:
%    x1:            The range of rates plotted for `prod1`
%    x2:            The range of rates plotted for `prod2`
%    y:             The plotted growth rates at each (`x1`, `x2`)
%
% .. Author: - Jeff Orth  9/12/07

if (nargin < 5)
    biomassRxn = 'biomass_SC4_bal';
end
if (nargin < 6)
    geneDelFlag = false;
end
if (nargin < 7)
    nPts = 20;
end

% Create model with deletions
if (length(deletions) > 0)
    if (geneDelFlag)
        model = deleteModelGenes(model,deletions);
    else
        model = changeRxnBounds(model,deletions,zeros(size(deletions)),'b');
    end
end

% find range for prod1
modelFixed1 = changeRxnBounds(model,biomassRxn,0,'b');
modelFixed1 = changeObjective(modelFixed1,prod1);
fbasol1 = optimizeCbModel(modelFixed1,'max');
max1 = fbasol1.f;

% find range for prod2
modelFixed2 = changeRxnBounds(model,biomassRxn,0,'b');
modelFixed2 = changeObjective(modelFixed2,prod2);
fbasol2 = optimizeCbModel(modelFixed2,'max');
max2 = fbasol2.f;

% vary both ranges, find max growth rate
x1 = linspace(0,max1,nPts);
x2 = linspace(0,max2,nPts);
y = zeros(nPts);

for i = 1:nPts
    for j = 1:nPts
        prod1val = x1(i);
        prod2val = x2(j);
        modelY = changeRxnBounds(model,prod1,prod1val,'b');
        modelY = changeRxnBounds(modelY,prod2,prod2val,'b');
        fbasol = optimizeCbModel(modelY,'max');
        y(j,i) = fbasol.f; %no, this isn't a mistake (probably)
    end
end

% plot
surf(x1,x2,y);
alpha(.4);
xlabel([strrep(prod1,'_','\_'),' (mmol/gDW h)']);
ylabel([strrep(prod2,'_','\_'),' (mmol/gDW h)']);
zlabel('Growth Rate (1/h)');
