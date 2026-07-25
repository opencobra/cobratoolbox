function fxk = Rate_function(opt, varargin)
% Computes the rate function `f(xk)` for the current point, given the
% forward/reverse stoichiometric matrices and kinetic parameter in `opt`
%
% USAGE:
%
%    fxk = Rate_function(opt, varargin)
%
% INPUTS:
%    xk:     current point;
%    opt:    structure includes required parameters;
%
%              * .FR - concatenation of forward and reverse stoichiometric matrix
%              * .FR_RF - `FR - RF`, difference of forward-reverse and reverse-forward concatenations
%              * .k - initial kinetic
%
% OUTPUT:
%    fxk:    the vector `f(xk)`

if nargin ~= 2
    error('The number of input arguments is not valid');
end

if nargout >= 2
    error('The number of output arguments is not valid');
end

FR    = opt.FR;
FR_RF = opt.FR_RF;
k     = opt.k;
xk    = varargin{1};

% ======================== Function evaluation =========================

fxk = FR_RF*exp(k+FR'*xk);

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% End of Rate_function.m %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
