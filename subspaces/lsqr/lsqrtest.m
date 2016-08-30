function x = lsqrtest( m, n, damp )
%        x = lsqrtest( m, n, damp );
%
% If m = n and damp = 0, this sets up a system Ax = b
% and calls lsqr.m to solve it.  Otherwise, the usual
% least-squares or damped least-squares problem is solved.
%
% lsqraprod.m defines the m x n matrix A.

%  11 Apr 1996: First version for distribution with lsqr.m.
%               Michael Saunders, Dept of EESOR, Stanford University.
%  22 Mar 2003: LSQR now outputs r1norm and r2norm.

xtrue  = (n : -1: 1)';
iw     = 0;
rw     = 0;
b      = lsqraprod( 1, m, n, xtrue, iw, rw );

atol   = 1.0e-6;
btol   = 1.0e-6;
conlim = 1.0e+10;
itnlim = 10*n;
show   = 1;
aprodfunc  = @(mode, m, n, x) lsqraprod(mode,m,n,x,iw,rw)

[ x, istop, itn, r1norm, r2norm, xnorm, var ] =  ...
    lsqr( m, n, aprodfunc, b, damp, atol, btol,  ...
          conlim, itnlim, show );

disp(' ');   j1 = min(n,5);   j2 = max(n-4,1);
disp('First elements of x:');  disp(x(1:j1)');
disp('Last  elements of x:');  disp(x(j2:n)');
%===================
% End of lsqrtest.m
%===================
