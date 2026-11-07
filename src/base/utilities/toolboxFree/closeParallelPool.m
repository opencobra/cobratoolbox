function closeParallelPool()
% Closes the current parallel pool, if there is one
%
% USAGE:
%
%    closeParallelPool()
%
% NOTE:
%    Replaces direct calls to `delete(gcp('nocreate'))` so that code runs on
%    base MATLAB: when the Parallel Computing Toolbox is not available, or no
%    pool is open, nothing is done and no error is raised.
%
% .. Authors:
%     - Generated for feature 20261103-120403-toolbox-free-replacements, 2026-11-03.

if isParallelToolboxAvailable()
    pool = gcp('nocreate');
    if ~isempty(pool)
        delete(pool);
    end
end
