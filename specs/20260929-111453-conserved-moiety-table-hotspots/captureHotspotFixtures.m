% captureHotspotFixtures.m
%
% One-off capture for feature 20260929-111453-conserved-moiety-table-hotspots
% (tasks.md T003; research R6, R7). MUST run on UNMODIFIED
% src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m (it refuses
% otherwise), so every reference is a pre-change output.
%
%   Part A: CI golden references for testConservedReactingMoieties - the main Recon3D
%     fixture (r0317/ACONTm/r0426) in conserved-only and default mode, each with
%     sanityChecks 0 and 1, and the coaX and crnM bond-key fixtures in conserved-only
%     mode - written to
%     test/verifiedTests/analysis/testReactingMoieties/data/conservedReactingMoietiesReference.mat
%   Part B: the identifyConservedReactingMoieties inputs (model, BG, dATM) of the
%     1,960-reaction lowSymmetryRisk_2000rxn model, written to the local results tree
%     (never committed), so later checks skip the ~400 s multigraph build.
%
% USAGE (headless, after initCobraToolbox):
%   setenv('CBT_CMH_PARTS', 'A');   % optional: A, B or A,B (default)
%   run('/home/jackmcgoldrick/cobratoolbox/specs/20260929-111453-conserved-moiety-table-hotspots/captureHotspotFixtures.m')

global CBTDIR
global CBT_MILP_SOLVER

featureDir = fileparts(mfilename('fullpath'));
repoRoot = fileparts(fileparts(featureDir));
srcFile = 'src/analysis/topology/reactingMoieties/identifyConservedReactingMoieties.m';
testDir = fullfile(repoRoot, 'test', 'verifiedTests', 'analysis', 'testReactingMoieties');
referenceFile = fullfile(testDir, 'data', 'conservedReactingMoietiesReference.mat');
homeDir = char(java.lang.System.getProperty('user.home'));
extDir = fullfile(homeDir, 'repos', 'reconXmoieties', 'experiments', 'moietySizing', ...
    'results', 'outputs', 'conservedMoietyHotspots');
prevFeatureDir = fullfile(repoRoot, 'specs', '20260928-100409-extract-bond-subgraphs-local-peeling');
baseCommit = '858feabc1';

srcStatus = system(sprintf('git -C "%s" diff --quiet %s -- %s', repoRoot, baseCommit, srcFile));
if srcStatus ~= 0
    error('captureHotspotFixtures:srcModified', ...
        '%s differs from %s: references must be captured from unmodified code.', srcFile, baseCommit);
end

parts = {'A', 'B'};
if ~isempty(getenv('CBT_CMH_PARTS'))
    parts = strtrim(strsplit(getenv('CBT_CMH_PARTS'), ','));
end
[~, gitCommit] = system(sprintf('git -C "%s" rev-parse --short HEAD', repoRoot));
gitCommit = strtrim(gitCommit);

%% Part A: CI golden references
if ismember('A', parts)
    rxnFilesDir = fullfile(testDir, 'data', 'rxnFiles');
    buildOptions = struct('directed', 0, 'sanityChecks', 1);
    recon3D = readCbModel(fullfile(CBTDIR, 'test', 'models', 'mat', 'Recon3D_301.mat'));
    fixtureModels = struct('main', extractSubNetwork(recon3D, {'r0317'; 'ACONTm'; 'r0426'}));
    loaded = load(fullfile(testDir, 'data', 'coaXBondKeySubmodel.mat'));
    fixtureModels.coaX = loaded.subModel;
    loaded = load(fullfile(testDir, 'data', 'crnMBondKeySubmodel.mat'));
    fixtureModels.crnM = loaded.subModel;
    clear recon3D loaded

    % name, fixture, conservedMoietiesOnly, sanityChecks
    caseList = {'mainConservedOnly', 'main', true, 0; ...
        'mainConservedOnlySanity', 'main', true, 1; ...
        'mainDefault', 'main', false, 0; ...
        'mainDefaultSanity', 'main', false, 1; ...
        'coaXConservedOnly', 'coaX', true, 0; ...
        'crnMConservedOnly', 'crnM', true, 0};

    built = struct();
    goldenCases = struct('name', {}, 'model', {}, 'BG', {}, 'dATM', {}, 'options', {}, ...
        'outcome', {}, 'arm', {}, 'moietyFormulae', {}, 'reacting', {}, ...
        'errorIdentifier', {}, 'errorMessage', {}, 'milpSolver', {});
    for k = 1:size(caseList, 1)
        fixture = caseList{k, 2};
        if ~isfield(built, fixture)
            [dATM, ~, ~, ~, ~, ~, BG] = buildAtomAndBondTransitionMultigraph( ...
                fixtureModels.(fixture), rxnFilesDir, buildOptions);
            built.(fixture) = struct('dATM', dATM, 'BG', BG);
        end
        options = struct('directed', 0, 'sanityChecks', caseList{k, 4});
        milpSolver = '';
        if caseList{k, 3}
            options.conservedMoietiesOnly = true;
        else
            milpSolver = CBT_MILP_SOLVER;
            if isempty(milpSolver)
                error('captureHotspotFixtures:noMILPSolver', ...
                    'Default-mode cases need a MILP solver (changeCobraSolver(..., ''MILP'')).');
            end
        end
        % the pre-change outcome: outputs, or the error it raises (with sanityChecks = 1 the
        % unchanged function stops in identifyIsomorphicClasses; the new code must stop the same way)
        outcome = 'ok';
        arm = [];
        moietyFormulae = {};
        reacting = [];
        errorIdentifier = '';
        errorMessage = '';
        try
            [arm, moietyFormulae, reacting] = identifyConservedReactingMoieties( ...
                fixtureModels.(fixture), built.(fixture).BG, built.(fixture).dATM, options);
        catch ME
            outcome = 'error';
            errorIdentifier = ME.identifier;
            errorMessage = ME.message;
            fprintf('case %s raised %s: %s (%s:%d)\n', caseList{k, 1}, ME.identifier, ME.message, ...
                ME.stack(1).file, ME.stack(1).line);
        end
        goldenCases(end + 1) = struct('name', caseList{k, 1}, 'model', fixtureModels.(fixture), ...
            'BG', built.(fixture).BG, 'dATM', built.(fixture).dATM, 'options', options, ...
            'outcome', outcome, 'arm', arm, 'moietyFormulae', {moietyFormulae}, ...
            'reacting', reacting, 'errorIdentifier', errorIdentifier, ...
            'errorMessage', errorMessage, 'milpSolver', milpSolver); %#ok<SAGROW>
        fprintf('captured %-24s outcome %-5s (%s)\n', caseList{k, 1}, outcome, ...
            ternary(isempty(milpSolver), 'no MILP', milpSolver));
    end
    provenance = struct('feature', '20260929-111453-conserved-moiety-table-hotspots', ...
        'baseCommit', baseCommit, 'headCommit', gitCommit, 'matlab', version, ...
        'created', char(datetime('now', 'TimeZone', 'UTC', 'Format', 'yyyy-MM-dd HH:mm')));
    save(referenceFile, 'goldenCases', 'provenance', '-v7');
    referenceInfo = dir(referenceFile);
    fprintf('PARTA wrote %s (%d bytes)\n', referenceFile, referenceInfo.bytes);
    if referenceInfo.bytes > 1048576
        warning('captureHotspotFixtures:largeReference', ...
            'The CI reference is %d bytes, above the 1 MB target.', referenceInfo.bytes);
    end
end

%% Part B: 1,960-reaction identifyConservedReactingMoieties inputs
if ismember('B', parts)
    addpath(prevFeatureDir);   % buildLowSymmetrySubsetModels
    if ~isfolder(extDir)
        mkdir(extDir);
    end
    corpusDir = '/media/JACK/repos/ctf/rxns/moiety_rxns/atomMapped_std';
    models = buildLowSymmetrySubsetModels(corpusDir, homeDir);
    model = models.n1960;
    clear models
    [dATM, ~, ~, ~, ~, ~, BG] = buildAtomAndBondTransitionMultigraph(model, corpusDir, ...
        struct('directed', 0, 'sanityChecks', 0));
    inputsFile = fullfile(extDir, 'n1960-identifyInputs.mat');
    save(inputsFile, 'model', 'BG', 'dATM', 'gitCommit', '-v7.3');
    inputsInfo = dir(inputsFile);
    fprintf('PARTB wrote %s (%d bytes, %d reactions)\n', inputsFile, inputsInfo.bytes, numel(model.rxns));
end

function out = ternary(condition, a, b)
if condition
    out = a;
else
    out = b;
end
end
