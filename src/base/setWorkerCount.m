function setWorkerCount(nworkers)
% configures the number of (parallel) workers
%
% USAGE:
%     setWorkerCount(nworkers);
%
% INPUT:
%
%    nworkers:      Number of workers in the pool
%
% NOTE:
%    Requires the Parallel computing toolbox
%

global poolobj

% find the number of workers in the current parallel pool
poolobj = gcp('nocreate');  % if no pool, do not create new one.
if isempty(poolobj)
    poolsize = 0;
else
    poolsize = poolobj.NumWorkers;
end

% Initialize a parallel pool
if nworkers <= 1
    if poolsize > 0
        delete(poolobj);
    end
else
    if poolsize ~= nworkers
        % Only need to do this once
        if poolsize > 0
            delete(poolobj);
        end
        parpool('local', nworkers);  % 'SpmdEnabled',false
        fprintf('Parallel computation initialized\n')
    end
end
