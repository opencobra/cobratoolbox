function S = scaleSMatrix(S)
% Scales stoichimetric matrix to integers
%
% USAGE:
%
%    S = scaleSMatrix(S)
%
% INPUT:
%    S:    `S` matrix
%
% OUTPUT:
%    S:    Scaled `S` matrix
%
% .. Author: - Markus Herrgard 6/2/06

tol = 1e-7; % Round-off tolerance

numNonZero = 10;
pow = 0;
while (numNonZero > 0)
    numNonZero = sum(sum(abs(10^pow*S-round(10^pow*S)) > tol));
    fprintf('%d\t%d\n',pow,full(numNonZero));
    pow = pow + 1;
end

S = round(S*10^(pow-1));
