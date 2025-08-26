function [hFig, axI, axS, axL] = upsetPlot(DataOrSets, setName, varargin)
% upsetPlot - Generate an UpSet plot
%
% An UpSet plot is a visualisation technique for exploring set intersections.
% It is an alternative to Venn diagrams, especially suited for larger numbers
% of sets. The plot shows:
%   • Horizontal bars representing the size of each set
%   • Vertical bars representing the size of intersections between sets
%   • A matrix of dots and connecting lines below the bars, indicating which
%     sets are involved in each intersection
%
% Usage:
%   upsetPlot(Data, setName)
%   upsetPlot(Sets, setName)
%   upsetPlot(..., 'bar1Color', [r g b], 'bar2Color', cmap, 'lineColor', [r g b])
%   upsetPlot(..., 'includeSingletons', true|false)
%   upsetPlot(..., 'Parent', figHandle)
%
% Inputs:
%   Data     - logical (N x M) matrix, rows = elements, columns = sets
%              OR
%   Sets     - 1 x M cell array of vectors (raw sets of elements). The
%              function will internally build the membership matrix.
%
%   setName  - 1 x M cell array of set names
%
% Optional name-value pairs:
%   'bar1Color'         - colour(s) for intersection bars (default teal gradient)
%   'bar2Color'         - colour(s) for set size bars (default blue gradient)
%   'lineColor'         - colour for connection lines (default grey)
%   'includeSingletons' - whether to include single-set intersections in the
%                         top bars. Default false, which excludes them.
%   'Parent'            - parent figure to draw into. If provided, the plot
%                         is created in this figure. The function clears it.
%
% Outputs:
%   hFig - handle to the created figure
%   axI  - intersection axes (top bars)
%   axS  - set size axes (left bars)
%   axL  - links matrix axes (dots and lines)
%
% Example 1 (binary matrix, whole-figure saving):
%   rng(5)
%   setName = {'RB1','PIK3R1','EGFR','TP53','PTEN'};
%   Data = rand([200,5]) > .85;
%   [h, axI] = upsetPlot(Data, setName);    % excludes singletons by default
%   savefig(h, 'upset_matrix.fig')          % save MATLAB figure
%   print(h, '-dpdf', 'upset_matrix.pdf')   % export to PDF
%   exportgraphics(axI, 'upset_intersections.png')  % export just top bars
%
% Example 2 (raw sets, provide parent to avoid Live Editor clean-up):
%   A = [1 2 5]; B = [2 3]; C = [1 4 5];
%   f = figure('Color','w');                                % parent from base workspace
%   [h, axI, axS, axL] = upsetPlot({A,B,C}, {'A','B','C'}, 'includeSingletons', true, 'Parent', f);
%   exportgraphics(axS, 'upset_set_sizes.png');             % left bars only
%   saveas(h, 'upset_whole.png');                           % whole figure
%
% Author: based on slandarer's demo (2023)
% Ref: https://www.mathworks.com/matlabcentral/fileexchange/123695-upset-plot

%% Convert raw sets to membership matrix if needed
if iscell(DataOrSets)
    % collect universe of elements
    allElements = unique([DataOrSets{:}]);
    nElem = numel(allElements);
    nSet  = numel(DataOrSets);
    Data  = false(nElem, nSet);
    for j = 1:nSet
        [~,loc] = ismember(DataOrSets{j}, allElements);
        Data(loc(loc>0), j) = true;
    end
else
    Data = logical(DataOrSets);
end

%% Parse inputs
p = inputParser;
addParameter(p, 'bar1Color', [66,182,195]./255);
addParameter(p, 'bar2Color', [253,255,228;164,218,183;68,181,197;44,126,185;35,51,154]./255);
addParameter(p, 'lineColor', [61,58,61]./255);
addParameter(p, 'includeSingletons', false, @(x) islogical(x) && isscalar(x));
addParameter(p, 'Parent', [], @(h) isempty(h) || ishghandle(h,'figure'));
parse(p, varargin{:});
bar1Color = p.Results.bar1Color;
bar2Color = p.Results.bar2Color;
lineColor = p.Results.lineColor;
includeSingletons = p.Results.includeSingletons;
parentFig = p.Results.Parent;

%% Construct or reuse figure
if isempty(parentFig)
    fig = figure('Units','normalized','Position',[.3,.2,.5,.63],'Color',[1,1,1], ...
                 'Visible','on','HandleVisibility','on');
else
    fig = parentFig;
    figure(fig);                 % make it current
    clf(fig);                    % clear if reusing
    set(fig, 'Color', [1 1 1], 'Visible','on');
end

%% Compute intersections
M = size(Data,2);
% fixed-width binary matrix of all non-empty intersection patterns
pBool = dec2bin(1:(2^M - 1), M) - '0';   % size: (2^M-1) x M

[pPos,~] = find(((pBool*(1-Data'))|((1-pBool)*Data'))==0);
sPPos = sort(pPos); dPPos = find([diff(sPPos);1]);
pType = sPPos(dPPos); pCount = diff([0;dPPos]);
[pCount,pInd] = sort(pCount,'descend');
pType = pType(pInd);

% filter by degree to include or exclude singletons
deg = sum(pBool(pType,:), 2);
if ~includeSingletons
    keep = deg >= 2;
    pType  = pType(keep);
    pCount = pCount(keep);
end

sCount = sum(Data,1);
[sCount,sInd] = sort(sCount,'descend');
sType = 1:size(Data,2); sType = sType(sInd); %#ok<NASGU>

%% Axes layout
axI = axes('Parent',fig); hold(axI,'on');
set(axI,'Position',[.33,.35,.655,.61],'LineWidth',1.2,'Box','off','TickDir','out', ...
    'FontName','Times New Roman','FontSize',12,'XTick',[])
axI.YLabel.String = 'Intersection Size';
axI.YLabel.FontSize = 16;

axS = axes('Parent',fig); hold(axS,'on');
set(axS,'Position',[.01,.08,.245,.26],'LineWidth',1.2,'Box','off','TickDir','out', ...
    'FontName','Times New Roman','FontSize',12,'YColor','none','YLim',[.5,size(Data,2)+.5], ...
    'YAxisLocation','right','XDir','reverse','YTick',[])
axS.XLabel.String = 'Set Size';
axS.XLabel.FontSize = 16;

axL = axes('Parent',fig); hold(axL,'on');
set(axL,'Position',[.33,.08,.655,.26],'YColor','none','YLim',[.5,size(Data,2)+.5], ...
    'XColor','none')

%% Intersection bar plot with headroom
nInt = numel(pType);
if nInt == 0
    set(axI, 'XLim', [0, 1], 'YLim', [0, 1]);
else
    set(axI,'XLim',[0, nInt+1])
    barHdlI = bar(axI,pCount);
    barHdlI.EdgeColor = 'none';
    barHdlI.FaceColor = 'flat';

    if size(bar1Color,1) == 1
        bar1Color = [bar1Color;bar1Color];
    end
    tx = linspace(0,1,size(bar1Color,1))';
    bar1Color = [interp1(tx,bar1Color(:,1),linspace(0,1,nInt)','pchip'), ...
                 interp1(tx,bar1Color(:,2),linspace(0,1,nInt)','pchip'), ...
                 interp1(tx,bar1Color(:,3),linspace(0,1,nInt)','pchip')];
    for i = 1:nInt
        barHdlI.CData(i,:) = bar1Color(i,:);
    end
    text(axI,1:nInt,pCount,string(pCount),'HorizontalAlignment','center', ...
        'VerticalAlignment','bottom','FontName','Times New Roman','FontSize',12, ...
        'Color',[61,58,61]./255)

    yMax = max(pCount);
    if ~isempty(yMax) && yMax > 0
        axI.YLim = [0, yMax*1.15];   % 15 percent headroom
    else
        axI.YLim = [0, 1];
    end
end

%% Set size bar plot with left margin
barHdlS = barh(axS,sCount,'BarWidth',.6);
barHdlS.EdgeColor = 'none';
barHdlS.BaseLine.Color = 'none';

if size(bar2Color,1) == 1
    bar2Color = [bar2Color;bar2Color];
end
tx = linspace(0,1,size(bar2Color,1))';
bar2Color = [interp1(tx,bar2Color(:,1),linspace(0,1,size(Data,2))','pchip'), ...
             interp1(tx,bar2Color(:,2),linspace(0,1,size(Data,2))','pchip'), ...
             interp1(tx,bar2Color(:,3),linspace(0,1,size(Data,2))','pchip')];
barHdlS.FaceColor = 'flat';

for i = 1:size(Data,2)
    barHdlS.CData(i,:) = bar2Color(i,:);
    % annotations live in figure coordinates
    figure(fig);
    annotation('textbox',[(axS.Position(1)+axS.Position(3)+axI.Position(1))/2-.02, ...
        axS.Position(2)+axS.Position(4)./size(Data,2).*(i-.5)-.02,.04,.04], ...
        'String',setName{sInd(i)},'HorizontalAlignment','center','VerticalAlignment','middle', ...
        'FitBoxToText','on','LineStyle','none','FontName','Times New Roman','FontSize',13);
end
text(axS,sCount,1:size(Data,2),compose('%d ',sCount),'HorizontalAlignment','right', ...
    'VerticalAlignment','middle','FontName','Times New Roman','FontSize',12, ...
    'Color',[61,58,61]./255)

% give 10 percent extra width so bars are not cut off on the left
xMax = max(sCount);
if isempty(xMax) || xMax <= 0
    axS.XLim = [0, 1];
else
    axS.XLim = [0, xMax*1.10];  % XDir is 'reverse', this adds space on the left
end

%% Links matrix
axL.XLim = axI.XLim;  % keep aligned with top bars

patchColor = [248,246,249;255,254,255]./255;
for i = 1:size(Data,2)
    fill(axL,axI.XLim([1,2,2,1]),[-.5,-.5,.5,.5]+i,patchColor(mod(i+1,2)+1,:), ...
        'EdgeColor','none');
end
[tX,tY] = meshgrid(1:nInt,1:size(Data,2));
if ~isempty(tX)
    plot(axL,tX(:),tY(:),'o','Color',[233,233,233]./255, ...
        'MarkerFaceColor',[233,233,233]./255,'MarkerSize',10);
end
for i = 1:nInt
    tY = find(pBool(pType(i),:));
    oY = arrayfun(@(j)find(sInd==j), tY);  % map to sorted set order
    plot(axL,i*ones(size(oY)),oY,'-o','Color',lineColor(1,:), ...
        'MarkerEdgeColor','none','MarkerFaceColor',lineColor(1,:), ...
        'MarkerSize',10,'LineWidth',2);
end

hFig = fig;
end
