% captureBondSubgraphReferences.m
%
% One-off capture of the CI-test reference for extractBondSubgraphs and
% findAndExtractMolecularGraphs (feature 20260921-154310-reacting-moiety-optimisation,
% tasks.md T003; research.md R8; data-model.md "Unit-test reference").
%
% MUST be run on UNMODIFIED src/ (it refuses otherwise). It:
%   1. builds the CI fixture exactly as testConservedReactingMoieties.m does;
%   2. captures BIG and ATG at the extractBondSubgraphs call inside
%      identifyConservedReactingMoieties with a conditional breakpoint (no src/ edit);
%   3. records the unmodified functions' outputs on those inputs, and their outcome
%      (outputs or error) on five synthetic inputs that break the fast-path preconditions;
%   4. saves everything to
%      test/verifiedTests/analysis/testReactingMoieties/data/bondSubgraphReference.mat.
%
% USAGE (headless, after initCobraToolbox):
%   run('specs/20260921-154310-reacting-moiety-optimisation/captureBondSubgraphReferences.m')

global CBTDIR

featureDir = fileparts(mfilename('fullpath'));
repoRoot = fileparts(fileparts(featureDir));
testDir = fullfile(repoRoot, 'test', 'verifiedTests', 'analysis', 'testReactingMoieties');
referenceFile = fullfile(testDir, 'data', 'bondSubgraphReference.mat');
icrmFile = fullfile(repoRoot, 'src', 'analysis', 'topology', 'reactingMoieties', ...
    'identifyConservedReactingMoieties.m');

%% 1. refuse unless src/ is unmodified relative to develop
srcStatus = system(sprintf('git -C "%s" diff --quiet develop -- src/', repoRoot));
if srcStatus ~= 0
    error('captureBondSubgraphReferences:srcModified', ...
        'src/ differs from develop: the reference must be captured from unmodified code.');
end
addpath(featureDir);   % captureStageNineInputs.m

%% 2. CI fixture, built exactly as in testConservedReactingMoieties.m
model = readCbModel(fullfile(CBTDIR, 'test', 'models', 'mat', 'Recon3D_301.mat'));
subModel = extractSubNetwork(model, {'r0317'; 'ACONTm'; 'r0426'});
buildOptions = struct('directed', 0, 'sanityChecks', 1);
[dATM, ~, ~, ~, ~, ~, BG] = buildAtomAndBondTransitionMultigraph(subModel, ...
    fullfile(testDir, 'data', 'rxnFiles'), buildOptions);

%% 3. locate the stage-09 call line by its text
icrmLines = splitlines(fileread(icrmFile));
callLine = find(strcmp(strtrim(icrmLines), '[bondSubgraphs, BMG] = extractBondSubgraphs(BIG, ATG);'));
assert(numel(callLine) == 1, 'Expected exactly one stage-09 call line, found %d.', numel(callLine));

%% 4. capture BIG and ATG by conditional breakpoint
captureFile = [tempname '.mat'];
setenv('CBT_RMO_CAPTURE_FILE', captureFile);
cleanupBreakpoints = onCleanup(@() clearCaptureState());
dbstop('in', 'identifyConservedReactingMoieties', 'at', num2str(callLine), ...
    'if', 'captureStageNineInputs(BIG, ATG)');
identifyConservedReactingMoieties(subModel, BG, dATM, ...
    struct('directed', 0, 'sanityChecks', 0, 'conservedMoietiesOnly', true));
clear cleanupBreakpoints
assert(isfile(captureFile), 'The conditional breakpoint did not write %s.', captureFile);
captured = load(captureFile);
delete(captureFile);
BIG = captured.BIG;
ATG = captured.ATG;
fprintf('Captured BIG (%d nodes, %d edges) and ATG (%d nodes, %d edges) at line %d.\n', ...
    numnodes(BIG), numedges(BIG), numnodes(ATG), numedges(ATG), callLine);

%% 5. reference outputs of the unmodified functions
ciInputs = struct('BIG', BIG, 'ATG', ATG);
ciExpected = struct();
[ciExpected.bondSubgraphs, ciExpected.BMG] = extractBondSubgraphs(BIG, ATG);
[ciExpected.CMTG, ciExpected.RMTG, ciExpected.CMG, ciExpected.RMG, ...
    ciExpected.conservedGroup, ciExpected.reactingGroups] = ...
    findAndExtractMolecularGraphs(BIG, ciExpected.BMG, ciExpected.bondSubgraphs);
fprintf('CI case: %d bond subgraphs, %d conserved, %d reacting.\n', numel(ciExpected.BMG), ...
    numel(ciExpected.conservedGroup), numel(ciExpected.reactingGroups));

%% 6. synthetic inputs that break the fast-path preconditions
caseNames = {'duplicateAtomIndex', 'nonIntegerAtomIndex', 'componentLabelOutOfRange', ...
    'namedBIGNodes', 'zeroBIGEdges'};
fallbackCases = repmat(struct('name', '', 'BIG', [], 'ATG', [], 'outcome', '', ...
    'bondSubgraphs', [], 'BMG', [], 'errorIdentifier', '', 'errorMessage', '', ...
    'errorTopFrame', ''), numel(caseNames), 1);
for k = 1:numel(caseNames)
    caseBIG = BIG;
    caseATG = ATG;
    switch caseNames{k}
        case 'duplicateAtomIndex'
            caseATG.Nodes.AtomIndex(2) = caseATG.Nodes.AtomIndex(1);
        case 'nonIntegerAtomIndex'
            caseATG.Nodes.AtomIndex = caseATG.Nodes.AtomIndex + 0.5;
        case 'componentLabelOutOfRange'
            caseATG.Nodes.Component(1) = max(conncomp(caseATG)) + 1;
        case 'namedBIGNodes'
            caseBIG.Nodes.Name = cellstr("a" + string((1:numnodes(caseBIG))'));
        case 'zeroBIGEdges'
            caseBIG = rmedge(caseBIG, 1:numedges(caseBIG));
    end
    fallbackCases(k).name = caseNames{k};
    fallbackCases(k).BIG = caseBIG;
    fallbackCases(k).ATG = caseATG;
    try
        [caseSubgraphs, caseBMG] = extractBondSubgraphs(caseBIG, caseATG);
        fallbackCases(k).outcome = 'ok';
        fallbackCases(k).bondSubgraphs = caseSubgraphs;
        fallbackCases(k).BMG = caseBMG;
        fprintf('  fallback case %-26s ok (%d subgraphs)\n', caseNames{k}, numel(caseBMG));
    catch ME
        fallbackCases(k).outcome = 'error';
        fallbackCases(k).errorIdentifier = ME.identifier;
        fallbackCases(k).errorMessage = ME.message;
        fallbackCases(k).errorTopFrame = sprintf('%s:%d', ME.stack(1).file, ME.stack(1).line);
        fprintf('  fallback case %-26s error %s: %s (%s)\n', caseNames{k}, ME.identifier, ...
            ME.message, fallbackCases(k).errorTopFrame);
    end
end

%% 7. save with provenance
[~, gitCommit] = system(sprintf('git -C "%s" rev-parse HEAD', repoRoot));
provenance = struct('gitCommit', strtrim(gitCommit), 'matlabVersion', version, ...
    'capturedAt', char(datetime('now', 'TimeZone', 'UTC', 'Format', 'yyyy-MM-dd''T''HH:mm:ss''Z''')), ...
    'fixture', 'Recon3D_301 r0317/ACONTm/r0426, directed = 0');
save(referenceFile, 'ciInputs', 'ciExpected', 'fallbackCases', 'provenance', '-v7');
info = dir(referenceFile);
fprintf('Wrote %s (%.1f kB).\n', referenceFile, info.bytes / 1024);
if info.bytes > 1024^2
    warning('captureBondSubgraphReferences:largeReference', ...
        'Reference file is %.1f MB, above the 1 MB target.', info.bytes / 1024^2);
end

function clearCaptureState()
dbclear all
setenv('CBT_RMO_CAPTURE_FILE', '');
end
