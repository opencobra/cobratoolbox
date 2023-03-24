classdef TwoSidedBarrier < handle
   % The log barrier for the domain {lu <= x <= ub}:
   %    phi(x) = - sum log(x - lb) - sum log(ub - x).
   properties (SetAccess = private)
      ub       % ub
      lb       % lb
      n        % Number of variables
      center   % Some feasible point x
   end
   
   methods
      function o = TwoSidedBarrier(lb, ub)
         % TwoSidedBarrier(lb, ub)
         % Construct a barrier with lower bound lb and upper bound ub.
         
         o.set(lb, ub);
      end
      
      function set(o, lb, ub)
         % o.set(lb, ub)
         % Update the bounds lb and ub.
         
         o.n = length(lb);
         assert(all(size(lb) == [o.n, 1]), 'Incompatible Size.');
         assert(all(size(ub) == [o.n, 1]), 'Incompatible Size.');
         assert(all(lb <= ub), 'Infeasible domain.');
         
         % Unbounded domain would lead to unbounded domain

         
         if (any(lb <= -Inf) || any(ub >= Inf))
            warning('Finite lower and upper bound are required for every constraint. We continue by assuming the set is coordinate-wise bounded by 1e+5.');
            lb = max(lb, -1e+5); 
            ub = min(ub, 1e+5);
         end
         
         o.lb = lb; 
         o.ub = ub;
         c = (o.ub+o.lb)/2;
         o.center = c;
      end
      
      function t = feasible(o, x)
         % t = o.feasible(x)
         % Output if x is feasible
		 
		 t = min(double(o.distance(x))) > 0;
      end
	  
      function t = distance(o, x, v)
         % t = o.distance(x)
         % Output the distance of x with its closest boundary for each coordinate
         % Any negative entries implies infeasible
         %
         % t = o.distance(x, v)
         % Output the maximum step from x with direction v for each coordinate
         if nargin == 2
            t = min(x-o.lb, o.ub-x);
         else
            t = ((o.ub - x).*(v>=0) + (o.lb - x).*(v<0))./v;
         end
      end
      
      function [g, h, t] = derivatives(o, x)
         % [g, h, t] = o.derivatives(x)
         % Output the gradient, Hessian and the third derivative of phi(x).
         
         s1 = 1./(o.ub - x);
         s2 = 1./(x - o.lb);
         
         if nargout >= 1
            g = s1 - s2;
         end
         
         if nargout >= 2
            h = s1 .* s1 + s2 .* s2;
         end
         
         if nargout >= 3
            t = -2*(s1 .* s1 .* s1 - s2 .* s2 .* s2);
         end
      end
      
      function [idx, b] = boundary(o, x, blocks)
         % [idx, b] = o.boundary(x, blocks)
         % Output the boundary value of each block and their cooresponding indices
         
         c = o.center;
         
         b = o.ub;
         b(x<c) = o.lb(x<c);
         
         b = b(blocks);
         idx = blocks;
      end
      
      function remove(o, blocks)
         % o.remove(x, blocks)
         % Remove the blocks from the barrier
         
         o.lb(blocks) = [];
         o.ub(blocks) = [];
         o.center(blocks) = [];
         o.n = o.n - length(blocks);
      end
      
      function rescale(o, scale)
         % o.rescale(scale)
         % Rescale lb = lb .* scale, ub = ub .* scale 
         
         o.lb = o.lb .* scale;
         o.ub = o.ub .* scale;
         o.center = o.center .* scale;
      end
      
      %
      %         function v = quadratic_form_gradient(o, x, u)
      %             % v = o.quadratic_form_gradient(x, u)
      %             % Output the -grad of u' (hess phi(x)) u.
      %
      %             t = o.tensor(x);
      %             v = u.*u.*t;
      %         end
      %
      %         function v = logdet_gradient(o, x)
      %             % v = o.logdet_gradient(x)
      %             % Output the gradient of log det (hess phi(x))
      %             % which is (hess phi(x))^-1 (grad hess phi (x))
      %
      %             d = o.hessian(x);
      %             t = o.tensor(x);
      %             v = t./d;
      % 		end
      %
      %         function u = hessian_norm(o, x, d)
      %             % v = o.hessian_norm(x, d)
      %             % Output d_i (hess phi(x))_ii d_i for each i
      %
      %             h = o.hessian(x);
      %             u = (d .* d) .* h;
      %         end
   end
end