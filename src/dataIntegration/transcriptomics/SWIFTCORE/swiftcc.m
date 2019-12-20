function consistent = swiftcc(S, rev, varargin)
% swiftcc is an even faster version of fastcc
%
% USAGE:
%
%    consistent = swiftcc(S, rev [, solver])
%
% INPUTS:
%    S:      the associated sparse stoichiometric matrix
%    rev:    the 0-1 vector with 1's corresponding to the reversible reactions
%
% OPTIONAL INPUT:
%    solver:    the LP solver to be used; the currently available options are
%               'gurobi', 'linprog', and 'cplex' with the default value of 
%               'linprog'. It fallbacks to the COBRA LP solver interface if 
%               another supported solver is called.
%
% OUTPUT:
%    consistent:    the 0-1 indicator vector of the reactions constituting 
%                   the maximum flux consistent metabolic subnetwork
%
% .. Authors:
%       - Mojtaba Tefagh, Stephen P. Boyd, 2019, Stanford University
    
    [m, n] = size(S);
    consistent = true(n, 1);
    
    %% setting up the LP solver
    if ~isempty(varargin)
        solver = varargin{1};
    else
        solver = 'linprog';
    end
    
    %% identifying the blocked irreversible reactions
    result = blocked(S, rev, solver);
    consistent(result.x(m+1:end) < -0.5) = false;
    
    %% setting up the zero-tolerance parameter
    tol = norm(S(:, consistent), 'fro')*eps(class(S));
    
    %% identifying the blocked reversible reactions
    [Q, R, ~] = qr(transpose(S(:, consistent)));
    Z = Q(rev(consistent) == 1, sum(abs(diag(R)) > tol)+1:end);
    
    %% finding the consistent reactions of the original metabolic network
    consistent(consistent & rev == 1) = diag(Z*Z.') > tol^2;
    consistent = find(consistent);
end