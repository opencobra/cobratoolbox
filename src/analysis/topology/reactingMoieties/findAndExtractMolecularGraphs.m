function [CMTG, RMTG, CMG, RMG, conservedGroup, reactingGroups] = findAndExtractMolecularGraphs(BIG, BMG, bondSubgraphs, bmgEdgeIndex)
% Identify conserved and reacting isomorphic groups of bond subgraphs and extract the associated molecular graphs
%
% USAGE:
%
%    [CMTG, RMTG, CMG, RMG, conservedGroup, reactingGroups] = findAndExtractMolecularGraphs(BIG, BMG, bondSubgraphs)
%    [CMTG, RMTG, CMG, RMG, conservedGroup, reactingGroups] = findAndExtractMolecularGraphs(BIG, BMG, bondSubgraphs, bmgEdgeIndex)
%
% INPUTS:
%    BIG:              the original bond instance graph containing all bonds and nodes, with fields:
%
%                        * .Edges - edge table with an `EdgeIndex` column
%                        * .Nodes - node table
%    BMG:              cell array containing bond mapping graphs (subgraphs)
%    bondSubgraphs:    cell array where each cell contains a subgraph representing a set of bonds mapped to each other
%
% OPTIONAL INPUT:
%    bmgEdgeIndex:     cell array, the same size as `BMG`, holding the `EdgeIndex` values of
%                      the edges of each `BMG{m}` (third output of `extractBondSubgraphs`).
%                      If omitted or empty, it is read from `BMG{m}.Edges.EdgeIndex`.
%
% OUTPUTS:
%    CMTG:             conserved molecular transition graph from `bondSubgraphs`
%    RMTG:             reacting molecular transition graph from `bondSubgraphs`
%    CMG:              conserved molecular graph from `BIG`
%    RMG:              reacting molecular graph from `BIG`
%    conservedGroup:    indices of subgraphs in the largest isomorphic group
%    reactingGroups:    indices of subgraphs not part of the largest isomorphic group
%
% NOTE:
%    The edge and node tables of the subgraphs of each group are joined with a single
%    concatenation, in group order, rather than grown one subgraph at a time, and the
%    edge indices of the bond mapping graphs can be passed in instead of being read from
%    every graph object. The outputs are identical to those of the original implementation.

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
    CMTG = assembleMolecularTransitionGraph(bondSubgraphs, conservedGroup); % Conserved Molecular Transition Graph
    RMTG = assembleMolecularTransitionGraph(bondSubgraphs, reactingGroups); % Reacting Molecular Transition Graph

    % Step 3: Extract CMG and RMG from BIG
    if ~exist('bmgEdgeIndex', 'var') || isempty(bmgEdgeIndex)
        bmgEdgeIndex = cellfun(@(g) g.Edges.EdgeIndex, BMG, 'UniformOutput', false);
    end
    bigEdges = BIG.Edges;

    % Extract conserved edge indices
    conservedEdgeIndices = vertcat(bmgEdgeIndex{conservedGroup});
    conservedEdgeIDs = find(ismember(bigEdges.EdgeIndex, conservedEdgeIndices));
    conservedEdgeTable = bigEdges(conservedEdgeIDs, :);
    CMG = digraph(conservedEdgeTable, BIG.Nodes); % Conserved Molecular Graph

    % Extract reacting edge indices
    reactingEdgeIndices = vertcat(bmgEdgeIndex{reactingGroups});
    reactingEdgeIDs = find(ismember(bigEdges.EdgeIndex, reactingEdgeIndices));
    reactingEdgeTable = bigEdges(reactingEdgeIDs, :);
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

function G = assembleMolecularTransitionGraph(bondSubgraphs, groupIdx)
% Union of the edge and node tables of bondSubgraphs(groupIdx), in group order, with
% duplicate nodes removed. Equivalent to growing the tables one subgraph at a time.
if isempty(groupIdx)
    edgesAll = [];
    nodesAll = table();
else
    edgeCells = cell(numel(groupIdx), 1);
    nodeCells = cell(numel(groupIdx), 1);
    for q = 1:numel(groupIdx)
        edgeCells{q} = bondSubgraphs{groupIdx(q), 1}.Edges;
        nodeCells{q} = bondSubgraphs{groupIdx(q), 1}.Nodes;
    end
    edgesAll = vertcat(edgeCells{:});
    nodesAll = vertcat(nodeCells{:});
end
nodesAll = unique(nodesAll, 'rows'); % Remove duplicate nodes
G = digraph(edgesAll, nodesAll);
end
