% Research: timing of baseline vs prototype on synthetic graphs of growing size
addpath(fileparts(mfilename('fullpath')));
sizes = [2000 4000 8000 16000];
T = zeros(numel(sizes), 3);
for i = 1:numel(sizes)
    rng(1);
    n = sizes(i);
    compOf = sort(randi(round(n / 3), n, 1)); % ~3 atoms per component
    [~, ~, compOf] = unique(compOf);
    s = zeros(0, 1); t = zeros(0, 1);
    for c = 1:max(compOf)
        ids = find(compOf == c);
        s = [s; ids(1:end-1)]; t = [t; ids(2:end)]; %#ok<AGROW>
    end
    ATG = graph(table([s t], (1:numel(s))', 'VariableNames', {'EndNodes', 'TransIndex'}), ...
        table((1:n)', compOf, 'VariableNames', {'AtomIndex', 'Component'}));
    ATG.Nodes.Component = conncomp(ATG)';
    % bonds join atoms with nearby indices (same "molecule" region)
    m = round(1.1 * n);
    bs = randi(n, m, 1); bt = min(n, max(1, bs + randi([-20 20], m, 1)));
    keep = bs ~= bt; bs = bs(keep); bt = bt(keep); m = numel(bs);
    BIG = digraph(table([bs bt], (1:m)', randi(round(m / 4), m, 1), rand(m, 1), ...
        'VariableNames', {'EndNodes', 'EdgeIndex', 'BondIndex', 'Weight'}), ...
        table((1:n)', 'VariableNames', {'AtomIndex'}));
    tic; [b0, m0, e0] = extractBondSubgraphsBaseline(BIG, ATG); T(i, 1) = toc;
    tic; [b1, m1, e1] = extractBondSubgraphsLocal(BIG, ATG, false); T(i, 2) = toc;
    tic; [b2, m2, e2, st] = extractBondSubgraphsLocal(BIG, ATG, true); T(i, 3) = toc;
    same = isequaln(e0, e1) && isequaln(e0, e2) && numel(b0) == numel(b2);
    fprintf('n=%5d edges=%5d passes=%5d outputs=%5d | baseline %7.2fs  story1 %6.2fs  story1+2 %6.2fs | same %d\n', ...
        n, m, st.passes, numel(b0), T(i, :), same);
end
for j = 1:3
    p = polyfit(log(sizes(:)), log(T(:, j)), 1);
    fprintf('log-log exponent column %d: %.2f\n', j, p(1));
end
