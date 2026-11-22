% The COBRAToolbox: testNormalizeCoverage.m
%
% Purpose:
%     - normalizeCoverage reads a table of organism coverages (organisms as rows, samples as
%       columns), renames the first header 'ID', replaces '-' by '_' in the sample IDs, sums
%       duplicate organism rows, removes samples whose coverages sum to zero, divides every
%       sample by its total, sets normalised coverages below the cutoff (default 0.0001) to
%       zero, removes organisms that are then absent from every sample and writes the result
%       to normalizedCoverage.csv in the current folder. Normalised columns that do not sum
%       to 1 raise an error. The values are not renormalised after the cutoff.
%     - The test writes small coverage tables to a temporary folder and runs the function
%       there; expected values are hand calculations.
%
% Function under test:
%     src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/normalizeCoverage.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-written table files in a temporary folder.
%
% Coverage exemptions:
%     Lines 52, 65, 84, 92: branches for MATLAB releases before R2020a (version-specific;
%     the test machines run R2020a or newer, where contains(version, 'R202') is true).
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testNormalizeCoverage'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% coverages of four organisms (a listed twice) in three samples; S2 is all zero
sandboxDir = tempname;
mkdir(sandboxDir);
cd(sandboxDir);
coverageFile = fullfile(sandboxDir, 'coverage.csv');
fid = fopen(coverageFile, 'w');
fprintf(fid, 'Organism,S-1,S2,S3\na,1,0,0\nb,3,0,0\na,4,0,1\nc,0,0,3\nd,0.0001,0,0\n');
fclose(fid);

%% default cutoff

% S-1: a = 1 + 4 = 5, b = 3, d = 0.0001, total 8.0001; d / 8.0001 = 1.25e-5 is below the
% cutoff 0.0001, so d is absent from every sample and removed. S3: a = 1, c = 3, total 4.
% S2 is removed. The values are quotients of decimal inputs: tolerance 1e-12
[normalizedCoverage, normalizedCoveragePath] = normalizeCoverage(coverageFile);
assert(isequal(normalizedCoverage(1, :), {'ID', 'S_1', 'S3'}));
assert(isequal(normalizedCoverage(:, 1), {'ID'; 'a'; 'b'; 'c'}));
expected = [5 / 8.0001, 0.25; 3 / 8.0001, 0; 0, 0.75];
assert(max(max(abs(cell2mat(normalizedCoverage(2:end, 2:end)) - expected))) < 1e-12);
% the table is written to normalizedCoverage.csv in the current folder; the file holds the
% values as printed by num2str (five significant digits), so the tolerance is 1e-4
assert(strcmp(normalizedCoveragePath, [sandboxDir filesep 'normalizedCoverage.csv']));
writtenTable = readcell(normalizedCoveragePath);
assert(isequal(writtenTable(1, :), {'ID', 'S_1', 'S3'}));
assert(isequal(writtenTable(:, 1), {'ID'; 'a'; 'b'; 'c'}));
assert(max(max(abs(cell2mat(writtenTable(2:end, 2:end)) - expected))) < 1e-4);

%% a larger cutoff removes coverages without renormalising

% a in S3 (0.25) is below 0.3 and set to zero; every organism is still present somewhere
normalizedCoverage = normalizeCoverage(coverageFile, 0.3);
assert(isequal(normalizedCoverage(:, 1), {'ID'; 'a'; 'b'; 'c'}));
expected = [5 / 8.0001, 0; 3 / 8.0001, 0; 0, 0.75];
assert(max(max(abs(cell2mat(normalizedCoverage(2:end, 2:end)) - expected))) < 1e-12);

%% normalised coverages that do not sum to 1 raise an error

% two coverages of 1e308 overflow to a total of Inf, so the normalised values are 0
overflowFile = fullfile(sandboxDir, 'overflow.csv');
fid = fopen(overflowFile, 'w');
fprintf(fid, 'Organism,S1\na,1e308\nb,1e308\n');
fclose(fid);
assert(verifyCobraFunctionError('normalizeCoverage', 'inputs', {overflowFile}, ...
    'testMessage', 'Normalized coverages do not sum up to 1!'));

%% clean up

cd(fileDir);
rmdir(sandboxDir, 's');

% change the directory
cd(currentDir)
