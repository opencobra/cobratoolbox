function S = scaleSMatrix(S)
%scaleSMatrix Scale stoichimetric matrix to integers
%
% Sscaled = scaleSMatrix(S) 
%
%INPUT
% S         S matrix
%
%OUTPUT
% S         Scaled S matrix
%
% Markus Herrgard 6/2/06

% Round-off tolerance
tol = 1e-7;

numNonZero = 10;
pow = 0;
while (numNonZero > 0)
    numNonZero = sum(sum(abs(10^pow*S-round(10^pow*S)) > tol));
    fprintf('%d\t%d\n',pow,full(numNonZero));
    pow = pow + 1;
end

S = round(S*10^(pow-1));