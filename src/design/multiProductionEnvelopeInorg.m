function [biomassValues,targetValues] = multiProductionEnvelopeInorg(model,deletions,biomassRxn,geneDelFlag,nPts,plotAllFlag)
% Calculates the byproduct secretion envelopes
% for every product, including inorganic compounds
%
% USAGE:
%
%    [biomassValues, targetValues] = multiProductionEnvelopeInorg(model, deletions, biomassRxn, geneDelFlag, nPts, plotAllFlag)
%
% INPUT:
%    model:         COBRA model structure
%
% OPTIONAL INPUT:
%    deletions:     List of reaction or gene deletions (empty if wild type)
%                   (Default = {})
%    biomassRxn:    Biomass rxn name (Default = whatever is defined in model)
%    geneDelFlag:   Perform gene and not reaction deletions (Default = false)
%    nPts:          Number of points in the plot (Default = 20)
%    plotAllFlag:   Plots all envelopes, even ones that are not growth coupled
%                   (Default = false)
%
% OUTPUT:
%    biomassValues: Biomass values for plotting
%    targetValues:  Target upper and lower bounds for plotting
%
% .. Author: - Jeff Orth 5/1/08

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
    plotAllFlag = false;
end


% Create model with deletions
if (length(deletions) > 0)
    if (geneDelFlag)
        model = deleteModelGenes(model,deletions);
    else
        model = changeRxnBounds(model,deletions,zeros(size(deletions)),'b');
    end
end

%get all exchange reactions
[selExc,selUpt] = findExcRxns(model,false,false);
excRxns = [];
for i = 1:length(model.rxns)
   if selExc(i) && ~selUpt(i)
       excRxns = [excRxns,model.rxns(i)];
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
for i = 1:length(excRxns)
    model = changeObjective(model,excRxns(i),1);
    model2 = changeRxnBounds(model,biomassRxn,max(biomassValues),'b');
    fbasol2 = optimizeCbModel(model2,'max');
    maxRate = fbasol2.f; %find max production at max growth rate
    if (plotAllFlag)||(maxRate > 0.5) %only plot growth coupled solutions
        plottedRxns = [plottedRxns,i];
        for j = 1:length(biomassValues)
            model = changeRxnBounds(model,biomassRxn,biomassValues(j),'b');
            sol = optimizeCbModel(model,'max');
            if (sol.stat > 0)
                targetUpperBound(i,j) = sol.f;
            else
                targetUpperBound(i,j) = NaN;
            end
            sol = optimizeCbModel(model,'min');
            if (sol.stat > 0)
                targetLowerBound(i,j) = sol.f;
            else
                targetLowerBound(i,j) = NaN;
            end
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
legend(excRxns(plottedRxns));
legend off;
ylabel('Production Rate (mmol/gDW h)');
xlabel('Growth Rate (1/h)');
plottools, plotbrowser('on'), figurepalette('hide'), propertyeditor('off');

biomassValues = biomassValues';
targetValues = [targetLowerBound' targetUpperBound'];
