function fxk = Rate_function(opt, varargin)
% USAGE:
%
%    Rate_function(opt, varargin)
%
% INPUTS:
%    xk:     current point;
%    opt:    structure includes required parameters;
%
%              * .FR - concatenation of forward and reverse stoichiometric matrix
%              * .A - Reduced forward stoichiometric matrix
%              * .B - Reduced reverse stoichiometric matrix
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
