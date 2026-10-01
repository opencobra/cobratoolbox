% Research probe (candidate feature after 20260929-111453): does classifying component
% subgraphs stripped to the one label variable give identical isomorphism classes, faster?
ext = '/home/jackmcgoldrick/repos/reconXmoieties/experiments/moietySizing/results/outputs/extractBondSubgraphsPeeling';
S = load(fullfile(ext, 'n1960-inputs.mat'), 'ATG');
ATG = S.ATG; clear S
atoms2component = conncomp(ATG)';
subgraphs = extractPartitionSubgraphs(ATG, atoms2component);
fprintf('components %d; node vars %d, edge vars %d\n', numel(subgraphs), ...
    width(subgraphs{1}.Nodes), width(subgraphs{1}.Edges));

% 1. current behaviour: full subgraphs
tic
[classesFull, firstFull, subsequentFull] = classifySubgraphIsomorphism(subgraphs, 'NodeVariables', 'mets');
tFull = toc;

% 2. candidate: the same subgraphs, carrying only the 'mets' node variable (edges keep
%    their end nodes only), built once
tic
stripped = cell(size(subgraphs));
for k = 1:numel(subgraphs)
    g = subgraphs{k};
    [s, t] = findedge(g);
    stripped{k} = graph(s, t, [], table(g.Nodes.mets, 'VariableNames', {'mets'}));
end
tStrip = toc;
% guard: stripping must not change node count, edge count or multi-edges
sameShape = all(cellfun(@(a, b) numnodes(a) == numnodes(b) && numedges(a) == numedges(b), subgraphs, stripped));
tic
[classesStripped, firstStripped, subsequentStripped] = classifySubgraphIsomorphism(stripped, 'NodeVariables', 'mets');
tStripped = toc;

same = isequal(classesFull, classesStripped) && isequal(firstFull, firstStripped) && ...
    isequal(subsequentFull, subsequentStripped);
fprintf('classes %d; identical %d; shapes preserved %d\n', numel(classesFull), same, sameShape);
fprintf('full: %.1f s | stripped: strip %.1f s + classify %.1f s = %.1f s | ratio %.3f\n', ...
    tFull, tStrip, tStripped, tStrip + tStripped, (tStrip + tStripped) / tFull);
