% The COBRAToolbox: testFunctionNameConflicts.m
%
% Purpose:
%     - Fails when a function is added to the toolbox with the same name as another
%       toolbox function (in src/ or in the bundled external/ code) or as a MATLAB
%       function (built-in or installed MATLAB toolbox), and says why it failed.
%       MATLAB runs only the first function with a given name that it finds on its path
%       and silently ignores the others, so such a name clash changes the behaviour of
%       code without any error message.
%       Conflicts that already existed when this check was introduced are recorded, with
%       a reason, in knownFunctionNameConflicts.txt (next to this file); only conflicts
%       that are not recorded make the test fail.
%       The test first proves that its own detector works on a small temporary tree.
%
% Function under test:
%     (none: the test checks a property of the whole source tree, not one function)
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, no MATLAB toolbox.
%
% Coverage exemptions:
%     None (there is no single source function to measure).
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Limitations of the check:
%     - A MATLAB function is recognised only if it has exactly the same letter case as the
%       toolbox function, and only if it is installed on the machine that runs the test
%       (a MATLAB toolbox that is not installed cannot be seen).
%     - A recorded name covers every file with that name: a further copy of an
%       already recorded name is not detected.
%
% Authors:
%     - Generated for feature function-name-conflicts, 2026-10-12.

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFunctionNameConflicts'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% values shared by the sections below
repositoryRoot = CBTDIR;
knownConflictsFile = fullfile(fileDir, 'knownFunctionNameConflicts.txt');
matlabRelease = version;

%% self-check: detector, failure message and known-conflicts reader on a temporary tree

% --- the detector ---

% build a small tree that contains every kind of case the detector must handle
tempRoot = tempname;
removeTempTree = onCleanup(@() removeFolder(tempRoot));
createFunctionFile(fullfile(tempRoot, 'src', 'a', 'dupFn.m'));        % duplicate ...
createFunctionFile(fullfile(tempRoot, 'src', 'b', 'dupFn.m'));        % ... in two src folders ...
createFunctionFile(fullfile(tempRoot, 'ext', 'dupFn.m'));             % ... and in the external folder
createFunctionFile(fullfile(tempRoot, 'src', 'c', 'CaseTwin.m'));     % names that differ only by case
createFunctionFile(fullfile(tempRoot, 'src', 'd', 'casetwin.m'));
createFunctionFile(fullfile(tempRoot, 'src', 'e', 'sum.m'));          % the name of a MATLAB built-in
createFunctionFile(fullfile(tempRoot, 'src', 'f', 'cleanOne.m'));     % a clean, unique name
createFunctionFile(fullfile(tempRoot, 'src', 'private', 'hiddenDup.m'));          % private, class and
createFunctionFile(fullfile(tempRoot, 'src', 'g', 'private', 'hiddenDup.m'));      % package folders are
createFunctionFile(fullfile(tempRoot, 'src', '@someClass', 'classDup.m'));         % not on the global
createFunctionFile(fullfile(tempRoot, 'src', 'h', 'classDup.m'));                  % path and are ignored
createFunctionFile(fullfile(tempRoot, 'src', '+somePackage', 'packageDup.m'));
createFunctionFile(fullfile(tempRoot, 'src', 'i', 'packageDup.m'));
createFunctionFile(fullfile(tempRoot, 'src', 'j', 'position.m'));     % only a MATLAB class method of this name exists

found = findNameConflicts(tempRoot, fullfile(tempRoot, 'src'), {fullfile(tempRoot, 'ext')}, matlabroot);
foundNames = lower({found.name});
foundKinds = {found.kind};

% a name used by two folders of src/ and by the external folder is reported once, with all 3 files
index = find(strcmp(foundNames, 'dupfn') & strcmp(foundKinds, 'duplicate'));
assert(isscalar(index));
assert(isequal(sort(found(index).files), {'ext/dupFn.m', 'src/a/dupFn.m', 'src/b/dupFn.m'}));

% names that differ only by letter case are the same name
index = find(strcmp(foundNames, 'casetwin') & strcmp(foundKinds, 'duplicate'));
assert(isscalar(index));
assert(isequal(sort(found(index).files), {'src/c/CaseTwin.m', 'src/d/casetwin.m'}));

% a function named like a MATLAB function is reported with the MATLAB location
index = find(strcmp(foundNames, 'sum') & strcmp(foundKinds, 'shadows-matlab'));
assert(isscalar(index));
assert(isequal(found(index).files, {'src/e/sum.m'}));
assert(contains(found(index).matlabFile, matlabroot));

% nothing else is reported: unique names, private/class/package folders, class methods
assert(isequal(sort(foundNames(strcmp(foundKinds, 'duplicate'))), {'casetwin', 'dupfn'}));
assert(isequal(foundNames(strcmp(foundKinds, 'shadows-matlab')), {'sum'}));

% a clean tree has no conflict
cleanRoot = tempname;
removeCleanTree = onCleanup(@() removeFolder(cleanRoot));
createFunctionFile(fullfile(cleanRoot, 'src', 'a', 'uniqueFunctionOne.m'));
createFunctionFile(fullfile(cleanRoot, 'src', 'b', 'uniqueFunctionTwo.m'));
assert(isempty(findNameConflicts(cleanRoot, fullfile(cleanRoot, 'src'), {}, matlabroot)));

% --- the failure message ---

message = formatConflicts(found, matlabRelease);
% every conflict is in one message, not only the first
assert(contains(message, 'dupFn') && contains(message, 'CaseTwin') && contains(message, 'sum'));
% the conflicting files and the MATLAB location
assert(contains(message, 'src/a/dupFn.m') && contains(message, 'src/b/dupFn.m') && contains(message, 'ext/dupFn.m'));
assert(contains(message, found(strcmp(foundNames, 'sum') & strcmp(foundKinds, 'shadows-matlab')).matlabFile));
% why it is a problem
assert(contains(message, 'only the first function') && contains(message, 'silently ignored'));
% how to fix it, including how to record an intentional duplicate
assert(contains(message, 'rename') && contains(message, 'knownFunctionNameConflicts.txt'));
% the MATLAB release that was used
assert(contains(message, matlabRelease));

% --- the known-conflicts file reader ---

tempKnownFile = [tempname '.txt'];
removeKnownFile = onCleanup(@() deleteFile(tempKnownFile));
fid = fopen(tempKnownFile, 'w');
fprintf(fid, '# a comment\n\nDupFn | duplicate | reviewed copy\nsum | shadows-matlab | reviewed\n');
fclose(fid);
knownKeys = readKnownConflicts(tempKnownFile);
% names are compared without regard to letter case
assert(isequal(sort(knownKeys), {'dupfn|duplicate', 'sum|shadows-matlab'}));

% a line with an unknown kind is rejected with a clear message
fid = fopen(tempKnownFile, 'w');
fprintf(fid, 'dupFn | wrong-kind | reason\n');
fclose(fid);
errorThrown = false;
try
    readKnownConflicts(tempKnownFile);
catch exception
    errorThrown = contains(exception.message, 'unknown kind');
end
assert(errorThrown);

%% the toolbox itself: no conflict that is not recorded

conflicts = findNameConflicts(repositoryRoot, fullfile(repositoryRoot, 'src'), ...
                              {fullfile(repositoryRoot, 'external')}, matlabroot);
knownKeys = readKnownConflicts(knownConflictsFile);
currentKeys = cellfun(@(name, kind) [lower(name) '|' kind], {conflicts.name}, {conflicts.kind}, 'UniformOutput', false);

% conflicts that are not recorded make the test fail, with the full explanation
isNew = ~ismember(currentKeys, knownKeys);
assert(~any(isNew), '%s', formatConflicts(conflicts(isNew), matlabRelease));

% recorded conflicts that no longer exist can be removed from the file (no failure)
removable = setdiff(knownKeys, currentKeys);
if ~isempty(removable)
    fprintf(['Note: these entries of knownFunctionNameConflicts.txt no longer match a conflict ' ...
             'and can be removed: %s\n'], strjoin(removable, ', '));
end

% change the directory
cd(currentDir)

%% local functions

function conflicts = findNameConflicts(baseRoot, srcRoot, otherRoots, matlabRoot)
% Find the function names of srcRoot that are also used by another toolbox function or
% by a MATLAB function.
%
% INPUTS:
%    baseRoot:    folder that the reported paths are relative to
%    srcRoot:     folder with the toolbox source functions (src/)
%    otherRoots:  cell array of further folders with toolbox functions (external/)
%    matlabRoot:  root folder of the MATLAB installation
%
% OUTPUT:
%    conflicts:   struct array with the fields name, kind ('duplicate' or 'shadows-matlab'),
%                 files (cell array of paths relative to baseRoot), matlabFile (char)

    sourceFiles = listFunctionFiles(baseRoot, srcRoot, true);
    otherFiles = struct('name', {}, 'path', {}, 'isSource', {});
    for k = 1:numel(otherRoots)
        otherFiles = [otherFiles, listFunctionFiles(baseRoot, otherRoots{k}, false)]; %#ok<AGROW>
    end
    allFiles = [sourceFiles, otherFiles];

    conflicts = struct('name', {}, 'kind', {}, 'files', {}, 'matlabFile', {});

    % toolbox duplicates: the same name, ignoring letter case, in two or more files of
    % which at least one is in src/ (the folders are scanned on disk, so folders that
    % are not on the MATLAB path are included)
    if ~isempty(allFiles)
        [~, ~, groupIndex] = unique(lower({allFiles.name}));
        for g = 1:max(groupIndex)
            members = allFiles(groupIndex == g);
            if numel(members) > 1 && any([members.isSource])
                firstSource = members(find([members.isSource], 1));
                conflicts(end + 1) = struct('name', firstSource.name, 'kind', 'duplicate', ...
                                            'files', {sort({members.path})}, 'matlabFile', ''); %#ok<AGROW>
            end
        end
    end

    % names that are also MATLAB functions (built-in or in an installed MATLAB toolbox);
    % methods inside class (@) or package (+) folders are not plain functions
    if ~isempty(sourceFiles)
        for k = 1:numel(sourceFiles)
            locations = which(sourceFiles(k).name, '-all');
            if ischar(locations)
                locations = {locations};
            end
            isMatlab = cellfun(@(p) contains(p, matlabRoot) && ~contains(p, [filesep '@']) ...
                                    && ~contains(p, [filesep '+']), locations);
            if any(isMatlab)
                matlabLocations = locations(isMatlab);
                conflicts(end + 1) = struct('name', sourceFiles(k).name, 'kind', 'shadows-matlab', ...
                                            'files', {{sourceFiles(k).path}}, ...
                                            'matlabFile', matlabLocations{1}); %#ok<AGROW>
            end
        end
    end
end

function files = listFunctionFiles(baseRoot, folder, isSource)
% List the .m files of a folder tree, ignoring private, class (@) and package (+) folders.
    files = struct('name', {}, 'path', {}, 'isSource', {});
    if ~isfolder(folder)
        return
    end
    listing = dir(fullfile(folder, '**', '*.m'));
    for k = 1:numel(listing)
        fullPath = fullfile(listing(k).folder, listing(k).name);
        insideRoot = fullPath(numel(folder) + 1:end);
        if ~isempty(regexp(insideRoot, '[/\\](private|@[^/\\]*|\+[^/\\]*)[/\\]', 'once'))
            continue
        end
        relativePath = strrep(fullPath(numel(baseRoot) + 2:end), '\', '/');
        files(end + 1) = struct('name', listing(k).name(1:end - 2), 'path', relativePath, ...
                                'isSource', isSource); %#ok<AGROW>
    end
end

function keys = readKnownConflicts(file)
% Read the reviewed known conflicts: lines 'name | kind | reason'; '#' lines and empty lines
% are ignored. Returns keys of the form 'lowercasename|kind'.
    validKinds = {'duplicate', 'shadows-matlab'};
    lines = strsplit(fileread(file), {'\r\n', '\n'});
    keys = {};
    for k = 1:numel(lines)
        line = strtrim(lines{k});
        if isempty(line) || line(1) == '#'
            continue
        end
        parts = strtrim(strsplit(line, '|'));
        if numel(parts) < 3 || isempty(parts{1}) || isempty(parts{3})
            error('%s line %d is malformed (use: name | kind | reason): %s', file, k, line);
        end
        if ~ismember(parts{2}, validKinds)
            error('%s line %d has an unknown kind ''%s'' (use: %s): %s', file, k, parts{2}, ...
                  strjoin(validKinds, ' or '), line);
        end
        keys{end + 1} = [lower(parts{1}) '|' parts{2}]; %#ok<AGROW>
    end
end

function message = formatConflicts(conflicts, matlabRelease)
% Build the failure message: what clashes, why it matters, how to fix it.
    lines = {sprintf('Function-name conflict(s) found (MATLAB %s):', matlabRelease), ''};
    for k = 1:numel(conflicts)
        c = conflicts(k);
        if strcmp(c.kind, 'duplicate')
            lines{end + 1} = sprintf('  %d. ''%s'' is used by %d files:', k, c.name, numel(c.files)); %#ok<AGROW>
            for f = 1:numel(c.files)
                lines{end + 1} = sprintf('       %s', c.files{f}); %#ok<AGROW>
            end
        else
            lines{end + 1} = sprintf('  %d. ''%s'' in %s has the name of a MATLAB function:', k, c.name, c.files{1}); %#ok<AGROW>
            lines{end + 1} = sprintf('       MATLAB: %s', c.matlabFile); %#ok<AGROW>
        end
    end
    lines = [lines, {'', ...
        ['Why this is a problem: MATLAB runs only the first function with a given name that it ' ...
         'finds on its path, and the others are silently ignored. Two toolbox functions with ' ...
         'the same name, or a toolbox function named like a MATLAB function, therefore change ' ...
         'behaviour without any error, and which one runs depends on the path order.'], '', ...
        ['How to fix it: rename the new function so that its name is unique. If the duplicate ' ...
         'is intentional and has been reviewed, add a line ''name | kind | reason'' to ' ...
         'test/verifiedTests/base/testInstall/knownFunctionNameConflicts.txt.']}];
    message = strjoin(lines, newline);
end

function createFunctionFile(path)
% Create a small function file (and its folders) for the self-check.
    folder = fileparts(path);
    if ~isfolder(folder)
        mkdir(folder);
    end
    fid = fopen(path, 'w');
    fprintf(fid, 'function y = f(x)\ny = x;\nend\n');
    fclose(fid);
end

function removeFolder(folder)
% Remove a temporary folder tree (used by onCleanup, so it must never error).
    if isfolder(folder)
        rmdir(folder, 's');
    end
end

function deleteFile(path)
% Remove a temporary file (used by onCleanup, so it must never error).
    if isfile(path)
        delete(path);
    end
end
