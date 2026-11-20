% The COBRAToolbox: testExtractSubsetFeaturesfromFile.m
%
% Purpose:
%     - extractSubsetFeaturesfromFile reads a tab-delimited file of samples (rows) and features
%       (columns) and writes <fileName>_subset.txt, comma separated, with the first column and
%       the requested features of every sample. The function is QUARANTINED (Constitution
%       III-Defects, quarantine in back-fill campaigns): the last sample is not written
%       (defect below), so no assertion about the function is made.
%
% Function under test:
%     src/analysis/fastForest/extractSubsetFeaturesfromFile.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would write a small file in a tempname folder.
%
% Coverage exemptions:
%     every line - extractSubsetFeaturesfromFile is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The last sample of the file is not written to the subset file
%       SEVERITY: wrong-result
%       TRIGGER: a file feat.txt with the lines 'sample<TAB>f1<TAB>f2<TAB>f3', 's1<TAB>1<TAB>2<TAB>3',
%         's2<TAB>4<TAB>5<TAB>6', 's3<TAB>7<TAB>8<TAB>9'; extractSubsetFeaturesfromFile(file, {'f1', 'f3'})
%       OBSERVED: feat.txt_subset.txt holds 'sample,f1,f3', 's1,1,3', 's2,4,6' (the write loop
%         runs to length(keep)-1)
%       EXPECTED: also 's3,7,9', the requested subset of every sample
%       LINES: 61
%     - DEFECT: The subset file is left open
%       SEVERITY: limitation
%       TRIGGER: any call
%       OBSERVED: after the call openedFiles() still lists the identifier of
%         <fileName>_subset.txt; the function has no fclose for it
%       EXPECTED: the output file closed before the function returns
%       LINES: 60-63
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testExtractSubsetFeaturesfromFile'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
