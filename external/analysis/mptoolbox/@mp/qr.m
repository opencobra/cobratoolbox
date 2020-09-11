function [Q,R]=qr(x,flag)

if nargin<3
 if nargin<2, flag=1; end
    %use the matrix Computation toolbox by N. Higham
    %[Q,R]=gs_m(x);
    [Q,R]=mp_myqr(x,flag);
else
    error('Three argument QR factorization is unimplemented yet!')
end