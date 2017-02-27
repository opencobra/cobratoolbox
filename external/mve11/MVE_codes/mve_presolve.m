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
%disp(msg);
 
  
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
