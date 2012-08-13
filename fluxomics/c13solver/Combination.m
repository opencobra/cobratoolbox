function [out] = Combination(n,k)
% produces the array of combinations possible picking k from n
% adapted from Combinadics
% http://msdn.microsoft.com/en-us/library/aa289166(VS.71).aspx

    if (n < 0 || k < 0) % normally n >= k
      disp('Negative parameter in constructor');
      return
    end
    
    data(k) = 0;
    for i = 1:k;
      data(i) = i;
    end
   % Combination(n,k)
    out.choose = getNumberCombinations(n,k);
   
   % determine the combinations
   for i = 1:out.choose
       out.all(:,i) = getCombination(n,k,i-1);
   end
return;

function [m] = getNumberCombinations(n,k)
   % find number of combinations by choose k items from n 
    if (n < k)
      m = 0;  % special case
    else
        if (n == k)
            m = 1;
        else
            m = factorial(n) / (factorial(k) * factorial(n-k)); 
        end
    end
    
return;

function [c] = getCombination(n,k,index)
    c(1) = 1;
    x = 1;
    for i = 1:n
        if (k == 0)
            return;
        end
    
        threshold = getNumberCombinations(n-i,k-1);
        %disp(sprintf('index = %d, threshold = %d',index,threshold));
        if (index < threshold)
            c(x) = i;
            x = x+1;
            k = k-1;
        else
            if (index >= threshold)
                index = index - threshold;
            end
        end
    end
return;

