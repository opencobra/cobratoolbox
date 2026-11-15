% The COBRAToolbox: testLrsSpecifyRows.m
%
% Purpose:
%     - lrsSpecifyRows(fileNameIn) counts the data rows between "begin" and "end" of an lrs
%       .ine/.ext file (the line after "begin", which holds the row and column counts, is not
%       a data row) and replaces the placeholder ***** with that count, in place, with GNU
%       sed; a name without a file separator is taken relative to the current folder. The
%       test writes small files in a temporary folder and compares the edited text with the
%       hand-written expected text; it checks a relative and an absolute name, zero data rows,
%       the error for a file without "begin", and the error for a failing sed (a stand-in
%       script called sed placed first on the PATH, then the PATH is restored).
%
% Function under test:
%     src/analysis/topology/extremeRays/lrs/lrsInterface/lrsSpecifyRows.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-written files. The function calls GNU sed through
%     system() (sed -i without a suffix argument), so the test needs a Unix system with GNU
%     sed; lrs itself is not called.
%
% Coverage exemptions:
%     Lines 22-23: missing or unreadable file, skipped for the cosmetic defect below (line 22
%     stops with an undefined-variable error before line 23).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: a file that cannot be opened gives an undefined-variable error
%       SEVERITY: cosmetic
%       TRIGGER: lrsSpecifyRows(fullfile(tempname, 'nope.ext'))
%       OBSERVED: error "Unrecognized function or variable 'fileNameOut'." (R2025a,
%         2026-11-15): line 22 displays fileNameOut, which is not defined in the function
%       EXPECTED: error 'Could not open lrs output file.' (line 23)
%       LINES: 22-23
%     - DEFECT: the file identifier is never closed
%       SEVERITY: limitation
%       TRIGGER: any call, for example lrsSpecifyRows('x.ext') on a valid file
%       OBSERVED: the identifier opened on line 20 stays in openedFiles() after the call
%         (identifier 3 after the first call, 3 and 4 after a second call that stopped with an
%         error); there is no fclose
%       EXPECTED: no open file left behind; this test closes the identifiers the function
%         leaves open
%       LINES: 20
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

global CBT_MISSING_REQUIREMENTS_ERROR_ID

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testLrsSpecifyRows'));
cd(fileDir);

% declare the requirements of this test: a Unix system with sed (needsLinux is not used
% because prepareTest compares computer('arch') with 'glnx64', a known defect)
prepareTest('needsUnix', true, 'requiredSoftwares', {'sed'});
% the function uses the GNU form "sed -i 's/.../g' file"; BSD sed (macOS) needs a suffix
[~, sedVersion] = system('sed --version 2>&1');
if ~contains(sedVersion, 'GNU')
    error(CBT_MISSING_REQUIREMENTS_ERROR_ID, 'lrsSpecifyRows needs GNU sed');
end

% the function leaves its file identifier open (defect above): remember the open files to
% close what it leaves
if exist('openedFiles') > 0 %#ok<EXIST>
    listOpenFiles = @() openedFiles();
else
    listOpenFiles = @() fopen('all');
end
openFilesBefore = listOpenFiles();

workDir = tempname;
mkdir(workDir);

%% relative file name: the file in the current folder is edited in place

cd(workDir);
fid = fopen('rel.ext', 'w');
fprintf(fid, 'rel\nV-representation\nbegin\n***** 3 rational\n 1 0 0\n 0 1 1\nend\n');
fclose(fid);
[status, result] = lrsSpecifyRows('rel.ext');
% two data rows between the count line and "end"; sed succeeded silently
assert(status == 0 && isempty(result));
editedText = fileread(fullfile(workDir, 'rel.ext'));
assert(strcmp(editedText, sprintf('rel\nV-representation\nbegin\n2 3 rational\n 1 0 0\n 0 1 1\nend\n')));
cd(fileDir);

%% absolute file name, no data rows, text after "end" left unchanged

fileName = fullfile(workDir, 'abs.ine');
fid = fopen(fileName, 'w');
fprintf(fid, 'abs\nH-representation\nbegin\n***** 4 rational\nend\nlponly\n');
fclose(fid);
[status, result] = lrsSpecifyRows(fileName);
% reading stops at "end": zero data rows
assert(status == 0 && isempty(result));
assert(strcmp(fileread(fileName), sprintf('abs\nH-representation\nbegin\n0 4 rational\nend\nlponly\n')));

%% a file without "begin" is an error

fileName = fullfile(workDir, 'nobegin.ext');
fid = fopen(fileName, 'w');
fprintf(fid, 'x\nV-representation\n');
fclose(fid);
assert(verifyCobraFunctionError('lrsSpecifyRows', 'inputs', {fileName}, ...
    'testMessage', 'Could not read lrs output file.'));

%% a failing sed is an error naming the file

% a script called sed that prints a message and exits with status 1, found first on the PATH
fakeSedDir = fullfile(workDir, 'fakeSed');
mkdir(fakeSedDir);
fid = fopen(fullfile(fakeSedDir, 'sed'), 'w');
fprintf(fid, '#!/bin/sh\necho fake sed failure\nexit 1\n');
fclose(fid);
fileattrib(fullfile(fakeSedDir, 'sed'), '+x');
fileName = fullfile(workDir, 'sedfail.ext');
fid = fopen(fileName, 'w');
fprintf(fid, 'x\nV-representation\nbegin\n***** 2 rational\n 1 0\nend\n');
fclose(fid);
systemPath = getenv('PATH');
setenv('PATH', [fakeSedDir pathsep systemPath]);
sedFailed = verifyCobraFunctionError('lrsSpecifyRows', 'inputs', {fileName}, ...
    'testMessage', ['sed failed on file ' fileName]);
setenv('PATH', systemPath);
assert(sedFailed);
% the placeholder is still there because the stand-in did not edit the file
assert(contains(fileread(fileName), '*****'));

%% clean up: close the identifiers left open by the function, remove the files

openFilesLeft = setdiff(listOpenFiles(), openFilesBefore);
for k = 1:numel(openFilesLeft)
    fclose(openFilesLeft(k));
end
rmdir(workDir, 's');

% change the directory
cd(currentDir)
