function x = LinearSystemSolve(A, b, W)
% x = LinearSystemSolve(A, b, W)
% Solve the linear system A W A' x = b

    so = LinearSystemSolver(A);
    if nargin == 2
        W = spdiag(ones(size(A,2),1));
    end
    so.Prepare(W);
    x = so.Solve(b);
end