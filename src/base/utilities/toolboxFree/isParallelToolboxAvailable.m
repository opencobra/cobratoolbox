function available = isParallelToolboxAvailable()
% Tells whether the Parallel Computing Toolbox is installed and licensed
%
% USAGE:
%
%    available = isParallelToolboxAvailable()
%
% OUTPUT:
%    available:    logical scalar, true when the Parallel Computing Toolbox is
%                  installed (`ver('parallel')` is not empty) and its licence
%                  (feature 'Distrib_Computing_Toolbox') is available, else false
%
% NOTE:
%    Used by getParallelPool, openParallelPool and closeParallelPool, which
%    replace direct calls to gcp/parpool/delete(gcp(...)) so that code runs on
%    base MATLAB (without the toolbox, `parfor` loops then run serially).
%    Nothing is cached: the check is cheap and always reflects the current
%    installation and licence.
%
% .. Authors:
%     - Generated for feature 20261103-120403-toolbox-free-replacements, 2026-11-03.

available = ~isempty(ver('parallel')) && license('test', 'Distrib_Computing_Toolbox') == 1;
