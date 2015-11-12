% lusolTest
% This is a script to test an implementation of the
% LUSOL Mex interface lu1fac.
% It loads data A and b from illc1033.mat
% and carries out a few factorizations and checks.

% 29 Apr 2004: First version of lusolTest.m.
%              Michael Saunders, SOL, Stanford University.
% 07 Jul 2005: Mike O'Sullivan modified lu1fac.c to allow for
%              rectangular matrices.  Works fine with m > n.
%              Added test with m < n.

load illc1033   % Loads sparse A (1033-by-320)
                % and   dense  b ( 320-by-1).

[m,n] = size(A);               % m = 1033   n = 320


[L,U,p,q,inform] = luSOL(A);   % Rectangular factors A = L*U, m > n

if inform > 0
   disp(' ')
   disp('Hmmmm: luSOL(A) should have returned inform = 0.')
end

E = A - L*U;
e = norm(full(E),'fro');
disp(' ')
disp(['norm(A - L*U)_F = ' num2str(e)])

if e < 1e-8*(m*n)
  disp('This seems good')
else
  disp('This seems too large')
end
disp(' ')



B = A(p(1:n),:);               % Square nonsingular matrix
c = b(p(1:n));
[LB,UB,pB,qB,informB] = luSOL(B);

if inform > 0
   disp(' ')
   disp('Hmmmm: luSOL(B) should have returned inform = 0.')
end

x = UB\(LB\c);   rx = norm(c - B*x);
y = B\c;         ry = norm(c - B*y);
disp(' ')
disp(['Residual for UB\(LB\c) = ' num2str(rx)])
disp(['Residual for      B\c  = ' num2str(ry)])

if norm(rx) < 1e-8*n
  disp('This seems good')
else
  disp('This seems too large')
end
disp(' ')


C = A';
[L,U,p,q,inform] = luSOL(C);   % Rectangular factors A = L*U, m < n

if inform == 1
   disp(' ')
   disp('OK - we expect singularity when m < n')
elseif inform > 0
   disp(' ')
   disp('Hmmmm: luSOL(C) should have returned inform = 1.')
end

E = C - L*U;
e = norm(full(E),'fro');
disp(' ')
disp(['norm(C - L*U)_F = ' num2str(e)])

if e < 1e-8*(m*n)
  disp('This seems good')
else
  disp('This seems too large')
end
disp(' ')
