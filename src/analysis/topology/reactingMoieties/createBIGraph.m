function BIG = createBIGraph(BG)
% Creates a multigraph (BIG) where each bond instance (e.g. in double bonds)
% is represented as a separate edge, preserving all node and edge properties
%
% USAGE:
%
%    BIG = createBIGraph(BG)
%
% INPUT:
%    BG:     the original bond graph, a MATLAB graph with field:
%
%              * .Nodes - node table with an `Element` column (the energy node has `Element` = `'E'`)
%
% OUTPUT:
%    BIG:    bond instance graph (digraph) with duplicate edges for each bond type, preserving all properties

    % Remove energy node from the original graph (assuming energy node has 'Element' named 'E')
    energyNodeId = find(ismember(BG.Nodes.Element, 'E'));
    graphNoE = rmnode(BG, energyNodeId);

    % Initialize a new graph for the bond multigraph
    BIG = digraph(); % Use digraph() for directed graphs, graph() for undirected

    % Add all nodes from the original graph to the bond multigraph, preserving properties
    BIG = addnode(BIG, graphNoE.Nodes);

    propNames = graphNoE.Edges.Properties.VariableNames;
    numEdges = numedges(graphNoE);

    % Expand each edge into one row per bond instance, in edge-major order.
    % Weight indicates bond multiplicity; max(floor(Weight), 0) matches the
    % 1:Weight instance count exactly (non-integer weights truncate, zero or
    % negative weights emit nothing).
    instanceCounts = max(floor(graphNoE.Edges.Weight), 0);
    rowIdx = repelem((1:numEdges)', instanceCounts);
    srcNodes = graphNoE.Edges.EndNodes(rowIdx, 1);
    tgtNodes = graphNoE.Edges.EndNodes(rowIdx, 2);

    % Duplicate edge properties for each instance, with every instance's weight set to 1
    edgeProps = struct();
    for propIdx = 1:numel(propNames)
        propName = propNames{propIdx};
        if strcmp(propName, 'Weight')
            edgeProps.(propName) = ones(numel(rowIdx), 1);
        else
            edgeProps.(propName) = graphNoE.Edges.(propName)(rowIdx, :);
        end
    end

    % Create a table of all edges
    newEdgesTable = table(srcNodes, tgtNodes, 'VariableNames', {'Source', 'Target'});

    % Append edge properties to the new edges table
    for propIdx = 1:numel(propNames)
        newEdgesTable.(propNames{propIdx}) = edgeProps.(propNames{propIdx});
    end

    % Add edges to the bond multigraph
    BIG = addedge(BIG, newEdgesTable.Source, newEdgesTable.Target);

    % Add unique identifiers for edges
    edgeIndices = (1:size(BIG.Edges, 1))';
    BIG.Edges.EdgeIndex = edgeIndices;

    % Assign edge properties to the bond multigraph
    for propIdx = 1:numel(propNames)
        if ~strcmp(propNames{propIdx}, 'EndNodes')
            BIG.Edges.(propNames{propIdx}) = newEdgesTable.(propNames{propIdx});
        end
    end
end

