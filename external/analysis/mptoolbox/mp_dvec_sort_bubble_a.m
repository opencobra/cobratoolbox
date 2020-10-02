function [a_new,I] = dvec_sort_bubble_a( a )

%% DVEC_SORT_BUBBLE_A ascending sorts a real vector using bubble sort.
%
%  Discussion:
%
%    Bubble sort is simple to program, but inefficient.  It should not
%    be used for large arrays.
%
%  Modified:
%
%    24 February 2004
%
%  Author:
%
%    John Burkardt
%  
%  Modified by: CLV 20061111
%
%  Parameters:
%
%    Input,  A, an unsorted array.
%
%    Output:
%          A_NEW, the array now sorted.
%          I      index to the old rows of a (before sorting). 
%                  Thus, a_new=a(I,:) if a is a vector, or
%                        for i=1:size(a,2),a_new(:,i)=a(I(:,i),:);end
%
%         
%
n=size(a,1);
a_new = a;
I=repmat((1:n)',1,size(a,2));
for k=1:size(a,2)
    for i = 1 : (n-1)
        for j = (i+1) : n
            if ( a_new(j,k) < a_new(i,k) )
                t        = a_new(i,k); P = I(i,k);
                a_new(i,k) = a_new(j,k); I(i,k) = I(j,k);
                a_new(j,k) = t; I(j,k) = P;
            end
        end
    end
end
