% captureClassifyReference.m
%
% One-off capture of the CI reference for feature 20260930-102230-isomorphism-label-only-copies
% (tasks.md T003; research R2, R3, R5). MUST run on UNMODIFIED
% src/analysis/topology/reactingMoieties/classifySubgraphIsomorphism.m (it refuses otherwise),
% so every expected classification, call count and error is the pre-change behaviour.
%
% Writes test/verifiedTests/analysis/testReactingMoieties/data/classifySubgraphIsomorphismReference.mat:
%   referenceLists - 30 deterministic lists of 12 graph/digraph multigraphs (parallel edges,
%                    self-loops, extra node and edge variables; every fifth list carries many
%                    extra variables), each stored once
%   referenceCases - every list classified in five modes (listIndex into referenceLists),
%                    with the call count
%   errorCases     - a cell-valued option and a missing variable, with the error raised
%
% USAGE (headless, after initCobraToolbox):
%   run('/home/jackmcgoldrick/cobratoolbox/specs/20260930-102230-isomorphism-label-only-copies/captureClassifyReference.m')

featureDir = fileparts(mfilename('fullpath'));
repoRoot = fileparts(fileparts(featureDir));
srcFile = 'src/analysis/topology/reactingMoieties/classifySubgraphIsomorphism.m';
referenceFile = fullfile(repoRoot, 'test', 'verifiedTests', 'analysis', 'testReactingMoieties', ...
    'data', 'classifySubgraphIsomorphismReference.mat');
baseCommit = 'f4a62639e';

srcStatus = system(sprintf('git -C "%s" diff --quiet %s -- %s', repoRoot, baseCommit, srcFile));
if srcStatus ~= 0
    error('captureClassifyReference:srcModified', ...
        '%s differs from %s: references must be captured from unmodified code.', srcFile, baseCommit);
end

modes = {{}, {'NodeVariables', 'mets'}, {'EdgeVariables', 'mets'}, ...
    {'NodeVariables', 'mets', 'EdgeVariables', 'mets'}, {'NodeVariables', "mets"}};

rng(1);
referenceLists = cell(30, 1);
referenceCases = struct('listIndex', {}, 'options', {}, 'isomorphismClasses', {}, ...
    'firstSubgraphIndices', {}, 'subsequentSubgraphIndices', {}, 'callCount', {});
for listIndex = 1:30
    isDirected = mod(listIndex, 2) == 0;
    manyVariables = mod(listIndex, 5) == 0;
    base = randomGraph(isDirected, manyVariables);
    subgraphs = cell(12, 1);
    for k = 1:12
        if rand < 0.5
            subgraphs{k} = reordernodes(base, randperm(numnodes(base)));   % isomorphic relabelling
        else
            subgraphs{k} = randomGraph(isDirected, manyVariables);
        end
    end
    referenceLists{listIndex} = subgraphs;
    for m = 1:numel(modes)
        classifySubgraphIsomorphism('resetCallCount');
        [isomorphismClasses, firstSubgraphIndices, subsequentSubgraphIndices] = ...
            classifySubgraphIsomorphism(subgraphs, modes{m}{:});
        callCount = classifySubgraphIsomorphism('getCallCount');
        referenceCases(end + 1) = struct('listIndex', listIndex, 'options', {modes{m}}, ...
            'isomorphismClasses', {isomorphismClasses}, 'firstSubgraphIndices', firstSubgraphIndices, ...
            'subsequentSubgraphIndices', subsequentSubgraphIndices, 'callCount', callCount); %#ok<SAGROW>
    end
end

errorSubgraphs = {randomGraph(false, false); randomGraph(false, false)};
errorOptions = {{'NodeVariables', {'mets'}}, {'NodeVariables', 'nope'}};
errorCases = struct('subgraphs', {}, 'options', {}, 'errorIdentifier', {}, 'errorMessage', {});
for e = 1:numel(errorOptions)
    errorRaised = false;
    try
        classifySubgraphIsomorphism(errorSubgraphs, errorOptions{e}{:});
    catch ME
        errorRaised = true;
        fprintf('error case %d: %s: %s (%s:%d)\n', e, ME.identifier, ME.message, ...
            ME.stack(1).name, ME.stack(1).line);
        errorCases(end + 1) = struct('subgraphs', {errorSubgraphs}, 'options', {errorOptions{e}}, ...
            'errorIdentifier', ME.identifier, 'errorMessage', ME.message); %#ok<SAGROW>
    end
    if ~errorRaised
        error('captureClassifyReference:noError', 'Error case %d did not raise an error.', e);
    end
end

provenance = struct('feature', '20260930-102230-isomorphism-label-only-copies', ...
    'baseCommit', baseCommit, 'matlab', version, ...
    'created', char(datetime('now', 'TimeZone', 'UTC', 'Format', 'yyyy-MM-dd HH:mm')));
save(referenceFile, 'referenceLists', 'referenceCases', 'errorCases', 'provenance', '-v7');
referenceInfo = dir(referenceFile);
nClasses = sum(arrayfun(@(c) numel(c.isomorphismClasses), referenceCases));
fprintf('REFERENCE wrote %s (%d bytes): %d reference cases (%d classes in total), %d error cases\n', ...
    referenceFile, referenceInfo.bytes, numel(referenceCases), nClasses, numel(errorCases));

function g = randomGraph(isDirected, manyVariables)
% A small multigraph (parallel edges and self-loops allowed) with label and extra variables
n = randi([3 9]);
m = randi([n 2 * n]);
s = randi(n, m, 1);
t = randi(n, m, 1);
metNames = {'a', 'b', 'c'};
nodes = table(metNames(randi(3, n, 1))', rand(n, 1), (1:n)', ...
    'VariableNames', {'mets', 'Junk', 'AtomIndex'});
edges = table([s t], metNames(randi(3, m, 1))', rand(m, 1), ...
    'VariableNames', {'EndNodes', 'mets', 'Weight'});
if manyVariables
    for v = 1:10
        if mod(v, 2) == 0
            edges.(sprintf('ExtraEdge%02d', v)) = arrayfun(@(x) sprintf('e%d', x), randi(9, m, 1), ...
                'UniformOutput', false);
        else
            edges.(sprintf('ExtraEdge%02d', v)) = rand(m, 1);
        end
    end
    for v = 1:5
        nodes.(sprintf('ExtraNode%02d', v)) = rand(n, 1);
    end
end
if isDirected
    g = digraph(edges, nodes);
else
    g = graph(edges, nodes);
end
end
