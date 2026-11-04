function pool = openParallelPool(varargin)
% Returns the current parallel pool, opening one if none is open
%
% USAGE:
%
%    pool = openParallelPool()
%    pool = openParallelPool(numWorkers)
%    pool = openParallelPool(profile, numWorkers, ...)
%
% OPTIONAL INPUTS:
%    varargin:    any arguments accepted by `parpool` (for example the number
%                 of workers, or a profile name such as 'local', 'Processes' or
%                 'Threads' followed by the number of workers); they are passed
%                 unchanged to `parpool` when a new pool is opened
%
% OUTPUT:
%    pool:        the parallel pool; `[]` when the Parallel Computing Toolbox
%                 is not available
%
% NOTE:
%    Replaces the pattern `if isempty(gcp('nocreate')), parpool(...); end`
%    so that code runs on base MATLAB: without the toolbox no error is raised
%    and `parfor` loops run serially. When a pool is already open it is
%    returned as it is, even if its size or profile differ from the requested
%    ones (same behaviour as the pattern it replaces). This function prints
%    nothing itself; `parpool` prints its usual start-up messages.
%
% .. Authors:
%     - Generated for feature 20261103-120403-toolbox-free-replacements, 2026-11-03.

if ~isParallelToolboxAvailable()
    % assign the output only when it is requested, so that a call without a
    % semicolon prints nothing on a MATLAB without the toolbox
    if nargout > 0
        pool = [];
    end
    return
end

pool = gcp('nocreate');
if isempty(pool)
    pool = parpool(varargin{:});
end
