% The COBRAToolbox: testCloseParallelPool.m
%
% Purpose:
%     - closeParallelPool deletes the current parallel pool when the Parallel Computing Toolbox
%       is available and a pool is open, and otherwise does nothing and raises no error. The
%       test checks the three cases. The case without the toolbox is produced on any machine by
%       putting a stand-in isParallelToolboxAvailable that returns false first on the path, in a
%       temporary folder that is removed again at the end of the section.
%
% Function under test:
%     src/base/utilities/toolboxFree/closeParallelPool.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver. Where the toolbox is installed, one-worker
%     thread pools ('Threads' profile, open in about a second) are opened and closed. A pool that
%     was open before the test is closed once and then reopened with the same profile and size.
%
% Coverage exemptions:
%     - Lines 17-19 (gcp, the check for an open pool and delete) are reached only where the
%       Parallel Computing Toolbox is installed and licensed; elsewhere the with-toolbox
%       sections print "skipped".
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261103-120403-toolbox-free-replacements, 2026-11-03.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCloseParallelPool'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% with the toolbox: the open pool is deleted

if isParallelToolboxAvailable()
    if isempty(gcp('nocreate'))
        testPool = parpool('Threads', 1);
        deleteTestPool = onCleanup(@() delete(testPool)); %#ok<NASGU> a failure must not leave it open
        closeParallelPool();
        assert(isempty(gcp('nocreate')));
        clear deleteTestPool
    else
        % a pool the user opened is not closed: its settings and worker state would be lost
        fprintf('skipped: a parallel pool was open before the test\n');
    end
else
    fprintf('skipped: Parallel Computing Toolbox not installed or not licensed\n');
end

%% with the toolbox: nothing is done when no pool is open

if isParallelToolboxAvailable()
    if isempty(gcp('nocreate'))
        closeParallelPool();
        assert(isempty(gcp('nocreate')));
    else
        fprintf('skipped: a parallel pool was open before the test\n');
    end
else
    fprintf('skipped: Parallel Computing Toolbox not installed or not licensed\n');
end

%% without the toolbox: nothing is done and no error is raised, even when a pool is open

% where the toolbox is installed, a pool is opened first (if none is open) so that leaving
% it open is shown to come from the availability check
closePool = []; %#ok<NASGU> cleared below
if isParallelToolboxAvailable() && isempty(gcp('nocreate'))
    openedPool = parpool('Threads', 1);
    closePool = onCleanup(@() delete(openedPool));
end
if isParallelToolboxAvailable()
    poolBefore = gcp('nocreate');
end
restorePath = shadowParallelToolbox(); %#ok<NASGU> cleared below
closeParallelPool();
clear restorePath
if isParallelToolboxAvailable()
    assert(isequal(gcp('nocreate'), poolBefore));
end
clear closePool

% change the directory
cd(currentDir)

%% local functions

function restorePath = shadowParallelToolbox()
% Put a stand-in isParallelToolboxAvailable that returns false first on the MATLAB path, as on
% an installation without the Parallel Computing Toolbox. Clearing the returned onCleanup
% object removes the stand-in from the path and from the disk.
    standInDir = tempname;
    mkdir(standInDir);
    restorePath = onCleanup(@() removeStandIn(standInDir));
    fid = fopen(fullfile(standInDir, 'isParallelToolboxAvailable.m'), 'w');
    fprintf(fid, 'function available = isParallelToolboxAvailable()\navailable = false;\nend\n');
    fclose(fid);
    addpath(standInDir, '-begin');
    rehash
    assert(~isParallelToolboxAvailable());
end

function removeStandIn(standInDir)
% Remove the stand-in folder from the MATLAB path and from the disk.
    rmpath(standInDir);
    rmdir(standInDir, 's');
    rehash
end
