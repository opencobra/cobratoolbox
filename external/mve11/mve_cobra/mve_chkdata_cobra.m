function mve_chkdata_cobra(A,b,x0)
% check consistency of data

%--------------------------------------
% Yin Zhang, Rice University, 07/29/02
%--------------------------------------

 [rA,cA] = size(A); [rb,cb] = size(b);
 if cA < 2 
    error('A must have at least 2 columns'); 
 end
 if rA < cA+1
    error('A has too few rows'); 
 end
 if cb ~= 1 || rb ~= rA
    error('size of b mis-matches');
 end

 if nargin < 3, return; end

 [rx0,cx0] = size(x0);
 if cA ~= rx0 || cx0 ~= 1
    error('size of x0 mis-matches');
 end
 if any(b-A*x0) <= eps
    error('x0 is not interior');
 end
