function [bondSubgraphs, BMG, bmgEdgeIndex] = extractBondSubgraphsBaselineAssertK(BIG, ATG)
% Extract subgraphs of bonds and their mappings from a bond instance graph
%
% USAGE:
%
%    [bondSubgraphs, BMG] = extractBondSubgraphs(BIG, ATG)
%    [bondSubgraphs, BMG, bmgEdgeIndex] = extractBondSubgraphs(BIG, ATG)
%
% INPUTS:
%    BIG:    bond instance graph, the full weighted bond graph containing all bonds and weights
%    ATG:    atom transition graph, representing atoms as nodes and their bonds as edges, with field:
%
%              * .Nodes - node table with `AtomIndex` and `Component` columns
%
% OUTPUTS:
%    bondSubgraphs:    cell array where each entry represents a subgraph of connected bonds
%    BMG:              cell array of bond mapping graphs, representing isolated sets of mapped bonds
%
% OPTIONAL OUTPUT:
%    bmgEdgeIndex:     cell array, the same size as `BMG`; `bmgEdgeIndex{m}` holds the
%                      `EdgeIndex` values of the edges of `BMG{m}` (the same set as
%                      `BMG{m}.Edges.EdgeIndex`, in the order the edges were extracted)
%
% NOTE:
%    The bond instance graph is peeled component pair by component pair, then layer by
%    layer of repeated bond instances. Atom-to-component lookups and the edge arrays of
%    the shrinking bond instance graph are held in arrays that are built once and kept in
%    step with every edge removal, instead of being re-read from the graph objects at
%    every step. The outputs are identical to those of the original implementation. When
%    the atom and edge indices do not allow these lookup arrays (non-integer, non-positive
%    or duplicated `AtomIndex`, component labels outside `1..max(conncomp(ATG))`,
%    non-numeric end nodes), the original algorithm is used instead.

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

% A bond instance graph without edges yields no subgraphs
if numedges(BIG) == 0
    bondSubgraphs = {};
    BMG = {};
    bmgEdgeIndex = {};
    return
end

% Lookup arrays: component of every atom index, and the edge arrays of BIG
atomIndexATG = full(ATG.Nodes.AtomIndex);
componentATG = full(ATG.Nodes.Component);
endNodes = BIG.Edges.EndNodes;
edgeIdx = BIG.Edges.EdgeIndex;

isPositiveWholeNumeric = @(v) isnumeric(v) && all(v(:) >= 1) && all(v(:) == fix(v(:)));
lookupOK = isPositiveWholeNumeric(atomIndexATG) && isPositiveWholeNumeric(componentATG) ...
    && isPositiveWholeNumeric(endNodes) ...
    && numel(unique(atomIndexATG)) == numel(atomIndexATG) ...
    && all(componentATG <= nComps) && all(endNodes(:) <= max(atomIndexATG));
if lookupOK
    compOfAtom = zeros(max(atomIndexATG), 1);
    compOfAtom(atomIndexATG) = componentATG;
    lookupOK = all(compOfAtom(endNodes(:)) > 0);
end
if ~lookupOK
    [bondSubgraphs, BMG] = extractBondSubgraphsByComponentScan(BIG, ATG, atoms2component);
    bmgEdgeIndex = cellfun(@(g) g.Edges.EdgeIndex, BMG, 'UniformOutput', false);
    return
end

% Positions of the atoms of every component, ascending, as find(atoms2component == c)
nodesByComp = accumarray(atoms2component(:), (1:numel(atoms2component))', [nComps, 1], ...
    @(v) {sort(v(:))});

% Initialize cell arrays to store all combined subgraphs
bondSubgraphs = {};  % Contains subgraphs of connected bonds
BMG = {};  % Bond Mapping Graphs: Isolated sets of bonds that are mapped to each other
bmgEdgeIndex = {};  % EdgeIndex values of the edges of each Bond Mapping Graph

% Initialize counter for the subgraph index
subgraphIndex = 1;

% Make a copy of BIG for processing; endNodes and edgeIdx mirror its edge table
BIGCopy = BIG;

% Iterate until all edges are processed from BIGCopy
while size(endNodes, 1) > 0
    % Update the number of bonds after each iteration, since BIGCopy changes
    numBonds = size(endNodes, 1);
    bondIdProcessed = [];  % Reinitialize to store processed bond IDs in each iteration

    % Iterate over each bond in BIGCopy
    k = 1; % Initialize iteration counter for edges
    while k <= numBonds
        % Define the component IDs for the nodes involved in the bond
        component1 = compOfAtom(endNodes(k, 1));
        component2 = compOfAtom(endNodes(k, 2));

        % Combine the nodes from both components. Normally component1 and
        % component2 are distinct, so this is a simple union of two disjoint
        % node sets. However, for bond-cleaving reactions (e.g. peroxidases,
        % hydrolases) where a bond within a reactant connects two atoms that
        % end up in different product molecules, atom-transition tracking can
        % merge both product fragments (and the original reactant) into a
        % single connected component -- so the bond's own two endpoint atoms
        % can already share the same component (component1 == component2).
        % In that case the two node sets are identical, and concatenating
        % them would duplicate every node, which subgraph() rejects. Guard
        % against that case explicitly.
        if component1 == component2
            nodesInBothComponents = nodesByComp{component1};
        else
            nodesInBothComponents = [nodesByComp{component1}; nodesByComp{component2}];
        end
        % Create the subgraph containing nodes from both selected components
        combinedSubgraph = subgraph(ATG, nodesInBothComponents);

        % Find the subgraph in BIGCopy that corresponds to the combined subgraph
        % by selecting edges whose nodes match the AtomIndex in the combinedSubgraph.
        % Only its edge and node tables are used from here on.
        GBB = subgraph(BIGCopy, combinedSubgraph.Nodes.AtomIndex);
        GEdges = GBB.Edges;
        GNodes = GBB.Nodes;

        % Initialize cell arrays to store the combined subgraphs for each iteration
        combinedSubgraphs = {};
        BMgraph = {};  % Temporary storage for Bond Mapping Graphs
        BMedgeIdx = {};  % Temporary storage for their EdgeIndex values

        % Repeat until no edges of GBB are left
        while size(GEdges, 1) > 0
            % Get unique BondIndex values
            [~, firstOccurrenceIndices, groupIndices] = unique(GEdges.BondIndex, 'first');

            % Calculate the number of occurrences of each unique BondIndex
            occurrences = accumarray(groupIndices, 1);
            maxOccurrences = max(occurrences);

            % Peel one layer of first occurrences per repeat
            for layer = 1:maxOccurrences
                % Extract the first occurrence indices
                layerEdgeIdx = GEdges.EdgeIndex(firstOccurrenceIndices);
                bondIdProcessed = [bondIdProcessed; layerEdgeIdx]; %#ok<AGROW>

                % Source and target nodes of those edges
                layerEndNodes = GEdges.EndNodes(firstOccurrenceIndices, :);

                % Create the Bond Mapping Graph for the current set of bonds
                EdgeTable = GEdges(firstOccurrenceIndices, :);
                BMgraph{layer, 1} = digraph(EdgeTable, GNodes); %#ok<AGROW>
                BMedgeIdx{layer, 1} = layerEdgeIdx; %#ok<AGROW>

                % Add these edges to the combined subgraph
                combinedSubgraphs{layer, 1} = addedge(combinedSubgraph, ...
                    layerEndNodes(:, 1), layerEndNodes(:, 2)); %#ok<AGROW>

                % Remove the processed edges (row order of the rest is kept, as rmedge does)
                GEdges(firstOccurrenceIndices, :) = [];

                % Update `firstOccurrenceIndices` after edge removal
                if size(GEdges, 1) > 0
                    [~, firstOccurrenceIndices, ~] = unique(GEdges.BondIndex, 'first');
                else
                    break; % No more edges left
                end
            end
        end

        % Store the combined subgraphs created in this iteration
        for m = 1:length(combinedSubgraphs)
            bondSubgraphs{subgraphIndex, 1} = combinedSubgraphs{m}; %#ok<AGROW>
            BMG{subgraphIndex, 1} = BMgraph{m}; %#ok<AGROW>
            bmgEdgeIndex{subgraphIndex, 1} = BMedgeIdx{m}; %#ok<AGROW>
            subgraphIndex = subgraphIndex + 1; % Increment subgraph index
        end

        % Find IDs of the edges that have been processed in BIGCopy
        idsToRemove = find(ismember(edgeIdx, bondIdProcessed));

        % Remove the processed edges from BIGCopy and from its mirrored edge arrays
        BIGCopy = rmedge(BIGCopy, idsToRemove);
        endNodes(idsToRemove, :) = [];
        edgeIdx(idsToRemove) = [];

        % Update the number of bonds after removing edges
        numBonds = size(endNodes, 1);

        % If we have removed edges, do not increment `k` as it needs to check the new first edge
        % Else increment to the next edge
        if numBonds == 0
            break; % No more edges left
        elseif ismember(k, idsToRemove)
            k = 1; % Reset to first edge after removal
        else
            error('extractBondSubgraphsPeeling:kAdvanced', 'k advanced past the first remaining edge (k = %d).', k);
        end
    end
end

end

function [bondSubgraphs, BMG] = extractBondSubgraphsByComponentScan(BIG, ATG, atoms2component)
% The original extractBondSubgraphs algorithm, which reads the component of every bond's
% end atoms by scanning ATG.Nodes. It is kept as the fallback for inputs whose atom or edge
% indices do not allow the lookup arrays of the main function, so that such inputs give
% exactly the results, or raise exactly the errors, they always did.

% Initialize cell array to store all combined subgraphs
bondSubgraphs = {};  % Contains subgraphs of connected bonds
BMG = {};  % Bond Mapping Graphs: Isolated sets of bonds that are mapped to each other

% Initialize counter for the subgraph index
subgraphIndex = 1;

% Make a copy of BGW for processing
BIGCopy = BIG;

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
        % Combine the nodes from both components. Normally component1 and
        % component2 are distinct, so this is a simple union of two disjoint
        % node sets. However, for bond-cleaving reactions (e.g. peroxidases,
        % hydrolases) where a bond within a reactant connects two atoms that
        % end up in different product molecules, atom-transition tracking can
        % merge both product fragments (and the original reactant) into a
        % single connected component -- so the bond's own two endpoint atoms
        % can already share the same component (component1 == component2).
        % In that case nodesInComponent1 and nodesInComponent2 are identical,
        % and concatenating them would duplicate every node, which subgraph()
        % rejects. Guard against that case explicitly.
                if component1 == component2
                    nodesInBothComponents = nodesInComponent1;
                else
                    nodesInBothComponents = [nodesInComponent1; nodesInComponent2];
                end
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
