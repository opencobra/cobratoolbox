function moietyGraph = createMoietyGraph(model, BG, arm)
% CreateMoietyGraph generates a graph representation of moieties in a metabolic network.
%
% Input:
%   - model: A structure containing information about the metabolic submodel.
%   - BG: A graph representing the metabolic network.
%   - arm: An atomically resolved model as a matlab structure
%          from identyConservedMoieties function.
% Output:
%   - moietyGraph: Graph representation of moiety cycles in a metabolic network.
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

