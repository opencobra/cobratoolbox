function [biomassValues, targetValues] = multiProductionEnvelope(model, deletions, biomassRxn, geneDelFlag, nPts, plotTools)
% Calculates the byproduct secretion envelopes for
% every product (excreted metabolites with 1 or more Carbons)
%
% USAGE:
%
%    [biomassValues, targetValues] = multiProductionEnvelope(model, deletions, biomassRxn, geneDelFlag, nPts, plotTools)
%
% INPUT:
%    model:            COBRA model structure
%
% OPTIONAL INPUT:
%    deletions:        List of reaction or gene deletions (empty if wild type)
%                      (Default = {})
%    biomassRxn:       Biomass `rxn` name (Default = whatever is defined in model)
%    geneDelFlag:      Perform gene and not reaction deletions (Default = false)
%    nPts:             Number of points in the plot (Default = 20)
%    plotTools:        boolean (default = false) - add tools for editing the figure and its properties
%
% OUTPUT:
%    biomassValues:    Biomass values for plotting
%    targetValues:     Target upper and lower bounds for plotting
%
% .. Author: - Jeff Orth 8/16/07

if (nargin < 2)
    deletions = {};
end
if (nargin < 3)
    % Biomass flux
    biomassRxn = model.rxns(model.c==1);
end
if (nargin < 4)
    % Gene or rxn deletions
    geneDelFlag = false;
end
if (nargin < 5)
    nPts = 20;
end
if (nargin < 6)
    plotTools = false;
end

% Create model with deletions
if (length(deletions) > 0)
    if (geneDelFlag)
        model = deleteModelGenes(model,deletions);
    else
        model = changeRxnBounds(model,deletions,zeros(size(deletions)),'b');
    end
end

%get all C exchange reactions
excRxns = model.rxns(findExcRxns(model,false,false));
CRxns = findCarbonRxns(model,1);
CExcRxns = intersect(excRxns,CRxns);
substrateIDs = find(model.lb(findRxnIDs(model,CExcRxns))<0);
%remove the substrate reactions
for i = 1:length(substrateIDs)
    j = substrateIDs(i);
    if j == 1
        CExcRxns = CExcRxns(2:length(CExcRxns));
    elseif j == length(CExcRxns)
        CExcRxns = CExcRxns(1:length(CExcRxns)-1);
    else
        CExcRxns = cat(1,CExcRxns(1:j-i),CExcRxns(j-i+2:length(CExcRxns)));
    end
end


% Run FBA to get upper bound for biomass
model = changeObjective(model,biomassRxn,1);
solMax = optimizeCbModel(model,'max');
solMin = optimizeCbModel(model,'min');

% Create biomass range vector
biomassValues = linspace(solMin.f,solMax.f,nPts);

plottedRxns = [];
targetUpperBound = [];
targetLowerBound = [];
% Max/min for target production
for i = 1:length(CExcRxns)
    model = changeObjective(model,CExcRxns(i),1);
    model2 = changeRxnBounds(model,biomassRxn,max(biomassValues),'b');
    fbasol2 = optimizeCbModel(model2,'max');
    maxRate = fbasol2.f; %find max production at max growth rate
        plottedRxns = [plottedRxns,i];
        for j = 1:length(biomassValues)
            model = changeRxnBounds(model,biomassRxn,biomassValues(j),'b');
            sol = optimizeCbModel(model,'max');
            if (sol.stat = 1)
                targetUpperBound(i,j) = sol.f;
            elseif (sol.stat = 2)
                targetUpperBound(i,j) = Inf;
            else
                targetUpperBound(i,j) = NaN;
            end
            sol = optimizeCbModel(model,'min');
            if (sol.stat = 1)
                targetLowerBound(i,j) = sol.f;
            elseif (sol.stat = 2)
                  targetUpperBound(i,j) = Inf;
            else
                targetLowerBound(i,j) = NaN;
            end
        end
end

% Plot results
colors = {'b','g','r','c','m','y','k'};
for i = 1:length(plottedRxns)
    plot([biomassValues fliplr(biomassValues)],[targetUpperBound(plottedRxns(i),:) fliplr(targetLowerBound(plottedRxns(i),:))],colors{mod(i-1,length(colors))+1},'LineWidth',2)
    axis tight;
    hold on;
end
hold off;
legend(CExcRxns(plottedRxns));
legend off;
ylabel('Production Rate (mmol/gDW h)');
xlabel('Growth Rate (1/h)');
if plotTools
    plottools, plotbrowser('on'), figurepalette('hide'), propertyeditor('off');
end
biomassValues = biomassValues';
targetValues = [targetLowerBound' targetUpperBound'];
