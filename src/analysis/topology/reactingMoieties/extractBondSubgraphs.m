function [bondSubgraphs, BMG] = extractBondSubgraphs(BIG, ATG)
% EXTRACTBONDSUBGRAPHS Extracts subgraphs of bonds and their mappings.
%
% INPUTS:
%   BIG - Bond Instance Graph: The full weighted bond graph containing all bonds and weights.
%   ATG - Atom Graph: Represents atoms as nodes and their bonds as edges.
%   atoms2component - Array mapping each atom to a specific component or group.
%
% OUTPUTS:
%   bondSubgraphs - Cell array where each entry represents a subgraph of connected bonds.
%   BMG - Cell array of Bond Mapping Graphs (BMG), representing isolated sets of mapped bonds.

% Initialize cell array to store all combined subgraphs
bondSubgraphs = {};  % Contains subgraphs of connected bonds
BMG = {};  % Bond Mapping Graphs: Isolated sets of bonds that are mapped to each other

% Initialize counter for the subgraph index
subgraphIndex = 1;

% Make a copy of BGW for processing
BIGCopy = BIG;

% Find connected components of underlying undirected graph.
% Each component corresponds to an "atom conservation relation".
if verLessThan('matlab','8.6')
    error('Requires matlab R2015b+')
else
    %assign the atoms of the atom transition graph into different
    %connected components
    atoms2component = conncomp(ATG)'; % Use built-in matlab algorithm. Introduced in R2015b.
    nComps = max(atoms2component);
end
% Iterate until all edges are processed from BGWCopy
while numedges(BIGCopy) > 0
    % Update the number of bonds after each iteration, since BGWCopy changes
    numBonds = numedges(BIGCopy);
    bondIdProcessed = [];  % Reinitialize to store processed bond IDs in each iteration

    % Iterate over each bond in BGWCopy
    k = 1; % Initialize iteration counter for edges
    while k <= numBonds
        % Get the tail and head atom indices for the current bond in BGWCopy
        i = BIGCopy.Edges.EndNodes(k, 1);
        j = BIGCopy.Edges.EndNodes(k, 2);
        
        % Define the component IDs for the nodes involved in the bond
        component1 = ATG.Nodes.Component(ATG.Nodes.AtomIndex == i);
        component2 = ATG.Nodes.Component(ATG.Nodes.AtomIndex == j);
        
        % Find nodes belonging to the selected components
        nodesInComponent1 = find(atoms2component == component1);
        nodesInComponent2 = find(atoms2component == component2);
        
        % Combine the nodes from both components
        nodesInBothComponents = [nodesInComponent1; nodesInComponent2];
        
        % Create the subgraph containing nodes from both selected components
        combinedSubgraph = subgraph(ATG, nodesInBothComponents);
        
        % Find the subgraph in BGWCopy that corresponds to the combined subgraph
        % by selecting edges whose nodes match the AtomIndex in the combinedSubgraph
        GBB = subgraph(BIGCopy, combinedSubgraph.Nodes.AtomIndex);
        
        % Initialize a cell array to store the combined subgraphs for each iteration
        combinedSubgraphs = {};
        BMgraph = {};  % Temporary storage for Bond Mapping Graphs
        iteration = 1;

        % Repeat until GBB is empty (i.e., no edges left)
        while numedges(GBB) > 0
            % Get unique BondIndex values
            [uniqueBonds, firstOccurrenceIndices, groupIndices] = unique(GBB.Edges.BondIndex, 'first');
            
            % Calculate the number of occurrences of each unique BondIndex
            occurrences = accumarray(groupIndices, 1);
            maxOccurrences = max(occurrences);
            
            % Iterate through the maximum occurrences to create subgraphs
            for j = 1:maxOccurrences
                % Extract the first occurrence indices
                bondIds = GBB.Edges.EdgeIndex(firstOccurrenceIndices);
                bondIdProcessed = [bondIdProcessed; bondIds];
                
                % Extract source and target nodes of those edges
                s = GBB.Edges.EndNodes(firstOccurrenceIndices, 1); % Source nodes
                t = GBB.Edges.EndNodes(firstOccurrenceIndices, 2); % Target nodes
                
                % Create a subgraph for the current set of bonds
                EdgeTable = GBB.Edges(firstOccurrenceIndices, :); % Edge table for the subgraph
                NodeTable = GBB.Nodes; % Full node table (preserved properties)
                BMgraph{j, 1} = digraph(EdgeTable, NodeTable); % Construct the Bond Mapping Graph
                
                % Add these edges to the combined subgraph
                currentCombinedGraph = addedge(combinedSubgraph, s, t);
                
                % Store the current subgraph
                combinedSubgraphs{j, 1} = currentCombinedGraph;
                
                % Remove the edges that have been processed from GBB
                GBB = rmedge(GBB, firstOccurrenceIndices);
                
                % Update `firstOccurrenceIndices` after edge removal
                if numedges(GBB) > 0
                    [~, firstOccurrenceIndices, ~] = unique(GBB.Edges.BondIndex, 'first');
                else
                    break; % No more edges left in GBB
                end
            end
            
            % Update iteration counter
            iteration = iteration + 1;
        end

        % Store the combined subgraphs created in this iteration in bondSubgraphs
        for m = 1:length(combinedSubgraphs)
            bondSubgraphs{subgraphIndex, 1} = combinedSubgraphs{m}; % Subgraphs of connected bonds
            BMG{subgraphIndex, 1} = BMgraph{m}; % Bond Mapping Graphs
            subgraphIndex = subgraphIndex + 1; % Increment subgraph index
        end

        % Find IDs of the edges that have been processed in BGWCopy
        idsToRemove = find(ismember(BIGCopy.Edges.EdgeIndex, bondIdProcessed));
        
        % Remove the processed edges from BGWCopy
        BIGCopy = rmedge(BIGCopy, idsToRemove);
        
        % Update the number of bonds after removing edges
        numBonds = numedges(BIGCopy);
        
        % If we have removed edges, do not increment `k` as it needs to check the new first edge
        % Else increment to the next edge
        if numBonds == 0
            break; % No more edges left
        elseif ismember(k, idsToRemove)
            k = 1; % Reset to first edge after removal
        else
            k = k + 1; % Increment to next edge
        end
    end
end

end

