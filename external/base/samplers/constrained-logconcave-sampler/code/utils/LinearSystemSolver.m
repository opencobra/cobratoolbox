classdef LinearSystemSolver < handle
    properties (Access = private)
        % the weight matrix
        W
        
        % the constraint matrix
        A
        
        % the cholesky decomposition of A W A'
        R
    end
    
    methods
        function o = LinearSystemSolver(A)
            o.R = NaN;
            o.A = A;
        end
        
        function Prepare(o, W)
            % prepare to the solver to solve AWA' x = b
            o.W = W;
            H = o.A * o.W * o.A';
            [o.R, p] = chol(H);
            if p ~= 0
                r = eps * (1 + sum(abs(H),1)');
                while 1
                    [o.R, p] = chol(H + spdiag(r));
                    if (p ~= 0)
                        r = r * 4 + eps;
                    else
                        break;
                    end
                end
            end
        end
        
        function R = getR(o)
            % update the cholesky decomposition of A W A'
            % The W is inputted by Prepare(o, W).
            R = o.R;
        end
        
        function x = Solve(o, b, x0)
            % x = Solve(o, b, x0)
            % Solve AWA' x =  b with the initial solution x0
            % The W is inputted by Prepare(o, W).
            if nargin == 2
                x = o.R \ (o.R' \ b);
            else
                r = b - o.A*(o.W*(o.A'*x0));
                x = x0 + o.R \ (o.R' \ r);
            end
            r = b - o.A*(o.W*(o.A'*x));
            x = x + o.R \ (o.R' \ r);
        end
    end
end