function [x, y] = combinatorialDependentRows(A)
% Find two combinatorially dependent subsets of rows of a binary [F, R] matrix
%
% Solves a binary feasibility problem (via CVX) for two nonempty, disjoint
% subsets of the rows of `A` that share the same column support; feasibility of
% the problem means the two subsets are combinatorially dependent.
%
% USAGE:
%
%    [x, y] = combinatorialDependentRows(A)
%
% INPUTS:
%    A:      binarized `[F R]` matrix with entries in {0, 1}; each row indexes
%            a (half-)reaction whose column support is compared
%
% OUTPUTS:
%    x:      `m x 1` binary indicator vector selecting the first subset of rows
%    y:      `m x 1` binary indicator vector selecting the second subset of rows
%

[m,n]=size(A);
% A is a binarized [F R] matrix (each entry of A is 0 or 1)
% if this program is feasible, then there exist 2 combinatorially dependent subsets of rows of A

%cvx_solver gurobi
cvx_solver mosek

cvx_begin sdp quiet

    variable x(m) binary;
    variable y(m) binary;

    % x,y are nonempty and disjoint subsets of rows of A
    x+y<=1;
    sum(x)>=1;
    sum(y)>=1;

    % trick to test for same support (idea: m > largest possible sum)
    m*x'*A>=y'*A;
    m*y'*A>=x'*A;

cvx_end

disp(find(x))
disp(find(y))

end
