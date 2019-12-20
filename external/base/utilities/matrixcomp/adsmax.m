function [x, fmax, nf] = adsmax(f, x, stopit, savit, P, varargin)
%ADSMAX  Alternating directions method for direct search optimization.
%        [x, fmax, nf] = ADSMAX(FUN, x0, STOPIT, SAVIT, P) attempts to
%        maximize the function FUN, using the starting vector x0.
%        The alternating directions direct search method is used.
%        Output arguments:
%               x    = vector yielding largest function value found,
%               fmax = function value at x,
%               nf   = number of function evaluations.
%        The iteration is terminated when either
%               - the relative increase in function value between successive
%                 iterations is <= STOPIT(1) (default 1e-3),
%               - STOPIT(2) function evaluations have been performed
%                 (default inf, i.e., no limit), or
%               - a function value equals or exceeds STOPIT(3)
%                 (default inf, i.e., no test on function values).
%        Progress of the iteration is not shown if STOPIT(5) = 0 (default 1).
%        If a non-empty fourth parameter string SAVIT is present, then
%        `SAVE SAVIT x fmax nf' is executed after each inner iteration.
%        By default, the search directions are the co-ordinate directions.
%        The columns of a fifth parameter matrix P specify alternative search
%        directions (P = EYE is the default).
%        NB: x0 can be a matrix.  In the output argument, in SAVIT saves,
%            and in function calls, x has the same shape as x0.
%        ADSMAX(fun, x0, STOPIT, SAVIT, P, P1, P2,...) allows additional
%        arguments to be passed to fun, via feval(fun,x,P1,P2,...).

%     Reference:
%     N. J. Higham, Optimization by direct search in matrix computations,
%        SIAM J. Matrix Anal. Appl, 14(2): 317-333, 1993.
%     N. J. Higham, Accuracy and Stability of Numerical Algorithms,
%        Second edition, Society for Industrial and Applied Mathematics,
%        Philadelphia, PA, 2002; sec. 20.5.

x0 = x(:);  % Work with column vector internally.
n = length(x0);

mu = 1e-4;  % Initial percentage change in components.
nstep = 25; % Max number of times to double or decrease h.

% Set up convergence parameters.
if nargin < 3 | isempty(stopit), stopit(1) = 1e-3; end
tol = stopit(1); % Required rel. increase in function value over one iteration.
if length(stopit) == 1, stopit(2) = inf; end  % Max no. of f-evaluations.
if length(stopit) == 2, stopit(3) = inf; end  % Default target for f-values.
if length(stopit) <  5, stopit(5) = 1; end    % Default: show progress.
trace  = stopit(5);
if nargin < 4, savit = []; end                   % File name for snapshots.

if nargin < 5 | isempty(P)
   P = eye(n);             % Matrix of search directions.
else
   if ~isequal(size(P),[n n])  % Check for common error.
      error('P must be of dimension the number of elements in x0.')
   end
end

fmax = feval(f,x,varargin{:}); nf = 1;
if trace, fprintf('f(x0) = %9.4e\n', fmax), end

steps = zeros(n,1);
it = 0; y = x0;

while 1    % Outer loop.
it = it+1;
if trace, fprintf('Iter %2.0f  (nf = %2.0f)\n', it, nf), end
fmax_old = fmax;

for i=1:n  % Loop over search directions.

    pi = P(:,i);
    flast = fmax;
    yi = y;
    h = sign(pi'*yi)*norm(pi.*yi)*mu;   % Initial step size.
    if h == 0, h = max(norm(yi,inf),1)*mu; end
    y = yi + h*pi;
    x(:) = y; fnew = feval(f,x,varargin{:}); nf = nf + 1;
    if fnew > fmax
       fmax = fnew;
       if fmax >= stopit(3)
           if trace
              fprintf('Comp. = %2.0f,  steps = %2.0f,  f = %9.4e*\n', i,0,fmax)
              fprintf('Exceeded target...quitting\n')
           end
           x(:) = y; return
       end
       h = 2*h; lim = nstep; k = 1;
    else
       h = -h; lim = nstep+1; k = 0;
    end

    for j=1:lim
        y = yi + h*pi;
        x(:) = y; fnew = feval(f,x,varargin{:}); nf = nf + 1;
        if fnew <= fmax, break, end
        fmax = fnew; k = k + 1;
        if fmax >= stopit(3)
           if trace
              fprintf('Comp. = %2.0f,  steps = %2.0f,  f = %9.4e*\n', i,j,fmax)
              fprintf('Exceeded target...quitting\n')
           end
           x(:) = y; return
        end
        h = 2*h;
   end

   steps(i) = k;
   y = yi + 0.5*h*pi;
   if k == 0, y = yi; end

   if trace
      fprintf('Comp. = %2.0f,  steps = %2.0f,  f = %9.4e', i, k, fmax)
      fprintf('  (%2.1f%%)\n', 100*(fmax-flast)/(abs(flast)+eps))
   end


   if nf >= stopit(2)
      if trace
         fprintf('Max no. of function evaluations exceeded...quitting\n')
      end
      x(:) = y; return
   end

   if fmax > flast & ~isempty(savit)
      x(:) = y;
      eval(['save ' savit ' x fmax nf'])
   end

end  % Loop over search directions.

if isequal(steps,zeros(n,1))
   if trace, fprintf('Stagnated...quitting\n'), end
   x(:) = y; return
end

if fmax-fmax_old <= tol*abs(fmax_old)
   if trace, fprintf('Function values ''converged''...quitting\n'), end
   x(:) = y; return
end

end %%%%%% Of outer loop.
