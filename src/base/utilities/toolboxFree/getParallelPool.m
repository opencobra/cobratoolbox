function pool = getParallelPool()
% Returns the current parallel pool without creating one
%
% USAGE:
%
%    pool = getParallelPool()
%
% OUTPUT:
%    pool:    the current parallel pool (`gcp('nocreate')`) when the Parallel
%             Computing Toolbox is available; `[]` when no pool is open or the
%             toolbox is not available
%
% NOTE:
%    Replaces direct calls to `gcp('nocreate')` so that code runs on base
%    MATLAB. Callers that read pool properties (for example `pool.NumWorkers`)
%    must first check `isempty(pool)`.
%
% .. Authors:
%     - Generated for feature 20261103-120403-toolbox-free-replacements, 2026-11-03.

if isParallelToolboxAvailable()
    pool = gcp('nocreate');
else
    pool = [];
end
