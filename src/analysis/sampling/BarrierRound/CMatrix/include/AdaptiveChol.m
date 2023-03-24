classdef AdaptiveChol < handle
   properties (Constant)
      mex = AdaptiveChol.mexSelector();
   end
   
   methods (Static)
      function func = mexSelector()
         if isarm()
            func = @AdaptiveCholArmMex;
         else
            func = @AdaptiveCholMex;
         end
      end
   end
   
   properties
      % the constraint matrix
      A
      w = NaN
      cholTol = 1e-4
      
      % private
      uid
      lastChol = 0; % 1 = double, 2 = ddouble, 3 = qdouble
   end
   
   methods (Static)
      function o = loadobj(s)
         s.uid = AdaptiveChol.mex('new', uint64(randi(2^32-1,'uint32')), s.A);
         if ~any(isnan(s.w))
            w = s.w; s.w = NaN;
            s.factorize(w);
         end
         o = s;
      end
   end
   
   methods
      function o = AdaptiveChol(A, cholTol)
         if nargin <= 1, cholTol = 1e-4; end;
         
         o.A = A;
         o.cholTol = cholTol;
         if isobject(A), A = A.x; end
         o.uid = AdaptiveChol.mex('new', uint64(randi(2^32-1,'uint32')), A);
      end
      
      function b = saveobj(a)
         b = a;
         b.uid = [];
      end
      
      function delete(o)
         if ~isempty(o.uid)
            AdaptiveChol.mex('delete', o.uid);
         end
      end
      
      function err = factorize(o, w, offset)
         if nargin <= 2, offset = 0.0; end
         if isvector(w), w = diag(sparse(w)); end
         
         o.w = w;
         err = +Inf;
         
         okay = AdaptiveChol.mex('factorize', o.uid, double(w), offset);
         o.lastChol = 1;
         if okay, err = o.cholAccuracy(); end
         if err < o.cholTol, return; end
         
         okay = AdaptiveChol.mex('factorize', o.uid, ddouble.toMex(w), offset);
         o.lastChol = 2;
         if okay, err = o.cholAccuracy(); end
         if err < o.cholTol, return; end
         
         okay = AdaptiveChol.mex('factorize', o.uid, qdouble.toMex(w), offset);
         o.lastChol = 3;
         if okay
            err = o.cholAccuracy();
         else
            err = +Inf;
         end
      end
      
      function ls = leverageScore(o, JLDim)
         % Warning: This compute (W A' (AWA')^-1 A)_ii
         % This is not exactly leverageScore unless W is diagonal.
         
         % tau = A' L^{-1} zeta
         tau = AdaptiveChol.mex('halfProj', o.uid, JLDim);
         if (o.lastChol == 2)
            tau = ddouble(tau);
         elseif (o.lastChol == 3)
            tau = qdouble(tau);
         end
         
         % ls = avg_j (W tau_j)_i (tau_j)_i
         ls = sum((o.w * tau) .* tau,2) / JLDim;
      end
      
      function err = cholAccuracy(o)
         err = abs(sum(o.leverageScore(1)) - size(o.A, 1));
      end
      
      function r = diagonal(o)
         assert(o.lastChol, 'factorize must be called before diagonal.');
         
         r = AdaptiveChol.mex('diagonal', o.uid);
         
         if (o.lastChol == 2)
            r = ddouble(r);
         elseif (o.lastChol == 3)
            r = qdouble(r);
         end
      end
      
      function y = solve(o, b, w, iter)
         assert(logical(o.lastChol), 'factorize must be called before solve.');
         assert(nargin >= 2);
         if nargin <= 2 || isempty(w), w = o.w; end
         if nargin <= 3, iter = 3; end
         
         className = class(b);
         if issparse(b), b = full(b); end
         if isobject(b), b = b.x; end
         if isobject(w), w = w.x; end
         
         y = AdaptiveChol.mex('solve', o.uid, b, w, iter);
         
         if (strcmp(className, 'ddouble')) %#ok<*STISA>
            y = ddouble(y);
         elseif (strcmp(className, 'qdouble'))
            y = qdouble(y);
         end
      end
      
      
   end
end