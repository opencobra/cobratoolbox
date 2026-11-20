% The COBRAToolbox: testHit_node.m
%
% Purpose:
%     - hit_node is the ButtonDownFcn callback that createMetIntrcNetwork installs on the node
%       labels of a metabolite-metabolite network. A left click ('normal') draws, in a new
%       figure, the part of the current network adjacent to the clicked metabolite; a right
%       click ('alt') rebuilds the network of the clicked metabolite from the model
%       (consumed -> produced metabolites of its reactions, weighted by flux + 1e-6); other
%       clicks do nothing.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): the independent review (T021) showed that the documented node-degree
%       exclusion range (varargin{18}) is never applied, so this file makes no assertion
%       about the function. The wave 11 version of this test (git history) checked the
%       hand-derived networks, weights, widths and colour bars of a five-metabolite toy model
%       with a degree range that excluded nothing; a test of the fixed function must use a
%       restrictive range (for example [2 2]).
%
% Function under test:
%     src/visualization/createMetIntrcNetwork/hit_node.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model file, no solver; hand-built toy model and adjacency matrices.
%     Figures are created invisible and closed.
%
% Coverage exemptions:
%     every line - hit_node is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers, independent review T021). Before the quarantine the
%     test exempted lines 163-167 (dead code: line 127 replaces every NaN of G.Edges.LWidths,
%     so the condition of line 154 is always true).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The node-degree exclusion range excNodesWithDeg has no effect
%       SEVERITY: unusable-option
%       TRIGGER: model.mets = {'A'; 'B'; 'C'; 'D'; 'E'}; model.rxns = {'R1'; 'R2'; 'R3'};
%         model.S = [-1 0 -1; 1 -1 0; 0 1 -1; 0 0 1; 0 -1 0]; src = struct('String', 'B',
%         'Parent', struct('Parent', struct('SelectionType', 'normal')));
%         hit_node(src, [], [0 2 0 1; 0 0 3 0; 0 0 0 4; 0 0 0 0], {'A'; 'B'; 'C'; 'D'},
%         model, ones(3, 1), {}, 'Toy', [0 0 1], [1 0 0], 1, 0, 1e-6, 4, 6, 4, 1e-7, [2 2]);
%         the same with SelectionType 'alt' and fluxes [2; 3; 1]
%       OBSERVED: (R2025a, 2026-11-17) the new figure labels A, B and C in both cases, although
%         A and C have degree 1 (edges A -> B, B -> C) and the range is [2 2]: varargin{18} is
%         read at line 74 and only passed on to the next callback (line 151); the only degree
%         filter is the fixed removal of isolated nodes (lines 134-137)
%       EXPECTED: nodes whose total degree lies outside [minimum maximum] are removed, as the
%         help text documents ("node-degree exclusion range") and createMetIntrcNetwork does
%         for the main figure (its lines 210-218); the help text says the produced figure "has
%         same property with main figure"
%       LINES: 74, 134-137
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
%     - Converted to the quarantine layout after the independent review (T021), 2026-11-17.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testHit_node'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
