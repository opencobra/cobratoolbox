function T = treshape(x,unit)
%TRESHAPE  Reshape vector to or from (unit) triangular matrix.
%          TRESHAPE(X) returns a square upper triangular matrix whose
%          elements are taken columnwise from the matrix X.
%          TRESHAPE(X,1) returns a UNIT upper triangular matrix, and
%          the 1s should not be specified in X.
%          An error results if X does not have a number of elements of the form
%          N*(N+1)/2 (or N less than this in the unit triangular case).
%          X = TRESHAPE(R,2) is the inverse operation to R = TRESHAPE(X).
%          X = TRESHAPE(R,3) is the inverse operation to R = TRESHAPE(X,1).

if nargin == 1, unit = 0; end

[p,q] = size(x);

if unit < 2   % Convert vector x to upper triangular R.

    m = p*q;
    n = round( (-1 + sqrt(1+8*m))/2 );
    if n*(n+1)/2 ~= m
          error('Matrix must have a ''triangular'' number of elements.')
    end

    if unit == 1
       n = n+1;
    end

    x = x(:);
    T = unit*eye(n);

    i = 1;
    for j = 1+unit:n
        T(1:j-unit,j) = x(i:i+j-1-unit);
        i = i+j-unit;
    end

elseif unit >= 2   % Convert upper triangular R to vector x.

   T = x;
   if p ~= q, error('Must pass square matrix'), end
   unit = unit - 2;
   n = p*(p+1)/2 - unit*p;
   x = zeros(n,1);
   i = 1;
   for j = 1+unit:p
       x(i:i+j-1-unit) = T(1:j-unit,j);
       i = i+j-unit;
   end
   T = x;

end
