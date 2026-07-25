function A = removeZeroRowsCols(A)
% Removes all zero rows and columns from a matrix
%
% USAGE:
%
%    A = removeZeroRowsCols(A)
%
% INPUTS:
%    A:    m x n matrix
%
% OUTPUT:
%    A:    `A` with all zero rows removed, followed by all zero columns
%          removed

A( all(~A,2), : ) = [];
% Remove zero columns
A( :, all(~A,1) ) = [];

end

