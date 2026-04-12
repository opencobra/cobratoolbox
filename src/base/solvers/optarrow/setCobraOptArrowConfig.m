function cfg = setCobraOptArrowConfig(problemType, cfg)
% setCobraOptArrowConfig Store OptArrow configuration for a problem type.
%
% USAGE:
%
%    cfg = setCobraOptArrowConfig(problemType, cfg)
%
% INPUTS:
%    problemType:    char/string, e.g. 'LP' or 'QP'
%    cfg:            struct, OptArrow configuration to store
%
% OUTPUT:
%    cfg:            struct, stored OptArrow configuration
%
% .. Author: - Farid Zare 07/04/2026

global CBT_OPTARROW_SOLVER_CONFIGS;

if nargin < 2 || ~isstruct(cfg)
    error('setCobraOptArrowConfig expects a problem type and a config struct.');
end

problemType = upper(char(string(problemType)));
if isempty(CBT_OPTARROW_SOLVER_CONFIGS) || ~isstruct(CBT_OPTARROW_SOLVER_CONFIGS)
    CBT_OPTARROW_SOLVER_CONFIGS = struct();
end

CBT_OPTARROW_SOLVER_CONFIGS.(problemType) = cfg;
end
