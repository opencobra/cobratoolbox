% The COBRAToolbox: testGetParallelPool.m
%
% Purpose:
%     - getParallelPool returns the current parallel pool (gcp('nocreate')) when the Parallel
%       Computing Toolbox is available and [] otherwise, without ever creating a pool. The test
%       checks both cases. The case without the toolbox is produced on any machine by putting a
%       stand-in isParallelToolboxAvailable that returns false first on the path, in a temporary
%       folder that is removed again at the end of the section.
%
% Function under test:
%     src/base/utilities/toolboxFree/getParallelPool.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver. Where the toolbox is installed, a one-worker
%     thread pool is opened for about a second; a pool that was open before the test is left
%     open.
%
% Coverage exemptions:
%     - Line 22 (pool = gcp('nocreate')) is reached only where the Parallel Computing Toolbox is
%       installed and licensed; elsewhere the with-toolbox section prints "skipped".
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261103-120403-toolbox-free-replacements, 2026-11-03.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetParallelPool'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% with the toolbox: the current pool, or [] when none is open, and no pool is created

if isParallelToolboxAvailable()
    poolAtStart = gcp('nocreate');
    if isempty(poolAtStart)
        % no pool is open: the result is empty and asking does not open one
        assert(isempty(getParallelPool()));
        assert(isempty(gcp('nocreate')));

        % once a pool is open, the result is that pool
        openedPool = parpool('Threads', 1);
        closePool = onCleanup(@() delete(openedPool));
        assert(isequal(getParallelPool(), openedPool));
        assert(isequal(getParallelPool(), gcp('nocreate')));
        clear closePool
        assert(isempty(gcp('nocreate')));
    else
        % a pool was already open before the test: the result is that pool, left open
        assert(isequal(getParallelPool(), poolAtStart));
    end
else
    fprintf('skipped: Parallel Computing Toolbox not installed or not licensed\n');
end

%% without the toolbox: [] and no error, even when a pool is open

% where the toolbox is installed, a pool is opened first (if none is open) so that the
% result is shown to come from the availability check and not from an absent pool
availableBefore = isParallelToolboxAvailable();
closePool = []; %#ok<NASGU> cleared below
if availableBefore && isempty(gcp('nocreate'))
    openedPool = parpool('Threads', 1);
    closePool = onCleanup(@() delete(openedPool));
end
restorePath = shadowParallelToolbox(); %#ok<NASGU> cleared below
pool = getParallelPool();
assert(isempty(pool) && isnumeric(pool));
clear restorePath closePool
% the stand-in is gone again: the real availability check is back in force
assert(isParallelToolboxAvailable() == availableBefore);

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
