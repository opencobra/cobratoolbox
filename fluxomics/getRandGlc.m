function [xGlc] = ...
    getRandGlc()

%
% Wing Choi 1/20/08

% generate random glucose in isotopomer format

%if(length(glucose) ~= 8)
%    warn('bad input');
%end
%glucose(9) = 1-sum(glucose);
%if(any(glucose < 0))
%    warn('bad input');
%end

glucose = rand(8,1);
glucose = glucose/sum(glucose);

% glc 1-6 = carbon 1-6
% glc 7 = carbon 1+2 (really 5 and 6)
% glc 8 = unlabeled
% glc 9 = fully labeled
glc = zeros(64,9);
glc(1+1,1) = 1;
glc(2+1,2) = 1;
glc(4+1,3) = 1;
glc(8+1,4) = 1;
glc(16+1,5) = 1;
glc(32+1,6) = 1;
glc(32+16+1,7) = 1;
glc(0+1,8) = 1;
glc(63+1,9) = 1;


xGlc = zeros(64,1);
for i = 1:8
    xGlc = xGlc + glucose(i)*glc(:,i);
end

%xGlc = idv2cdv(6)*xGlc;


return
end