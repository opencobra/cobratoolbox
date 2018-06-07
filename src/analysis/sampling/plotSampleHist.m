function sampleFig = plotSampleHist(rxnNames, samples, models, nBins, perScreen, modelNames)
% Compares flux histograms for one or more samples
% for one or more reactions
%
% USAGE:
%
%    plotSampleHist(rxnNames, samples, models, nBins, perScreen, modelNames)
%
% INPUTS:
%    rxnNames:     Cell array of reaction abbreviations.
%    samples:      Cell array containing samples.
%    models:       Cell array containing model structures or common model
%                  structure.
%
% OPTIONAL INPUTS:
%    nBins:        Number of bins to be used.
%    perScreen:    Number of reactions to show per screen.  Either a number
%                  or [nY, nX] vector (press 'enter' to advance screens).
%    options:      Options for plotting sampled fulx spaces (default values
%                  in parenthesis).
%
%                     * .modelNames - Cell array containing the name of the
%                                     models (used for the plot's legend)
%                                    (model1, model2, ..., modeln).
%                     * .plottingApproach - Selects which ploting approach
%                                           will be used ('nBins').
%
% EXAMPLE:
%
%    sampleStructOut1 = gpSampler(model1, 2150);
%    sampleStructOut2 = gpSampler(model2, 2150);
%    %Plot for model 1
%    plotSampleHist(model1.rxns,{samplePoints1},{model1})
%
%    %Plot reactions reactions in model 1 that also exist in model 2 using 10
%    %bins and plotting 12 reactions per screen.
%    plotSampleHist(model1.rxns,{samplePoints1,samplePoints2},{model1,model2},10,12)
%
% .. Authors;
%       - Markus Herrgard 7/17/06
%       - Richard Que 2/05/10, added ability to move in reverse direction.
%
% CONTROLS:
% To advance to next screen hit 'enter/return' or type 'f' and hit 'enter/return'
% To rewind to previous screen type 'r' or 'b' and hit 'enter/return'
% To quit script type 'q' and hit 'enter/return'


if nargin < 4 || isempty(nBins)
    if iscell(samples)
        [~, nSamples] = size(samples{1});
    else
        [~, nSamples] = size(samples);        
    end
    nBins = round(nSamples / 25);
end

if nargin < 5 || isempty(perScreen)
    perScreen = 1e5;
end

for i = 1:length(models)
    modelNames{i} = ['Model ' num2str(i)];
end
plottingApproach = 'nBins';
FVAdata = {};

% Handle options
if exist('options', 'var')
    if (isfield(options, 'modelNames'))
        modelNames = options.modelNames;
    end
    if (isfield(options, 'plottingApproach'))
        plottingApproach = options.plottingApproach;
    end
    if (isfield(options, 'FVAdata'))
        FVAdata = options.FVAdata;
    end
end

plotColor(1, :) = [0 0.4470 0.7410];
plotColor(2, :) = [0 0.4470 0.7410];
plotColor(3, :) = [0.8500    0.3250    0.0980];
plotColor(4, :) = [0.8500    0.3250    0.0980];
plotColor(5, :) = [0.9290    0.6940    0.1250];
plotColor(6, :) = [0.9290    0.6940    0.1250];
plotColor(7, :) = [0.4940    0.1840    0.5560];
plotColor(8, :) = [0.4940    0.1840    0.5560];
plotColor(9, :) = [0.4660    0.6740    0.1880];
plotColor(10, :) = [0.4660    0.6740    0.1880];
plotColor(11, :) = [0.3010    0.7450    0.9330];
plotColor(12, :) = [0.3010    0.7450    0.9330];
plotColor(13, :) = [0.6350    0.0780    0.1840];
plotColor(14, :) = [0.6350    0.0780    0.1840];
colors = {'y', 'm', 'c', 'g', 'k'};

% Check the length of the data
if ~iscell(models)
    commonModelFlag = true;
    samplesTmp = samples;
    clear samples;
    samples{1} = samplesTmp;
    model = models;
else
    commonModelFlag = false;
    model = models{1};
end
rxnNames = cellstr(rxnNames);
nRxns = length(rxnNames);

% Check which reactions to plot
for i = 1:nRxns
    if commonModelFlag
        keepRxn(i) = ismember(rxnNames{i}, models.rxns);
    else
        for j = 1:length(models)
            isIn(j) = ismember(rxnNames{i}, models{j}.rxns);
        end
        if all(isIn)
            keepRxn(i) = true;
        else
            keepRxn(i) = false;
            warning(['Reaction "' rxnNames{i} '" does not exist.'])
        end
    end
end

% Calculates the dimensions of the subplot
rxnNames = rxnNames(keepRxn');
nRxns = length(rxnNames);
if length(perScreen) == 2
    nX = perScreen(2);
    nY = perScreen(1);
    perScreen = nX * nY;
else
    nX = ceil(sqrt(min(nRxns, perScreen)));
    nY = ceil(min(nRxns, perScreen) / nX);
end

%%% DELETE %%%
     nX = 2; %%
     nY = 5; %%
%%%%%%%%%%%%%%

j = 1;
flagQuit = false;
fig = figure;
while ~flagQuit
    clear counts;
    currLB = 1e6;
    currUB = -1e6;
    for i = 1:length(samples)
        id = findRxnIDs(model, rxnNames{j});
        currLB = min(currLB, min(samples{i}(id, :)'));
        currUB = max(currUB, max(samples{i}(id, :)'));
    end
    % Rescale currUB, LB if they are the same # within numerical precision
    % (8*eps)
    if currUB - currLB < 8 * eps * abs(mean([currUB, currLB]))
        av = abs(mean([currUB, currLB]));
        currUB = currUB + 8 * eps * av;
        currLB = currLB - 8 * eps * av;
    end
    switch plottingApproach
        case 'nBins'
            clear counts;
            
            bins = linspace(currLB, currUB, nBins);
            for i = 1:length(samples)
                n = hist(1 * samples{i}(id, :), bins);
                counts(:, i) = smooth(bins, n');
            end
            freq = counts ./ repmat(sum(counts), size(counts, 1), 1);
            subplot(nX, nY, mod(j - 1, perScreen) + 1);
            pl = plot(bins, freq, '-');
            axis([currLB - .0001, currUB + .0001, 0, max(max(freq))]);

        case 'ksdensity'
            id = findRxnIDs(model, rxnNames{j});
            subplot(nX, nY, mod(j - 1, perScreen) + 1);
            hold on
            for i = 1:length(samples)
                eval(sprintf('sample_%s = samples{%d};', num2str(i), i));
                eval(sprintf('ksdensity(sample_%s(id,:));', num2str(i)));
            end
%%%%%%%%%%%%%%%%%%%%%%%%%%%% DELETE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
eval(sprintf('plot(mean(sample_%s(id,:)), 0, ''r*'', ''LineWidth'', 2)', num2str(i)));%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            hold off
    end
    

    
    if ~isempty(FVAdata)
        hold on
        ylim = get(gca, 'ylim');
        xlim = get(gca, 'xlim');
        for i = 1:(size(FVAdata, 2) / 2)
            %plotColor(i, :) = get(pl(round(i / 2)), 'color');  
            patch([FVAdata(id, (i * 2) - 1) FVAdata(id, (i * 2))...
                FVAdata(id, (i * 2)) FVAdata(id, (i * 2) - 1)],... 
                [(((ylim(2) / 10) * i) - (ylim(2) / 10)) ...
                (((ylim(2) / 10) * i) - (ylim(2) / 10))...
                ((ylim(2) / 10) * i) ((ylim(2) / 10) * i)], colors{i}); %%%%%%%% borrar
            %%%%%%% descomentar la de abajo
            % plot(repmat(FVAdata(id, i),1,2), ylim, '--', 'Color', plotColor(i, :))
%             if mod(i, 2) == 1
%                 text(FVAdata(id, i), (ylim(2) / 2) + ((ylim(2) / 20) * i), 'min', 'Color', plotColor(i, :));
%             else
%                 text(FVAdata(id, i), (ylim(2) / 2) + ((ylim(2) / 20) * i), 'max', 'Color', plotColor(i, :));
%             end
        end
        axis([min([FVAdata(id, :) xlim]) max([FVAdata(id, :) xlim]) 0 ylim(2)]);
        hold off
    end
    freq = counts./repmat(sum(counts), size(counts, 1), 1);
    
    subplot(nX, nY, mod(j-1, perScreen) + 1);
    pl = plot(bins, freq, '-');
    axis([currLB - .0001 currUB + .0001 0 max(max(freq))]);
    if j==1
        legend(modelNames)
    end
    xlabel({['Flux of ' regexprep(rxnNames{j}, '\_', '\\_') ' ']; '(mmol/gDW/h)'})
    ylabel('Frequency')
    
    x0 = 10;
    y0 = 10;
    width = 560;
    height = 420;
    if nY > 1
        height = 420 + (420 / (3 / nY));
    end
    set(gcf, 'units', 'points', 'position', [x0, y0, width, height])
    
    user_input = 'f';
    if j >= nRxns
        if nRxns <= perScreen, return; end
        user_input = input('End of sampples; reverse (r) or quit (q): ', 's');
        while isempty(user_input) || ~(ismember(user_input(1), {'b', 'r', 'q', 'e'}))
            user_input = input('End of sampples; reverse (r) or quit (q)): ', 's');
        end
        clear fig
    elseif mod(j, perScreen) == 0
        user_input = input('Move forward (f), reverse (r) or quit (q): ', 's');
        if isempty(user_input), user_input = 'f'; end
        clear fig
    end
    if user_input(1) == 'r' || user_input(1) == 'b'
        j = j - perScreen * 2 + 1;
        if j < 0, j = 1; end
    elseif user_input(1) == 'q'|| user_input(1) == 'e'
        flagQuit = true;
    elseif user_input(1) == 'f'
        j = j + 1;
    end
end
