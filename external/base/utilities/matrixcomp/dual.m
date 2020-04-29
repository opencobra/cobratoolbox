function y = dual(x, p)
%DUAL    Dual vector with respect to Holder p-norm.
%        Y = DUAL(X, p), where 1 <= p <= inf, is a vector of unit q-norm
%        that is dual to X with respect to the p-norm, that is,
%        norm(Y, q) = 1 where 1/p + 1/q = 1 and there is
%        equality in the Holder inequality: X'*Y = norm(X, p)*norm(Y, q).
%        Special case: DUAL(X), where X >= 1 is a scalar, returns Y such
%                      that 1/X + 1/Y = 1.

%        Called by PNORM.

warns = warning;
warning('off')

if nargin == 1
   if length(x) == 1
       y = 1/(1-1/x);
       return
   else
       error('Second argument missing.')
   end
end

q = 1/(1-1/p);

if norm(x,inf) == 0, y = x; return, end

if p == 1

   y = sign(x) + (x == 0);   % y(i) = +1 or -1 (if x(i) real).

elseif p == inf

   [xmax, k] = max(abs(x));
   f = find(abs(x)==xmax); k = f(1);
   y = zeros(size(x));
   y(k) = sign(x(k));        % y is a multiple of unit vector e_k.

else  % 1 < p < inf.  Dual is unique in this case.

  x = x/norm(x,inf);         % This scaling helps to avoid under/over-flow.
  y = abs(x).^(p-1) .* ( sign(x) + (x==0) );
  y = y / norm(y,q);         % Normalize to unit q-norm.

end
warning(warns)
