% The COBRAToolbox: testCreateGroupContributionStruct.m
%
% Purpose:
%     - createGroupContributionStruct(primaryFile, pH, secondaryFile) reads whitespace
%       delimited group-contribution files (abbreviation, formulaMarvin, delta_G_formation,
%       delta_G_formation_uncertainty, chargeMarvin) into a structure array, one element per
%       metabolite, with the pH and the source file; a metabolite of the secondary file is
%       added only if its abbreviation is not in the primary file. This test writes two small
%       files by hand and checks every field, the default pH, the precedence of the primary
%       file and the errors for files that cannot be opened. Expected values are the numbers
%       written to the files.
%
% Function under test:
%     src/analysis/thermo/groupContribution/jankowski/createGroupContributionStruct.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-written text files in a tempname folder.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The input files are left open
%       SEVERITY: limitation
%       TRIGGER: createGroupContributionStruct(primaryFile, 7, secondaryFile) with two readable files
%       OBSERVED: the file identifiers opened on lines 50 and 75 are never closed (no fclose);
%         this test closes them itself
%       EXPECTED: the files closed after reading
%       LINES: 50, 75
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCreateGroupContributionStruct'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the function leaves its files open (limitation above); the test closes the files that
% were opened during each call
if exist('openedFiles') %#ok<EXIST> openedFiles replaces fopen('all') from R2024a
    getOpenFiles = @openedFiles;
else
    getOpenFiles = @() fopen('all');
end
openFilesBefore = getOpenFiles();
closeNewFiles = @() arrayfun(@fclose, setdiff(getOpenFiles(), openFilesBefore));

% two hand-written files; h2o is in both, with different values
tmpDir = tempname;
mkdir(tmpDir);
primaryFile = fullfile(tmpDir, 'primary.txt');
secondaryFile = fullfile(tmpDir, 'secondary.txt');
fid = fopen(primaryFile, 'w');
fprintf(fid, 'atp\tC10H12N5O13P3\t-2768.1\t2.5\t-4\nh2o\tH2O\t-237.2\t0.5\t0\n');
fclose(fid);
fid = fopen(secondaryFile, 'w');
fprintf(fid, 'h2o\tH2O\t-999\t9\t1\nglc_D\tC6H12O6\t-915.9\t1.1\t0\n');
fclose(fid);

% the energies are read from decimal text and compared with the same decimal literals;
% both are the correctly rounded double, a tolerance of 1e-12 only guards the parser
tol = 1e-12;

%% primary file only, default pH 7

metGroupCont = createGroupContributionStruct(primaryFile);
closeNewFiles();
assert(isequal(size(metGroupCont), [2, 1]));
assert(isequal(fieldnames(metGroupCont), {'abbreviation'; 'formulaMarvin'; 'delta_G_formation'; ...
    'delta_G_formation_uncertainty'; 'chargeMarvin'; 'pH'; 'file'}));
assert(isequal({metGroupCont.abbreviation}, {'atp', 'h2o'}));
assert(isequal({metGroupCont.formulaMarvin}, {'C10H12N5O13P3', 'H2O'}));
assert(max(abs([metGroupCont.delta_G_formation] - [-2768.1, -237.2])) < tol);
assert(max(abs([metGroupCont.delta_G_formation_uncertainty] - [2.5, 0.5])) < tol);
% charges and pH are integers or exact literals
assert(isequal([metGroupCont.chargeMarvin], [-4, 0]));
assert(isequal([metGroupCont.pH], [7, 7]));
assert(isequal({metGroupCont.file}, {primaryFile, primaryFile}));

%% primary and secondary file: the primary file wins for h2o, glc_D is appended

metGroupCont = createGroupContributionStruct(primaryFile, 6.5, secondaryFile);
closeNewFiles();
assert(isequal(size(metGroupCont), [3, 1]));
assert(isequal({metGroupCont.abbreviation}, {'atp', 'h2o', 'glc_D'}));
assert(isequal({metGroupCont.formulaMarvin}, {'C10H12N5O13P3', 'H2O', 'C6H12O6'}));
% h2o keeps -237.2, 0.5 and charge 0 of the primary file, not -999, 9 and 1
assert(max(abs([metGroupCont.delta_G_formation] - [-2768.1, -237.2, -915.9])) < tol);
assert(max(abs([metGroupCont.delta_G_formation_uncertainty] - [2.5, 0.5, 1.1])) < tol);
assert(isequal([metGroupCont.chargeMarvin], [-4, 0, 0]));
assert(isequal([metGroupCont.pH], [6.5, 6.5, 6.5]));
assert(isequal({metGroupCont.file}, {primaryFile, primaryFile, secondaryFile}));

%% files that cannot be opened raise an error naming the file

missingFile = fullfile(tmpDir, 'missing.txt');
assert(verifyCobraFunctionError('createGroupContributionStruct', 'inputs', {missingFile}, ...
    'testMessage', ['Cannot open ' missingFile]));
assert(verifyCobraFunctionError('createGroupContributionStruct', 'inputs', {primaryFile, 7, missingFile}, ...
    'testMessage', ['Cannot open ' missingFile]));
closeNewFiles();

% remove the temporary folder and restore the directory
rmdir(tmpDir, 's');
cd(currentDir)
