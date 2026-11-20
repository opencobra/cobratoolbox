% The COBRAToolbox: testCheckExchangeProfiles.m
%
% Purpose:
%     - checkExchangeProfiles loads <path>/<sample>.mat for every sample (each file holds the
%       cell arrays uptake and secretion, as written by prepIntegrationQuant) and returns
%       mapped_exchanges (per sample: number of secretions, number of uptakes, their sum),
%       minMax (row 1 the minima, row 2 the maxima of these three numbers over the samples) and
%       the uptake and secretion names per sample (nmets rows, more when a sample has more).
%     - The test writes three sample files by hand into a temporary folder; expected values are
%       counted by hand from the files written.
%
% Function under test:
%     src/dataIntegration/metabotools/checkExchangeProfiles.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built sample files.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCheckExchangeProfiles'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% three samples: sampleB has more uptakes than nmets, sampleC has no uptake
sampleDir = tempname;
mkdir(sampleDir);
uptake = {'EX_a'; 'EX_b'};
secretion = {'EX_c'};
save(fullfile(sampleDir, 'sampleA.mat'), 'uptake', 'secretion');
uptake = {'EX_a'; 'EX_d'; 'EX_e'};
secretion = {'EX_f'; 'EX_g'};
save(fullfile(sampleDir, 'sampleB.mat'), 'uptake', 'secretion');
uptake = cell(0, 1);
secretion = {'EX_h'};
save(fullfile(sampleDir, 'sampleC.mat'), 'uptake', 'secretion');
clear uptake secretion
samples = {'sampleA'; 'sampleB'; 'sampleC'};
nmets = 2;

%% counts, extremes and names per sample

[mappedExchanges, minMax, mappedUptake, mappedSecretion] = checkExchangeProfiles(samples, sampleDir, nmets);

% counts are integers: exact comparison. Rows: secretions, uptakes, sum
assert(isequal(mappedExchanges, {1, 2, 1; 2, 3, 0; 3, 5, 1}));
% minima (row 1) and maxima (row 2) of secretions, uptakes and the sum over the samples
assert(isequal(minMax, [1 0 1; 2 3 5]));
% names: nmets rows, extended to three rows by sampleB's three uptakes; unused cells empty
assert(isequal(size(mappedUptake), [3 3]));
assert(isequal(mappedUptake(:, 1), {'EX_a'; 'EX_b'; []}));
assert(isequal(mappedUptake(:, 2), {'EX_a'; 'EX_d'; 'EX_e'}));
assert(all(cellfun(@isempty, mappedUptake(:, 3))));
assert(isequal(mappedSecretion, {'EX_c', 'EX_f', 'EX_h'; [], 'EX_g', []}));

%% one sample: the extremes are its own counts

[mappedExchanges, minMax] = checkExchangeProfiles({'sampleB'}, sampleDir, nmets);
assert(isequal(mappedExchanges, {2; 3; 5}));
assert(isequal(minMax, [2 3 5; 2 3 5]));

% remove the temporary folder and change the directory
rmdir(sampleDir, 's');
cd(currentDir)
