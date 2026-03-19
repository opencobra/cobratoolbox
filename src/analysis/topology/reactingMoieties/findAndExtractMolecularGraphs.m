function [CMTG, RMTG, CMG, RMG, conservedGroup, reactingGroups] = findAndExtractMolecularGraphs(BIG, BMG, bondSubgraphs)
% findAndExtractMolecularGraphs - Identifies conserved and reacting isomorphic groups
% and extracts associated molecular graphs.
%
% Inputs:
%   BIG - The original graph containing all bonds and nodes.
%   BMG - Cell array containing bond mapping graphs (subgraphs).
%   bondSubgraphs - Cell array where each cell contains a subgraph representing
%                   a set of bonds mapped to each other.
%
% Outputs:
%   CMTG - Conserved Molecular Transition Graph from bondSubgraphs.
%   RMTG - Reacting Molecular Transition Graph from bondSubgraphs.
%   CMG  - Conserved Molecular Graph from BIG.
%   RMG  - Reacting Molecular Graph from BIG.
%   conservedGroup - Indices of subgraphs in the largest isomorphic group.
%   reactingGroups - Indices of subgraphs not part of the largest isomorphic group.

    % Step 1: Identify Conserved and Reacting Groups
    numSubgraphs = size(bondSubgraphs, 1);

    % Initialize isomorphic matrix
    isomorphicMatrix = false(numSubgraphs, numSubgraphs);

    % Compare all pairs of subgraphs for isomorphism
    for i = 1:numSubgraphs
        for j = i+1:numSubgraphs
            if isisomorphic(bondSubgraphs{i, 1}, bondSubgraphs{j, 1})
                isomorphicMatrix(i, j) = true;
                isomorphicMatrix(j, i) = true;
            end
        end
    end

    % Identify isomorphic groups
    isomorphicGroups = cell(numSubgraphs, 1);
    visited = false(1, numSubgraphs);
    groupIndex = 1;

    for i = 1:numSubgraphs
        if ~visited(i)
            isomorphicGroup = find(isomorphicMatrix(i, :));
            isomorphicGroup = [i, isomorphicGroup];
            visited(isomorphicGroup) = true;
            isomorphicGroups{groupIndex} = isomorphicGroup;
            groupIndex = groupIndex + 1;
        end
    end

    % Remove empty cells
    isomorphicGroups = isomorphicGroups(~cellfun('isempty', isomorphicGroups));

    % Find the largest group of isomorphic subgraphs
    [~, largestGroupIndex] = max(cellfun(@length, isomorphicGroups));
    conservedGroup = isomorphicGroups{largestGroupIndex};
    reactingGroups = setdiff(1:numSubgraphs, conservedGroup);

    % Step 2: Create CMTG and RMTG from bondSubgraphs
    conservedEdges = [];
    conservedNodes = table();
    for idx = conservedGroup
        conservedEdges = [conservedEdges; bondSubgraphs{idx, 1}.Edges];
        conservedNodes = [conservedNodes; bondSubgraphs{idx, 1}.Nodes];
    end
    conservedNodes = unique(conservedNodes, 'rows'); % Remove duplicate nodes
    CMTG = digraph(conservedEdges, conservedNodes); % Conserved Molecular Transition Graph

    reactingEdges = [];
    reactingNodes = table();
    for idx = reactingGroups
        reactingEdges = [reactingEdges; bondSubgraphs{idx, 1}.Edges];
        reactingNodes = [reactingNodes; bondSubgraphs{idx, 1}.Nodes];
    end
    reactingNodes = unique(reactingNodes, 'rows'); % Remove duplicate nodes
    RMTG = digraph(reactingEdges, reactingNodes); % Reacting Molecular Transition Graph

    % Step 3: Extract CMG and RMG from BIG
    % Extract conserved edge indices
    conservedEdgeIndices = [];
    for i = 1:length(conservedGroup)
        conservedEdgeIndices = [conservedEdgeIndices; BMG{conservedGroup(i), 1}.Edges.EdgeIndex];
    end
    conservedEdgeIDs = find(ismember(BIG.Edges.EdgeIndex, conservedEdgeIndices));
    conservedEdgeTable = BIG.Edges(conservedEdgeIDs, :);
    CMG = digraph(conservedEdgeTable, BIG.Nodes); % Conserved Molecular Graph

    % Extract reacting edge indices
    reactingEdgeIndices = [];
    for i = 1:length(reactingGroups)
        reactingEdgeIndices = [reactingEdgeIndices; BMG{reactingGroups(i), 1}.Edges.EdgeIndex];
    end
    reactingEdgeIDs = find(ismember(BIG.Edges.EdgeIndex, reactingEdgeIndices));
    reactingEdgeTable = BIG.Edges(reactingEdgeIDs, :);
    RMG = digraph(reactingEdgeTable, BIG.Nodes); % Reacting Molecular Graph

    % Display Results
    %fprintf('Conserved Molecular Transition Graph (CMTG):\n');
    %fprintf('- Number of nodes: %d\n', numnodes(CMTG));
    %fprintf('- Number of edges: %d\n\n', numedges(CMTG));

    %fprintf('Reacting Molecular Transition Graph (RMTG):\n');
   % fprintf('- Number of nodes: %d\n', numnodes(RMTG));
    %fprintf('- Number of edges: %d\n\n', numedges(RMTG));

    %fprintf('Conserved Molecular Graph (CMG):\n');
    %fprintf('- Number of nodes: %d\n', numnodes(CMG));
    %fprintf('- Number of edges: %d\n\n', numedges(CMG));

    %fprintf('Reacting Molecular Graph (RMG):\n');
    %fprintf('- Number of nodes: %d\n', numnodes(RMG));
    %fprintf('- Number of edges: %d\n', numedges(RMG));
end

