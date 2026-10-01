% Research probe R2-R4 for feature 20260930-102230
addpath(fileparts(mfilename('fullpath')));
%% R2: random graph/digraph multigraphs with self-loops and extra variables, three modes
rng(1); nFail = 0; nCases = 0;
for c = 1:60
    subgraphs = cell(12, 1);
    base = randomGraph(mod(c, 2) == 0);
    for k = 1:12
        if rand < 0.5
            p = randperm(numnodes(base));   % isomorphic relabelling of the base graph
            g = reordernodes(base, p);
        else
            g = randomGraph(mod(c, 2) == 0);
        end
        subgraphs{k} = g;
    end
    modes = {{}, {'NodeVariables', 'mets'}, {'EdgeVariables', 'mets'}, {'NodeVariables', 'mets', 'EdgeVariables', 'mets'}};
    for m = 1:numel(modes)
        [a1, b1, c1] = classifySubgraphIsomorphism(subgraphs, modes{m}{:});
        [a2, b2, c2] = classifySubgraphIsomorphismLabelOnly(subgraphs, modes{m}{:});
        nCases = nCases + 1;
        if ~(isequal(a1, a2) && isequal(b1, b2) && isequal(c1, c2))
            nFail = nFail + 1;
        end
    end
end
fprintf('R2 random: %d mismatches of %d classifications\n', nFail, nCases);

%% R3: option values that are cells or strings, and a missing variable
g = randomGraph(false); subgraphs = {g; g};
tryCall('cell {''mets''}', @() classifySubgraphIsomorphism(subgraphs, 'NodeVariables', {'mets'}));
tryCall('string "mets"', @() classifySubgraphIsomorphism(subgraphs, 'NodeVariables', "mets"));
tryCall('missing var', @() classifySubgraphIsomorphism(subgraphs, 'NodeVariables', 'nope'));
tryCall('label-only cell', @() classifySubgraphIsomorphismLabelOnly(subgraphs, 'NodeVariables', {'mets'}));
tryCall('label-only string', @() classifySubgraphIsomorphismLabelOnly(subgraphs, 'NodeVariables', "mets"));
tryCall('label-only missing', @() classifySubgraphIsomorphismLabelOnly(subgraphs, 'NodeVariables', 'nope'));

%% R4: real n1960 component subgraphs, uniform copy construction
ext = '/home/jackmcgoldrick/repos/reconXmoieties/experiments/moietySizing/results/outputs/extractBondSubgraphsPeeling';
S = load(fullfile(ext, 'n1960-inputs.mat'), 'ATG'); ATG = S.ATG; clear S
subgraphs = extractPartitionSubgraphs(ATG, conncomp(ATG)');
classifySubgraphIsomorphism('resetCallCount');
tic; [a1, b1, c1] = classifySubgraphIsomorphism(subgraphs, 'NodeVariables', 'mets'); t1 = toc;
n1 = classifySubgraphIsomorphism('getCallCount');
tic; [a2, b2, c2] = classifySubgraphIsomorphismLabelOnly(subgraphs, 'NodeVariables', 'mets'); t2 = toc;
fprintf('R4 n1960: identical %d; full %.1f s, label-only (copies built inside) %.1f s, ratio %.3f; isisomorphic calls %d\n', ...
    isequal(a1, a2) && isequal(b1, b2) && isequal(c1, c2), t1, t2, t2 / t1, n1);

function g = randomGraph(isDirected)
n = randi([3 9]); m = randi([n 2 * n]);
s = randi(n, m, 1); t = randi(n, m, 1);        % parallel edges and self-loops allowed
metNames = {'a', 'b', 'c'};
nodes = table(metNames(randi(3, n, 1))', rand(n, 1), (1:n)', 'VariableNames', {'mets', 'Junk', 'AtomIndex'});
edges = table([s t], metNames(randi(3, m, 1))', rand(m, 1), 'VariableNames', {'EndNodes', 'mets', 'Weight'});
if isDirected
    g = digraph(edges, nodes);
else
    g = graph(edges, nodes);
end
end

function tryCall(name, f)
try
    f(); fprintf('R3 %-20s ok\n', name);
catch ME
    fprintf('R3 %-20s ERROR %s: %s (%s:%d)\n', name, ME.identifier, ME.message, ME.stack(1).name, ME.stack(1).line);
end
end
