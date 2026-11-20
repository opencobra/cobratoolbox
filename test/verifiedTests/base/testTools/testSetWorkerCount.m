% The COBRAToolbox: testSetWorkerCount.m
%
% Purpose:
%     - setWorkerCount(nworkers) sets the parallel pool to nworkers workers: for nworkers <= 1
%       it closes an open pool; otherwise it keeps a pool of that size, or closes a pool of
%       another size and opens a 'local' (process) pool of nworkers workers. It stores the pool
%       found at the call in the global poolobj. The test starts from a one-worker thread pool,
%       lets setWorkerCount replace it by a two-worker process pool, keeps that pool, closes it,
%       and calls it without a pool; the pool state found at the start is restored at the end.
%
% Function under test:
%     src/base/setWorkerCount.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; needs the Parallel Computing Toolbox (declared below, as the
%     function's NOTE requires it) and opens one process pool of two workers.
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
fileDir = fileparts(which('testSetWorkerCount'));
cd(fileDir);

% the function needs the Parallel Computing Toolbox
prepareTest('requiredToolboxes', {'distrib_computing_toolbox'});

% setWorkerCount creates the global poolobj; it is removed (or restored) at the end
globalsBefore = who('global');
global poolobj
poolobjBefore = poolobj;

% the pool found at the start: its size is restored at the end
poolAtStart = gcp('nocreate');
if isempty(poolAtStart)
    workersAtStart = 0;
else
    workersAtStart = poolAtStart.NumWorkers;
    delete(poolAtStart);
end

try
    %% a pool of another size is closed and a process pool of nworkers workers is opened

    threadPool = parpool('Threads', 1);
    setWorkerCount(2);
    % the global holds the pool found at the call (now deleted)
    assert(isequal(poolobj, threadPool));
    newPool = gcp('nocreate');
    assert(isa(newPool, 'parallel.ProcessPool') && newPool.NumWorkers == 2);

    %% a pool of the requested size is kept

    setWorkerCount(2);
    assert(isequal(gcp('nocreate'), newPool) && isequal(poolobj, newPool));

    %% nworkers <= 1 closes the pool

    setWorkerCount(1);
    assert(isempty(gcp('nocreate')));

    %% nworkers <= 1 without a pool: nothing to do, no pool is opened

    setWorkerCount(0);
    assert(isempty(gcp('nocreate')) && isempty(poolobj));
catch ME
    % never leave a pool open
    delete(gcp('nocreate'));
    rethrow(ME);
end

% restore the pool size found at the start (no pool, or a process pool of that size)
delete(gcp('nocreate'));
if workersAtStart > 0
    parpool('local', workersAtStart);
end

% restore poolobj, or remove it when it did not exist before the test
poolobj = poolobjBefore;
newGlobals = setdiff(who('global'), globalsBefore);
for k = 1:numel(newGlobals)
    clear('global', newGlobals{k});
end

% change the directory
cd(currentDir)
