% The COBRAToolbox: testRemoveTempFiles.m
%
% Purpose:
%     - removeTempFiles(directory, oldcontent, ...) deletes the files of a folder that are not in
%       the list of its earlier content, by default only those matching a pattern of the COBRA
%       .gitignore file (for example *.log) and including subfolders, and returns true when no
%       deletion raised a warning. The test builds a folder in a tempname folder (outside git),
%       records its content, adds new files and checks, against the files written by the test,
%       which files are deleted for each combination of COBRAGitIgnoredOnly and checkSubFolders,
%       the call with nothing new, the false status when a file cannot be deleted (a read-only
%       folder), that the current folder and the warning state are restored, and the error for
%       an invalid option. The function is never called on the repository or CBTDIR.
%
% Function under test:
%     src/base/install/removeTempFiles.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model and no solver; hand-built files in a tempname folder.
%
% Coverage exemptions:
%     None. Every executable line is reached below. (Line 65, the false status, is reached by
%     a file in a read-only folder; where the test runs with rights that ignore the read-only
%     attribute, such as root or Windows, that one assertion is skipped and line 65 is not
%     reached.)
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRemoveTempFiles'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the function sets lastwarn (to detect warnings of delete): keep the value to restore it
[lastWarnMessageBefore, lastWarnIdBefore] = lastwarn();

% all files are made in one temporary folder; git does not look above it for a repository, so
% the folder is listed as a folder outside git even if the temporary folder is inside one
baseFolder = tempname;
mkdir(baseFolder);
ceilingBefore = getenv('GIT_CEILING_DIRECTORIES');
setenv('GIT_CEILING_DIRECTORIES', baseFolder);

% the absolute file names as the function lists them (the folder as pwd gives it inside the
% folder, so symbolic links in the temporary path are resolved in the same way)
previousDir = cd(baseFolder);
absBase = pwd;
cd(previousDir);
absName = @(names) strcat(absBase, filesep, strrep(names, '/', filesep));
writeFiles = @(names) cellfun(@(name) writeTestFile(fullfile(baseFolder, name)), names);
existing = @(names) cellfun(@(name) exist(fullfile(baseFolder, name), 'file') == 2, names);

% the earlier content: a data file and a log file (a log file that already existed is kept)
oldFiles = {'oldData.dat', 'old.log', 'sub/oldSub.log'};
writeFiles(oldFiles);
oldContent = absName(oldFiles);
% new files: *.log matches a pattern of the COBRA .gitignore file, *.dat matches none
newIgnored = {'new.log'};
newIgnoredSub = {'sub/newSub.log'};
newOther = {'newData.dat'};
newOtherSub = {'sub/newSub.dat'};
allNew = [newIgnored, newIgnoredSub, newOther, newOtherSub];

%% defaults: the new files matching the COBRA .gitignore are deleted, in subfolders too

writeFiles(allNew);
status = removeTempFiles(baseFolder, oldContent);
% status is a logical flag: exact comparison
assert(islogical(status) && status);
assert(~any(existing([newIgnored, newIgnoredSub])));
assert(all(existing([newOther, newOtherSub])));
% the earlier content is kept, including the earlier log files
assert(all(existing(oldFiles)));
% the current folder is restored
assert(strcmp(pwd, previousDir));

%% checkSubFolders false: only the new ignored files of the folder itself are deleted

writeFiles(allNew);
status = removeTempFiles(baseFolder, oldContent, 'checkSubFolders', false);
assert(status);
assert(~any(existing(newIgnored)));
assert(all(existing([newIgnoredSub, newOther, newOtherSub])));
assert(all(existing(oldFiles)));

%% COBRAGitIgnoredOnly false: every new file is deleted, in subfolders too

writeFiles(allNew);
status = removeTempFiles(baseFolder, oldContent, 'COBRAGitIgnoredOnly', false);
assert(status);
assert(~any(existing(allNew)));
assert(all(existing(oldFiles)));

%% numeric options (0/1): every new file of the folder itself, none of the subfolder

writeFiles(allNew);
status = removeTempFiles(baseFolder, oldContent, 'COBRAGitIgnoredOnly', 0, 'checkSubFolders', 0);
assert(status);
assert(~any(existing([newIgnored, newOther])));
assert(all(existing([newIgnoredSub, newOtherSub])));
assert(all(existing(oldFiles)));
% remove the remaining new files with the function itself (all new files, subfolders: 1)
status = removeTempFiles(baseFolder, oldContent, 'COBRAGitIgnoredOnly', 0, 'checkSubFolders', 1);
assert(status);
assert(~any(existing(allNew)));

%% nothing new: nothing is deleted and the status is true

status = removeTempFiles(baseFolder, oldContent, 'COBRAGitIgnoredOnly', false);
assert(status);
assert(all(existing(oldFiles)));

%% the warning state is restored after the call (the function turns warnings off inside)

warningStateBefore = warning();
writeFiles(newIgnored);
removeTempFiles(baseFolder, oldContent);
assert(isequal(warning(), warningStateBefore));

%% a file that cannot be deleted: delete warns, the status is false and the file stays

lockedFolder = fullfile(baseFolder, 'locked');
writeFiles({'locked/locked.log'});
fileattrib(lockedFolder, '-w');
% the read-only attribute protects the file only if a file cannot be created in the folder
% (it does not for root, or on Windows, where the attribute does not protect folders)
probeId = fopen(fullfile(lockedFolder, 'probe.dat'), 'w');
if probeId < 0
    status = removeTempFiles(baseFolder, oldContent);
    assert(islogical(status) && ~status);
    assert(existing({'locked/locked.log'}));
else
    fclose(probeId);
end
fileattrib(lockedFolder, '+w');

%% invalid options are errors

assert(verifyCobraFunctionError('removeTempFiles', 'inputs', {baseFolder, oldContent, 'COBRAGitIgnoredOnly', 2}));
assert(verifyCobraFunctionError('removeTempFiles', 'inputs', {baseFolder, oldContent, 'checkSubFolders', 'yes'}));
assert(verifyCobraFunctionError('removeTempFiles', 'inputs', {baseFolder, oldContent, 'unknownOption', true}));
assert(all(existing(oldFiles)));

% restore lastwarn and the git setting, and remove the temporary folder
lastwarn(lastWarnMessageBefore, lastWarnIdBefore);
setenv('GIT_CEILING_DIRECTORIES', ceilingBefore);
rmdir(baseFolder, 's');

% change the directory
cd(currentDir)

function writeTestFile(fileName)
% writes a small text file, making its folder if needed
folder = fileparts(fileName);
if ~exist(folder, 'dir')
    mkdir(folder);
end
fid = fopen(fileName, 'w');
fprintf(fid, '%s\n', 'test');
fclose(fid);
end
