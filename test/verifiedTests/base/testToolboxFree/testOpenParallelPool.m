% The COBRAToolbox: testOpenParallelPool.m
%
% Purpose:
%     - openParallelPool returns the current parallel pool, opening one with the given parpool
%       arguments when none is open; without the Parallel Computing Toolbox it returns [] with no
%       error and no output, so that parfor loops run serially. The test checks both cases. The
%       case without the toolbox is produced on any machine by putting a stand-in
%       isParallelToolboxAvailable that returns false first on the path, in a temporary folder
%       that is removed again at the end of the section.
%
% Function under test:
%     src/base/utilities/toolboxFree/openParallelPool.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver. Where the toolbox is installed, a one-worker
%     thread pool ('Threads' profile, opens in about a second) is opened and closed again; a pool
%     that was open before the test is left open.
%
% Coverage exemptions:
%     - Lines 36-37 (gcp and the check for an open pool) are reached only where the Parallel
%       Computing Toolbox is installed and licensed; elsewhere the with-toolbox section prints
%       "skipped".
%     - Line 38 (parpool) is reached only where the toolbox is installed and no pool was open
%       when the test started.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261103-120403-toolbox-free-replacements, 2026-11-03.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testOpenParallelPool'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% with the toolbox: a pool is opened with the given arguments, an open pool is reused

if isParallelToolboxAvailable()
    poolAtStart = gcp('nocreate');
    if isempty(poolAtStart)
        % no pool is open: one is opened with the parpool arguments and becomes the current pool
        pool = openParallelPool('Threads', 1);
        closePool = onCleanup(@() closeParallelPool());
        assert(isa(pool, 'parallel.ThreadPool') && pool.NumWorkers == 1);
        assert(isequal(pool, gcp('nocreate')));

        % a pool is open: it is returned as it is, even though another size is asked for
        samePool = openParallelPool('Threads', 2);
        assert(isequal(samePool, pool) && samePool.NumWorkers == 1);

        % closing restores the state found at the start: no pool
        clear closePool
        assert(isempty(gcp('nocreate')));
    else
        % a pool was already open before the test: it is returned and left open
        assert(isequal(openParallelPool('Threads', 1), poolAtStart));
        assert(isequal(gcp('nocreate'), poolAtStart));
    end
else
    fprintf('skipped: Parallel Computing Toolbox not installed or not licensed\n');
end

%% without the toolbox: [] with no error, no output and no pool opened

if isParallelToolboxAvailable()
    poolWasOpen = ~isempty(gcp('nocreate'));
end
restorePath = shadowParallelToolbox(); %#ok<NASGU> cleared below
printed = evalc('pool = openParallelPool(1);');
assert(isempty(pool) && isnumeric(pool));
assert(isempty(printed));
% most callers write openParallelPool(n) without a semicolon: nothing may be printed then either
printed = evalc('openParallelPool(1)');
assert(isempty(printed));
clear restorePath
% where the toolbox is installed, no pool was opened behind the stand-in
if isParallelToolboxAvailable()
    assert(~isempty(gcp('nocreate')) == poolWasOpen);
end

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
