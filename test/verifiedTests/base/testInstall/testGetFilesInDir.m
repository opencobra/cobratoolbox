% The COBRAToolbox: testGetFilesInDir.m
%
% Purpose:
%     - getFilesInDir lists the files of a folder with their absolute paths, using git ls-files
%       for git-controlled folders (types tracked, untracked, ignored, all, ignoredByCOBRA) and
%       rdir otherwise, optionally without subfolders and filtered by a regular expression. The
%       test builds folders in a tempname folder, one outside git and git repositories made with
%       git init (no commit, no network), and checks every type, checkSubFolders (default true),
%       restrictToPattern, the default folder (the current one), the switch of ignoredByCOBRA
%       to ignored in a repository whose remote is a cobratoolbox.git, and that an empty listing
%       is an empty cell array, against the files written by the test.
%
% Function under test:
%     src/base/install/getFilesInDir.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model and no solver; hand-built folders in a tempname folder (some made git
%     repositories with git init, no network).
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found. (The three defects recorded on 2026-11-15, an empty git listing returned as
%     the folder itself, the default checkSubFolders omitting subfolders outside git, and
%     folders listed as files outside git, were fixed by feature
%     20261120-161825-core-blocker-fixes and are tested below.)
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.
%     - Full test after the fix (feature 20261120-161825-core-blocker-fixes), 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetFilesInDir'));
cd(fileDir);

% declare the requirements of this test: git, to make and list the test repositories (git is
% the free version control program COBRA itself is installed with)
prepareTest('requiredSoftwares', {'git'});

% the COBRA .gitignore patterns are read once and kept (persistent): clear them, so that the
% first call below reads them
clear getFilesInDir

% all folders are made in one temporary folder; git does not look above it for a repository,
% so the folder outside git is outside git even if the temporary folder is inside a repository
baseFolder = tempname;
mkdir(baseFolder);
ceilingBefore = getenv('GIT_CEILING_DIRECTORIES');
setenv('GIT_CEILING_DIRECTORIES', baseFolder);

% write a file (folders made as needed); absolute name of a file of a folder as listed (the
% folder as pwd gives it, so symbolic links in the temporary path are resolved as by the
% function); compare two lists as sets of names, the output being a row
writeFile = @(folder, name) writeTestFile(fullfile(folder, name));
listed = @(folder, names) strcat(resolvedPath(folder), filesep, strrep(names, '/', filesep));
sameFiles = @(files, expected) iscell(files) && (isempty(files) || size(files, 1) == 1) ...
    && isequal(sort(files(:)), sort(expected(:)));

%% a folder outside git: every file, with the files of the subfolders by default, no folders

plain = fullfile(baseFolder, 'plain');
writeFile(plain, 'a.txt');
writeFile(plain, 'sub/b.txt');
writeFile(plain, 'sub/c.m');
writeFile(plain, 'sub/deeper/d.log');
mkdir(fullfile(plain, 'emptySub'));
[gitStatus, ~] = system(['git -C "' plain '" status']);
assert(gitStatus ~= 0);
allPlain = listed(plain, {'a.txt', 'sub/b.txt', 'sub/c.m', 'sub/deeper/d.log'});
files = getFilesInDir('dirToList', plain);
assert(sameFiles(files, allPlain));
assert(sameFiles(getFilesInDir('dirToList', plain, 'checkSubFolders', true), allPlain));
% the top level only: files, no folders
assert(sameFiles(getFilesInDir('dirToList', plain, 'checkSubFolders', false), listed(plain, {'a.txt'})));
assert(sameFiles(getFilesInDir('dirToList', plain, 'checkSubFolders', 0), listed(plain, {'a.txt'})));
% a git type outside git is taken as all
for type = {'tracked', 'untracked', 'ignored', 'all', 'TRACKED'}
    assert(sameFiles(getFilesInDir('dirToList', plain, 'type', type{1}), allPlain));
end
% a pattern filters the absolute names
assert(sameFiles(getFilesInDir('dirToList', plain, 'restrictToPattern', '\.m$'), listed(plain, {'sub/c.m'})));
assert(sameFiles(getFilesInDir('dirToList', plain, 'restrictToPattern', 'sub'), ...
    listed(plain, {'sub/b.txt', 'sub/c.m', 'sub/deeper/d.log'})));
% ignoredByCOBRA: the files matching a pattern of the COBRA .gitignore (*.log), at every level
assert(sameFiles(getFilesInDir('dirToList', plain, 'type', 'ignoredByCOBRA'), listed(plain, {'sub/deeper/d.log'})));
assert(sameFiles(getFilesInDir('dirToList', plain, 'type', 'ignoredByCOBRA', 'checkSubFolders', false), {}));
% the default folder is the current one, and the current folder is kept
cd(plain);
files = getFilesInDir();
cd(fileDir);
assert(sameFiles(files, allPlain) && strcmp(pwd, fileDir));

%% an empty folder outside git: an empty cell array

emptyPlain = fullfile(baseFolder, 'emptyPlain');
mkdir(emptyPlain);
assert(sameFiles(getFilesInDir('dirToList', emptyPlain), {}));
assert(sameFiles(getFilesInDir('dirToList', emptyPlain, 'checkSubFolders', false), {}));

%% a git repository: tracked, untracked, ignored and all

repo = fullfile(baseFolder, 'repo');
writeFile(repo, 't.txt');
writeFile(repo, 'sub/t2.m');
writeFile(repo, 'u.txt');
writeFile(repo, 'i.log');
writeFile(repo, 'sub/i2.log');
assert(system(['git -C "' repo '" init -q .']) == 0);
% ignore patterns in the repository's own exclude file (no .gitignore file is listed)
writeTestFile(fullfile(repo, '.git', 'info', 'exclude'), '*.log');
assert(system(['git -C "' repo '" add t.txt sub/t2.m']) == 0);
tracked = listed(repo, {'t.txt', 'sub/t2.m'});
untracked = listed(repo, {'u.txt'});
ignored = listed(repo, {'i.log', 'sub/i2.log'});
assert(sameFiles(getFilesInDir('dirToList', repo, 'type', 'tracked'), tracked));
assert(sameFiles(getFilesInDir('dirToList', repo, 'type', 'untracked'), untracked));
assert(sameFiles(getFilesInDir('dirToList', repo, 'type', 'ignored'), ignored));
assert(sameFiles(getFilesInDir('dirToList', repo), [tracked, untracked, ignored]));
assert(sameFiles(getFilesInDir('dirToList', repo, 'type', 'all'), [tracked, untracked, ignored]));
% the top level only, and a pattern
assert(sameFiles(getFilesInDir('dirToList', repo, 'type', 'tracked', 'checkSubFolders', false), listed(repo, {'t.txt'})));
assert(sameFiles(getFilesInDir('dirToList', repo, 'checkSubFolders', false), listed(repo, {'t.txt', 'u.txt', 'i.log'})));
assert(sameFiles(getFilesInDir('dirToList', repo, 'type', 'tracked', 'restrictToPattern', '\.m$'), listed(repo, {'sub/t2.m'})));
% ignoredByCOBRA in a repository that is not a COBRA repository: the COBRA .gitignore patterns
assert(sameFiles(getFilesInDir('dirToList', repo, 'type', 'ignoredByCOBRA'), ignored));
assert(sameFiles(getFilesInDir('dirToList', repo, 'type', 'ignoredByCOBRA', 'checkSubFolders', false), listed(repo, {'i.log'})));

%% a repository whose remote is a cobratoolbox.git: ignoredByCOBRA uses the repository's own
%% ignore patterns (type ignored), and printLevel 1 names the repository

cobraRepo = fullfile(baseFolder, 'cobraRepo');
writeFile(cobraRepo, 'k.txt');
writeFile(cobraRepo, 'x.tmpout');
writeFile(cobraRepo, 'y.log');
assert(system(['git -C "' cobraRepo '" init -q .']) == 0);
assert(system(['git -C "' cobraRepo '" remote add origin https://example.org/cobratoolbox.git']) == 0);
% the repository ignores *.tmpout, not *.log (the COBRA .gitignore would select y.log)
writeTestFile(fullfile(cobraRepo, '.git', 'info', 'exclude'), '*.tmpout');
assert(sameFiles(getFilesInDir('dirToList', cobraRepo, 'type', 'ignoredByCOBRA'), listed(cobraRepo, {'x.tmpout'})));
assert(sameFiles(getFilesInDir('dirToList', cobraRepo, 'type', 'ignored', 'printLevel', 1), listed(cobraRepo, {'x.tmpout'})));

%% empty git listings: an empty cell array, not the folder itself

emptyRepo = fullfile(baseFolder, 'emptyRepo');
mkdir(emptyRepo);
assert(system(['git -C "' emptyRepo '" init -q .']) == 0);
for type = {'tracked', 'untracked', 'ignored', 'all', 'ignoredByCOBRA'}
    assert(sameFiles(getFilesInDir('dirToList', emptyRepo, 'type', type{1}), {}));
end
% a repository whose files are all tracked: all lists them and nothing else
cleanRepo = fullfile(baseFolder, 'cleanRepo');
writeFile(cleanRepo, 'only.txt');
assert(system(['git -C "' cleanRepo '" init -q .']) == 0);
assert(system(['git -C "' cleanRepo '" add only.txt']) == 0);
assert(sameFiles(getFilesInDir('dirToList', cleanRepo), listed(cleanRepo, {'only.txt'})));
assert(sameFiles(getFilesInDir('dirToList', cleanRepo, 'type', 'untracked'), {}));

%% invalid options are errors

assert(verifyCobraFunctionError('getFilesInDir', 'inputs', {'dirToList', fullfile(baseFolder, 'missing')}));
assert(verifyCobraFunctionError('getFilesInDir', 'inputs', {'dirToList', plain, 'type', 'modified'}));
assert(verifyCobraFunctionError('getFilesInDir', 'inputs', {'dirToList', plain, 'checkSubFolders', 2}));

% restore the git setting and remove the temporary folders
setenv('GIT_CEILING_DIRECTORIES', ceilingBefore);
rmdir(baseFolder, 's');

% change the directory
cd(currentDir)

function writeTestFile(fileName, content)
% writes a small text file, making its folder if needed
if nargin < 2
    content = 'test';
end
folder = fileparts(fileName);
if ~exist(folder, 'dir')
    mkdir(folder);
end
fid = fopen(fileName, 'w');
fprintf(fid, '%s\n', content);
fclose(fid);
end

function folder = resolvedPath(folder)
% the absolute path of a folder as pwd gives it inside the folder
previous = cd(folder);
folder = pwd;
cd(previous);
end
