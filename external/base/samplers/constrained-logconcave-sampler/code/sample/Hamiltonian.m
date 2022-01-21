classdef Hamiltonian < handle
    properties
        % data
        A
        b
        grad
        barrier
        
        % JL options
        JLsize % 0 = not using JL.
        
        % internal variables
        JLdir
        m
        n
        so
    end
    methods
        function obj = Hamiltonian(barrier, A, b, grad, JLsize)
            m = size(A,1); n = size(A,2);
            assert(all(size(b) == [m 1]));
            assert(barrier.n == n);
            
            if exist('JLsize', 'var') == 0, JLsize = 1; end
            if exist('grad', 'var') == 0 || isempty(grad), grad = zeros(n,1); end
            if ~isa(grad, 'function_handle'), grad = @(x) grad; end
            
            obj.A = A;
            obj.b = b;
            obj.grad = grad;
            obj.m = m;
            obj.n = n;
            obj.JLsize = JLsize;
            obj.barrier = barrier;
            obj.JLdir = [];
            obj.so = LinearSystemSolver(A);
            obj.GenerateJL();
        end
        
        % This function is not correct because it did not use f(x)
%         function e = H(o,z)
%             x = z(1:o.n);
%             v = z((1+o.n):end);
%             
%             bar = o.barrier; A = o.A;
%             
%             hessInv = bar.HessianInv(x);
%             o.so.Prepare(hessInv);
%             g_inv_v = hessInv * v;
%             IPv = g_inv_v - hessInv * (A' * o.so.Solve(A *g_inv_v));
%             e = 0.5 * v' * IPv;
%             o.so.UpdateR();
%             
%             e = e + sum(log(diag(o.so.R)));
%             H = bar.Hessian(x);
%             e = e + sum(log(diag(H))) * 0.5;
%         end
        
        function dz = f(o, z)
            assert(all(size(z) == [2*o.n 1]));
            x = z(1:o.n);
            v = z((1+o.n):end);
            
            bar = o.barrier; A = o.A;
            if (any(isnan(z)) || ~bar.Feasible(x))
                dz = 0;
                return;
            end
            
            hessInv = bar.HessianInv(x);
            o.so.Prepare(hessInv);
            g_inv_v = hessInv * v;
            
            z = (A*x-o.b) + A *g_inv_v;
            
            if (o.JLsize == 0)
                o.so.UpdateR();
            else
                z = [z A *(bar.SqrtHessianInv(x)*o.JLdir)];
            end
            
            y = hessInv * (A' * o.so.Solve(z));
                
            if (o.JLsize == 0)
                V = full((o.so.R'\(A * hessInv))');
            else
                %V = hessInv * (A' * o.so.Solve(A *(bar.SqrtHessianInv(x,o.JLdir))));
                V = y(:,2:end);
            end
            
            %dx = g_inv_v - hessInv * (A' * o.so.Solve(0*(A*x-o.b) + A *g_inv_v));
            dx = g_inv_v - y(:,1);
            
            sigma = bar.LogDetGradient(x) - bar.QuadraticFormGradient(x, V);
            dv = - o.grad(x) + 0.5 * bar.QuadraticFormGradient(x, dx) - 0.5 * sigma;
            dz = [dx; dv];
        end
        
        function t = StepSize(o, z, dz)
            assert(all(size(z) == [2*o.n 1]));
            x = z(1:o.n);
            dx = dz(1:o.n);
            t1 = o.barrier.StepSize(x, dx);
            t2 = 1 / max(sqrt(o.barrier.HessianNorm(x, dx)));
            t = min(t1,t2);
        end
        
        function z = Generate(o, x)
            assert(all(size(x) == [o.n 1]));
            %o.JLdir = sign(randn(o.n,o.JLsize)) ./ sqrt(o.JLsize);
            
            % random direction
            gv = o.barrier.SqrtHessian(x) * randn(o.n,1);
            %o.so.Prepare(speye(o.n));
            %v = gv - o.A'*o.so.Solve(o.A*gv);
            
            % Above random direction has the same effect as the following:
            v = gv;
            %v = zeros(size(v));
            z = [x;v];
        end
        
        function GenerateJL(o)
            o.JLdir = sign(randn(o.n,o.JLsize)) ./ sqrt(o.JLsize);
        end
    end
end