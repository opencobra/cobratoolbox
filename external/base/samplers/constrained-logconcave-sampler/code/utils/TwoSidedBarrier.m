classdef TwoSidedBarrier < handle
% The barrier for the domain {lu <= x <= ub}.
% phi(x) = - sum log(x - lb) - sum log(ub - x)
    properties (SetAccess = private)
        group % group(i) = ID for the barrier cooresponding to the idx
        ub % ub (it becomes +Inf when the constraint is disabled)
        lb % lb (it becomes -Inf when the constraint is disabled)
        ubOrg % original ub
        lbOrg % original lb
        ui % upper only index 
        li % lower only index
        fi % free index
        enabled % enabled(i) = true if the barrier i is enabled
        extraHessian % a vector: the extra diagonal matrix added to the hessian
        center  % a feasible point
        n % number of variables
    end
    
    properties
        extraGrad % a vector function handle: the extra gradient added
        extraHess % a vector function handle: the extra hessian added (on top of extraHessian)
        extraTensor % a vector function handle: the extra tensor added
    end
    
    methods
        function o = TwoSidedBarrier(lb, ub)
            n = length(lb);
            assert(all(size(lb) == [n 1]));
            assert(all(size(ub) == [n 1]));
            assert(all(lb < ub));
            
            o.group = (1:n)';
            o.lb = lb;
            o.ub = ub;
            o.lbOrg = lb;
            o.ubOrg = ub;
            o.ui = find(lb == -Inf);
            o.li = find(ub == Inf);
            o.fi = find((lb == -Inf) & (ub == Inf));
            o.enabled = ones(n,1);
            o.extraHessian = zeros(n,1);
            o.extraGrad = [];
            o.extraHess = [];
            o.extraTensor = [];
            o.n = n;
            
            center = (ub+lb)/2;
            center(o.li) = lb(o.li) + 1e6;
            center(o.ui) = ub(o.ui) - 1e6;
            center(o.fi) = 0;
            o.center = center;
        end
        
        function SetExtraHessian(o, extraHessian)
            o.extraHessian = extraHessian;
        end
        
        function r = Feasible(o, x)
            % r = Feasible(o, x)
            % output if x is feasible
            r = all((x > o.lb) & (x < o.ub));
        end
        
        function t = StepSize(o, x, v)
            % t = StepSize(o, x, v)
            % output the maximum step size from x with direction v
            
            % check positive direction
            pi = v > 0;
            t = min([+Inf;(o.ub(pi) - x(pi))./v(pi)]);
            
            % check positive direction
            ni = v < 0;
            t = min([t;(o.lb(ni) - x(ni))./v(ni)]);
        end
        
        function [A, b] = Boundary(o, x)
            % [A, b] = Boundary(o, x)
            % output the normal at the boundary around x for each barrier
            
            r = o.center;
            
            b = o.ubOrg;
            b(x<r) = -o.lbOrg(x<r);
            
            A = ones(size(x));
            A(x<r) = -A(x<r);
            
            A = spdiag(A);
        end
        
        function DisableVariables(o, groupIds)
            o.lb(groupIds) = -Inf;
            o.ub(groupIds) = Inf;
            o.enabled(groupIds) = 0;
            o.fi = sort([o.fi;find(groupIds)]);
        end
        
        function grad = Gradient(o, x)
            % output the dense vector grad phi(x)
            
            assert(o.Feasible(x));
            
            grad = 1./(o.ub-x) - 1./(x-o.lb);
            grad(o.ui) = 1./(o.ub(o.ui)-x(o.ui));
            grad(o.li) = -1./(x(o.li)-o.lb(o.li));
            grad(o.fi) = 0;
            
            if ~isempty(o.extraGrad)
                grad = grad + o.extraGrad(x);
            end
        end
        
        function d = HessianInternal(o, x)
            d = 1./((x-o.lb).*(x-o.lb)) + 1./((o.ub-x).*(o.ub-x)) + o.extraHessian;
            
            if ~isempty(o.extraHess)
                d = d + o.extraHess(x);
            end
        end
        
        function t = TensorInternal(o, x)
            t = -2*(1./((x-o.lb).*(x-o.lb).*(x-o.lb)) - 1./((o.ub-x).*(o.ub-x).*(o.ub-x)));
            
            if ~isempty(o.extraTensor)
                t = t + o.extraTensor(x);
            end
        end
        
        function g = Hessian(o, x)
            % output the sparse matrix hess phi(x)
            
            d = o.HessianInternal(x);
            g = spdiag(d);
        end
        
        function g = HessianInv(o, x)
            % output the sparse matrix (hess phi(x))^-1
            
            d = o.HessianInternal(x);
            g = spdiag(1./d);
        end
        
        function v = SqrtHessian(o, x)
            % output the sparse matrix (hess phi(x))^(1/2)
            
            d = o.HessianInternal(x);
            v = spdiag(sqrt(d));
        end
        
        function v = SqrtHessianInv(o, x)
            % output the sparse matrix (hess phi(x))^(-1/2)
           
            d = o.HessianInternal(x);
            v = spdiag(1./sqrt(d));
        end
        
        function v = QuadraticFormGradient(o, x, u)
            % v = QuadraticFormGradient(o, x, u)
            % output the dense vector - grad of sum_i u_i^T (hess phi(x)) u_i
            % where each col of u is one vector
            
            t = o.TensorInternal(x);
            v = sum(u.^2,2).*t;
        end
        
        function v = LogDetGradient(o, x) 
            % output the dense vector - gradient of log det (hess phi(x))
            
            d = o.HessianInternal(x);
            t = o.TensorInternal(x);
            v = t./d;
        end
        
        function u = RepVector(o, v)
            u = v;
        end
        
        function v = GradientNorm(o, x)
            v = abs(o.Gradient(x)) .* o.enabled;
        end
        
        function u = HessianNorm(o, x, v)
            d = o.HessianInternal(x);
            u = (v .* v) .* d;
            u = u .* o.enabled;
        end
    end
end