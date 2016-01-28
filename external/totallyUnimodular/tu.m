function [tuValue, indices] = tu(A)

%% Created by Robert Hildebrand and Mark Junod
%  February 25, 2013

% tu(A) -- this function determines if A is totally unimodular
% output:  tu - boolean describing if matrix A is totally unimodular
%          indices   - indices of violating submatrix
% a submatrix is violating if it is non-integer, if it is not 0-1, or if 
%   it is a submatrix B with |det(B)| >= 2.

% This function uses the nested function increment_n_choose_k(v,n)

% This function runs over all submatrices using the increment_n_choose_k.m
% to increment the indices that are being looped over.  

tuValue = 1; %boolean describing if matrix A is totally unimodular
[r,c] = size(A);  
n = min(r,c); % the size of the larger submatrix that we need to test
indices = [];  %indices for rows, cols with largest sub-determinant, initialize as empty


%% First check if the matrix is integer
  %test if the matrix is integer using floor function because this is
  %supposed to be a faster way to do this
  %if the matrix is not integer, then we use a mod method to find a
  %non-integer entry and return that as the indices.
integerTest = min(A == floor(A));
if ~integerTest
    tuValue = 0;
    [a,b] = find(mod(A, 1) ~= 0);
    indices = [a;b];
    disp('Must input an integer matrix!');
    return
end


subDet =  max(abs(A(:)));     %max subdeterminant, initialize as sup-norm

%% Second, check if the size of the entries (1x1 determinants) are in 0,1,-1

if ~(subDet <= 1)
    tuValue = 0;
    disp('Entries are not all 0, 1, -1!');
     [a,b] = find(abs(A) == subDet);
    indices = [a;b];
    return
end

%% Start testing all subdeterminants
 
%% for loops over all sizes of submatrices, except k=1, since this is handled by the sup-norm
for k = 2:n    % k is the size of submatrix being checked
    rowidx = 1:k;  %initialize rowidx as the first k rows
    
    %% while loops over all choices a row indices of size k, incremented by the increment_n_choose_k function
    while ~isempty(rowidx)
        colidx = 1:k;  %initialize colidx as the first k cols
        %% while loops over all choices a row indices of size k, incremented by the increment_n_choose_k function
        while ~isempty(colidx)
            B = A(rowidx,colidx);   %submatrix of A to test
			if  abs(det(B)) >= 2 
                tuValue = 0;
                indices = [rowidx;colidx];  %Store indices of violating submatrix
                return
            end
            colidx = increment_n_choose_k(colidx, c);
        end
        rowidx = increment_n_choose_k(rowidx,r);
    end
end

%% Nested Function			
    function v = increment_n_choose_k(v,n)
    %  This function increments the index vectors through all possible n
    %  choose k possiblities.  By doing this index update, you don't have
    %  to store all n choose k possibilities, which saves space and time
    %  when iterating through all squar submatrices.  
    
        m = length(v);  
        if v(end) == n
            %first find the last gap between consecutive entries
            x = (n-m+1:n) - v;
            I = find(x,1,'last');
            %if I is empty, then we're on the k'th iteration
            if isempty(I)
                v = [];
            end
            %This next step is updates the vector approiately.
            v(I:end) = (1:m-I+1) + v(I);
        else
            v(end) = v(end) + 1;
        end

    end %end the nested function

end  %end the main function

