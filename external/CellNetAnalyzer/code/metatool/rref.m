function [A, k, tolerance] = rref (A, tolerance)
[rows,cols] = size (A);

if isempty(A) % to prevent errors with 0xi matrices
  tolerance= 0;
  k=[];
  return;
end

if (nargin < 2)
  tolerance = eps * max (rows, cols) * norm (A, inf);
end

used = zeros(1,cols);
r = 1;
for c=1:cols
  %# Find the pivot row
  [m, pivot] = max (abs (A (r:rows, c)));
  pivot = r + pivot - 1;
  
  if (m <= tolerance)
    %# Skip column c, making sure the approximately zero terms are
    %# actually zero.
    A (r:rows, c) = zeros (rows-r+1, 1);
    
  else
    %# keep track of bound variables
    used (1, c) = 1;
    
    %# Swap current row and pivot row
    A ([pivot, r], c:cols) = A ([r, pivot], c:cols);
    
    %# Normalize pivot row
    A (r, c:cols) = A (r, c:cols) / A (r, c);
    
    %# Eliminate the current column
    ridx = [1:r-1, r+1:rows];
    A (ridx, c:cols) = A (ridx, c:cols) - A (ridx, c) * A(r, c:cols);
    
    %# Check if done
    if (r == rows)
      break;
    end
    r= r + 1;
  end
end
k = find(used);
