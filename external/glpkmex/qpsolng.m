%  Core QP Solver. Use qpng.m instead.
%
% This routine solves the following optimization problem:
%
% min_x .5x' H x + q' x
% s.t.  Aeq x =  beq
%       Ain x <= bin
%
% note that x0 is a feasible starting point.
%
% (C) Nicolo Giorgetti, 2006.
function [x, lam, k, status]=qpsolng(H, q, Aeq, beq, Ain, bin, x0)

nmax=200; % max number of iterations
tol=1e-6; % tolerance

neq=length(beq); % number of eqs
nin=length(bin); % number of ineqs

x=x0;
n=size(x);
Wact=[];
nact=0; % number of rows in Wact (only active inequalities)

status=1; % problem feasible
lam=zeros(neq+nin,1);
k=[];

for k=1:nmax
   % Construct KKT
   K=H;
   r=-q-H*x;
   if neq > 0
      % Add equality constraints
      A=Aeq;
   end
   if nin > 0
      % Add active inequality constraints
      for j=1:nact
         i=Wact(j);
         if j+neq==1
            A=Ain(i,:);
         else
            A=[A; Ain(i,:)];
         end
      end
   end
   nneq=neq+nact;
   if nneq>0
      K=[K, A'; A, zeros(nneq,nneq)];
      r=[r; zeros(nneq,1)];
   end
   
   y=K\r; %%%%%%%% Check this: we should use pinv instead. Possible numerical problems
   p=y(1:n);
     
   if norm(p)<tol
      % check optimality or add to work set
      if nact==0
         x=x+p;
         status=1;
         return % successfully
      else
         lam=y(n+neq+1:n+neq+nact);
         [lmin,arg]=min(lam);
         if lmin >= 0
            x=x+p;
            status=1;
            return; % successfully
         else
            % remove constraints from W
            nact=nact-1;
            for j=arg:nact
               Wact(j)=Wact(j+1);
            end
         end
      end
   else % x is not the minimizer in W
      count=nin+1;
      val(1:count)=1.1;
      for j=1:nin
         if Ain(j,1:n)*p > max(tol^2,1e-15)
            val(j)=(bin(j)-Ain(j,1:n)*x)/(Ain(j,1:n)*p);
         end
      end
      val(count)=1;
      
      [alpha,ind]=min(val); % this is the allowed step size
      
      x=x+alpha*p;
      
      if ind < count % there are blocking constraints, add one to W
         nact=nact+1;
         Wact(nact)=ind;
      end
   end
end

eq_infeas=0;
in_infeas=0;

if neq>0
   eq_infeas = (norm(Aeq*x-beq) > rtol*(1+norm(beq)));
end
if nin>0
   in_infeas = (any(Ain*x-bin > -rtol*(1+norm(bin))));
end

if eq_infeas | in_infeas
   status=2; % Max iterations reached, no solution found.
else
   status=3; % Max iterations reached but a feasible solution found.
end

return;