function [x,LUA,b,P]=mp_gausscpp(A,b)
%function [x,LUA,b,P]=gausscpp(A,b)
%gaussian elimination with partial pivoting. Gives back the LU decomposition of 
%matrix A, jointly with the permutation required and the RHS before the backward substitution

%perform forward gaussian elimination
[LUA,b,P]=mp_gausscppSolve1(A,b);
%perform backward substitution
x=mp_gausscppSolve2(LUA,b);