% The COBRAToolbox: testEditCobraToolboxPath.m
%
% Purpose:
%     - editCobraToolboxPath(basePath, folderPattern, method) adds to or removes from the MATLAB
%       path every folder below basePath whose full path contains folderPattern. This test
%       builds a folder tree in a tempname folder and checks which folders are added and
%       removed (the pattern is a plain substring), the defaults (basePath = the thermo folder
%       holding vonBertalanffy, folderPattern = [filesep 'new'], method = 'remove') and the
%       error for an unknown method. The MATLAB path is saved first and restored at the end.
%
% Function under test:
%     src/base/paths/editCobraToolboxPath.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-built folders.
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
fileDir = fileparts(which('testEditCobraToolboxPath'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the MATLAB path, restored at the end
pathBefore = path;

% a folder tree: base/new, base/old, base/old/new, base/newer and base/other (one file each)
basePath = tempname;
subFolders = {'new', fullfile('old'), fullfile('old', 'new'), 'newer', 'other'};
for i = 1:numel(subFolders)
    mkdir(fullfile(basePath, subFolders{i}));
    fid = fopen(fullfile(basePath, subFolders{i}, 'readme.txt'), 'w');
    fclose(fid);
end
% true when a folder is an entry of the MATLAB path
onPath = @(folder) any(strcmp(strsplit(path, pathsep), folder));

%% 'add' adds every folder whose path contains the pattern (a substring, so 'newer' too)

editCobraToolboxPath(basePath, [filesep 'new'], 'add');
assert(onPath(fullfile(basePath, 'new')));
assert(onPath(fullfile(basePath, 'old', 'new')));
assert(onPath(fullfile(basePath, 'newer')));
% folders without the pattern are not added
assert(~onPath(basePath));
assert(~onPath(fullfile(basePath, 'old')));
assert(~onPath(fullfile(basePath, 'other')));

%% default pattern and method: remove the folders containing [filesep 'new']

editCobraToolboxPath(basePath);
assert(~onPath(fullfile(basePath, 'new')));
assert(~onPath(fullfile(basePath, 'old', 'new')));
assert(~onPath(fullfile(basePath, 'newer')));

%% a pattern of one folder and an explicit 'remove'

editCobraToolboxPath(basePath, 'other', 'add');
assert(onPath(fullfile(basePath, 'other')) && ~onPath(fullfile(basePath, 'new')));
editCobraToolboxPath(basePath, 'other', 'remove');
assert(~onPath(fullfile(basePath, 'other')));

%% an unknown method is an error (raised at the first matching folder)

assert(verifyCobraFunctionError('editCobraToolboxPath', 'inputs', {basePath, 'other', 'toggle'}, ...
    'testMessage', 'toggle is not a recognised method'));

%% default base folder: the thermo folder that holds vonBertalanffy/initVonBertalanffy.m

% empty inputs take the defaults for basePath and folderPattern; 'add' adds its new folders
thermoPath = strrep(which('initVonBertalanffy'), ['vonBertalanffy' filesep 'initVonBertalanffy.m'], '');
% the folders below it whose path contains [filesep 'new'], listed independently with genpath
thermoFolders = strsplit(genpath(thermoPath), pathsep);
thermoNewFolders = thermoFolders(contains(thermoFolders, [filesep 'new']));
assert(~isempty(thermoNewFolders));
editCobraToolboxPath([], '', 'add');
assert(all(cellfun(onPath, thermoNewFolders)));
% restore the MATLAB path at once: the new folders shadow functions of the toolbox
path(pathBefore);

% remove the folder tree and restore the directory
rmdir(basePath, 's');
cd(currentDir)
