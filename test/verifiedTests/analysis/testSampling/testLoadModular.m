% The COBRAToolbox: testLoadModular.m
%
% Purpose:
%     - loadModular(name) adds the module folder BarrierRound/<name> (a sibling of the utils
%       folder that holds loadModular) to the top of the path and runs the module's
%       configuration function config<name>. The modules of the repository (CMatrix,
%       PolytopeSimplifier) run configCMatrix and configPolytopeSimplifier, which stop on the
%       missing script config (see testConfigCMatrix.m), so the test uses the existing folder
%       utils as the module and provides its configuration function configutils in a tempname
%       folder; that function writes a marker file. The test checks that the module folder is
%       at the top of the path and that the configuration function ran once, and restores the
%       path.
%
% Function under test:
%     src/analysis/sampling/BarrierRound/utils/loadModular.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a hand-written configuration function in a tempname
%     folder.
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
fileDir = fileparts(which('testLoadModular'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the configuration function of the module 'utils', in a tempname folder on the path; it
% appends one line to a marker file next to itself each time it runs
pathBefore = path;
sandboxDir = tempname;
mkdir(sandboxDir);
markerFile = fullfile(sandboxDir, 'configutils.called');
fid = fopen(fullfile(sandboxDir, 'configutils.m'), 'w');
fprintf(fid, '%s\n', 'function configutils()', ...
    'fid = fopen(fullfile(fileparts(mfilename(''fullpath'')), ''configutils.called''), ''a'');', ...
    'fprintf(fid, ''called\n'');', 'fclose(fid);', 'end');
fclose(fid);
addpath(sandboxDir);
utilsDir = fileparts(which('loadModular'));

%% the module folder goes to the top of the path and config<name> runs once

loadModular('utils');
pathEntries = strsplit(path, pathsep);
% the folder BarrierRound/utils/../utils is BarrierRound/utils itself
assert(strcmp(pathEntries{1}, utilsDir));
assert(isfile(markerFile));
assert(strcmp(fileread(markerFile), sprintf('called\n')));

%% clean up: path, temporary folder and directory restored

path(pathBefore);
rmdir(sandboxDir, 's');

% change the directory
cd(currentDir)
