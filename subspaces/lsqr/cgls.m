function [x,resNE,k,info] = cgls( Aname ,shift,b,m,n,kmax,tol,prnt)
%
%        [x,resNE,k,info] = cgls('gemat',shift,b,m,n,kmax,tol,prnt);
%
% solves a symmetric system
%
%        (A'A + shift I)x = A'b      or      N x = A'b,
%
% where A is a general m by n matrix and shift may be positive or negative.
% The method should be stable if N = (A'A + shift I) is positive definite.
% It MAY be unstable otherwise.
%
% 'gemat' specifies an M-file gemat.m (say), such that
%           y = gemat(0,x,m,n) identifies gemat (if you wish),
%           y = gemat(1,x,m,n) gives y = A x,
%           y = gemat(2,x,m,n) gives y = A'x.
% NOTE: The M-file must not be called Aname.m!
%
% Input:
% kmax  = maximum number of iterations.
% tol   = desired relative residual size, norm(rNE)/norm(A'b),
%         where rNE = A'b - N x.
% prnt  = 1 gives an iteration log, 0 suppresses it.
%
% Output:
% resNE = relative residual for normal equations: norm(A'b - Nx)/norm(A'b).
% k     = final number of iterations performed.
% info  = 1 if required accuracy was achieved,
%       = 2 if the limit kmax was reached,
%       = 3 if N seems to be singular or indefinite.
%       = 4 if instability seems likely.  (N indefinite and normx decreased.)

% When shift = 0, cgls is Hestenes and Stiefel's specialized form of the
% conjugate-gradient method for least-squares problems.  The general shift
% is a simple modification.
%
% 01 Sep 1999: First version.
%              Per Christian Hansen (DTU) and Michael Saunders (visiting DTU).
%-----------------------------------------------------------------------------

%% Let Aname identify itself
   x    = zeros(n,1);    q     = feval(Aname,0,x,m,n);

%% Initialize
   r    = b;
   s    = feval(Aname,2,b,m,n);                     % s = A'b
   p    = s;
   norms0 = norm(s);     gamma = norms0^2;
   xmax = 0;             normx  = 0;
   k    = 0;             info   = 0;

   if prnt
      head = '    k       x(1)             x(n)           normx        resNE';
      form = '%5.0f %16.10g %16.10g %9.2g %12.5g';
      disp('  ');   disp(head);
      disp( sprintf(form, k,x(1),x(n),normx,1) )
   end

   indefinite = 0;
   unstable   = 0;

%---------------------------------------------------------------------------
%% Main loop
%---------------------------------------------------------------------------
   while (k < kmax) & (info == 0) 

      k     = k+1;
      q     = feval(Aname,1,p,m,n);                % q = A p

      delta = norm(q)^2  +  shift*norm(p)^2;
      if delta <= 0, indefinite = 1;   end
      if delta == 0, delta      = eps; end
      alpha = gamma / delta;

      x     = x + alpha*p;
      r     = r - alpha*q;
      s     = feval(Aname,2,r,m,n)  -  shift*x;    % s = A'r - shift x

      norms = norm(s);
      gamma1= gamma;
      gamma = norms^2;
      beta  = gamma / gamma1;
      p     = s + beta*p;

   %% Convergence
      normx = norm(x);
      xmax  = max( xmax, normx );
      info  = (norms <= norms0 * tol) | (normx * tol >= 1);

   %% Output
      resNE = norms / norms0;
      if prnt, disp( sprintf(form, k,x(1),x(n),normx,resNE) ); end
   end %while

shrink = normx/xmax;
if     k == kmax,       info = 2; end
if    indefinite,       info = 3; end
if shrink <= sqrt(tol), info = 4; end
return;
