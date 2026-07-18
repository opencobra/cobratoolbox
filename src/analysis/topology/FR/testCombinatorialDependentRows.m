% Test combinatorialDependentRows on a small binary [F, R] matrix A, printing
% the two combinatorially dependent subsets of rows returned in x and y.

A=[1,0,1,1,0,0;
   0,1,0,0,1,0;
   0,1,1,0,0,1];

[x,y] = combinatorialDependentRows(A)
