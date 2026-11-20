% The COBRAToolbox: testOpenSammi.m
%
% Purpose:
%     - openSammi opens an html file written by sammi (in the folder of sammi.m) in the system
%       browser, adding the extension '.html' when it is missing; a file that does not exist
%       gives a warning; without an input it prints the names of the html files of that
%       folder.
%     - No browser is opened: the test makes a temporary folder the current folder and writes
%       into it a stand-in sammi.m (so that which('sammi') names that folder), a stand-in
%       web.m that records its arguments in a file, and a few html and text files. Expected
%       file names are the ones written by the test.
%
% Function under test:
%     src/visualization/SAMMIM/openSammi.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; sammi and web are replaced by stand-ins.
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
fileDir = fileparts(which('testOpenSammi'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% temporary folder with the stand-ins (the current folder precedes the path)
tmpDir = tempname;
mkdir(tmpDir);
cd(tmpDir);
writeLines('sammi.m', {'function sammi(varargin)', 'end'});
writeLines('web.m', {'function web(varargin)', ...
    'fid = fopen(fullfile(fileparts(mfilename(''fullpath'')), ''webCalls.txt''), ''a'');', ...
    'fprintf(fid, ''%s|'', varargin{:});', ...
    'fprintf(fid, ''\n'');', ...
    'fclose(fid);', ...
    'end'});
writeLines('model.html', {'<html></html>'});
writeLines('other.html', {'<html></html>'});
writeLines('notes.txt', {'not a visualization'});
assert(strcmp(which('sammi'), fullfile(pwd, 'sammi.m')));
assert(strcmp(which('web'), fullfile(pwd, 'web.m')));
callLog = fullfile(pwd, 'webCalls.txt');

%% without an input the html files of the sammi folder are printed, nothing is opened

% the printed names are recorded with diary (no other output exists); an active diary of
% the caller is restored afterwards
diaryWasOn = strcmp(get(0, 'Diary'), 'on');
diaryFileBefore = get(0, 'DiaryFile');
diaryFile = fullfile(tmpDir, 'listing.txt');
diary(diaryFile);
openSammi();
diary('off');
set(0, 'DiaryFile', diaryFileBefore);
if diaryWasOn
    diary('on');
end
printedNames = strtrim(strsplit(strtrim(fileread(diaryFile)), newline));
assert(isequal(sort(printedNames), {'model.html', 'other.html'}));
assert(~exist(callLog, 'file'));

%% a name without extension gets '.html' and the file is opened in the system browser

openSammi('model');
% exact text: the file name is the sammi folder followed by the html name
assert(strcmp(fileread(callLog), sprintf('%s|-browser|\n', fullfile(pwd, 'model.html'))));

%% a name with extension is used as it is

delete(callLog);
openSammi('other.html');
assert(strcmp(fileread(callLog), sprintf('%s|-browser|\n', fullfile(pwd, 'other.html'))));

%% a file that does not exist gives a warning and nothing is opened

delete(callLog);
lastwarn('');
openSammi('absent');
assert(strcmp(lastwarn(), ['Could not locate file ', fullfile(pwd, 'absent.html')]));
assert(~exist(callLog, 'file'));

% remove the stand-ins and the temporary folder
cd(fileDir);
clear('web', 'sammi');
rmdir(tmpDir, 's');

% change the directory
cd(currentDir)

function writeLines(fileName, textLines)
% Writes the lines of text to a file in the current folder.
fid = fopen(fileName, 'w');
fprintf(fid, '%s\n', textLines{:});
fclose(fid);
end
