% num2bin(num,n)
%  Odefy helper function that converts a number into its binary
%  representation. 
%
%  num - number to be converted to binary representation
%  n   - number of digits, required for leading zeros

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%
function v = num2bin(num, n)

v = zeros(n,1);

for i=n-1:-1:0
    pow2 = 2^i;
    if num >= pow2
        v(i+1) = 1;
        num = num - pow2;
    end
end