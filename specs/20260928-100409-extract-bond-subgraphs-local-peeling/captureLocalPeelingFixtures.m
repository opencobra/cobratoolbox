% captureLocalPeelingFixtures.m
%
% One-off capture of the golden references for feature
% 20260928-100409-extract-bond-subgraphs-local-peeling (tasks.md T006, T007; research R8).
%
% MUST be run on UNMODIFIED src/analysis/topology/reactingMoieties/extractBondSubgraphs.m
% (it refuses otherwise). Golden outputs come from extractBondSubgraphsBaseline.m, a
% verbatim copy of the pre-change function at b57404773, so they are pre-change outputs.
%
%   Part A (fixture 'synthetic'): hand-built and randomised CI inputs, a labelling-mismatch
%     case and an error-parity case, with their golden outputs, written to
%     test/verifiedTests/analysis/testReactingMoieties/data/bondSubgraphPeelingReference.mat
%   Part B (fixtures 'tyr', 'n332', 'n531', 'n1067', 'n1604', 'n1960'): BIG and ATG
%     captured at the extractBondSubgraphs call inside identifyConservedReactingMoieties by
%     a conditional breakpoint (no src/ edit), plus their golden outputs, written to the
%     local results tree (never committed) as SHA-256 fingerprints (research R8). For
%     n1960 the end-to-end outputs of identifyConservedReactingMoieties are saved as well
%     (SC-002).
%
% USAGE (headless, after initCobraToolbox):
%   setenv('CBT_EBS_FIXTURES', 'synthetic');   % optional subset; default: all
%   run('specs/20260928-100409-extract-bond-subgraphs-local-peeling/captureLocalPeelingFixtures.m')

featureDir = fileparts(mfilename('fullpath'));
repoRoot = fileparts(fileparts(featureDir));
srcFile = 'src/analysis/topology/reactingMoieties/extractBondSubgraphs.m';
testDataDir = fullfile(repoRoot, 'test', 'verifiedTests', 'analysis', 'testReactingMoieties', 'data');
referenceFile = fullfile(testDataDir, 'bondSubgraphPeelingReference.mat');
homeDir = char(java.lang.System.getProperty('user.home'));
extDir = fullfile(homeDir, 'repos', 'reconXmoieties', 'experiments', 'moietySizing', ...
    'results', 'outputs', 'extractBondSubgraphsPeeling');
baseCommit = 'b57404773';

%% refuse unless the function under change is the pre-change version
srcStatus = system(sprintf('git -C "%s" diff --quiet %s -- %s', repoRoot, baseCommit, srcFile));
if srcStatus ~= 0
    error('captureLocalPeelingFixtures:srcModified', ...
        '%s differs from %s: references must be captured from unmodified code.', srcFile, baseCommit);
end
addpath(featureDir);   % baseline copies, breakpoint condition helper, model builder

allFixtures = {'synthetic', 'tyr', 'n332', 'n531', 'n1067', 'n1604', 'n1960'};
fixtureList = allFixtures;
if ~isempty(getenv('CBT_EBS_FIXTURES'))
    fixtureList = strtrim(strsplit(getenv('CBT_EBS_FIXTURES'), ','));
    assert(all(ismember(fixtureList, allFixtures)), 'Unknown fixture in CBT_EBS_FIXTURES.')
end
[~, gitCommit] = system(sprintf('git -C "%s" rev-parse --short HEAD', repoRoot));
gitCommit = strtrim(gitCommit);

%% Part A: CI fixtures
if ismember('synthetic', fixtureList)
    cases = struct('name', {}, 'BIG', {}, 'ATG', {});
    [BIG, ATG] = buildHandBuiltCase();
    assertHandBuiltProperties(BIG, ATG);
    cases(end + 1) = struct('name', 'handBuilt', 'BIG', BIG, 'ATG', ATG);
    for seed = 1:20
        rng(seed);
        [BIGs, ATGs] = makeSynthetic(seed);
        cases(end + 1) = struct('name', sprintf('random%02d', seed), 'BIG', BIGs, 'ATG', ATGs); %#ok<SAGROW>
    end

    % labelling mismatch (research R2a): swap Component labels 1 and 2. With swapped labels
    % the pre-change loop never terminates if a bond has an end atom in component 1 or 2
    % but not one in each (its own pair's subgraph never contains it), so the BIG of this
    % case keeps only the bonds joining components 1 and 2 and the bonds avoiding both.
    ATGm = ATG;
    component = ATGm.Nodes.Component;
    component(ATG.Nodes.Component == 1) = 2;
    component(ATG.Nodes.Component == 2) = 1;
    ATGm.Nodes.Component = component;
    compOfAtom = zeros(max(ATG.Nodes.AtomIndex), 1);
    compOfAtom(ATG.Nodes.AtomIndex) = ATG.Nodes.Component;
    edgePair = sort(reshape(compOfAtom(BIG.Edges.EndNodes), [], 2), 2);
    keepEdge = ismember(edgePair, [1 2], 'rows') | ~any(edgePair <= 2, 2);
    BIGm = rmedge(BIG, find(~keepEdge));
    assert(passesLookupPreconditions(BIGm, ATGm) && ~isequal(ATGm.Nodes.Component(:), conncomp(ATGm)'), ...
        'labelMismatch must pass the lookup-array preconditions with Component ~= conncomp(ATG).');
    cases(end + 1) = struct('name', 'labelMismatch', 'BIG', BIGm, 'ATG', ATGm);

    % error parity (research R4): an atom that no BIG edge uses, in a component with BIG
    % edges, gets an AtomIndex beyond numnodes(BIG)
    ATGe = ATG;
    unusedPosition = 15;
    assert(~ismember(ATG.Nodes.AtomIndex(unusedPosition), BIG.Edges.EndNodes(:)), ...
        'atomBeyondBIG: the changed atom must not be an end node of any BIG edge.');
    ATGe.Nodes.AtomIndex(unusedPosition) = numnodes(BIG) + 2;
    assert(passesLookupPreconditions(BIG, ATGe), ...
        'atomBeyondBIG must pass the lookup-array preconditions.');
    cases(end + 1) = struct('name', 'atomBeyondBIG', 'BIG', BIG, 'ATG', ATGe);

    peelingCases = struct('name', {}, 'BIG', {}, 'ATG', {}, 'outcome', {}, ...
        'bondSubgraphs', {}, 'BMG', {}, 'bmgEdgeIndex', {}, 'errorIdentifier', {}, ...
        'errorMessage', {}, 'errorTopFrame', {}, 'kAlwaysFirst', {});
    for k = 1:numel(cases)
        rec = recordBaselineOutcome(cases(k));
        peelingCases(end + 1) = rec; %#ok<SAGROW>
        fprintf('synthetic case %-14s outcome %-5s outputs %3d  k-always-first %d\n', rec.name, ...
            rec.outcome, numel(rec.bondSubgraphs), rec.kAlwaysFirst);
    end
    isMainPathCase = ~ismember({peelingCases.name}, {'labelMismatch', 'atomBeyondBIG'});
    assert(all([peelingCases(isMainPathCase).kAlwaysFirst]), ...
        'FR-009: k advanced on a hand-built or randomised case; research R2 is disproved.');

    provenance = struct('feature', '20260928-100409-extract-bond-subgraphs-local-peeling', ...
        'baseCommit', baseCommit, 'headCommit', gitCommit, 'matlab', version, ...
        'created', char(datetime('now', 'TimeZone', 'UTC', 'Format', 'yyyy-MM-dd HH:mm')));
    save(referenceFile, 'peelingCases', 'provenance', '-v7');
    referenceInfo = dir(referenceFile);
    fprintf('Wrote %s (%d bytes)\n', referenceFile, referenceInfo.bytes);
end

%% Part B: local captures
realFixtures = setdiff(fixtureList, {'synthetic'}, 'stable');
if ~isempty(realFixtures)
    if ~isfolder(extDir)
        mkdir(extDir);
    end
    corpusDir = '/media/JACK/repos/ctf/rxns/moiety_rxns/atomMapped_std';
    assert(isfolder(corpusDir), 'Atom-mapped RXN corpus not found: %s', corpusDir)
    icrmFile = fullfile(repoRoot, 'src', 'analysis', 'topology', 'reactingMoieties', ...
        'identifyConservedReactingMoieties.m');
    icrmLines = splitlines(fileread(icrmFile));
    callLine = find(strcmp(strtrim(icrmLines), ...
        '[bondSubgraphs, BMG, bmgEdgeIndex] = extractBondSubgraphs(BIG, ATG);'));
    assert(numel(callLine) == 1, 'Expected exactly one extractBondSubgraphs call line, found %d.', ...
        numel(callLine));
    buildOptions = struct('directed', 0, 'sanityChecks', 0);
    identifyOptions = struct('directed', 0, 'sanityChecks', 0, 'conservedMoietiesOnly', true);
    expectedRxns = struct('n332', 332, 'n531', 531, 'n1067', 1067, 'n1604', 1604, 'n1960', 1960);
    nestedModels = [];

    for f = 1:numel(realFixtures)
        name = realFixtures{f};
        fprintf('\n=== fixture %s ===\n', name);
        if strcmp(name, 'tyr')
            subModelMatPath = fullfile(homeDir, 'repos', 'ReconXKG-cidev', 'ReconXKGtoCobra', ...
                'models', 'subsystemSubModels', 'subsystemSubModels.mat');
            loaded = load(subModelMatPath, 'subModels');
            model = loaded.subModels.tyr;
        else
            if isempty(nestedModels)
                nestedModels = buildLowSymmetrySubsetModels(corpusDir, homeDir);
            end
            model = nestedModels.(name);
            if numel(model.rxns) ~= expectedRxns.(name)
                warning('captureLocalPeelingFixtures:rxnCount', ...
                    'Fixture %s has %d reactions, expected %d.', name, numel(model.rxns), ...
                    expectedRxns.(name));
            end
        end

        [dATM, ~, ~, ~, ~, ~, BG] = buildAtomAndBondTransitionMultigraph(model, corpusDir, buildOptions);

        inputsFile = fullfile(extDir, [name '-inputs.mat']);
        setenv('CBT_EBS_CAPTURE_FILE', inputsFile);
        cleanupCapture = onCleanup(@() clearCaptureState());
        dbstop('in', 'identifyConservedReactingMoieties', 'at', num2str(callLine), ...
            'if', 'captureExtractBondSubgraphsInputs(BIG, ATG)');
        tStart = tic;
        [arm, moietyFormulae, reacting] = identifyConservedReactingMoieties(model, BG, dATM, ...
            identifyOptions);
        endToEndSeconds = toc(tStart);
        clear cleanupCapture
        assert(isfile(inputsFile), 'The conditional breakpoint did not write %s.', inputsFile);
        if strcmp(name, 'n1960')
            save(fullfile(extDir, 'n1960-endToEnd-golden.mat'), 'arm', 'moietyFormulae', ...
                'reacting', 'endToEndSeconds', 'gitCommit', '-v7.3');
        end
        clear arm moietyFormulae reacting dATM BG

        captured = load(inputsFile);
        rec = recordBaselineOutcome(struct('name', name, 'BIG', captured.BIG, 'ATG', captured.ATG));
        assert(strcmp(rec.outcome, 'ok'), 'Baseline raised an error on fixture %s: %s', name, ...
            rec.errorMessage);
        bondSubgraphs = rec.bondSubgraphs;
        BMG = rec.BMG;
        bmgEdgeIndex = rec.bmgEdgeIndex;
        kAlwaysFirst = rec.kAlwaysFirst;
        nOutputs = numel(bondSubgraphs);
        % full golden outputs take ~0.2 MB per graph as MAT files, so the local fixtures
        % keep SHA-256 fingerprints instead; the check compares live against the
        % pre-change function (research R8)
        fingerprint = fingerprintBondSubgraphOutputs(bondSubgraphs, BMG, bmgEdgeIndex);
        provenance = struct('fixture', name, 'nRxns', numel(model.rxns), 'baseCommit', baseCommit, ...
            'headCommit', gitCommit, 'matlab', version, 'endToEndSeconds', endToEndSeconds, ...
            'created', char(datetime('now', 'TimeZone', 'UTC', 'Format', 'yyyy-MM-dd HH:mm')));
        save(fullfile(extDir, [name '-golden.mat']), 'fingerprint', 'nOutputs', ...
            'kAlwaysFirst', 'provenance', '-v7');
        fprintf('fixture %s: %d reactions, %d outputs, k-always-first %d\n', name, ...
            numel(model.rxns), nOutputs, kAlwaysFirst);

        if strcmp(name, 'n332')
            % clarification Q2: commit only if the compressed -v7 file is at most 1 MB
            n332Inputs = struct('BIG', captured.BIG, 'ATG', captured.ATG);
            n332Expected = struct('bondSubgraphs', {bondSubgraphs}, 'BMG', {BMG}, ...
                'bmgEdgeIndex', {bmgEdgeIndex});
            sizeProbeFile = [tempname '.mat'];
            save(sizeProbeFile, 'n332Inputs', 'n332Expected', '-v7');
            sizeProbeInfo = dir(sizeProbeFile);
            n332Bytes = sizeProbeInfo.bytes;
            copyfile(sizeProbeFile, fullfile(extDir, 'n332-ci-candidate.mat'));
            delete(sizeProbeFile);
            fprintf('n332 CI candidate (-v7): %d bytes\n', n332Bytes);
        end
        clear captured bondSubgraphs BMG bmgEdgeIndex
    end
end

%% Local functions
function clearCaptureState()
dbclear all
setenv('CBT_EBS_CAPTURE_FILE', '');
end

function rec = recordBaselineOutcome(inputCase)
% Pre-change outputs (or error) of one input, and whether FR-009 held on it
rec = struct('name', inputCase.name, 'BIG', inputCase.BIG, 'ATG', inputCase.ATG, ...
    'outcome', 'ok', 'bondSubgraphs', {{}}, 'BMG', {{}}, 'bmgEdgeIndex', {{}}, ...
    'errorIdentifier', '', 'errorMessage', '', 'errorTopFrame', '', 'kAlwaysFirst', true);
try
    [rec.bondSubgraphs, rec.BMG, rec.bmgEdgeIndex] = ...
        extractBondSubgraphsBaseline(inputCase.BIG, inputCase.ATG);
catch ME
    rec.outcome = 'error';
    rec.errorIdentifier = ME.identifier;
    rec.errorMessage = ME.message;
    rec.errorTopFrame = sprintf('%s:%d', ME.stack(1).file, ME.stack(1).line);
end
try
    extractBondSubgraphsBaselineAssertK(inputCase.BIG, inputCase.ATG);
catch ME
    if strcmp(ME.identifier, 'extractBondSubgraphsPeeling:kAdvanced')
        rec.kAlwaysFirst = false;
    elseif ~strcmp(rec.outcome, 'error')
        error('captureLocalPeelingFixtures:instrumentDiverged', ...
            'Instrumented baseline raised %s on %s but the baseline did not (%s:%d).', ...
            ME.identifier, inputCase.name, ME.stack(1).file, ME.stack(1).line);
    end
end
end

function tf = passesLookupPreconditions(BIG, ATG)
% The lookup-array preconditions of extractBondSubgraphs (lines 54-68), restated
nComps = max(conncomp(ATG));
atomIndexATG = full(ATG.Nodes.AtomIndex);
componentATG = full(ATG.Nodes.Component);
endNodes = BIG.Edges.EndNodes;
isPositiveWholeNumeric = @(v) isnumeric(v) && all(v(:) >= 1) && all(v(:) == fix(v(:)));
tf = isPositiveWholeNumeric(atomIndexATG) && isPositiveWholeNumeric(componentATG) ...
    && isPositiveWholeNumeric(endNodes) ...
    && numel(unique(atomIndexATG)) == numel(atomIndexATG) ...
    && all(componentATG <= nComps) && all(endNodes(:) <= max(atomIndexATG));
if tf
    compOfAtom = zeros(max(atomIndexATG), 1);
    compOfAtom(atomIndexATG) = componentATG;
    tf = all(compOfAtom(endNodes(:)) > 0);
end
end

function [BIG, ATG] = buildHandBuiltCase()
% Hand-built main-path input (tasks.md T006 A1). ATG positions 1..15 form six components:
%   a = {1,2,3}, b = {4,5}, c = {6,7,8,9,15}, d = {10} (single atom), e = {11,12}, f = {13,14}
% AtomIndex is a non-identity permutation of 1..15; BIG has 16 nodes (one more than ATG).
atgEnds = [1 2; 2 3; 4 5; 6 7; 7 8; 8 9; 9 15; 11 12; 13 14];
atomIndex = [1 7 3 12 5 9 14 2 11 4 8 13 6 10 15]';
nodes = table(atomIndex, zeros(15, 1), 'VariableNames', {'AtomIndex', 'Component'});
atgEdges = table(atgEnds, (1:size(atgEnds, 1))', 'VariableNames', {'EndNodes', 'TransIndex'});
ATG = graph(atgEdges, nodes);
ATG.Nodes.Component = conncomp(ATG)';

% BIG edges, given as ATG positions and mapped to atom indices
bigPositions = [ ...
    1 4;    % a-b: first edge processed (smallest source atom index)
    1 4;    % a-b: parallel edge, same end atoms and same BondIndex
    2 5;    % a-b: second bond of the first pair
    3 6;    % a-c: BondIndex repeated on different end atoms; pairs a with c on a later pass
    6 8;    % c-c: both end atoms in one component (component1 == component2)
    5 11;   % b-e: leaves the first pass's node set (one end in a|b, the other in e)
    7 9;    % c-c: second intra-component bond
    12 13;  % e-f
    14 10;  % f-d: bond into the single-atom component
    11 12;  % e-e: intra-component bond
    9 2];   % c-a: repeated BondIndex, same pair as row 4
bondIndex = [1 1 2 2 3 4 3 5 6 7 2]';
edgeIndex = [105 103 110 101 108 102 111 104 109 107 106]';
weight = [0.5 0.25 1 2 0.75 1.5 3 0.125 4 2.5 5]';
bigEdges = table(atomIndex(bigPositions), edgeIndex, bondIndex, weight, ...
    'VariableNames', {'EndNodes', 'EdgeIndex', 'BondIndex', 'Weight'});
elements = [repmat({'C'}, 12, 1); repmat({'O'}, 4, 1)];
bigNodes = table((1:16)', elements, 'VariableNames', {'AtomIndex', 'Element'});
BIG = digraph(bigEdges, bigNodes);
end

function assertHandBuiltProperties(BIG, ATG)
% The hand-built case must exercise every spec edge case it is documented to exercise
compOfAtom = zeros(max(ATG.Nodes.AtomIndex), 1);
compOfAtom(ATG.Nodes.AtomIndex) = ATG.Nodes.Component;
endNodes = BIG.Edges.EndNodes;
edgeComp = compOfAtom(endNodes);
firstPair = sort(edgeComp(1, :));
assert(firstPair(1) ~= firstPair(2), 'handBuilt: the first edge must join two components.');
[~, ~, pairRow] = unique(endNodes, 'rows');
assert(any(accumarray(pairRow, 1) > 1), 'handBuilt: parallel BIG edges are missing.');
assert(any(edgeComp(:, 1) == edgeComp(:, 2)), 'handBuilt: an intra-component bond is missing.');
laterPairs = sort(edgeComp(2:end, :), 2);
sharesA = any(laterPairs == firstPair(1), 2) | any(laterPairs == firstPair(2), 2);
isOtherPair = ~all(ismember(laterPairs, firstPair), 2);
assert(any(sharesA & isOtherPair), 'handBuilt: no component of the first pair pairs again later.');
[~, ~, bondGroup] = unique(BIG.Edges.BondIndex);
assert(any(accumarray(bondGroup, 1) > 1), 'handBuilt: a repeated BondIndex is missing.');
assert(passesLookupPreconditions(BIG, ATG), 'handBuilt must pass the lookup-array preconditions.');
end

function [BIG, ATG] = makeSynthetic(seed)
% Randomised input generator, verbatim from research-prototype/runPrototypeEquivalence.m
% components are chains/trees of atoms; AtomIndex is a permutation; BIG has parallel
% edges, repeated BondIndex, intra-component and cross-component edges
nComp = randi([2 12]);
sizes = randi([1 6], nComp, 1);
n = sum(sizes);
perm = randperm(n)';
s = zeros(0, 1); t = zeros(0, 1);
offset = 0;
for c = 1:nComp
    ids = offset + (1:sizes(c))';
    for j = 2:sizes(c)
        s(end+1, 1) = ids(randi(j - 1)); t(end+1, 1) = ids(j); %#ok<AGROW>
    end
    if sizes(c) > 2 && rand < 0.3 % extra cycle / parallel ATG edge
        s(end+1, 1) = ids(1); t(end+1, 1) = ids(end); %#ok<AGROW>
    end
    offset = offset + sizes(c);
end
shuffle = randperm(n)'; % ATG node positions are shuffled relative to component
nodeOrder = shuffle;
posOf = zeros(n, 1); posOf(nodeOrder) = 1:n;
Nodes = table(perm(nodeOrder), zeros(n, 1), 'VariableNames', {'AtomIndex', 'Component'});
ET = table([posOf(s) posOf(t)], (1:numel(s))', 'VariableNames', {'EndNodes', 'TransIndex'});
if mod(seed, 7) == 0
    ATG = digraph(ET, Nodes);
else
    ATG = graph(ET, Nodes);
end
ATG.Nodes.Component = conncomp(ATG)';
% BIG over atom indices 1..n (+ possible isolated extra nodes)
nB = randi([1 4 * n]);
bs = randi(n, nB, 1); bt = randi(n, nB, 1);
bad = bs == bt; bt(bad) = mod(bt(bad), n) + 1;
keep = bs ~= bt; bs = bs(keep); bt = bt(keep);
if isempty(bs), bs = 1; bt = min(2, n); end
if n == 1, BIG = digraph(); BIG = addnode(BIG, table(1, 'VariableNames', {'Label'})); ATG = graph(table(zeros(0,2),zeros(0,1),'VariableNames',{'EndNodes','TransIndex'}), table(1,1,'VariableNames',{'AtomIndex','Component'})); return, end
m = numel(bs);
if rand < 0.5 % parallel edges
    dup = randi(m, randi(3), 1); bs = [bs; bs(dup)]; bt = [bt; bt(dup)]; m = numel(bs);
end
EB = table([bs bt], randperm(m)' + 100, randi(max(1, round(m / 3)), m, 1), rand(m, 1), ...
    'VariableNames', {'EndNodes', 'EdgeIndex', 'BondIndex', 'Weight'});
NB = table((1:n + randi([0 2]))' * 10, 'VariableNames', {'Label'});
BIG = digraph(EB, NB);
end
