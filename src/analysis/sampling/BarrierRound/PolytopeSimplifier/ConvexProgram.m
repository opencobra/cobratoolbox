classdef ConvexProgram < handle
   % Convex Program is given by 
   % min <c,x> + sum f_i(x_i) subject Ax = b, x_i in K_i
   % given that such block K_i is a *strictly* convex set
   
   % The objective is given by
   % phi(x) + <c,x> + sum f_i(x_i)
   
   properties (SetAccess = private)
      A        % constraint matrix A
      b        % constraint vector b
      c        % cost vector c
      df       % first derivative of cost function
      ddf      % second derivative of cost function
      barrier	% barrier for prod K_i
      interior = []; % some interior point we found
      feasible = []; % indicate if the domain is empty, [] means not determined
      
      % We represent any z in the domain implicitly by x as follows:
      % z = x0;
      % z(idx) += scale.*x;
      x0       % values on the original coordinate system
      idx      % original coordinates that x supported on
      scale    % scale of x.
      scale2   % scale.^2
      
      % Linear system solver used to solve (A W A')^-1
      solver = [];
      choleskyTol = 1e-4;
   end
   
   methods (Static)
      function o = LinearProgram(Aeq, beq, c, lb, ub)
         % o = LinearProgram(Aeq, beq, c, lb, ub)
         % Output a ConvexProgram representing the linear program
         % min <c,x> subject Aeq x = beq, lb <= x <= ub
         
         fixed_coords = find(ub == lb);
         barrier = TwoSidedBarrier(lb, ub);
         o = ConvexProgram(Aeq, beq, c, [], [], barrier);
         [~, okay] = o.collapse(lb, fixed_coords);
         if (~okay)
            o.feasible = false;
         end
      end
   end
   
   methods
      function o = ConvexProgram(Aeq, beq, c, df, ddf, barrier)
         % o = ConvexProgram(Aeq, beq, c, df, ddf, barrier)
         % Output a ConvexProgram representing the linear program
         % min <c,x> + sum f_i(x_i) subject Aeq x = beq, barrier(x) < inf
         
         o.A = Aeq;
         o.b = beq;
         o.c = c;
         o.df = df;
         o.ddf = ddf;
         o.barrier = barrier;
         
         o.x0 = zeros([size(Aeq,2) 1], class(Aeq));
         o.idx = (1:size(Aeq,2))';
         o.scale = ones([size(Aeq,2) 1], class(Aeq));
         o.scale2 = o.scale;
         
         o.rowReorder();
         o.rescale();
         o.solver = AdaptiveChol(o.A, o.choleskyTol);
      end
      
      function setCholeskyTol(o, value)
         o.choleskyTol = value;
         o.solver = AdaptiveChol(o.A, o.choleskyTol);
      end
      
      function t = distance(o, x, v)
         % t = o.distance(x)
         % Output the distance of x with its closest boundary for each block
         % Any negative entries implies infeasible
         %
         % t = o.distance(x, v)
         % Output the maximum step from x with direction v for each coordinate
         % (The maximum step may not reach the boundary.)
         
         if nargin == 2
            t = o.barrier.distance(x);
         elseif nargin == 3
            t = o.barrier.distance(x, v);
         end
      end
      
      function [block_idx, okay] = collapse(o, x, blocks)
         % o.collapse(x, blocks)
         % Collapse the domain on the blocks to boundaries closest to x
         % Return okay = 1 if the collapse is successful
         % Return okay = 0 if the rows are not inconsistenc (infeasible).
         
         [block_idx, d] = o.barrier.boundary(x, blocks);
         x_block_idx = o.x0(o.idx(block_idx)) + o.scale(block_idx) .* d;
         
         % update x0 and idx
         o.x0(o.idx(block_idx)) = x_block_idx;
         o.idx(block_idx) = [];
         
         % update A, b and c
         z = zeros(size(x), class(x));
         z(block_idx) = d;
         o.b = double(o.b - o.A * z);
         o.A(:, block_idx) = [];
         if ~isempty(o.c)
            o.c(block_idx) = [];
         end
         o.scale(block_idx) = [];
         o.scale2(block_idx) = [];
         
         % update barrier
         o.barrier.remove(blocks);
         
         % remove redundant rows
         okay = o.removeRedundantRows();
         if ~okay
            o.feasible = false;
         end
         
         if (~isempty(o.solver) && any(size(o.A) ~= size(o.solver.A)))
            o.solver = AdaptiveChol(o.A, o.choleskyTol);
         end
      end
      
      function [x, info] = findInterior(o)
         % x = o.findInterior()
         % Find an interior point of the convex set using analytic center
         % return NaN if the set is empty
         
         opts = struct('Output', @(x) 0);
         [x, info] = analyticCenter(o, [], opts);
         if o.feasible == false
            x = NaN;
            info = NaN;
         else
            if norm(o.A * x - o.b) < 1e-6 && o.barrier.feasible(x)
               o.interior = x;
               o.feasible = true;
               x = double(x);
            else
               x = NaN;
               info = NaN;
            end
         end
      end
      
      function [x, info] = normalize(o)
         % x = o.normalize()
         
         if isempty(o.feasible)
            o.findInterior();
         end
         
         if (o.feasible == true)
            opts = struct('Output', @(x) 0);
            [x, info] = lewisCenter(o, o.interior, opts); 
            h = info.hess;
            x = sqrt(h).*x;
            
            o.A = o.A ./ sqrt(h)';
            o.b = o.b;
            o.interior = x;
            o.barrier.rescale(sqrt(h));
            o.scale = o.scale ./ sqrt(h);
            o.scale2 = o.scale2 ./ (h);
            o.solver = AdaptiveChol(o.A, o.choleskyTol);
            x = double(x);
         else
            x = NaN;
            info = NaN;
         end
      end
      
      function z = export(o, x)
         % z = o.export(x)
         % Output x in the original coordinate system
         
         z = o.x0;
         z(o.idx) = z(o.idx) + o.scale.*x;
      end
      
      function okay = removeRedundantRows(o)
         % o.removeRedundantRows()
         % Remove redundant rows from Ax=b
         % Return 1 if the removal is successful
         % Return 0 if the rows are not inconsistenc (infeasible).
         
         inconsistencyTol = 1e-8;
         
         % Remove zero rows
         zero_rows = full(sum(logical(o.A), 2)) == 0;
         if (norm(o.b(zero_rows)) >= inconsistencyTol)
            okay = false;
            return;
         end
         
         o.A = o.A(~zero_rows,:); o.b = o.b(~zero_rows);
         
         % Remove redundant rows from Ax=b
         Ad = ddouble(o.A);
         R = chol(Ad * Ad' + 1e-24 * speye(size(o.A,1)));
         dR = full(diag(R));
         I = find(dR > 1e-8);
         A_ = Ad(I, :);
         b_ = o.b(I, :);
         
         % check if the redundant rows are consistence
         v = A_' * ((A_*A_')\b_);
         if (norm(Ad*v - o.b) >= inconsistencyTol)
            okay = false;
            return;
         end
         
         o.A = o.A(I, :);
         o.b = o.b(I, :);
         okay = true;
         
         if (~isempty(o.solver) && any(size(o.A) ~= size(o.solver.A)))
            o.solver = AdaptiveChol(o.A, o.choleskyTol);
         end
      end

      function rowReorder(o)
         % o.rowReorder()
         % Reorder rows to speed up sparse cholesky
         
         q = dissect(o.A * o.A');
         o.A = o.A(q,:);
         o.b = o.b(q);
         
         if (~isempty(o.solver))
            o.solver = AdaptiveChol(o.A, o.choleskyTol);
         end
      end
      
      function rescale(o)
         % o.rescale()
         % Rescale rows to improve numerical stability
         
         % Do not rescale if A has zero contraints/variables
         if min(size(o.A)) <= 0, return; end
         
         % Rescale
         abs_A = abs(o.A);
         rscale = ones([1, size(o.A,2)], class(o.A));
         cscale = ones([size(o.A,1), 1], class(o.A));
         
         for t = 1:10
            v = full(max(abs_A, [], 2));
            v(v == 0) = 1;
            v = 1./v;
            abs_A = abs_A .* v;
            cscale = cscale .* v;
            
            v = full(max(abs_A, [], 1));
            v(v == 0) = 1;
            v = 1./v;
            abs_A = abs_A .* v;
            rscale = rscale .* v;
         end
         
         cscale = 2.^round(log2(double(cscale)));
         rscale = 2.^round(log2(double(rscale)))';
         
         o.A = o.A.*cscale;
         o.b = o.b.*cscale;
         
         if ismethod(o.barrier, 'rescale')
            o.A = o.A.*rscale';
            if ~isempty(o.c)
               o.c = o.c.*rscale;
            end
            o.barrier.rescale(1 ./ rscale);
            o.scale = o.scale .* rscale;
            o.scale2 = o.scale2 .* (rscale.*rscale);
         else
            error('unsupported now');
         end
         
         if (~isempty(o.solver) && any(size(o.A) ~= size(o.solver.A)))
            o.solver = AdaptiveChol(o.A, o.choleskyTol);
         end
      end
   end
end