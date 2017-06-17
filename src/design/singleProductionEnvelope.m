function [x , y] = singleProductionEnvelope(model, deletions, prod, biomassRxn, fileName, geneDelFlag, nPts)
% singleProductionEnvelope plots maximum growth rate as a function of the
% output of one specified products
%
% USAGE: 
%    [x, y] = doubleProductionEnvelope(model, deletions, prod, biomassRxn, geneDelFlag, nPts)
%
% INPUTS:
%    model          COBRA model structure
%    deletions      The reactions or genes to knockout of the model
%    prod           One of the two products to investigate
%
% OPTIONAL INPUTS:
%    biomassRxn     The biomass objective function rxn name
%                   (Default = 'biomass_SC4_bal')
%    geneDelFlag    Perform gene and not reaction deletions
%                   (Default = false)
%    nPts           Number of points to plot for each product
%                   (Default = 20)
%
% OUTPUTS:
%    x            The range of rates plotted for prod
%    y             The plotted growth rates at each x
%
% .. Author: Sebastian Mendoza 9/12/07

if (nargin < 6)
    geneDelFlag = false;
end
if (nargin < 7)
    nPts = 20;
end

% Create model with deletions
if (length(deletions) > 0)
    if (geneDelFlag)
        modelKO = deleteModelGenes(model,deletions);
    else
        modelKO = changeRxnBounds(model,deletions,zeros(size(deletions)),'b');
    end
end

% find range for biomass
model = changeObjective(model,biomassRxn);
fbasol = optimizeCbModel(model,'max');
max=fbasol.f;
x = linspace(0,max,nPts);
ymin = zeros(nPts,1);
ymax = zeros(nPts,1);

for i = 1:nPts
    modelY = changeRxnBounds(model,biomassRxn,x(i),'b');
    modelY = changeObjective(modelY,prod);
    fmin=optimizeCbModel(modelY,'min');
    fmax=optimizeCbModel(modelY,'max');
    ymin(i)=fmin.f;
    ymax(i)=fmax.f;
end
f=figure;
set(gcf,'Visible','Off');
plot(x,ymin,x,ymax,'LineWidth',2);

% find range for biomass using K.O.s
modelKO = changeObjective(modelKO,biomassRxn);
fbasol = optimizeCbModel(modelKO,'max');
max=fbasol.f;
target=fbasol.x(strcmp(modelKO.rxns,prod));
x2 = linspace(0,max,nPts);
ymin_KO = zeros(nPts,1);
ymax_KO = zeros(nPts,1);

for i = 1:nPts
    modelY = changeRxnBounds(modelKO,biomassRxn,x2(i),'b');
    modelY = changeObjective(modelY,prod);
    fmin=optimizeCbModel(modelY,'min');
    fmax=optimizeCbModel(modelY,'max');
    ymin_KO(i)=fmin.f;
    ymax_KO(i)=fmax.f;
end

% plot
hold on
plot(x2,ymin_KO,'r',x2,ymax_KO,'m','LineWidth',2);
legend('Minimun Wild-type','Maximun Wild-type','Minimun Mutant','Maximun Mutant')
ylabel([strrep(prod,'_','\_'),' (mmol/gDW h)']);
xlabel('Growth Rate (1/h)');

%plot optKnock sol
plot(max,target,'Marker','o','Color',[0 0 0],'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[0.5 0.5 0.5],'MarkerSize',10);

%directory change
currectDirectory=pwd;
NewDirectory=[currectDirectory '\OptKnock_Results'];
if exist(NewDirectory,'dir')==0
    mkdir(NewDirectory)
end
cd(NewDirectory)

set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperPosition', [0 0 20 10]);
% saveas(gcf,[fileName '.png'])
saveas(f,[fileName '.pdf'])
close(f);
cd(currectDirectory)

end


