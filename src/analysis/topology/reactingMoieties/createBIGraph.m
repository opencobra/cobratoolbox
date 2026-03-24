function BIG = createBIGraph(BG)
% CREATEBMGRAPH Creates a multigraph (BMGraph) where each bond instance 
% (e.g., in double bonds) is represented as a separate edge.
%
% INPUT:
%   BG - The original graph containing nodes and edges with properties.
%
% OUTPUT:
%   BIG - Bond instance graph with duplicate edges for each bond type, preserving all properties.

    % Remove energy node from the original graph (assuming energy node has 'Element' named 'E')
    energyNodeId = find(ismember(BG.Nodes.Element, 'E'));
    graphNoE = rmnode(BG, energyNodeId);

    % Initialize a new graph for the bond multigraph
    BIG = digraph(); % Use digraph() for directed graphs, graph() for undirected

    % Add all nodes from the original graph to the bond multigraph, preserving properties
    BIG = addnode(BIG, graphNoE.Nodes);

    % Initialize arrays for new edges
    srcNodes = [];
    tgtNodes = [];
    edgeProps = struct();
    propNames = graphNoE.Edges.Properties.VariableNames;

    % Prepare edge properties array
    for propIdx = 1:numel(propNames)
        edgeProps.(propNames{propIdx}) = [];
    end

    % Iterate over each edge to handle bond instances
    numEdges = numedges(graphNoE);
    for edgeIdx = 1:numEdges
        srcNode = graphNoE.Edges.EndNodes(edgeIdx, 1);
        tgtNode = graphNoE.Edges.EndNodes(edgeIdx, 2);
        edgeData = graphNoE.Edges(edgeIdx, :);

        bondMult = edgeData.Weight; % Assuming Weight indicates bond multiplicity
        for bInstance = 1:bondMult
            % Add edges for each bond instance
            srcNodes = [srcNodes; srcNode];
            tgtNodes = [tgtNodes; tgtNode];

            % Duplicate edge properties for each instance
            for propIdx = 1:numel(propNames)
                propName = propNames{propIdx};
                if strcmp(propName, 'Weight')
                    edgeProps.(propName) = [edgeProps.(propName); 1]; % Assign weight as 1 for each bond instance
                else
                    edgeProps.(propName) = [edgeProps.(propName); edgeData{1, propIdx}];
                end
            end
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

