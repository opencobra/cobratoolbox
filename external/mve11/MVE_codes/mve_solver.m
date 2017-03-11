function [x,E2,msg,y,z,iter] = mve_solver(A,b,x0,maxiter,tol)
%  Find the maximum volume ellipsoid
%    {v:  v = x + Es, ||s|| <= 1}
%  inscribing a full-dimensional polytope
%          {v:  Av <= b}
%  Input:  A, b --- defining the polytope
%          x0 --- interior point (Ax0 < b)
%  Output: x --- center of the ellipsoid
%          E2 --- E'*E

%--------------------------------------
% Yin Zhang, Rice University, 07/29/02
% Last modified: 09/29/16
%--------------------------------------

[m, n] = size(A);
bnrm = norm(b); 

if ~exist('maxiter','var'), maxiter = 50; end;
if ~exist('tol','var'), tol = 1.e-4; end;
minmu = 1.e-8; tau0 = .75;

bmAx0 = b - A*x0;
if any(bmAx0<=0), error('x0 not interior'); end

A = sparse(1:m,1:m,1./bmAx0)*A; b = ones(m,1); 
x = zeros(n,1); y = ones(m,1); bmAx = b;

fprintf('\n  Residuals:   Primal     Dual    Duality  logdet(E)\n');
fprintf('  --------------------------------------------------\n');

%res = 1; 
msg = 0;
for iter=1:maxiter %----- loop starts -----

if iter > 1, bmAx = bmAx - astep*Adx; end

Y = sparse(1:m,1:m,y);
E2 = inv(full(A'*Y*A));
Q = A*E2*A'; %#ok<MINV>
h = sqrt(diag(Q));
if iter==1
   t = min(bmAx./h); 
   y = y/t^2; h = t*h;
   z = max(1.e-1, bmAx-h);
   Q = t^2*Q; Y = Y/t^2;
end

yz = y.*z; yh = y.*h;
gap = sum(yz)/m;
rmu = min(.5, gap)*gap;
rmu = max(rmu, minmu);

R1 = -A'*yh;
R2 = bmAx - h - z;
R3 = rmu - yz;

r1 = norm(R1,'inf');
r2 = norm(R2,'inf');
r3 = norm(R3,'inf');
res = max([r1 r2 r3]);
objval = log(det(E2))/2;

fprintf('  iter %3i  ', iter);
fprintf('%9.1e %9.1e %9.1e  %9.3e\n', r2,r1,r3,objval);
if res < tol*(1+bnrm) && rmu <= minmu 
   fprintf('  Converged!\n'); 
   x = x + x0; msg=1; break; 
end

YQ = Y*Q; YQQY = YQ.*YQ'; y2h = 2*yh; YA = Y*A;
G  = YQQY + sparse(1:m,1:m,max(1.e-12,y2h.*z));
T = G \ (sparse(1:m,1:m,h+z)*YA);
ATP = (sparse(1:m,1:m,y2h)*T-YA)';

R3Dy = R3./y; R23 = R2 - R3Dy;
dx = (ATP*A)\(R1 + ATP*R23); Adx = A*dx;
dyDy = G\(y2h.*(Adx - R23));
dy = y.*dyDy;
dz = R3Dy - z.*dyDy;

ax = -1/min([-Adx./bmAx; -.5]);
ay = -1/min([ dyDy; -.5]);
az = -1/min([dz./z; -.5]); 
tau = max(tau0, 1 - res);
astep = tau*min([1 ax ay az]);

x = x + astep*dx;
y = y + astep*dy;
z = z + astep*dz;

end