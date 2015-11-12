function [x,y] = combinatorialDependentRows(A)

% A is a binarized [F R] matrix (each entry of A is 0 or 1)
[m,n]=size(A);

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

