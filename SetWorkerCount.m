function SetWorkerCount(nworkers)
% SetWorkerCount Configures the number of (parallel) workers
%
% Requires the Parallel computing toolbox
%
% 20160316: Support for R2014b+

%Find the number of workers in the current parallel pool.

global poolobj

poolobj = gcp('nocreate'); % If no pool, do not create new one.
if isempty(poolobj)
    poolsize = 0;
else
    poolsize = poolobj.NumWorkers;
end

%Initialize a parallel pool
if nworkers <= 1
   if poolsize > 0
      delete(poolobj);
   end
else
   if poolsize ~= nworkers
      % Only need to do this once
      if poolsize  > 0
         delete(poolobj);
      end
      parpool('local', nworkers);
      fprintf('Parallel computation initialized\n')
   end
end
