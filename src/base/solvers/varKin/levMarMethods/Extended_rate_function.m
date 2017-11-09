function [hxk, ghxk] = Extended_rate_function(opt, varargin)
% USAGE:
%
%    [hxk, ghxk] = Extended_rate_function(opt, varargin)
%
% INPUTS:
%    xk:      current point;
%    opt:     structure includes required parameters:
%
%               * .FR - concatenation of forward and reverse stoichiometric matrix
%               * .A - Reduced forward stoichiometric matrix
%               * .B - Reduced reverse stoichiometric matrix
%               * .L - left null space of `R-F`
%               * .l0 - positive initial concentration
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
AB_BA = opt.AB_BA;
L     = opt.L;
l0    = opt.l0;
k     = opt.k;

xk = varargin{1};

% ======================== Function evaluation =========================
f   = AB_BA*exp(k+FR'*xk);
l   = L*exp(xk)-l0;
hxk = [f;l];

if nargout>1
    gf   = FR*diag(exp(k+FR'*xk))*AB_BA';
    gl   = diag(exp(xk))*L';
    ghxk = [gf,gl];
end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% End of Extended_rate_function.m %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
