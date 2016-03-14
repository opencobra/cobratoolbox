function SetWorkerCount(nworkers)
% SetWorkerCount Configures the number of (parallel) workers
%
% Requires the Parallel computing toolbox

if nworkers <= 1
   if matlabpool('size') > 0
      matlabpool close
   end
else
   if matlabpool('size') ~= nworkers
      % Only need to do this once
      if matlabpool('size')  > 0
         matlabpool close
      end
      matlabpool('open', nworkers)
      fprintf('Parallel computation initialized\n')
   end
end
