function plotOverlapResults(overlapresults,statistic,savepath)
% USAGE:
%   plot the overlapped heatmap for each model with proportion text labels
%
% Input:
%   overlapresults: from compareXomicsModels.m
%   statistic:  from compareXomicsModels.m
%   savepath (optional): the path to save the plot
%
% Output:
%   a heat map plot
%
% Author(s):
%   Xi Luo, 2023/02
%
%
%use proportion to create map
figure('units','normalized','outerposition',[0 0 1 1])
%mets
a=statistic.overlapnumber_mets{:,1};
metsdata=statistic.overlapnumber_mets{:,2:end};
%find model size
for i=1:size(metsdata,1)
[max_a(i),index(i)]=max(metsdata(i,:));
end
%generate proportion
xa=repmat(max_a',[1 length(statistic.overlapnumber_mets{:,1})]);
pro=round(metsdata./xa*100,2);
ax = subplot(3,1,1);
h = imagesc(ax, pro);
daspect([1 4 1]);
title(['All Overlapped Mets=' num2str(length(overlapresults.mets.alloverlap))])
ax.TickLength(1) = 0;
% Create heatmap's colormap
n=256;
cmap = [linspace(.9,0,n)', linspace(.9447,.447,n)', linspace(.9741,.741,n)'];
colormap(ax, cmap);
colorbar(ax)
hold on
%add text label (proportion (accuracy))
label1=reshape(pro',[],1);
% accuracy_mets=accuracy.mets{:,2:end};
% label2=round(reshape(accuracy_mets,[],1),2);
% labels=append(string(label1),'%','(',string(label2),')');
try
    %labels(find(label1==100))=append(string(max_a'),'(',string(label2(find(label1==100))),')');
    labels=append(string(label1));
    labels(find(label1==100))=append(string(max_a'));
catch ME
    disp(ME)
end
[xTxt, yTxt] = ndgrid(1:size(metsdata,1), 1:size(metsdata,1));
th = text(xTxt(:), yTxt(:), labels(:), ...
    'VerticalAlignment', 'middle','HorizontalAlignment','Center');
set(ax,'XTick',1:size(metsdata,1),'YTick',1:size(metsdata,1))
xticklabels(a)
yticklabels(a)
set(gca,'XTickLabelRotation',0);


%rxns
rxnsdata=statistic.overlapnumber_rxns{:,2:end};
%find model size
for i=1:size(rxnsdata,1)
[max_a(i),index(i)]=max(rxnsdata(i,:));
end
%generate proportion
xa=repmat(max_a',[1 length(statistic.overlapnumber_rxns{:,1})]);
pro=round(rxnsdata./xa*100,2);
ax = subplot(3,1,2);
h = imagesc(ax, pro);
daspect([1 4 1]);
title(['All Overlapped Rxns=' num2str(length(overlapresults.rxns.alloverlap))])
ax.TickLength(1) = 0;
% Create heatmap's colormap
n=256;
cmap = [linspace(.9,0,n)', linspace(.9447,.447,n)', linspace(.9741,.741,n)'];
colormap(ax, cmap);
colorbar(ax)
hold on
%add text label (proportion (accuracy))
label1=reshape(pro',[],1);
% accuracy_rxns=accuracy.rxns{:,2:end};
% label2=round(reshape(accuracy_rxns,[],1),2);
% labels=append(string(label1),'%','(',string(label2),')');
try
    %labels(find(label1==100))=append(string(max_a'),'(',string(label2(find(label1==100))),')');
    labels=append(string(label1));
    labels(find(label1==100))=append(string(max_a'));
catch ME
    disp(ME)
end
[xTxt, yTxt] = ndgrid(1:size(rxnsdata,1), 1:size(rxnsdata,1));
th = text(xTxt(:), yTxt(:), labels(:), ...
    'VerticalAlignment', 'middle','HorizontalAlignment','Center');
set(ax,'XTick',1:size(metsdata,1),'YTick',1:size(metsdata,1))
xticklabels(a)
yticklabels(a)
set(gca,'XTickLabelRotation',0);

%genes
genesdata=statistic.overlapnumber_genes{:,2:end};
%find model size
for i=1:size(genesdata,1)
[max_a(i),index(i)]=max(genesdata(i,:));
end
%generate proportion
xa=repmat(max_a',[1 length(statistic.overlapnumber_genes{:,1})]);
pro=round(genesdata./xa*100,2);
ax = subplot(3,1,3);
h = imagesc(ax, pro);
daspect([1 4 1]);
title(['All Overlapped Genes=' num2str(length(overlapresults.genes.alloverlap))])
ax.TickLength(1) = 0;
% Create heatmap's colormap
n=256;
cmap = [linspace(.9,0,n)', linspace(.9447,.447,n)', linspace(.9741,.741,n)'];
colormap(ax, cmap);
colorbar(ax)
hold on
%add text label (proportion (accuracy))
label1=reshape(pro',[],1);
% accuracy_genes=accuracy.genes{:,2:end};
% label2=round(reshape(accuracy_genes,[],1),2);
% labels=append(string(label1),'%','(',string(label2),')');
try
    %labels(find(label1==100))=append(string(max_a'),'(',string(label2(find(label1==100))),')');
    labels=append(string(label1));
    labels(find(label1==100))=append(string(max_a'));
catch ME
    disp(ME)
end
[xTxt, yTxt] = ndgrid(1:size(genesdata,1), 1:size(genesdata,1));
th = text(xTxt(:), yTxt(:), labels(:), ...
    'VerticalAlignment', 'middle','HorizontalAlignment','Center');
set(ax,'XTick',1:size(genesdata,1),'YTick',1:size(genesdata,1))
xticklabels(a)
yticklabels(a)
set(gca,'XTickLabelRotation',0);

% add annotation
annotation('textbox',...
    [0.29 0.90 0.2 0.08],...
    'String',{'Colorbar = overlapped proportion(%);  textlabel = proportion;  Diagonal number = model size'},...
    'FontSize',12,'FitBoxToText','on','LineStyle','none');

if exist('savepath', 'var')
    iterationMethod=extractAfter(savepath,'models_');
    sgtitle(['Overlapped result of ' iterationMethod])
    % myAxes=findobj(ax,'Type','Axes');
    % exportgraphics(myAxes,['overlap.pdf']);
    cd(savepath)
    saveas(ax, ['overlap_' iterationMethod '.fig'])
end

end

