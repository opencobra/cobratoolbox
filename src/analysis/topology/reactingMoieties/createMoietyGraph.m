function moietyGraph = createMoietyGraph(model, BG, arm)
% Generates a graph representation of moiety cycles in a metabolic network
%
% USAGE:
%
%    moietyGraph = createMoietyGraph(model, BG, arm)
%
% INPUTS:
%    model:        COBRA model structure of the metabolic submodel, with field:
%
%                    * .mets - `m x 1` cell array of metabolite identifiers
%    BG:           bond graph of the metabolic network, a MATLAB graph with field:
%
%                    * .Nodes - node table with a `mets` column identifying the metabolite of each node
%    arm:          atomically resolved model structure from identifyConservedReactingMoieties, with fields:
%
%                    * .L - matrix mapping isomorphism classes to metabolites
%                    * .MTG - moiety transition graph (MATLAB graph)
%
% OUTPUT:
%    moietyGraph:    graph representation of moiety cycles in the metabolic network
%
% .. Author: - Hadjar Rahou, 2023


mets=model.mets;
%Create an empty graph to store moieties
moietyGraph = graph();


   % Loop through each moiety species
for j = 1:size(arm.L,1)
    MoietyNodes = arm.MTG.Nodes(arm.MTG.Nodes.IsomorphismClass == j, :);
    % Calculate the moeity inclusion rates for each metabolite
    moietyMets = unique(MoietyNodes.mets);
    [~,moietyMG,~] = getMetMoietySubgraphs(model,BG,arm);
    inclusionRates = zeros(length(moietyMets), 1);
    
    for i = 1:length(moietyMets)
        metId = find(ismember(mets, moietyMets(i)));
        moietyCount = arm.L(j, metId);
        inclusionRate = sum(ismember(moietyMG{j, 1}.Nodes.mets, moietyMets(i))) / ...
            (moietyCount * sum(ismember(BG.Nodes.mets, moietyMets(i))));
        %inclusionRates = [inclusionRates; inclusionRate];
        inclusionRates(i) = inclusionRate;
    end
    % Sort metabolites based on inclusion rates
    [A, I] = sort(inclusionRates);
    inclusionOrder = moietyMets(I);
    
    % Get the end node for the moiety cycle
    endNode = MoietyNodes.MoietyIndex(ismember(MoietyNodes.mets, inclusionOrder(end)));
    ids = find(ismember(MoietyNodes.mets, inclusionOrder(1)));
    
    % Loop through the selected starting nodes
    for i = 1:length(ids)
        firstNode = MoietyNodes.MoietyIndex(ids(i));
        connectedMoieties = allpaths(arm.MTG, firstNode, endNode);
        connectedMoieties = unique([connectedMoieties{:}]);
        NodeTable = MoietyNodes(find(ismember(MoietyNodes.MoietyIndex, connectedMoieties)), :);
        %v = 1:size(NodeTable, 1);
        %edges = [v; circshift(v, -1)];
            
        % Create edges for the current moiety cycle
        edges=[connectedMoieties; circshift(connectedMoieties, -1)];
        inclusionOrder = inclusionOrder(ismember(inclusionOrder, NodeTable.mets));
        A = A(ismember(inclusionOrder, NodeTable.mets));
        IsomorphismClass=repmat(j,1,length(inclusionOrder))';
        EdgeTable = table([edges(1, :)' edges(2, :)'], inclusionOrder, A, IsomorphismClass,'VariableNames', {'EndNodes', 'mets', 'Weight','IsomorphismClass'});
        
        % Create a graph for the current cycle
        moietyCycle = graph(EdgeTable, arm.MTG.Nodes);
        %moietyCycle = graph(EdgeTable);
        
        % Add the edges from the current cycle to the combined graph
        moietyGraph = addedge(moietyGraph, moietyCycle.Edges);
    end
end
%Add the node table to moietyGraph
%moietyGraph.Nodes=arm.MTG.Nodes;

end

