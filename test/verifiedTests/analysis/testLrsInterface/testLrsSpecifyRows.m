% The COBRAToolbox: testLrsSpecifyRows.m
%
% Purpose:
%     - lrsSpecifyRows(fileNameIn) counts the data rows between "begin" and "end" of an lrs
%       .ine/.ext file (the line after "begin", which holds the row and column counts, is not
%       a data row) and replaces the placeholder ***** with that count, in place, in MATLAB
%       (no external program); a name without a file separator is taken relative to the
%       current folder. The test writes small files in a temporary folder and compares the
%       edited text with the hand-written expected text; it checks a relative and an absolute
%       name, zero data rows, several placeholders and a run of six stars (expected text: the
%       output of the earlier GNU sed version, s/\*\*\*\*\*/<n>/g, recorded 2026-11-20), a run
%       with an empty PATH (no external program needed), the errors for a file that cannot be
%       opened and for a file without "begin" or "end", and that no file is left open.
%
% Function under test:
%     src/analysis/topology/extremeRays/lrs/lrsInterface/lrsSpecifyRows.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-written files; the function uses base MATLAB only, so
%     the test declares no requirement.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found. (The two defects recorded on 2026-11-15, an undefined-variable error for a
%     file that cannot be opened and a file identifier left open, were fixed by feature
%     20261120-144501-lrsspecifyrows-without-sed and are tested below.)
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.
%     - No sed: Tier 1 without requirement, fixed defects tested (feature
%       20261120-144501-lrsspecifyrows-without-sed), 2026-11-20.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testLrsSpecifyRows'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the open files now; the function must leave none open
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
writeText('rel.ext', sprintf('rel\nV-representation\nbegin\n***** 3 rational\n 1 0 0\n 0 1 1\nend\n'));
[status, result] = lrsSpecifyRows('rel.ext');
% two data rows between the count line and "end"; the outputs keep their form
assert(status == 0 && isempty(result));
editedText = fileread(fullfile(workDir, 'rel.ext'));
assert(strcmp(editedText, sprintf('rel\nV-representation\nbegin\n2 3 rational\n 1 0 0\n 0 1 1\nend\n')));
cd(fileDir);
assert(isempty(setdiff(listOpenFiles(), openFilesBefore)));

%% absolute file name, no data rows, text after "end" left unchanged

fileName = fullfile(workDir, 'abs.ine');
writeText(fileName, sprintf('abs\nH-representation\nbegin\n***** 4 rational\nend\nlponly\n'));
[status, result] = lrsSpecifyRows(fileName);
% reading stops at "end": zero data rows
assert(status == 0 && isempty(result));
assert(strcmp(fileread(fileName), sprintf('abs\nH-representation\nbegin\n0 4 rational\nend\nlponly\n')));

%% placeholders: every ***** is replaced, leftmost and without overlap, as sed's g did

% expected text written by the GNU sed version on this input (2026-11-20): ****** -> 1*
fileName = fullfile(workDir, 'stars.ext');
writeText(fileName, sprintf('p\nV-representation\nbegin\n***** 3 rational\n 1 0 0\nend\n*****\n******\n'));
lrsSpecifyRows(fileName);
assert(strcmp(fileread(fileName), sprintf('p\nV-representation\nbegin\n1 3 rational\n 1 0 0\nend\n1\n1*\n')));

%% no external program: the same result with an empty PATH

fileName = fullfile(workDir, 'nopath.ext');
writeText(fileName, sprintf('n\nV-representation\nbegin\n***** 3 rational\n 1 0 0\n 0 1 1\nend\n'));
[status, result] = lrsSpecifyRowsWithEmptyPath(fileName);
assert(status == 0 && isempty(result));
assert(strcmp(fileread(fileName), sprintf('n\nV-representation\nbegin\n2 3 rational\n 1 0 0\n 0 1 1\nend\n')));
assert(isempty(setdiff(listOpenFiles(), openFilesBefore)));

%% a file that cannot be opened is an error

assert(verifyCobraFunctionError('lrsSpecifyRows', 'inputs', {fullfile(tempname, 'nope.ext')}, ...
    'testMessage', 'Could not open lrs output file.'));

%% a file without "begin", or without "end", is an error and is left unchanged

fileName = fullfile(workDir, 'nobegin.ext');
writeText(fileName, sprintf('x\nV-representation\n'));
assert(verifyCobraFunctionError('lrsSpecifyRows', 'inputs', {fileName}, ...
    'testMessage', 'Could not read lrs output file.'));
fileName = fullfile(workDir, 'noend.ext');
writeText(fileName, sprintf('x\nV-representation\nbegin\n***** 2 rational\n 1 0\n'));
assert(verifyCobraFunctionError('lrsSpecifyRows', 'inputs', {fileName}, ...
    'testMessage', 'Could not read lrs output file.'));
assert(strcmp(fileread(fileName), sprintf('x\nV-representation\nbegin\n***** 2 rational\n 1 0\n')));
% no file is left open, also after the errors
assert(isempty(setdiff(listOpenFiles(), openFilesBefore)));

%% remove the files

rmdir(workDir, 's');

% change the directory
cd(currentDir)

function writeText(fileName, text)
% writes text to fileName
fid = fopen(fileName, 'w');
fprintf(fid, '%s', text);
fclose(fid);
end

function [status, result] = lrsSpecifyRowsWithEmptyPath(fileName)
% runs lrsSpecifyRows with an empty PATH, so that no external program can be found; the PATH
% is restored on return, also when the function fails
previousPath = getenv('PATH');
restorePath = onCleanup(@() setenv('PATH', previousPath));
setenv('PATH', '');
[status, result] = lrsSpecifyRows(fileName);
end
