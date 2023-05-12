function [x, info] = analyticCenter(f, x, opts)
% x = analyticCenter(f, opts, x)
% compute the analytic center for the domain {Ax=b} intersect the domain of f
% 
% Input:
%    f - a ConvexProgram
%    x - a feasible initial point (optional)
%    opts - a structure for options with the following properties (optional)
%       MaxIter - maximum number of iterations
%       Output - maximum number of iterations
%       CentralityTol, FeasibilityTol - stop the following are satisfied
%           ||(A' * lambda - grad f(x)) / sqrt(hess)||_inf < CentralityTol
%           ||A x - b||_inf < FeasibilityTol
%       CollapseDistanceTol - 
%           if x_i is CollapseDistanceTol close to some boundary,
%           we assume the block i is tight.
%       SolverIter - the number of iteration in solving linear systems
%       VectorType - the class we use for x (@double, @ddouble, @qdouble)
% 
% Output:
%  x - It outputs the analytic center of f
%  info - a structure containing centrality, feasibility and iter.
%  f - the problem f will be modified as we discover collapsed subspace

defaultOpts = struct('MaxIter', 1000, 'Output', @disp, 'CentralityTol', 1e-8, 'FeasibilityTol', 1e-12, ...
            'CollapseDistanceTol', 1e-8, 'SolverIter', 3, 'VectorType', @ddouble);
if nargin >= 3
   opts = setField(defaultOpts, opts);
else
   opts = defaultOpts;
end

if f.feasible == false
   x = []; info = [];
   return;
end

%% prepare the printout
output = TableDisplay('Iter', '5i', 'PredStep', '13.2e', 'CorrStep', '13.2e', 'Centrality', '13.2e', 'Feasibility', '13.2e', 'mu', '13.2e');
output.output = opts.Output;
output.header();

%% initial parameters
f.removeRedundantRows();
if nargin <= 1 || isempty(x) || any(f.distance(x) <= 0)
   % a heuristic initial point 
   f.solver.factorize(ones(size(f.A,2),1));
   v = f.A' * f.solver.solve(f.b);
   x = f.barrier.center;
   t = stepSize(x, v-x, 0.95);
   x = x + t * (v-x);
end

A = f.A; At = A'; b = f.b; rx = [];
x = opts.VectorType(x);
y = 0*b;
feasibilityMode = true;
mu = 0;
lastProgress = 0; % record the last iteration making progress
bestCentrality = 1e32; bestFeasibility = 1e32;

%% find the central path
for iter = 1:opts.MaxIter
   % Compute the residual
   if (isempty(rx))
      [rs, rx, h] = updateResidual(x, y, mu);
   end
   
   % Compute the cholesky decomposition
   cholErr = f.solver.factorize(1./h);
   
   % Compute the direction
   if (cholErr < f.solver.cholTol)
      v = f.solver.solve([A*(rs./h) rx], [], opts.SolverIter);
      Atv = At * v;
      y = y - v(:,1);
      
      if (feasibilityMode)
         % corr_dx = (rs - At * (R\(R'\(A*(rs./hess)))))./hess;
         % pred_dx = (At * (R\(R'\rx)))./hess;
         
         corr_dx = (rs - Atv(:,1))./h;
         pred_dx = -Atv(:,2)./h;
         
         pred_t = stepSize(x, pred_dx, 1.0);
         dx = corr_dx + pred_t * pred_dx;
         t = stepSize(x, dx, 0.95);
         x = x + t * dx;
      else
         % y = y - (R\(R'\(A*(rs./hess))))
         % dx = (rs + At * (R\(R'\(rx - A*(rs./hess)))))./hess;
         
         pred_t = 1.0;
         dx = (rs - Atv(:,1))./h - Atv(:,2)./h;
         t = stepSize(x, dx, 0.95);
         x = x + t * dx;
      end
      
      [rs, rx, h] = updateResidual(x, y, mu);
      
      centrality = max(abs(rs./sqrt(h)));
      feasibility = max(abs(rx));
      if isempty(feasibility), feasibility = 0; end % Fix the case rx is []
      
      % Output the error
      o = struct('Iter', iter, 'PredStep', t * pred_t, 'CorrStep', t, 'Centrality', centrality, 'Feasibility', feasibility, 'mu', mu);
      output.row(o);
      
      if (centrality < 0.9 * bestCentrality)
         bestCentrality = centrality;
         if ~feasibilityMode, lastProgress = iter; end
      end
      
      if (feasibility < 0.9 * bestFeasibility)
         bestFeasibility = feasibility;
         if feasibilityMode, lastProgress = iter; end
      end
      
      % Check stop criteria
      if centrality < opts.CentralityTol && feasibility < opts.FeasibilityTol
         if feasibilityMode && (~isempty(f.c) || ~isempty(f.df))
            feasibilityMode = false;
            mu = 1;
            [rs, rx, h] = updateResidual(x, y, mu);
            opts.Output('Switch to optimize mode.');
            
            bestCentrality = 1e32; bestFeasibility = 1e32;
         else
            break;
         end
      end
   end
   
   % Perform the collpase if needed
   dist = f.distance(x);
   if any(dist < opts.CollapseDistanceTol / 10)
      blocks = find(dist < opts.CollapseDistanceTol);

      % Update barrier
      block_idx = f.collapse(x, blocks);
      
      % check feasibility after collapsing
      if f.feasible == false
         x = []; info = [];
         opts.Output('The problem is infeasible.');
         return;
      end

      % Update other variables
      A = f.A; At = A'; b = f.b;
      x(block_idx) = [];
      y = 0*b;
      rx = [];
      
      lastProgress = iter;
      bestCentrality = 1e32; bestFeasibility = 1e32;
      opts.Output(sprintf('Collapsed %i blocks.', length(blocks)));
      continue;
   end
   
   if (cholErr >= f.solver.cholTol)
      opts.Output('Failed due to numerical issue.');
      f.feasible = false;
      x = []; info = [];
      return;
   end
   
   if (iter > lastProgress + 20)
      opts.Output('Stopped due to no progress.');
      break;
   end
end
x = double(x);
info = struct('centrality', centrality, 'feasibility', feasibility, 'iter', iter, 'hess', h);

function t = stepSize(x, dx, factor)
   t = min(double(factor*min(f.barrier.distance(x, dx))),1); % min(Nan,1) = 1 for double
end

function [rs, rx, h] = updateResidual(x, y, mu)
   [gb, hb] = f.barrier.derivatives(x);

   gc = zeros(size(gb), class(gb));
   hc = zeros(size(hb), class(hb));

   if ~isempty(f.c)
      gc = gc + f.c;
   end

   if ~isempty(f.df)
      gc_ = f.df(f.export(x));
      gc = gc + f.scale .* gc_(f.idx);

      hc_ = f.ddf(f.export(x));
      hc = hc + f.scale2 .* hc_(f.idx);
   end
   
   g = gb + mu * gc; h = hb + mu * hc;
   
   rs = At * y - g;
   rx = A * x - b;
end

end
