classdef TwoSidedBarrier < handle
    % The log barrier for the domain {lu <= x <= ub}:
    % 	phi(x) = - sum log(x - lb) - sum log(ub - x).
    properties (SetAccess = private)
        ub          % ub
        lb          % lb
        vdim        % Each point is stored along the dimension vdim
        n           % Number of variables
        upperIdx	% Indices that lb == -Inf
        lowerIdx	% Indices that ub == Inf
        freeIdx     % Indices that ub == Inf and lb == -Inf
        center      % Some feasible point x
    end
    
    properties
        extraHessian = 0 % Extra factor added when computing Hessian. Used to handle free constraints.
    end
    
    methods
        function o = TwoSidedBarrier(lb, ub, vdim)
            % o.update(lb, ub)
            % Update the bounds lb and ub.
            
            if nargin < 3, vdim = 1; end
            o.set_bound(lb, ub);
            o.vdim = vdim;
        end
        
        function set_bound(o, lb, ub)
            % o.set_bound(lb, ub)
            % Update the bounds lb and ub.
            
            o.n = length(lb);
            assert(numel(lb) == o.n);
            assert(numel(ub) == o.n);
            assert(all(lb < ub));
            
            o.lb = lb;
            o.ub = ub;
            o.upperIdx = find(o.lb == -Inf);
            o.lowerIdx = find(o.ub == Inf);
            o.freeIdx = find((o.lb == -Inf) & (o.ub == Inf));
            
            c = (o.ub+o.lb)/2;
            c(o.lowerIdx) = o.lb(o.lowerIdx) + 1e6;
            c(o.upperIdx) = o.ub(o.upperIdx) - 1e6;
            c(o.freeIdx) = 0;
            o.center = c;
        end
        
        function set_vdim(o, vdim)
            % o.set_bound(lb, ub)
            % Update the dimension dim.
            
            assert(vdim == 1 || vdim == 2);
            
            o.vdim = vdim;
            if vdim == 1
                o.lb = reshape(o.lb, [o.n, 1]);
                o.ub = reshape(o.ub, [o.n, 1]);
                o.center = reshape(o.center, [o.n, 1]);
            else
                o.lb = reshape(o.lb, [1, o.n]);
                o.ub = reshape(o.ub, [1, o.n]);
                o.center = reshape(o.center, [1, o.n]);
            end
        end
        
        function r = feasible(o, x)
            % r = o.feasible(x)
            % Output if x is feasible.
            
            r = all((x > o.lb) & (x < o.ub), o.vdim);
        end
        
        function t = step_size(o, x, v)
            % t = o.stepsize(x, v)
            % Output the maximum step size from x with direction v.
            
            max_step = 1e16; % largest step size
            if (o.vdim == 2)
               max_step = max_step * ones(size(x,1),1);
            end
            
            % check positive direction
            posIdx = v > 0;
            t1 = min((o.ub(posIdx) - x(posIdx))./v(posIdx), [], o.vdim);
            if isempty(t1), t1 = max_step; end
            
            % check negative direction
            negIdx = v < 0;
            t2 = min((o.lb(negIdx) - x(negIdx))./v(negIdx), [], o.vdim);
            if isempty(t2), t2 = max_step; end
            
            t = min(min(t1, t2), max_step);
        end
        
        function [A, b] = boundary(o, x)
            % [A, b] = o.boundary(x)
            % Output the normal at the boundary around x for each barrier.
            % Assume: only 1 vector is given
            
            assert(size(x, 3-o.vdim) == 1);
            
            c = o.center;
            
            b = o.ub;
            b(x<c) = -o.lb(x<c);
            
            A = ones(size(x));
            A(x<c) = -A(x<c);
            
            A = spdiag(A);
        end
        
        function grad = gradient(o, x)
            % g = o.gradient(x)
            % Output gradient phi(x).
            
            grad = 1./(o.ub-x) - 1./(x-o.lb);
        end
        
        function d = hessian(o, x)
            % g = o.hessian(x)
            % Output Hessian phi(x).
            
            d = 1./((x-o.lb).*(x-o.lb)) + 1./((o.ub-x).*(o.ub-x)) + o.extraHessian;
        end
        
        function t = tensor(o, x)
            % g = o.tensor(x)
            % Output the third derivative of phi(x).
            
            t = -2*(1./((x-o.lb).*(x-o.lb).*(x-o.lb)) - 1./((o.ub-x).*(o.ub-x).*(o.ub-x)));
        end
        
        function v = quadratic_form_gradient(o, x, u)
            % v = o.quadratic_form_gradient(x, u)
            % Output the -grad of u' (hess phi(x)) u.
            
            t = o.tensor(x);
            v = u.*u.*t;
        end
        
        function v = logdet_gradient(o, x)
            % v = o.logdet_gradient(x)
            % Output the gradient of log det (hess phi(x))
            % which is (hess phi(x))^-1 (grad hess phi (x))
            
            d = o.hessian(x);
            t = o.tensor(x);
            v = t./d;
        end
        
        function v = boundary_distance(o, x)
            % v = o.boundary_distance(x)
            % Output the distance of x with its closest boundary for each
            % coordinate
            
            v = abs(min(x-o.lb, o.ub-x));
        end
        
        function u = hessian_norm(o, x, d)
            % v = o.hessian_norm(x, d)
            % Output d_i (hess phi(x))_ii d_i for each i
            
            h = o.hessian(x);
            u = (d .* d) .* h;
        end
    end
end