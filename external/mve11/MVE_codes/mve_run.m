function [x,E] = mve_run(A,b,x0)

%  Find the maximum volume ellipsoid
%     Ell = {v:  v = x + Es, ||s|| <= 1}
%  or Ell = {v:  ||E^{-1}(v-x)|| <= 1}
%  inscribing a full-dimensional polytope
%          {v:  Av <= b}
%  Input:  A, b --- defining the polytope
%   (Optinal x0 --- interior point, A*x0 < b)
%  Output:  x --- center of the ellipsoid
%           E --- matrix defining ellipsoid

%--------------------------------------
% Yin Zhang, Rice University, 07/29/02
% Last modified: 09/29/16
%--------------------------------------

maxiter = 80; tol1 = 1.e-8; tol2 = 1.E-6;
[m, n] = size(A); 
t0 = tic;

if nargin < 3
  mve_chkdata(A,b);
  [msg,x0] = mve_presolve(A,b,maxiter,tol1);
  fprintf('  End of Presolve ......\n');
  if msg(1) ~= 's', disp(msg); return; end
  [x,E2] = mve_solver(A,b,x0,maxiter,tol2);
else
  mve_chkdata(A,b,x0);
  [x,E2] = mve_solver(A,b,x0,maxiter,tol2);
end
E = chol(E2); E = E';
fprintf('  [m, n] = [%i, %i]\n', m, n);
fprintf('  Elapsed time: %g seconds\n', toc(t0));