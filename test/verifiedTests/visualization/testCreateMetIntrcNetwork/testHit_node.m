% The COBRAToolbox: testHit_node.m
%
% Purpose:
%     - hit_node is the ButtonDownFcn callback that createMetIntrcNetwork installs on the node
%       labels of a metabolite-metabolite network. A left click ('normal') draws, in a new
%       figure, the part of the current network adjacent to the clicked metabolite; a right
%       click ('alt') rebuilds the network of the clicked metabolite from the model
%       (consumed -> produced metabolites of its reactions, weighted by flux + 1e-6); other
%       clicks do nothing. Excluded metabolites, the edge threshold, zero-degree nodes, the
%       flux colouring (fcont = 0) and the colour-bar scale are applied as in
%       createMetIntrcNetwork. The test calls the callback directly with a struct standing
%       for the clicked text object (only .String and .Parent.Parent.SelectionType are read)
%       and checks the drawn figure: title, node labels, edge weights and widths, colour bar
%       and the callback bound to the new labels. Expected networks are derived by hand from
%       the stoichiometry of a five-metabolite toy model.
%
% Function under test:
%     src/visualization/createMetIntrcNetwork/hit_node.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model file, no solver; hand-built toy model and adjacency matrices.
%     Figures are created invisible and closed.
%
% Coverage exemptions:
%     Lines 163-167: unreachable (dead code). Line 127 replaces every NaN of
%     G.Edges.LWidths by 1e-6 and the later rmedge/rmnode calls only delete rows, so the
%     condition ~any(isnan(G.Edges.LWidths)) of line 154 is always true.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The help text describes the fcont flag the wrong way round
%       SEVERITY: cosmetic
%       TRIGGER: reading the OPTIONAL INPUTS of hit_node (varargin{11})
%       OBSERVED: fcont is documented as true if fluxes were supplied to
%         createMetIntrcNetwork; createMetIntrcNetwork sets fcont = 1 when the fluxes are the
%         default all-ones vector, and hit_node draws flux colours only for fcont = 0.
%       EXPECTED: fcont = 1 when no fluxes were supplied
%       LINES: 44-45
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testHit_node'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% figures created by hit_node are invisible; the default is restored at the end
savedFigureVisibility = get(groot, 'DefaultFigureVisible');
set(groot, 'DefaultFigureVisible', 'off');
figuresBefore = findall(groot, 'Type', 'figure');

% toy model: R1: A -> B, R2: B + E -> C, R3: A + C -> D; fluxes 2, 3, 1
model.mets = {'A'; 'B'; 'C'; 'D'; 'E'};
model.rxns = {'R1'; 'R2'; 'R3'};
model.S = [-1  0 -1;
            1 -1  0;
            0  1 -1;
            0  0  1;
            0 -1  0];
fluxes = [2; 3; 1];

% plotting arguments as createMetIntrcNetwork passes them (defaults of that function)
graphTitle = 'Toy';
nodeColour = [0 0.4470 0.7410];
highlightColour = [1 0 0];
nodeSize = 4;
highlightSize = 6;
arrowSize = 4;
noThreshold = 1e-7;          % createMetIntrcNetwork's value for "no threshold"
degreeRange = [0 100];

% the clicked text object: hit_node reads .String and .Parent.Parent.SelectionType
clickOn = @(metName, selection) struct('String', metName, ...
    'Parent', struct('Parent', struct('SelectionType', selection)));

% current network of the left-click sections: A -> B (2), B -> C (3), C -> D (4), A -> D (1)
networkMets = {'A'; 'B'; 'C'; 'D'};
networkAdjacency = [0 2 0 1;
                    0 0 3 0;
                    0 0 0 4;
                    0 0 0 0];

% weights are flux + 1e-6 (exact sums of doubles); 1e-12 absorbs rounding of the products
tol = 1e-12;

%% right click: network of B rebuilt from the model, coloured by flux (fcont = 0)

% reactions of B: R1, R2; their metabolites A, B, C, E; consumed -> produced edges
% A -> B (flux 2 + 1e-6), B -> C and E -> C (flux 3 + 1e-6); only edges of B are kept,
% so E is dropped
hit_node(clickOn('B', 'alt'), [], [], {}, model, fluxes, {}, graphTitle, nodeColour, ...
    highlightColour, 0, 0, 1e-6, nodeSize, highlightSize, arrowSize, noThreshold, degreeRange);
newFigure = gcf;
plotAxes = newFigure.CurrentAxes;
graphPlot = findobj(plotAxes, 'Type', 'graphplot');
labels = findobj(plotAxes, 'Type', 'text');
assert(strcmp(plotAxes.Title.String, 'B Centred Toy'));
assert(isequal(sort({labels.String}), {'A', 'B', 'C'}));
% edge colours are the weights (edges ordered A -> B, B -> C)
assert(max(abs(graphPlot.EdgeCData(:) - [2 + 1e-6; 3 + 1e-6])) < tol);
% line widths: 2.5 * ((w - min) / (max - min) + 1e-5)
assert(max(abs(graphPlot.LineWidth(:) - 2.5 * [1e-5; 1 + 1e-5])) < tol);
% default scale (scaleMin 0, scaleMax 1e-6): colour bar titled 'Fluxes'
colourBar = findobj(newFigure, 'Type', 'colorbar');
assert(strcmp(colourBar.Title.String, 'Fluxes'));
% the new labels call hit_node again with the network of B
callback = labels(1).ButtonDownFcn;
assert(strcmp(func2str(callback{1}), 'hit_node'));
assert(max(max(abs(callback{2} - [0 2 + 1e-6 0; 0 0 3 + 1e-6; 0 0 0]))) < tol);
assert(isequal(callback{3}, {'A'; 'B'; 'C'}));
assert(isequal(callback{4}, model));
close(newFigure);

%% right click with a colour-bar scale and an excluded metabolite

% A is excluded, so only B -> C is left; the scale 0 - 5 sets the colour limits
hit_node(clickOn('B', 'alt'), [], [], {}, model, fluxes, {'A'}, graphTitle, nodeColour, ...
    highlightColour, 0, 0, 5, nodeSize, highlightSize, arrowSize, noThreshold, degreeRange);
newFigure = gcf;
plotAxes = newFigure.CurrentAxes;
labels = findobj(plotAxes, 'Type', 'text');
assert(isequal(sort({labels.String}), {'B', 'C'}));
assert(isequal(plotAxes.CLim, [0 5]));
colourBar = findobj(newFigure, 'Type', 'colorbar');
assert(strcmp(colourBar.Title.String, 'Scaled Fluxes (0 - 5)'));
close(newFigure);

%% left click without fluxes (fcont = 1): sub-network of B in the current network

% edges of B: A -> B and B -> C; C -> D and A -> D are dropped, and so is D
hit_node(clickOn('B', 'normal'), [], networkAdjacency, networkMets, model, ones(3, 1), {}, ...
    graphTitle, nodeColour, highlightColour, 1, 0, 1e-6, nodeSize, highlightSize, ...
    arrowSize, noThreshold, degreeRange);
newFigure = gcf;
plotAxes = newFigure.CurrentAxes;
graphPlot = findobj(plotAxes, 'Type', 'graphplot');
labels = findobj(plotAxes, 'Type', 'text');
assert(strcmp(plotAxes.Title.String, 'B Centred Sub- Toy'));
assert(isequal(sort({labels.String}), {'A', 'B', 'C'}));
% without fluxes all edges have width 1 and no colour bar is drawn
assert(isequal(graphPlot.LineWidth, 1));
assert(isempty(findobj(newFigure, 'Type', 'colorbar')));
callback = labels(1).ButtonDownFcn;
assert(isequal(callback{2}, [0 2 0; 0 0 3; 0 0 0]));
close(newFigure);

%% left click with a threshold: edges below it and then isolated nodes are removed

% threshold 2.5 removes A -> B (2); A is then isolated and removed
hit_node(clickOn('B', 'normal'), [], networkAdjacency, networkMets, model, fluxes, {}, ...
    graphTitle, nodeColour, highlightColour, 0, 0, 1e-6, nodeSize, highlightSize, ...
    arrowSize, 2.5, degreeRange);
newFigure = gcf;
plotAxes = newFigure.CurrentAxes;
graphPlot = findobj(plotAxes, 'Type', 'graphplot');
labels = findobj(plotAxes, 'Type', 'text');
assert(isequal(sort({labels.String}), {'B', 'C'}));
assert(isequal(graphPlot.EdgeCData(:), 3));
close(newFigure);

%% left click: weights below 1e-4 are drawn as 1e-6; a single width range gives width 1e-6

% A -> B has weight 1e-5 and becomes 1e-6; B -> C keeps 3
tinyAdjacency = networkAdjacency;
tinyAdjacency(1, 2) = 1e-5;
hit_node(clickOn('B', 'normal'), [], tinyAdjacency, networkMets, model, fluxes, {}, ...
    graphTitle, nodeColour, highlightColour, 0, 0, 1e-6, nodeSize, highlightSize, ...
    arrowSize, noThreshold, degreeRange);
newFigure = gcf;
graphPlot = findobj(newFigure.CurrentAxes, 'Type', 'graphplot');
assert(max(abs(graphPlot.EdgeCData(:) - [1e-6; 3])) < tol);
close(newFigure);
% one edge only (C -> D, weight 4): max = min, the 0/0 width is replaced by 1e-6
hit_node(clickOn('D', 'normal'), [], [0 4; 0 0], {'C'; 'D'}, model, fluxes, {}, ...
    graphTitle, nodeColour, highlightColour, 0, 0, 1e-6, nodeSize, highlightSize, ...
    arrowSize, noThreshold, degreeRange);
newFigure = gcf;
graphPlot = findobj(newFigure.CurrentAxes, 'Type', 'graphplot');
assert(abs(graphPlot.LineWidth - 2.5e-6) < tol);
close(newFigure);

%% other clicks (double click, 'open') draw nothing

hit_node(clickOn('B', 'open'), [], networkAdjacency, networkMets, model, fluxes, {}, ...
    graphTitle, nodeColour, highlightColour, 0, 0, 1e-6, nodeSize, highlightSize, ...
    arrowSize, noThreshold, degreeRange);
assert(numel(findall(groot, 'Type', 'figure')) == numel(figuresBefore));

% restore the default figure visibility
set(groot, 'DefaultFigureVisible', savedFigureVisibility);

% change the directory
cd(currentDir)
