function[x] = solveLin(A,B)

s = warning('off', 'MATLAB:singularMatrix');
warning('off','MATLAB:nearlySingularMatrix');

t = (size(B,2) == 1);

Ao2 = logical(A)|logical(A');

black = false(size(B,1),1);
gray = (any(B,2) ~= 0);
while (sum(gray) > 0)
    black = black | gray;
    gray = any(Ao2(:,gray),2) & (~black);
end

A2 = A(black,black);
B2 = B(black,:);
if t % the case size(B) = 1
    x2 = A2\B2;
%     if(any(any(isnan(x2))))
%         x2 = pinv(full(A2))*B2;
%     end
%x2(isnan(x2)) = 0;
    x = zeros(size(B));
    x(black,:) = x2;
else    %the case of size(B) > 1
    x2 = A2\B2(:,2:end);
%     if(any(any(isnan(x2))))
%         x2 = pinv(full(A2))*B2(:,2:end);
%     end
    %x2(isnan(x2)) = 0;
    x = zeros(size(B));
    x(black,2:end) = x2;
    x(:,1) = 1-sum(x,2);
end



warning(s);