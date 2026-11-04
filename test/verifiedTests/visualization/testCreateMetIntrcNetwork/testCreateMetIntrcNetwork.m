% The COBRAToolbox: createMetIntrcNetwork.m
%
% Purpose:
%     - tests the basic functionality of createMetIntrcNetwork
%
% Function under test:
%     src/visualization/createMetIntrcNetwork/createMetIntrcNetwork.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; ecoli_core_model through getDistributedModel and
%     hand-built toy models.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Author:
%     - Kadir Kocabas November/2020
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%

% save the current path
currentDir = pwd;
% initialize the test
cd(fileparts(which('testCreateMetIntrcNetwork')))

fprintf('   Testing createMetIntrcNetwork...\n')

% load the ecoli core model
model= getDistributedModel('ecoli_core_model.mat');

% testing if nodes in the graph object and metabolites in the model are same.
tic
[GraphObj]=createMetIntrcNetwork(model,model.mets);
toc
delete(findall(0, 'Type', 'figure')) ; %deleting figure

left=model.S;
left(left>0)=0;
right=model.S;
right(right<0)=0;

model.mets(any(left,2)&any(right,2));%Detect if there are any metabolites with no interaction 
%with other metabolites inside the model.
%Because function won't add it on the network

assert(all(ismember(model.mets(any(left,2)&any(right,2)),GraphObj.Nodes.Variables)))
%
%
% testing if flux values are right in the graph creating toy metabolic model 
% with the defined reactions to make easy to keep track flux values and edge weights.
% Arbitrary fluxes were assigned to each reaction.
%
%  R1   ->  E                 flux: 1
%  R2:  ->  B                 flux: 1
%  R3:  A + B -> C + H        flux: 3
%  R4:  C + F-> D + G         flux: 5 
%  R5:  E + A <=> C + D       flux: 1
%  R6:  G + I <=> A + C       flux: -4
%  R7:  K + A + C + D -> T    flux: 1
%  R8:  T - > I               flux: 2
%  R9:  H-> K                 flux: 0

s=[0 0 -1 0 -1 1 -1 0 0;
   0 1 -1 0 0 0 0 0 0;
   0 0 1 -1 1 1 -2 0 0;
   0 0 0 1 2 0 -1 0 0;
   1 0 0 0 -1 0 0 0 0;
   0 0 0 1 0 -1 0 0 0;
   0 0 0 0 0 -1 0 1 0;
   0 0 0 0 0 0 -1 0 1;
   0 0 0 0 0 0 1 -1 0;
   0 0 1 0 0 0 0 0 -1];

metabolites={'A';'B';'C';'D';'E';'G';'I';'K';'T';'H'};
reactions={'R1';'R2';'R3';'R4';'R5';'R6';'R7';'R8';'R9'};

fluxes=[1;1;3;5;1;-4;1;2;0];%example fluxeses

model=struct();
model.S=s;
model.mets=metabolites;
model.rxns=reactions;

[GraphObj]=createMetIntrcNetwork(model,model.mets,'fluxes',fluxes);

%very small value added to flux values to produce comparable flux values with graph since matlab 
%graph object does not accept 0 as weight, and same procedure are also applied 
%in the main codes to avoid matlab graph object error.  
fluxes=fluxes+1e-6;
%
%fluxes were written in abs since the graph is produced as directed graph while
%the model is a reversible model.
%controling abitarily chosen 3 edge

%controlling A->C 
assert(GraphObj.Edges.Weight(findedge(GraphObj,'A','C'))==sum(abs(fluxes([3 5]))));
%controlling E->D
assert(GraphObj.Edges.Weight(findedge(GraphObj,'E','D'))==abs(fluxes(5)));
%controlling C->G
assert(GraphObj.Edges.Weight(findedge(GraphObj,'C','G'))==sum(abs(fluxes([4 6]))));


%Testing scale
min=0;
max=3;
[GraphObj]=createMetIntrcNetwork(model,model.mets,'fluxes',fluxes,'scaleMin',min,'scaleMax',max);
colorbarObj = get(gca,'Colorbar'); % getting colorbar object from figure
limits = get(colorbarObj, 'Limits'); % getting limits of colorbar
assert(limits(1)==min & limits(2)==max);
delete(findall(0,'Type','figure')); %deleting figure

% Testing direction of arrows using nodes that are only source or target.

%testing if A can be produced. A only produces another
%metabolites in the toy model and fluxes. Controlling A  if it takes place in 
%the network as a target
assert(~any(ismember(GraphObj.Edges.EndNodes(:,2),'A')));

%testing if G can produce another metabolites. G is only produced from another
%metabolites in the toy model and fluxes. Controlling G  if it takes place in 
%the network as a source
assert(~any(ismember(GraphObj.Edges.EndNodes(:,1),'G')));

%% Invalid scale and degree options are rejected
assert(verifyCobraFunctionError('createMetIntrcNetwork', 'inputs', {model, model.mets, 'scaleMin', 2, 'scaleMax', 1}, ...
                                'testMessage', 'scaleMax should bigger than scaleMin'));
assert(verifyCobraFunctionError('createMetIntrcNetwork', 'inputs', {model, model.mets, 'excNodesWithDeg', [5 1]}, ...
                                'testMessage', 'maximum degree should bigger or equal to minimum degree'));
assert(verifyCobraFunctionError('createMetIntrcNetwork', 'inputs', {model, model.mets, 'excNodesWithDeg', [1000 2000]}, ...
                                'testMessage', 'There is no node with degree in the given range'));

%% Warnings: scales without fluxes, and metabolites that are not in the model
lastwarn('');
createMetIntrcNetwork(model, model.mets, 'scaleMin', 0, 'scaleMax', 3);
assert(contains(lastwarn, 'Scales are given without giving fluxes'));
delete(findall(0, 'Type', 'figure'));

lastwarn('');
[GraphUnknownMet] = createMetIntrcNetwork(model, {'A'; 'notInModel'});
assert(contains(lastwarn, 'These metabolites are not found in model : notInModel'));
assert(ismember('A', GraphUnknownMet.Nodes.Name));
assert(~ismember('notInModel', GraphUnknownMet.Nodes.Name));
delete(findall(0, 'Type', 'figure'));

%% The threshold removes edges from the plot (the returned graph keeps them)
% A threshold of 0 stands for 1e-5, which removes the edges of the reaction without flux (R9).
[GraphAllEdges] = createMetIntrcNetwork(model, model.mets, 'fluxes', fluxes, 'threshold', 0);
plottedGraph = findobj(gca, 'Type', 'GraphPlot');
nSmallEdges = nnz(GraphAllEdges.Edges.Weight < 1e-5);
assert(nSmallEdges > 0);
assert(numel(plottedGraph.LineWidth) == numedges(GraphAllEdges) - nSmallEdges); % one width per edge
delete(findall(0, 'Type', 'figure'));

% a threshold above every weight leaves a plot without edges and a warning
lastwarn('');
createMetIntrcNetwork(model, model.mets, 'fluxes', fluxes, 'threshold', 1e6);
assert(contains(lastwarn, 'There is no edges in the Network'));
assert(isempty(get(gca, 'Colorbar'))); % nothing to colour
delete(findall(0, 'Type', 'figure'));

%% All edges with the same weight: no relative width can be computed, so the width is one
modelOneRxn = struct();
modelOneRxn.S = [-1; 1];
modelOneRxn.mets = {'X'; 'Y'};
modelOneRxn.rxns = {'R1'};
createMetIntrcNetwork(modelOneRxn, modelOneRxn.mets, 'fluxes', 2);
plottedGraph = findobj(gca, 'Type', 'GraphPlot');
assert(plottedGraph.LineWidth == 1);
assert(~isempty(get(gca, 'Colorbar')));
delete(findall(0, 'Type', 'figure'));

% output a success message
fprintf('Done.\n');

% change the directory
cd(currentDir)
