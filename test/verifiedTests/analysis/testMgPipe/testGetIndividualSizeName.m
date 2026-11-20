% The COBRAToolbox: testGetIndividualSizeName.m
%
% Purpose:
%     - getIndividualSizeName reads an abundance file (organisms in rows, samples in columns,
%       organism names in the first column) and returns the sample names and the organism
%       names. The test writes a small CSV file in a temporary folder and checks both outputs
%       against the names written in it. One sample name starts with a digit: readtable
%       (MATLAB R2020a and newer, VariableNamingRule 'modify') turns it into a valid MATLAB
%       name by prefixing 'x' (and prints its own warning about modified headers).
%
% Function under test:
%     src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/getIndividualSizeName.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a hand-written CSV file in a temporary folder.
%
% Coverage exemptions:
%     Lines 25-62: branch for MATLAB releases older than R2020a (the test runs on R2020a or
%     newer, where version contains '(R202'; MATLAB-version-specific branch).
%     Lines 68-69: reachable only from that branch; in R2020a and newer readtable already
%     returns valid MATLAB names (VariableNamingRule 'modify'), so isvarname is never false.
%     Line 75: unreachable by any input; the names were made valid by readtable or by
%     matlab.lang.makeValidName on line 69, which always returns a valid name.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetIndividualSizeName'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% abundance file: two organisms, three samples (the third named with a leading digit)
tmpFolder = tempname;
mkdir(tmpFolder);
abunFile = fullfile(tmpFolder, 'abundances.csv');
fid = fopen(abunFile, 'w');
fprintf(fid, 'ID,Sample_A,Sample_B,1sample\n');
fprintf(fid, 'Bacteroides_sp,0.5,0.2,0.1\n');
fprintf(fid, 'Escherichia_coli,0.5,0.8,0.9\n');
fclose(fid);

%% sample names from the header row and organism names from the first column

% modPath is not used by the function; the folder of the file is passed as the callers do
[sampNames, organisms] = getIndividualSizeName(abunFile, tmpFolder);
% names are compared exactly; '1sample' is returned as readtable made it valid
assert(isequal(sampNames, {'Sample_A'; 'Sample_B'; 'x1sample'}));
assert(isequal(organisms, {'Bacteroides_sp'; 'Escherichia_coli'}));
% every returned sample name is a valid MATLAB name
assert(all(cellfun(@isvarname, sampNames)));

%% clean up

rmdir(tmpFolder, 's');

% change the directory
cd(currentDir)
