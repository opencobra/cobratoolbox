% captureBaseline.m
%
% Feature 20261012-093525-symmetric-iso-zero-bond, tasks.md T003 (run before any source edit):
%   1. runs test/verifiedTests/analysis/testReactingMoieties/ and saves pass/fail per test to
%      results/20261012-093525-symmetric-iso-zero-bond/baseline_tests.mat;
%   2. captures the develop readABRXNFile atom and bond tables of the bonded fixture
%      ETOHt_implicitH and three existing explicit-hydrogen fixtures into
%      test/.../data/readABRXNFileReference.mat (the reference for testReadABRXNFile, T012);
%   3. runs symmetricIsoTimingCheck.m in 'baseline' mode (SC-005 baseline).
%
% USAGE (headless): matlab -batch "initCobraToolbox(false); run('<this file>')"

featureDir = fileparts(mfilename('fullpath'));
repoRoot = fileparts(fileparts(featureDir));
resultsDir = fullfile(repoRoot, 'results', '20261012-093525-symmetric-iso-zero-bond');
testDir = fullfile(repoRoot, 'test', 'verifiedTests', 'analysis', 'testReactingMoieties');
if ~isfolder(resultsDir)
    mkdir(resultsDir);
end
[~, gitCommit] = system(sprintf('git -C "%s" rev-parse --short HEAD', repoRoot));
[~, gitDirty] = system(sprintf('git -C "%s" status --porcelain -- src', repoRoot));
assert(isempty(strtrim(gitDirty)), 'T003 must run before any source edit.');

%% 1. test folder baseline
testResults = runtests(testDir);
testNames = {testResults.Name}';
testPassed = [testResults.Passed]';
testSeconds = [testResults.Duration]';
save(fullfile(resultsDir, 'baseline_tests.mat'), 'testNames', 'testPassed', 'testSeconds', 'gitCommit');
disp(table(testNames, testPassed, testSeconds));

%% 2. readABRXNFile reference on develop
fixtures = {'ETOHt_implicitH', fullfile(testDir, 'data', 'rxn'); ...
    'r0317', fullfile(testDir, 'data', 'rxnFiles'); ...
    'ACONTm', fullfile(testDir, 'data', 'rxnFiles'); ...
    'r0426', fullfile(testDir, 'data', 'rxnFiles')};
readABRXNFileReference = struct('rxnfileName', fixtures(:, 1), 'atoms', [], 'bonds', []);
for k = 1:size(fixtures, 1)
    [atoms, bonds] = readABRXNFile(fixtures{k, 1}, fixtures{k, 2});
    readABRXNFileReference(k).atoms = atoms;
    readABRXNFileReference(k).bonds = bonds;
end
save(fullfile(testDir, 'data', 'readABRXNFileReference.mat'), 'readABRXNFileReference');

%% 3. SC-005 baseline timing
setenv('CBT_SIZ_MODE', 'baseline');
run(fullfile(featureDir, 'symmetricIsoTimingCheck.m'));
