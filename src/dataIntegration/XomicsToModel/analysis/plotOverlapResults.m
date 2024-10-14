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
%   Xi Luo, update 2024/10
%
%
%% use proportion data to create map
figure('units','normalized','outerposition',[0 0 1 1])

%% Mets data
a=statistic.overlapnumber_mets.Properties.RowNames;
metsdata = statistic.overlapproportion_mets{:, :};

% Plot Mets Data
ax1 = subplot(3,1,1);
plotHeatmapWithLabels(ax1, metsdata, a, 'Mets', overlapresults.mets, 'All Overlapped Mets');

%% Rxns Heatmap
rxnsdata = statistic.overlapproportion_rxns{:, :};  

% Plot Rxns Data
ax2 = subplot(3,1,2);
plotHeatmapWithLabels(ax2, rxnsdata, a, 'Rxns', overlapresults.rxns, 'All Overlapped Rxns');

%% Genes Heatmap
genesdata = statistic.overlapproportion_genes{:, :};  

% Plot Genes Data
ax3 = subplot(3,1,3);
plotHeatmapWithLabels(ax3, genesdata, a, 'Genes', overlapresults.genes, 'All Overlapped Genes');

annotation('textbox', [0.35 0.92 0.3 0.07], ...
    'String', {'Colorbar = Overlapped Proportion (%), Text Label = Proportion, Diagonal = Model Size'}, ...
    'FontSize', 12, 'HorizontalAlignment', 'center', 'FitBoxToText', 'on', 'LineStyle', 'none', 'EdgeColor', 'none');

if exist('savepath', 'var')
    iterationMethod=extractAfter(savepath,'models_');
    sgtitle(['Overlapped result of ' iterationMethod])
    cd(savepath)
    saveas(ax, ['overlap_' iterationMethod '.fig'])
end

end

function plotHeatmapWithLabels(ax, data, labels, featureType, overlapData, titleText)
%plot a heat map of the overlapped number

% Create heatmap
imagesc(ax, data);
daspect([1 4 1]);  % Equal aspect ratio for squares
title([titleText ' = ' num2str(size(overlapData.alloverlap, 1))]);  % Title with all overlapped count
ax.TickLength(1) = 0;  % No ticks

% Create heatmap's colormap
n = 256;
cmap = [linspace(.9,0,n)', linspace(.9447,.447,n)', linspace(.9741,.741,n)'];
colormap(ax, cmap);
colorbar(ax);
hold on;

% Set the diagonal labels with corresponding sizes
for i = 1:length(labels)
    modelName = labels{i};
    if isfield(overlapData, modelName) && isfield(overlapData.(modelName), modelName)
        modelSize = length(overlapData.(modelName).(modelName));
        text(i, i, num2str(modelSize), 'HorizontalAlignment', 'center', 'FontSize', 10, 'Color', 'k', 'FontWeight', 'bold');  % Bold size on diagonal
    end
end

% Add text labels for each square
textStrings = num2str(data(:), '%0.2f');  % Convert data to string
textStrings = strtrim(cellstr(textStrings));  % Remove any padding
[x, y] = meshgrid(1:size(data, 1));  % Create grid for positions

% Plot the text labels, skipping the diagonal
for i = 1:size(data, 1)
    for j = 1:size(data, 2)
        if i ~= j  % Skip diagonal
            text(x(i,j), y(i,j), textStrings((i-1)*size(data,1) + j), ...
                'HorizontalAlignment', 'center', 'FontSize', 10);
        end
    end
end

% Set axes labels and formatting
set(ax, 'XTick', 1:length(labels), 'YTick', 1:length(labels));
set(ax, 'XTickLabel', labels, 'YTickLabel', labels);
set(ax, 'XTickLabelRotation', 0);  % Rotate X-axis labels for readability
hold off;

end