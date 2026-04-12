function cfg = getCobraOptArrowConfig(problemType)
% getCobraOptArrowConfig Return OptArrow configuration stored for a problem type.
%
% USAGE:
%
%    cfg = getCobraOptArrowConfig(problemType)
%
% INPUT:
%    problemType:    char/string, e.g. 'LP' or 'QP'
%
% OUTPUT:
%    cfg:            struct, previously stored OptArrow configuration or empty struct
%
% .. Author: - Farid Zare 07/04/2026

global CBT_OPTARROW_SOLVER_CONFIGS;

if nargin < 1 || isempty(problemType)
    error('getCobraOptArrowConfig requires a problem type.');
end

problemType = upper(char(string(problemType)));
if isempty(CBT_OPTARROW_SOLVER_CONFIGS) || ~isstruct(CBT_OPTARROW_SOLVER_CONFIGS) ...
        || ~isfield(CBT_OPTARROW_SOLVER_CONFIGS, problemType)
    cfg = struct();
    return;
end

cfg = CBT_OPTARROW_SOLVER_CONFIGS.(problemType);
end
