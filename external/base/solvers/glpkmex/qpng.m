% Quadratic programming solver using a null-space active-set method.
% 
% [x, obj, lambda, info] = qpng (H, q, A, b, ctype, lb, ub, x0)
%
% Solve the general quadratic program
%
%      min 0.5 x'*H*x + q'*x
%       x
%
% subject to
%      A*x [ "=" | "<=" | ">=" ] b
%      lb <= x <= ub
%
% and given x0 as initial guess.
% 
% ctype = An array of characters containing the sense of each constraint in the
%         constraint matrix.  Each element of the array may be one of the
%         following values
%           'U' Variable with upper bound ( A(i,:)*x <= b(i) ).
%           'E' Fixed Variable ( A(i,:)*x = b(i) ).
%           'L' Variable with lower bound ( A(i,:)*x >= b(i) ).
%
% status = an integer indicating the status of the solution, as follows:
%        0 The problem is infeasible.
%        1 The problem is feasible and convex.  Global solution found.
%        2 Max number of iterations reached no feasible solution found.
%        3 Max number of iterations reached but a feasible solution found.
%
% If only 4 arguments are provided the following QP problem is solved:
%
% min_x .5 x'*H*x+x'*q   s.t. A*x <= b 
%
% Any bound (ctype, lb, ub, x0) may be set to the empty matrix [] 
% if not present.  If the initial guess is feasible the algorithm is faster.
%
% See also: glpk.
%
% Copyright 2006-2007 Nicolo Giorgetti.

% This file is part of GLPKMEX.
%
% GLPKMEX is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2, or (at your option)
% any later version.
%
% GLPKMEX is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with GLPKMEX; see the file COPYING.  If not, write to the Free
% Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
% 02110-1301, USA.

function varargout = qpng (varargin)

% Inputs
H=[];
q=[];
A=[];
b=[];
lb=[];
ub=[];
x0=[];
ctype=[];

% Outputs
x=[];
obj=[];
lambda=[];
info=[];

if nargin < 1
   disp('Quadratic programming solver using null-space active set method.');
   disp('(C) 2006-2007, Nicolo Giorgetti. Version 1.0');
   disp(' ');
   disp('Syntax: [x, obj, lambda, info] = qpng (H, q, A, b, ctype, lb, ub, x0)');
   return;
end
if nargin<4
   error('At least 4 argument are necessary');
else
   H=varargin{1};
   q=varargin{2};
   A=varargin{3};
   b=varargin{4};
end
if nargin>=5
   ctype=varargin{5};
end
if nargin>=7
   lb=varargin{6};
   ub=varargin{7};
end
if nargin>=8
   x0=varargin{8};   
end
if nargin>8
   warning('qpng: Arguments more the 8th are omitted');
end
   
% Checking the quadratic penalty
[n,m] = size(H);
if n ~= m
   error('qpng: Quadratic penalty matrix not square');
end

if H ~= H'
   warning('qpng: Quadratic penalty matrix not symmetric');
   H = (H + H')/2;
end

% Linear penalty.
if isempty(q)
   q=zeros(n,1);
else
   if length(q) ~= n
      error('qpng: The linear term has incorrect length');
   end
end

% Constraint matrices
if (isempty(A) || isempty(b))
   error('qpng: Constraint matrices cannot be empty');
end
[nn, n1] = size(A);
if n1 ~= n
   error('qpng: Constraint matrix has incorrect column dimension');
end
if length (b) ~= nn
   error ('qpng: Equality constraint matrix and vector have inconsistent dimension');
end

Aeq=[];
beq=[];
Ain=[];
bin=[];

if nargin <= 4
   Ain=A;
   bin=b;
end

if ~isempty(ctype)
   if length(ctype) ~= nn
       tmp=sprintf('qpng: ctype must be a char valued vector of length %d', nn);
       error(tmp);
   end
   indE=find(ctype=='E');
   Aeq=A(indE,:);
   beq=b(indE,:);   
   
   indU=find(ctype=='U');
   Ain=A(indU,:);
   bin=b(indU,:);
   indL=find(ctype=='L');
   Ain=[Ain; -A(indL,:)];
   bin=[bin; -b(indL,:)];     
end

if ~isempty(lb)
   if length(lb) ~= n
	  error('qpng: Lower bound has incorrect length');
	else
	  Ain = [Ain; -eye(n)];
	  bin = [bin; -lb];
   end
end

if ~isempty(ub)
   if length(ub) ~= n
	  error('qpng: Upper bound has incorrect length');
	else
	  Ain = [Ain; eye(n)];
	  bin = [bin; ub];
   end
end

% Discard inequality constraints that have -Inf bounds since those
% will never be active.
idx = isinf(bin) &  (bin > 0);
bin(idx) = [];
Ain(idx,:) = [];

% Now we should have the following QP:
%
%   min_x  0.5*x'*H*x + q'*x
%   s.t.   A*x = b
%          Ain*x <= bin

% Checking the initial guess (if empty it is resized to the
% right dimension and filled with 0)
if isempty(x0)
   x0 = zeros(n, 1);
elseif length(x0) ~= n
   error('qpng: The initial guess has incorrect length');
end

% Check if the initial guess is feasible.
rtol = sqrt (eps);

n_eq=size(Aeq,1);
n_in=size(Ain,1);

eq_infeasible=0;
in_infeasible=0;

if n_eq>0
   eq_infeasible = (norm(Aeq*x0-beq) > rtol*(1+norm(beq)));
end
if n_in>0
   in_infeasible = any(Ain*x0-bin > 0);
end

status = 1;

% if (eq_infeasible | in_infeasible)
%    % The initial guess is not feasible. Find one by solving an LP problem.
%    % This function has to be improved by moving in the null space.
%    Atmp=[Aeq; Ain];
%    btmp=[beq; bin];
%    ctmp=zeros(size(Atmp,2),1);
%    ctype=char(['S'*ones(1,n_eq), 'U'*ones(1,n_in)]');
%    [P, dummy, stat] = glpk (ctmp, Atmp, btmp, [], [], ctype);
% 
%    if  (stat == 180 | stat == 181 | stat == 151)
%       x0=P;
%    else
%       % The problem is infeasible
%       status = 0;
%    end
%   
% end

if (eq_infeasible | in_infeasible)
   % The initial guess is not feasible.
   % First define xbar that is feasible with respect to the equality
   % constraints.
   if (eq_infeasible)
      if (rank(Aeq) < n_eq)
         error('qpng: Equality constraint matrix must be full row rank')
      end
      xbar = pinv(Aeq) * beq;
   else
      xbar = x0;
   end

   % Check if xbar is feasible with respect to the inequality
   % constraints also.
   if (n_in > 0)
      res = Ain * xbar - bin;
      if any(res > 0)
         % xbar is not feasible with respect to the inequality
         % constraints.  Compute a step in the null space of the
         % equality constraints, by solving a QP.  If the slack is
         % small, we have a feasible initial guess.  Otherwise, the
         % problem is infeasible.
         if (n_eq > 0)
            Z = null(Aeq);
            if (isempty(Z))
               % The problem is infeasible because A is square and full
               % rank, but xbar is not feasible.
               info = 0;
            end
         end

         if info
            % Solve an LP with additional slack variables to find
            % a feasible starting point.
            gamma = eye(n_in);
            if (n_eq > 0)
               Atmp = [Ain*Z, gamma];
               btmp = -res;
            else
               Atmp = [Ain, gamma];
               btmp = bin;
            end
            ctmp = [zeros(n-n_eq, 1); ones(n_in, 1)];
            lb = [-Inf*ones(n-n_eq,1); zeros(n_in,1)];
            ub = [];
            ctype = repmat ('L', n_in, 1);
            [P, dummy, status] = glpk (ctmp, Atmp, btmp, lb, ub, ctype);

            if ((status == 180 | status == 181 | status == 151) & all (abs (P(n-n_eq+1:end)) < rtol * (1 + norm (btmp))))
               % We found a feasible starting point
               if (n_eq > 0)
                  x0 = xbar + Z*P(1:n-n_eq);
               else
                  x0 = P(1:n);
               end
            else
               % The problem is infeasible
               info = 0;
            end
         end
      else
         % xbar is feasible.  We use it a starting point.
         x0 = xbar;
      end
   else
      % xbar is feasible.  We use it a starting point.
      x0 = xbar;
   end
end


if status
   % The initial (or computed) guess is feasible.
   % We call the solver.
   t=cputime;
   [x, lambda, iter, status]=qpsolng(H, q, Aeq, beq, Ain, bin, x0);
   time=cputime-t;
else
   iter = 0;
   x = x0;
   lambda = [];
   time=0;
end

varargout{1}= x;
varargout{2}= 0.5 * x' * H * x + q' * x; %obj
varargout{3}= lambda;

info=struct('status', status, 'solveiter', iter, 'time', time);
varargout{4}=info;


 

