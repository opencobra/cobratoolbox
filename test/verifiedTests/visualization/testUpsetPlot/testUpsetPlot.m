% The COBRAToolbox: testUpSetPlot.m
%
% Purpose:
%     - Validate upsetPlot on binary matrix and raw set inputs
%     - Check includeSingletons option
%     - Check axis padding so bars are not clipped
%     - Demonstrate exporting of panels and whole figure
%
% Authors:
%     - initial version: <your name> <YYYY-MM-DD>
%

global CBTDIR

% define the features required to run the test
requiredToolboxes = {};   % none required
requiredSolvers   = {};   % none required

% prepare the test environment
solversPkgs = prepareTest('requiredSolvers', requiredSolvers, ...
                          'requiredToolboxes', requiredToolboxes);

% save the current path and initialise the test
currentDir = cd(fileparts(which(mfilename)));

% determine the test path for references
testPath = pwd; %#ok<NASGU>

% set the tolerance (not used here, kept for template consistency)
tol = 1e-8; %#ok<NASGU>

fprintf(' -- Running testUpSetPlot without solver dependencies ... ');

%% 1) Binary matrix input, exclude singletons (default)
rng(1)
N = 200; M = 4;
Data = rand(N, M) > 0.86;
names = arrayfun(@(j) sprintf('S%d', j), 1:M, 'UniformOutput', false);

f1 = figure('Color','w','Visible','off');
[hFig1, axI1, axS1, axL1] = callUpSetPlot(Data, names, 'Parent', f1); %#ok<ASGLU>
assert(ishghandle(hFig1,'figure'), 'Figure handle invalid for binary input.');
assert(ishghandle(axI1,'axes') && ishghandle(axS1,'axes') && ishghandle(axL1,'axes'), 'Axes missing.');

% expected number of intersections when excluding singletons
nExp = expectedIntersectionCount(Data, false);
nBars = countBarsOnAxes(axI1);
assert(nBars == nExp, 'Intersection bar count mismatch when excluding singletons.');

% set-size axis padding: XDir is reverse, so XLim(2) should exceed max by about 10 percent
sCount = sum(Data,1);
if ~isempty(sCount)
    assert(axS1.XLim(2) >= max(sCount)*1.09, 'Set-size axis lacks padding.');
end

% intersection axis headroom
yVals = getBarHeights(axI1);
if ~isempty(yVals)
    assert(axI1.YLim(2) >= max(yVals)*1.12, 'Intersection axis lacks headroom.');
end

% export examples
tmpPng1 = [tempname, '.png'];
exportgraphics(axI1, tmpPng1); % export just top bars
assert(isfile(tmpPng1), 'Top bars export failed.');
delete(tmpPng1);

tmpPng2 = [tempname, '.png'];
saveas(hFig1, tmpPng2); % whole figure via figure handle
assert(isfile(tmpPng2), 'Whole figure save failed.');
delete(tmpPng2);
close(hFig1);

%% 2) Binary matrix input, include singletons
f2 = figure('Color','w','Visible','off');
[hFig2, axI2] = callUpSetPlot(Data, names, 'includeSingletons', true, 'Parent', f2);
nBarsWithSingles = countBarsOnAxes(axI2);
close(hFig2)

f3 = figure('Color','w','Visible','off');
[hFig3, axI3] = callUpSetPlot(Data, names, 'includeSingletons', false, 'Parent', f3);
nBarsNoSingles = countBarsOnAxes(axI3);
close(hFig3)

assert(nBarsWithSingles >= nBarsNoSingles, 'Including singletons reduced bar count unexpectedly.');

%% 3) Raw sets input equivalence
A = [1 2 5 8];
B = [2 3 8];
C = [1 4 5 9 10];
namesABC = {'A','B','C'};

% Construct Data the same way as upsetPlot for equivalence
U = unique([A B C], 'stable');
DataABC = false(numel(U),3);
[~,la] = ismember(A, U); DataABC(la,1) = true;
[~,lb] = ismember(B, U); DataABC(lb,2) = true;
[~,lc] = ismember(C, U); DataABC(lc,3) = true;

f4 = figure('Color','w','Visible','off');
[hFig4, axI4] = callUpSetPlot({A,B,C}, namesABC, 'includeSingletons', false, 'Parent', f4);
f5 = figure('Color','w','Visible','off');
[hFig5, axI5] = callUpSetPlot(DataABC, namesABC, 'includeSingletons', false, 'Parent', f5);

assert(countBarsOnAxes(axI4) == countBarsOnAxes(axI5), 'Raw sets and matrix path differ.');
close([hFig4 hFig5]);

%% 4) Labels and directions
f6 = figure('Color','w','Visible','off');
[hFig6, axI6, axS6] = callUpSetPlot(Data, names, 'Parent', f6);
assert(strcmp(get(get(axI6,'YLabel'),'String'), 'Intersection Size'), 'Y label incorrect on intersection axis.');
assert(strcmp(axS6.XDir,'reverse'), 'Set-size axis should point inward.');
close(hFig6);

% wrong inputs should error
wrongInputs = {{struct('a',1)}, {'OnlyOneName'}}; % unsupported set element type and mismatched names
verifyCobraFunctionError('upsetPlot', 'inputs', wrongInputs);

% output a success message
fprintf('Done.\n');

% change the directory back
cd(currentDir)

%% ----- Local helper functions -----

function [hFig, axI, axS, axL] = callUpSetPlot(DataOrSets, setName, varargin)
% Call upsetPlot and support both signatures: with or without axes outputs.
    try
        [hFig, axI, axS, axL] = upsetPlot(DataOrSets, setName, varargin{:});
        return
    catch
        % fall back to figure-only return, then discover axes
        hFig = upsetPlot(DataOrSets, setName, varargin{:});
        axI = []; axS = []; axL = [];
        axs = findobj(hFig, 'Type','axes');
        for k = 1:numel(axs)
            yl = get(axs(k).YLabel, 'String');
            xl = get(axs(k).XLabel, 'String');
            if ischar(yl) && strcmp(yl, 'Intersection Size')
                axI = axs(k);
            elseif ischar(xl) && strcmp(xl, 'Set Size')
                axS = axs(k);
            else
                axL = axs(k);
            end
        end
        if isempty(axI) || isempty(axS) || isempty(axL)
            [axI, axS, axL] = guessAxesByPosition(axs);
        end
    end
end

function [axI, axS, axL] = guessAxesByPosition(axs)
% Heuristic: top, left, bottom panels by position rectangles
    pos = cat(1, axs.Position);
    [~, iTop] = max(pos(:,2) + pos(:,4));  % top has highest top edge
    axI = axs(iTop);
    [~, iLeft] = min(pos(:,1));            % left has smallest x
    axS = axs(iLeft);
    idx = true(1,numel(axs)); idx([iTop iLeft]) = false;
    axL = axs(find(idx,1,'first'));
end

function nInt = expectedIntersectionCount(Data, includeSingletons)
% Compute number of intersections that upsetPlot will show
    M = size(Data,2);
    if M == 0
        nInt = 0; return
    end
    pBool = dec2bin(1:(2^M - 1), M) - '0';
    mask = ((pBool*(1-Data')) | ((1-pBool)*Data')) == 0;
    [pPos,~] = find(mask);
    sPPos = sort(pPos); dPPos = find([diff(sPPos);1]);
    pType = sPPos(dPPos);
    if ~includeSingletons
        deg = sum(pBool(pType,:), 2);
        pType = pType(deg >= 2);
    end
    nInt = numel(pType);
end

function n = countBarsOnAxes(ax)
% Count bars in a vertical bar chart on the given axes
    bh = findall(ax, 'Type','Bar');
    if isempty(bh)
        bh = findall(ax, 'Type','matlab.graphics.chart.primitive.Bar');
    end
    if isempty(bh)
        n = 0; return
    end
    if isprop(bh, 'YEndPoints') && ~isempty(bh.YEndPoints)
        n = numel(bh.YEndPoints);
    else
        n = numel(bh.YData);
    end
end

function y = getBarHeights(ax)
% Get heights of a vertical bar chart on the given axes
    bh = findall(ax, 'Type','Bar');
    if isempty(bh)
        bh = findall(ax, 'Type','matlab.graphics.chart.primitive.Bar');
    end
    if isempty(bh)
        y = []; return
    end
    if isprop(bh, 'YEndPoints') && ~isempty(bh.YEndPoints)
        y = bh.YEndPoints(:);
    else
        y = bh.YData(:);
    end
end
