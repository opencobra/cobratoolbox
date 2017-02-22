function result = computeMutualCoherence(A)
%     [M N] = size(A);
%     if (N<2)
%         disp('error - input contains only one column');
%         u=NaN;   beep;    return    
%     end
% 
%     % normalize the columns
%     nn = sqrt(sum(A.*conj(A),1));
%     if ~all(nn)
%         disp('error - input contains a zero column');
%         u=NaN;   beep;    return
%     end
%     nA = bsxfun(@rdivide,A,nn);  % nA is a matrix with normalized columns
%     result = max(max(triu(abs((nA')*nA),1)));
    
    X = A/(diag(sqrt(diag(A'*A))));
    mcoh = abs(X'*X);
    V = diag(mcoh);
    V = -diag(V,0);
    mcoh = mcoh+V;
    result = max(max(mcoh));
end