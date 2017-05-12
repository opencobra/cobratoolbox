function [growthRates,shadowPrices1,shadowPrices2] = phenotypePhasePlane(model,controlRxn1,controlRxn2,nPts,range1,range2)
%phenotypePhasePlane Plots three phenotype phase planes for two reactions.  The first plot is
% a double robustness analysis, a kind of 3D surface plot.  The second
% two plots show the shadow prices of the metabolites from the two control
% reactions, which define the phases.  Use the COLORMAP and SHADING
% functions to change the looks of the plots.
%
% [growthRates,shadowPrices1,shadowPrices2] = phenotypePhasePlane(model,controlRxn1,controlRxn2,nPts,range1,range2)
%
%INPUTS
% model             COBRA model structure
% controlRxn1       the first reaction to be plotted
% controlRxn2       the second reaction to be plotted
%
%OPTIONAL INPUTS
% nPts              the number of points to plot in each dimension
%                   (Default = 50)
% range1            the range of reaction 1 to plot
%                   (Default = 20)
% range2            the range of reaction 2 to plot
%                   (Default = 20)
%
%OUTPUTS
% growthRates1      a matrix of maximum growth rates
% shadowPrices1     a matrix of rxn 1 shadow prices
% shadowPrices2     a matrix of rxn 2 shadow prices
%
% Jeff Orth 6/26/08

if (nargin < 4)
    nPts = 50;
end
if (nargin < 5)
    range1 = 20;
end
if (nargin < 6)
    range2 = 20;
end

% find rxn and met ID numbers to get shadow prices and reduced costs
rxnID1 = findRxnIDs(model,controlRxn1);
metID1 = find(model.S(:,rxnID1));
rxnID2 = findRxnIDs(model,controlRxn2);
metID2 = find(model.S(:,rxnID2));

% create empty vectors for the results
ind1 = linspace(0,range1,nPts);
ind2 = linspace(0,range2,nPts);
growthRates = zeros(nPts);
shadowPrices1 = zeros(nPts);
shadowPrices2 = zeros(nPts);

% calulate points
showprogress(0,'generating PhPP');
global CBT_LP_PARAMS  % save the state of the primal only flag.
if isfield( CBT_LP_PARAMS, 'primalOnly')
    primalOnlySave = CBT_LP_PARAMS.primalOnly;
end
changeCobraSolverParams('LP', 'primalOnly', false);
for i = 1:nPts %ind1
    for j = 1:nPts %ind2
        showprogress((nPts*(i-1)+j)/(nPts^2));
        model1 = changeRxnBounds(model,controlRxn1,-1*ind1(i),'b');
        model1 = changeRxnBounds(model1,controlRxn2,-1*ind2(j),'b');

        fbasol = optimizeCbModel(model1,'max');
        growthRates(j,i) = fbasol.f;
        try % calculate shadow prices
            shadowPrices1(j,i) = fbasol.y(metID1(1));
            shadowPrices2(j,i) = fbasol.y(metID2(1));
        end
    end
end

if exist('primalOnlySave', 'var')
    changeCobraSolverParams('LP', 'primalOnly', primalOnlySave);
else
    changeCobraSolverParams('LP', 'primalOnly', true);
end

% plot the points
figure(2);
pcolor(ind1,ind2,shadowPrices1);
xlabel(strrep(strcat(controlRxn1,' (mmol/g DW-hr)'),'_','\_')), ylabel(strrep(strcat(controlRxn2,' (mmol/g DW-hr)'),'_','\_')), zlabel('growth rate (1/hr)');
figure(3);
pcolor(ind1,ind2,shadowPrices2);
xlabel(strrep(strcat(controlRxn1,' (mmol/g DW-hr)'),'_','\_')), ylabel(strrep(strcat(controlRxn2,' (mmol/g DW-hr)'),'_','\_')), zlabel('growth rate (1/hr)');
figure(1);
surfl(ind1,ind2,growthRates);
xlabel(strrep(strcat(controlRxn1,' (mmol/g DW-hr)'),'_','\_')), ylabel(strrep(strcat(controlRxn2,' (mmol/g DW-hr)'),'_','\_')), zlabel('growth rate (1/hr)');
