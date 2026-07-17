function [MG, moietyMG, moietyInstanceG] = getMetMoietySubgraphs(model, BG, arm)
% Extract metabolite, moiety, and moiety-instance subgraphs from the bond graph of a model
%
% USAGE:
%
%    [MG, moietyMG, moietyInstanceG] = getMetMoietySubgraphs(model, BG, arm)
%
% INPUTS:
%    model:            COBRA model structure, with field:
%
%                        * .mets - `m x 1` cell array of metabolite identifiers
%    BG:               bipartite bond graph of the metabolic network, a MATLAB graph with field:
%
%                        * .Nodes - node table with a `mets` column identifying the metabolite of each node
%    arm:              atomically resolved model structure from identifyConservedReactingMoieties, with fields:
%
%                        * .L - matrix mapping isomorphism classes to metabolites (its row count is the number of moiety classes)
%                        * .I2A - matrix mapping each isomorphism class to one or more atoms
%                        * .ATG - atom transition graph (MATLAB graph)
%                        * .MTG - moiety transition graph (MATLAB graph)
%
% OUTPUTS:
%    MG:               cell array of metabolite subgraphs
%    moietyMG:         cell array of moiety subgraphs
%    moietyInstanceG:    cell array of moiety instance subgraphs
%
% .. Author: - Hadjar Rahou, 2023


% Create a moiety subgraph
n=size(arm.L,1);
Moiety = cell(n, 1);
moietyMG = cell(n, 1);
for i = 1:n
    Moiety{i} = find(arm.I2A(i,:) == 1)';
    moietyMG{i,1} = subgraph(BG, Moiety{i});
end
%Create a moiety instance graph 
m=size(arm.MTG.Nodes,1);
MoietyInstances = cell(m, 1);
moietyInstanceG = cell(m, 1);
%Create the matrix MI2A
MI2A=zeros(size(arm.MTG.Nodes,1),size(arm.ATG.Nodes,1));
for i=1:size(arm.ATG.Nodes,1)
j=arm.ATG.Nodes.MoietyIndex(i);
MI2A(j,i)=1;
end
for i = 1:m
    MoietyInstances{i} = find(MI2A(i,:) == 1)';
    moietyInstanceG{i,1} = subgraph(BG, MoietyInstances{i});
end
%Create a metabolite subgraph
numMetabolites = length(model.mets);
metIds = cell(1, numMetabolites);
MG= cell( numMetabolites,1);

for i = 1:numMetabolites
    metIds{i} = find(ismember(BG.Nodes.mets, model.mets(i)));
    MG{i,1}=subgraph(BG,metIds{i});
end

% Test 1: Check the number of moieties and metabolite subgraphs
assert(length(moietyMG) == n, 'Number of moieties subgraphs does not match.');
assert(length(MG) == numMetabolites, 'Number of metabolite subgraphs does not match.');

% Test 2: Check if moieties subgraphs contain nodes
for i = 1:n
    assert(numnodes(moietyMG{i}) > 0, 'Moiety subgraph should contain nodes.');
end

% Test 3: Check if metabolite subgraphs contain nodes
for i = 1:numMetabolites
    assert(numnodes(MG{i}) > 0, 'Metabolite subgraph should contain nodes.');
end

end

