function [brokenBondsTable, formedBondsTable, CAG, RAG, CBG, RBG] = identifyConservedReactingSubgraphs(model, dATM, dBTM)
% IDENTIFYCONSERVEDREACTINGSUBGRAPHS Identifies conserved and reacting bond and atom subgraphs.
%
% Inputs:
%   - dBTM: Bond transition multigraph.
%   - dATM: Atom transition multigraph.
%   - model: model containing reactions of interest.
%
% Outputs:
%   - CBG: Conserved bond subgraph.
%   - RBG: Reacting bond subgraph.
%   - CAG: Conserved atom subgraph.
%   - RAG: Reacting atom subgraph.
%   - brokenBondsTable: a table of the broken bonds in the model.
%   - formedBondsTable: a table of the formed bonds in the model.
%
% This function identifies conserved and reacting bond subgraphs from the
% bond transition multigraph and conserved and reacting atom subgraphs from
% the atom transition multigraph based on the provided submodel.
%
% Usage:
%   [brokenBondsTable, formedBondsTable, CAG, RAG, CBG, RBG] =
%   identifyConservedReactingSubgraphs(model, dATM, dBTM);
%
%
% Author: Hadjar Rahou, 2023
%
% Check if all inputs are defined
    if nargin ~= 3
        error('Three input arguments are required.');
    end

    % Check if inputs are of the correct type
    if ~isa(model, 'struct') || ~isa(dATM, 'digraph') || ~isa(dBTM, 'digraph')
        error('Invalid input types.');
    end
%Broken and formed bond tables in the reaction network 
rxns=model.rxns;
brokenBonds=[];
formedBonds=[];
for i=1:length(rxns)
    %rxnNode=dBTM.Nodes.BondIndex(find(ismember(dBTM.Nodes.mets,rxns(i))));
    %brokenBondrxnId=dBTM.Edges.HeadBondIndex(find(dBTM.Edges.TailBondIndex==rxnNode));
    %formedBondrxnId=dBTM.Edges.TailBondIndex(find(dBTM.Edges.HeadBondIndex==rxnNode));
    %brokenBondrxnId=dBTM.Edges.HeadBondIndex(find(ismember(dBTM.Edges.HeadMet,rxns(i))));
    %formedBondrxnId=dBTM.Edges.HeadBondIndex(find(ismember(dBTM.Edges.TailMet,rxns(i))));
    brokenBondrxnId=find(ismember(dBTM.Edges.TailMet,rxns(i)));
    formedBondrxnId=find(ismember(dBTM.Edges.HeadMet,rxns(i)));
    brokenBonds=[brokenBonds;brokenBondrxnId];
    formedBonds=[formedBonds;formedBondrxnId];
end
brokenBondsTable=dBTM.Edges(brokenBonds,:);
formedBondsTable=dBTM.Edges(formedBonds,:);

% Reacting bond subgraph
bins = conncomp(dBTM, 'Type', 'weak');
reactionNodes = find(ismember(dBTM.Nodes.mets, model.rxns));
componentIndices = bins(reactionNodes);
UniqueComponentIndices = unique(componentIndices);
componentNodes = [];
for i = 1:length(UniqueComponentIndices)
    componentNode = find(bins == UniqueComponentIndices(i));
    componentNodes = [componentNodes; componentNode'];
end
RBG = subgraph(dBTM, componentNodes);
% % In case of double bonds, conseved bond will be connected to reacting
% % bond graph
% % Define the initial set of nodes
% G=graph(RBG.Edges,RBG.Nodes);
% initialNodes = find(ismember(RBG.Nodes.mets, model.rxns)); %reaction nodes in RBG
% 
% % Initialize an empty array to store connected nodes
% connectedNodes = [];
% 
% % Find all nodes connected to any of the initial nodes
% for i = 1:length(initialNodes)
%     node = initialNodes(i);
%     % Find nodes connected to the current node within distance 1
%     nearestNodes = nearest(G, node, 1);
%     % Append these nodes to the connectedNodes array
%     connectedNodes = [connectedNodes; nearestNodes];
% end
% 
% % Remove duplicate nodes
% connectedNodes = unique(connectedNodes);
% 
% % Identify nodes that are not connected to the initial nodes
% allNodes = 1:numnodes(G);
% unconnectedNodes = setdiff(allNodes, [connectedNodes;initialNodes]);
% % Remove unconnected nodes from the graph
% RBG = rmnode(RBG, unconnectedNodes);

% Conserved bond subgraph
ReactingBonds = RBG.Nodes.BondIndex;
ConservedNodeIds = find(~ismember(dBTM.Nodes.BondIndex, ReactingBonds));
CBG = subgraph(dBTM, ConservedNodeIds);

% Remove the reaction nodes from the reacting bond graph
RBSG = rmnode(RBG, reactionNodes);

% Reacting atoms in the Bond transition multigraph
reactingAtomsBTM = unique([RBSG.Nodes.BondHeadAtomIndex; RBSG.Nodes.BondTailAtomIndex]);
reactingAtomsATM = find(ismember(dATM.Nodes.AtomIndex, reactingAtomsBTM));
RAG = subgraph(dATM, reactingAtomsATM);

% Conserved atoms in the Atom transition multigraph
conservedAtomsATM = find(~ismember(dATM.Nodes.AtomIndex, reactingAtomsBTM));
CAG = subgraph(dATM, conservedAtomsATM);
end


