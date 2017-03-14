function [x,E2,msg,y,z,iter] = mve_solver_cobra(A,b,x0,maxiter,tol,reg)
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
%--------------------------------------

%lines modified by me (Ben Cousins) have a %Ben after them

t0 = cputime; 
[m, n] = size(A);
bnrm = norm(b); 

if ~exist('maxiter') maxiter = 50; end;
if ~exist('tol') tol = 1.e-4; end;
minmu = 1.e-8; tau0 = .75;

last_r1 = -Inf;
last_r2 = -Inf;

bmAx0 = b - A*x0;
if any(bmAx0<=0) error('x0 not interior'); end

A = sparse(1:m,1:m,1./bmAx0)*A; b = ones(m,1); 
x = zeros(n,1); y = ones(m,1); bmAx = b;

% fprintf('\n  Residuals:   Primal     Dual    Duality  logdet(E)\n');
% fprintf('  --------------------------------------------------\n');

res = 1; msg = 0;
prev_obj = -Inf;
for iter=1:maxiter %----- loop starts -----

if iter > 1 bmAx = bmAx - astep*Adx; end

Y = sparse(1:m,1:m,y);
E2 = inv(full(A'*Y*A));

% condE(iter) = rcond(E2); %Ben
Q = A*E2*A';
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

if mod(iter,10)==0
%     fprintf('  iter %3i  ', iter);
    if abs((last_r1-r1)/min(abs(last_r1),abs(r1)))<1e-2 && abs((last_r2 - r2)/min(abs(last_r2),abs(r2)))<1e-2 && max(eig(E2))/min(eig(E2))>100 && reg>1e-10
       fprintf('Stopped making progress, stopping and restarting.\n');
       msg=2;
       break;
    end
%     fprintf('%9.1e %9.1e %9.1e  %9.3e\n', r2,r1,r3,objval);
    last_r2 = r2;
    last_r1 = r1;
end
if (res < tol*(1+bnrm) && rmu <= minmu ) || (iter>100 && prev_obj ~= -Inf && (prev_obj >= (1-tol)*objval  || prev_obj <=(1-tol)*objval))
   fprintf('  Converged!\n'); 
   x = x + x0; msg=1; break; 
end
prev_obj = objval;

YQ = Y*Q; YQQY = YQ.*YQ'; y2h = 2*yh; YA = Y*A;
G  = YQQY + sparse(1:m,1:m,max(reg,y2h.*z)); %Ben
T = G \ (sparse(1:m,1:m,h+z)*YA);

ATP = (sparse(1:m,1:m,y2h)*T-YA)';

R3Dy = R3./y; R23 = R2 - R3Dy;
ATP_A = ATP*A;
ATP_A = ATP_A + sparse(1:size(ATP_A,1), 1:size(ATP_A,1),reg); %Ben
dx = ATP_A \ (R1 + ATP*R23);

Adx = A*dx;
dyDy = G \ (y2h.*(Adx-R23));

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


if reg > 1e-6 && iter>=10 %Ben
    break; %Ben
end %Ben

end
