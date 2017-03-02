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

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mve_chkdata(A,b,x0)
% check consistency of data

%--------------------------------------
% Yin Zhang, Rice University, 07/29/02
% Last modified: 09/29/16
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
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function [msg,x,t,s,y] = mve_presolve(A,b,maxiter,tol)
% Solve LP: max t, s.t. Ax + t*e <= b

%--------------------------------------
% Yin Zhang, Rice University, 07/29/02
% Last modified: 09/29/16
%--------------------------------------

[m, n] = size(A);  bnrm = norm(b); 
o_m = zeros(m,1);  o_n = zeros(n,1);
e_m =  ones(m,1);  %e_n =  ones(n,1);

% initialize
x = o_n; y = e_m/m;
t = min(b) - 1; s = b - t;

dx = o_n; dxc = dx; %#ok<*NASGU>
ds = o_m; dsc = ds;
dy = o_m; dyc = dy;
dt = 0;   dtc = 0;
tau0 = 0.995; 
sigma0 = 0.2;
msg = 'successful';

p = 1:n;
if issparse(A)
    absA = abs(A); 
    p = symamd(absA'*absA);
end
p(n+1) = n+1;

fprintf('\n  Residuals:   Primal     Dual     Duality    Obj\n');
fprintf('  --------------------------------------------------\n');

for iter = 0:maxiter

  % KKT residuals
  r1 = b - (A*x + s + t);
  r2 = -A'*y;
  r3 = 1 - sum(y);
  r4 = -s.*y;
  gap = -sum(r4);

  % relative residual norms and gap
  prif = norm(r1)/(1 + bnrm); 
  drif = norm([r2;r3]); 
  rgap = abs(b'*y - t)/(1 + abs(t)); 
  total_err = max([prif drif rgap]);
  
  % progress output & check stopping
  if (total_err < tol) 
      fprintf('  iter. %3i: %9.1e %9.1e %9.1e %9.1e\n',...
      iter,prif,drif,rgap,t); break; 
  end
  fprintf('  iter. %3i: %9.1e %9.1e %9.1e %9.1e\n',...
             iter,prif,drif,rgap,t); 
  if dt > 1.e+3*bnrm || t > 1.e+6*bnrm
      msg = 'unbounded?'; break; 
  end  

  % Shur complement matrix
  d = min(5.e+15,y./s); 
  AtD = A'*spdiags(d,0,m,m);
  AtDe = AtD*e_m;  
  B = [AtD*A AtDe; AtDe' sum(d)];
  B = B + 1.e-14*speye(n+1);

  % Cholesky decomposition
  if ~issparse(A)
      R = chol(B);
  else
      %R = cholinc(B(p,p),'inf');
      R = chol(B(p,p));
  end
  
  % predictor step & length
  [dx,ds,dt,dy] = calcstep(A,R,p,s,y,r1,r2,r3,r4);   

  alphap = -1/min([-1; ds./s]);
  alphad = -1/min([-1; dy./y]);
  
  % determine mu
  ratio = (s+alphap*ds)'*(y+alphad*dy)/gap;
  sigma = min(sigma0, ratio^2);
  mu = sigma*gap/m;
  
  % corrector and combined step & length
  [dxc,dsc,dtc,dyc] = calcstep(A,R,p,s,y,o_m,o_n,0,mu-ds.*dy);  
  dx = dx + dxc; ds = ds + dsc; 
  dt = dt + dtc; dy = dy + dyc;
  alphap = -1/min([-.5; ds./s]);
  alphad = -1/min([-.5; dy./y]);
  
  % update iterates
  tau = max(tau0, 1-gap/m);
  alphap = min(1,tau*alphap);
  alphad = min(1,tau*alphad);
  x = x + alphap * dx;
  s = s + alphap * ds;
  t = t + alphap * dt; 
  y = y + alphad * dy;
end
if t < eps, msg = 'no volume'; end
 
  
%%%%%%%%%%%%%%%%%%%%%%%%%%
function [dx,ds,dt,dy] = calcstep(A,R,p,s,y,r1,r2,r3,r4)
 dxdt = zeros(size(R,1),1);
 tmp = (r1.*y-r4)./s;
 rhs = [r2+A'*tmp; r3+sum(tmp)]; 
 if ~issparse(A)
     dxdt = R\(R'\rhs);
 else
     dxdt(p) = R\(R'\rhs(p));
 end
 dx = dxdt(1:end-1); 
 dt = dxdt(end);
 ds = r1 - A*dx - dt;
 dy = (r4 - y.*ds)./s;
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
end