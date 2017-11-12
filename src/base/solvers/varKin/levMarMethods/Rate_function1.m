function [fxk, gfxk] = Rate_function1(opt, varargin)
% USAGE:
%
%    [fxk, gfxk] = Rate_function1(opt, varargin)
%
% INPUTS:
%    xk:      current point;
%    opt:     structure includes required parameters;
%
%               * .FR - concatenation of forward and reverse stoichiometric matrix
%               * .A - Reduced forward stoichiometric matrix
%               * .B - Reduced reverse stoichiometric matrix
%               * .k - initial kinetic
%
% OUTPUTS:
%    hxk:     the vector `h(xk)`
%    ghxk:    gradient of `h` at `xk`

if nargin ~= 2
    error('The number of input arguments is not valid');
end

if nargout >= 3
    error('The number of output arguments is not valid');
end

FR    = opt.FR;
FR_RF = opt.FR_RF;
k     = opt.k;
xk = varargin{1};

% ======================== Function evaluation =========================
fxk  = FR_RF*exp(k+FR'*xk);
gfxk = FR*diag(exp(k+FR'*xk))*FR_RF';

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% End of Rate_function1.m %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
