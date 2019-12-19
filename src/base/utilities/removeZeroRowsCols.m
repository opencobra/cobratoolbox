function A = removeZeroRowsCols(A)
%removes all zero rows and columns from a matrix

% Remove zero rows
A( all(~A,2), : ) = [];
% Remove zero columns
A( :, all(~A,1) ) = [];

end

