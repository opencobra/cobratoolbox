function plotFeasibleReactionEnergyRanges(modelT)
% Plots feasible dGr0' and dGr' for all reactions with quantitatively
% determined reaction energies
%
% USAGE:
%
%    plotFeasibleReactionEnergyRanges(modelT)
%
% INPUT:
%    modelT:

nRxn = size(modelT.rxns,2);

Y1 = [];
LMatrix1 = [];
UMatrix1 = [];
reactions = {};

for n = 1:nRxn
        Y1 = [Y1; (modelT.DrGtMax(n) - ((modelT.DrGtMax(n,1) - modelT.DrGtMin(n))/2))];
        LMatrix1 = [LMatrix1; abs(modelT.DrGtMin(n) - Y1(end)), abs(modelT.DrGtMin(n) - Y1(end))];
        UMatrix1 = [UMatrix1; abs(Y1(end) - modelT.DrGtMax(n)), abs(Y1(end) - modelT.DrGtMax(n))];
end

[Y1, crossIndices] = sortrows(Y1);
LMatrix1 = LMatrix1(crossIndices,:);
UMatrix1 = UMatrix1(crossIndices,:);

xvector = 1:size(Y1,1);
X1 = xvector';

figure1 = figure('PaperType','<custom>','PaperOrientation','landscape');

% Divide plot area into irreversible/reversible with colored bars in background
% X2 = [find(sorted(:,1) == -1); find(sorted(:,1) == 1)];
% bar1 = bar(X2,1000*ones(length(X2),1),1,'BaseValue',-1000,'FaceColor',[0.86 0.86 0.86],'EdgeColor','none');
%
% hold on

% Create multiple error bars using matrix input to errorbar
errorbar1 = errorbar(X1,Y1,LMatrix1(:,1),UMatrix1(:,1),'LineStyle','none',...
    'LineWidth',2,...
    'DisplayName','forwardReversible');
set(errorbar1,'LineStyle','none','LineWidth',2 ,'Color',[1 0 0]);
hE_c=get(errorbar1, 'Children');
errorbarXData= get(hE_c(2), 'XData');
errorbarXData(4:9:end) = errorbarXData(1:9:end) - 0;
errorbarXData(7:9:end) = errorbarXData(1:9:end) - 0;
errorbarXData(5:9:end) = errorbarXData(1:9:end) + 0;
errorbarXData(8:9:end) = errorbarXData(1:9:end) + 0;
set(hE_c(2), 'XData', errorbarXData);

hold on

errorbar2 = errorbar(X1,Y1,LMatrix1(:,2),UMatrix1(:,2),'LineStyle','none',...
    'LineWidth',2,...
    'DisplayName','forwardReversible');
set(errorbar2,'LineStyle','none','LineWidth',2,'Color',[0 0 1]);
hE_c=get(errorbar2, 'Children');
errorbarXData= get(hE_c(2), 'XData');
errorbarXData(4:9:end) = errorbarXData(1:9:end) - 0;
errorbarXData(7:9:end) = errorbarXData(1:9:end) - 0;
errorbarXData(5:9:end) = errorbarXData(1:9:end) + 0;
errorbarXData(8:9:end) = errorbarXData(1:9:end) + 0;
set(hE_c(2), 'XData', errorbarXData);

hold on

% Create multiple lines using matrix input to plot
plot1 = plot(X1,[Y1,zeros(length(Y1),1)],'LineStyle','none');
set(plot1(1),'Marker','.','MarkerSize',5,'Color',[0.3412 0.7961 0.1922]);
set(plot1(2),'LineWidth',1,'LineStyle','--','Color',[0 0 0]);

hold on

h = plot(-1000, [-1000, -1000, -1000]);

hold off

axis([0 length(Y1) -200 100])

% set(gca, 'FontSize', 16, 'YTick', -600:300:300)
set(gca, 'FontSize', 16, 'fontname', 'Arial', 'YTick', -200:50:50)

% Create ylabel
ylabel('\Delta_{r}G (kJ/mol)');

% Create xlabel
xlabel('Reactions, ordered by \Delta_{r}G^{\prime0}');

% Create legend
set(h(1), 'Marker', 's', 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'r', 'LineStyle', 'none')
set(h(2), 'Marker', 's', 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'b', 'LineStyle', 'none')
set(h(3), 'Marker', 's', 'MarkerEdgeColor', [0.3412 0.7961 0.1922], 'MarkerFaceColor', [0.3412 0.7961 0.1922], 'LineStyle', 'none')
l = legend(h, '\Delta_{r}G_{k}^{\prime}', '\Delta_{r}G_{k}^{\prime0} \pm u_{r}', '\Delta_{r}G_{k}^{\prime0}', 'Location', 'south', 'Orientation', 'horizontal');
legend(gca, 'boxoff')
set(l,'FontSize', 16, 'fontname', 'Arial')
