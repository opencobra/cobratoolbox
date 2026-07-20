function [x, info] = lewisCenter(f, x, opts)
% Compute the Lewis-weight center of the domain {Ax = b} intersected with the domain of f
%
% USAGE:
%
%    [x, info] = lewisCenter(f, x, opts)
%
% INPUTS:
%    f:          a `ConvexProgram` object describing the feasible domain, with fields:
%
%                  * .A - constraint matrix of the equality system `A x = b`
%                  * .b - right-hand side of the equality system `A x = b`
%                  * .solver - linear-system solver object (factorize/solve/leverageScore)
%                  * .feasible - logical flag, set false on numerical failure
%                  * .barrier - self-concordant barrier for the domain
%                  * .c - linear objective coefficient vector (may be empty)
%                  * .df - handle to the gradient of the nonlinear objective (may be empty)
%                  * .scale - scaling applied to the exported gradient of the objective
%                  * .idx - index mapping into the exported (original) space
%                  * .scale2 - scaling applied to the exported Hessian of the objective
%    x:          a feasible initial point (required)
%
% OPTIONAL INPUTS:
%    opts:       structure of options with fields:
%
%                  * .MaxIter - maximum number of iterations
%                  * .Output - handle used to print progress (e.g. `@disp`)
%                  * .CentralityTol - centrality stopping tolerance on the scaled residual
%                  * .FeasibilityTol - feasibility stopping tolerance on `||A x - b||_inf`
%                  * .JLDim - number of dimensions used to estimate the leverage score
%                  * .p - exponent parameter for the lp Lewis weight
%
% OUTPUTS:
%    x:          the Lewis-weight center of `f`, or empty on numerical failure
%    info:       structure with fields centrality, feasibility, iter and hess

defaultOpts = struct('MaxIter', 100, 'Output', @disp, 'CentralityTol', 0.1, 'FeasibilityTol', 1e-12, 'JLDim', 10, 'p', 4);
if nargin >= 3
   opts = setField(defaultOpts, opts);
else
   opts = defaultOpts;
end
x = ddouble(x);

%% prepare the printout
output = TableDisplay('Iter', '5i', 'PredStep', '13.2e', 'CorrStep', '13.2e', 'Centrality', '13.2e', 'Feasibility', '13.2e');
output.output = opts.Output;
output.header();

%% initial parameters
assert(nargin >= 2 && all(f.distance(x) > 0), 'a feasible inital point is required.');

A = f.A; At = A'; b = f.b;
y = 0*b;
lastProgress = 0; % record the last iteration making progress
bestCentrality = 1e32;
d = size(f.A, 1); n = size(f.A, 2);
w = (n-d)/n * ones(n, 1);

%% find the central path
[rs, rx, h] = updateResidual(x, y, w);

for iter = 1:opts.MaxIter
   % Compute the cholesky decomposition
   cholErr = f.solver.factorize(1./h);
   w_new = max(double(1-f.solver.leverageScore(opts.JLDim)), 0);
   w = (w + w_new)/2;
   
   % Compute the direction
   if (cholErr < f.solver.cholTol)
      v = f.solver.solve([A*(rs./h) rx]); %rs = A^T y - g; %rx = Ax - b;
      Atv = At * v;
      y = y - v(:,1);
      
      % y = y - (R\(R'\(A*(rs./hess))))
      % dx = (rs + At * (R\(R'\(rx - A*(rs./hess)))))./hess;

      dx = (rs - Atv(:,1))./h - Atv(:,2)./h;
      t = stepSize(x, dx, 0.95); % 0.95*(distance from x to the closest boundart in direction dx)
      x = x + t * dx; % move in direction dx with distance of t (measured in dx)
      
      [rs, rx, h] = updateResidual(x, y, w);
      
      centrality = max(abs(rs./sqrt(h))); %||(A^T y - grad \phi)/sqrt(h)||_Inf
      feasibility = max(abs(rx)); %||Ax-b||_Inf
      if isempty(feasibility), feasibility = 0; end % Fix the case rx is []
      
      % Output the error
      o = struct('Iter', iter, 'PredStep', t, 'CorrStep', t, 'Centrality', centrality, 'Feasibility', feasibility);
      output.row(o);
      
      if (centrality < 0.9 * bestCentrality)
         bestCentrality = centrality;
         lastProgress = iter;
      end
      
      % Check stop criteria
      if centrality < opts.CentralityTol && feasibility < opts.FeasibilityTol
         break;
      end
   end
   
   if (iter > lastProgress + 10)
      break;
   end
   
   if (cholErr >= f.solver.cholTol)
      opts.Output('Failed due to numerical issue.');
      f.feasible = false;
      x = []; info = [];
      return;
   end
end

info = struct('centrality', centrality, 'feasibility', feasibility, 'iter', iter, 'hess', h);

function t = stepSize(x, dx, factor)
   t = min(double(factor*min(f.barrier.distance(x, dx))),1); % min(Nan,1) = 1 for double
end

function [rs, rx, h, wp] = updateResidual(x, y, w)
   wp = w.^(1-2/opts.p);
   
   [gb, hb] = f.barrier.derivatives(x); % obtain gradient and hessian of log-barrier ftn \phi(x) = -\sum log(x-l) -\sum log(u-x)
   % hp = diagonals of hessian matrix of log-barrier
   
   gb = gb.*wp;
   hb = hb.*wp;
   
   gc = zeros(size(gb), class(gb));
   hc = zeros(size(hb), class(hb));

   % Below if-end is skipped while running f.normalize() in sample.m (due to c=[])
   if ~isempty(f.c)
      gc = gc + f.c;
   end

   % Below if-end is skipped while running f.normalize() in sample.m (due to df=[])
   if ~isempty(f.df)
      gc_ = f.df(f.export(x));
      gc = gc + f.scale .* gc_(f.idx);

      hc_ = f.ddf(f.export(x));
      hc = hc + f.scale2 .* hc_(f.idx);
   end
   
   % Thus, g=gb and h=hb in f.normalize() 
   g = gb + gc; h = hb + hc;
   
   rs = At * y - g;
   rx = A * x - b;
end

end
