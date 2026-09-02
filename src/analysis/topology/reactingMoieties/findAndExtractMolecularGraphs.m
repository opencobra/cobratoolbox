function [CMTG, RMTG, CMG, RMG, conservedGroup, reactingGroups] = findAndExtractMolecularGraphs(BIG, BMG, bondSubgraphs)
% Identify conserved and reacting isomorphic groups of bond subgraphs and extract the associated molecular graphs
%
% USAGE:
%
%    [CMTG, RMTG, CMG, RMG, conservedGroup, reactingGroups] = findAndExtractMolecularGraphs(BIG, BMG, bondSubgraphs)
%
% INPUTS:
%    BIG:              the original bond instance graph containing all bonds and nodes, with fields:
%
%                        * .Edges - edge table with an `EdgeIndex` column
%                        * .Nodes - node table
%    BMG:              cell array containing bond mapping graphs (subgraphs)
%    bondSubgraphs:    cell array where each cell contains a subgraph representing a set of bonds mapped to each other
%
% OUTPUTS:
%    CMTG:             conserved molecular transition graph from `bondSubgraphs`
%    RMTG:             reacting molecular transition graph from `bondSubgraphs`
%    CMG:              conserved molecular graph from `BIG`
%    RMG:              reacting molecular graph from `BIG`
%    conservedGroup:    indices of subgraphs in the largest isomorphic group
%    reactingGroups:    indices of subgraphs not part of the largest isomorphic group

    % Step 1: Identify Conserved and Reacting Groups
    numSubgraphs = size(bondSubgraphs, 1);

    % Classification itself is delegated to the shared, invariant-prefiltered
    % helper classifySubgraphIsomorphism (feature
    % 021-prefilter-isomorphism-classification), which also gives this
    % function excludedSubgraphs-equivalent early-exit pruning it previously
    % lacked.
    isomorphicGroups = classifySubgraphIsomorphism(bondSubgraphs);

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

