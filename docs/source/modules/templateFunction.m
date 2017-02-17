function [out1, out2] = templateFunction(arg1, arg2, arg3)
% This function does this and that
%
% Usage:
%
%   [out1, out2] = templateFunction(arg1, arg2, arg3)
%
% Inputs:
%    arg1: a short description for this argument
%    arg2: another argument
%
% Optional input:
%    arg3: optional argument
%
% Output:
%    out1: the product of arg1 and arg2
%
% Optional output:
%    out2: the product of arg1, arg2 and arg3
%
% Example:
% ::
%
%   [out1, out2] = templateFunction(1, 2, 3);
%   >> out1 = 2
%   >> out2 = 6
%
% .. Authors: - myself
%             - laurent
%
if nargin < 3
    arg3 = 1;
end

out1 = arg1 * arg2;

if nargout > 1
    out2 = out1 * arg3;
end
